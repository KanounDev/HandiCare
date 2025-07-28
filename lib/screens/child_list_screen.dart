import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildListScreen extends StatefulWidget {
  const ChildListScreen({super.key});

  @override
  _ChildListScreenState createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  String? userEmail;
  List<Map<String, dynamic>> children = [];
  List<Map<String, dynamic>> filteredChildren = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    _searchController.addListener(_filterChildren);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Récupérer l'email du parent depuis SharedPreferences
  Future<void> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail');
    });
    if (userEmail != null) {
      _fetchChildren(userEmail!);
    }
  }

  // Récupérer la liste des enfants du parent depuis Firestore
  Future<void> _fetchChildren(String parentEmail) async {
    FirebaseFirestore.instance
        .collection('enfants')
        .where('parentEmail', isEqualTo: parentEmail)
        .get()
        .then((querySnapshot) {
      setState(() {
        children = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': '${doc['nom']} ${doc['prenom']} ',
            'age': doc['age'].toString(),
            'diagnostic': doc['diagnostic'] ?? 'Non renseigné',
          };
        }).toList();
        filteredChildren = children;
      });
    });
  }

  // Fonction de filtrage des enfants
  void _filterChildren() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredChildren = children
          .where((child) =>
              child['name'].toLowerCase().contains(query) ||
              child['age'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Enfants'),
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Liste des enfants
            Expanded(
              child: filteredChildren.isEmpty
                  ? const Center(child: Text("Aucun enfant trouvé."))
                  : ListView.builder(
                      itemCount: filteredChildren.length,
                      itemBuilder: (context, index) {
                        final child = filteredChildren[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: const Color.fromARGB(255, 139, 222, 161),
                              child: Text(child['name'][0], style: const TextStyle(color: Colors.black87)),
                            ),
                            title: Text(
                              child['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Âge: ${child['age']}, Diagnostic: ${child['diagnostic']}'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildInfoScreen(child: child),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildInfoScreen extends StatefulWidget {
  final Map<String, dynamic> child;

  const ChildInfoScreen({required this.child, super.key});

  @override
  _ChildInfoScreenState createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    _fetchActivities(widget.child['id']);
  }

  // Récupérer les activités de l'enfant depuis Firestore
  Future<void> _fetchActivities(String childId) async {
    FirebaseFirestore.instance
        .collection('activites')
        .where('enfantId', isEqualTo: childId)
        .get()
        .then((querySnapshot) {
      setState(() {
        activities = querySnapshot.docs.map((doc) {
          return {
            'libelle': doc['libelle'], // Nom de l'activité
            'progress': doc['progress'], // Progression de l'activité
          };
        }).toList();
      });
    }).catchError((error) {
      print("Erreur lors de la récupération des activités: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informations sur ${widget.child['name']}'),
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom et Prénom : ${widget.child['name']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Âge: ${widget.child['age']}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Diagnostic: ${widget.child['diagnostic']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text('Activités de l\'enfant:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            activities.isEmpty
                ? const Text('Aucune activité trouvée.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      double progress = activity['progress'].toDouble();
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(activity['libelle']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height:10),
                              Text('Progression: ${progress.toInt()}%', style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: Colors.grey[200],
                                color: progress.toInt() > 80 ? Colors.green : (progress.toInt() <= 80  && progress.toInt() >= 50 ? Colors.orange : Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
