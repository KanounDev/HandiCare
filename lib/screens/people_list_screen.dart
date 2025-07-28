import 'package:flutter/material.dart';
import 'person_details_screen.dart';
import 'add_child.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({super.key});

  @override
  _PeopleListScreenState createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  List<Map<String, String>> children = [];
  List<Map<String, String>> filteredChildren = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadChildren();
    _searchController.addListener(_filterChildren);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Charger la liste des enfants depuis Firestore
  Future<void> _loadChildren() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('enfants').get();
      print("Nombre de documents récupérés: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        print("Aucun enfant trouvé");
      }

      List<Map<String, String>> childrenList = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // 🔥 Correction : ajout de l'ID Firestore
          'name': '${doc['nom']} ${doc['prenom']}',
          'age': '${doc['age']}',
          'diagnostic': '${doc['diagnostic']}',
        };
      }).toList();

      setState(() {
        children = childrenList;
        filteredChildren = childrenList;
      });
    } catch (e) {
      print('Erreur lors du chargement des enfants: $e');
    }
  }

  // Filtrer les enfants en fonction de la recherche
  void _filterChildren() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredChildren = children
          .where((child) => child['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  

  // Supprimer un enfant de Firestore et recharger la liste
  Future<void> _deleteChild(int index) async {
    try {
      String? childId = filteredChildren[index]['id'];
      String? childName = filteredChildren[index]['name'];

      // Supprimer de Firestore
      await FirebaseFirestore.instance
          .collection('enfants')
          .doc(childId)
          .delete();


      // Recharger la liste après suppression
      await _loadChildren();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enfant supprimé avec succès'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Erreur lors de la suppression : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la suppression"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Enfants'),
        backgroundColor: Color.fromARGB(255, 139, 222, 161),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadChildren();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un enfant...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Afficher un message si aucun enfant n'est trouvé
            Expanded(
              child: filteredChildren.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredChildren.length,
                      itemBuilder: (context, index) {
                        final child = filteredChildren[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: ListTile(
                            title: Text(child['name'] ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Âge: ${child['age']} - Diagnostic: ${child['diagnostic']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteChild(index);
                                  },
                                ),
                                const Icon(Icons.arrow_forward),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PersonDetailsScreen(
                                    personName: child['name'] ?? '',
                                    personAge: child['age'] ?? '',
                                    personDiagnostic: child['diagnostic'] ?? '',
                                    enfantId: child['id'] ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "Aucun enfant disponible.",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
            // Bouton pour ajouter un enfant
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddChildPage(),
                  ));
                },
                child: const Text('Ajouter un Enfant',
                    style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 139, 222, 161),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
