import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'conversation_page.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  List<Map<String, dynamic>> parents = [];
  List<Map<String, dynamic>> filteredParents = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadParents();
    _searchController.addListener(_filterParents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParents() async {
    try {
      var snapshot =
          await FirebaseFirestore.instance.collection('parent').get();
      List<Map<String, dynamic>> parentsList = snapshot.docs.map((doc) {
        return {
          'name':
              '${doc['nom'] ?? ''} ${doc['prenom'] ?? ''}', // Assurez-vous que ces clés existent dans Firestore
          'email': doc['email'] ?? '', // Vérifier si l'email est présent
        };
      }).toList();

      setState(() {
        parents = parentsList;
        filteredParents = parentsList;
      });
    } catch (e) {
      print('Erreur lors du chargement des parents: $e');
    }
  }

  void _filterParents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredParents = parents
          .where((parent) => parent['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 139, 222, 161),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un parent...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: parents.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun parent trouvé.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredParents.length,
                      itemBuilder: (context, index) {
                        final person = filteredParents[index];
                        return _buildConversationTile(context, person);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(
      BuildContext context, Map<String, dynamic> person) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('conversations')
          .doc(person[
              'email']) // Utiliser l'email du parent pour identifier la conversation
          .collection('messages')
          .orderBy('timestamp',
              descending: true) // Trier par timestamp décroissant
          .limit(1) // Limiter à un seul message
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Si aucune donnée n'est présente ou la collection est vide
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              title: Text(
                person['name'] ??
                    'Nom non disponible', // Afficher un message par défaut si le nom est vide
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: const Text(
                'Aucun message', // Si aucun message, afficher "Aucun message"
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.info, color: Colors.blue),
                    onPressed: () => _showInfoDialog(context, person),
                  ),
                  const Icon(Icons.message,
                      color: Color.fromARGB(255, 2, 13, 5)),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationPage(
                      person: person['name'] ?? 'Nom non disponible',
                      email: person['email'] ?? 'Email non disponible',
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Si nous avons des messages, récupérer le dernier
        var message =
            snapshot.data!.docs.first; // Le dernier message (premier après tri)
        var lastMessage = message['message'] ??
            'Aucun message'; // Récupérer le texte du dernier message

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            title: Text(
              person['name'] ??
                  'Nom non disponible', // Afficher un message par défaut si le nom est vide
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              lastMessage, // Afficher le dernier message
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.blue),
                  onPressed: () => _showInfoDialog(context, person),
                ),
                const Icon(Icons.message, color: Color.fromARGB(255, 2, 13, 5)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationPage(
                    person: person['name'] ?? 'Nom non disponible',
                    email: person['email'] ?? 'Email non disponible',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informations sur ${person['name']}'),
          content: Text(
            '${person['name']}\nEmail: ${person['email']}\nRelation: Parent',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Fermer', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 139, 222, 161),
              ),
            ),
          ],
        );
      },
    );
  }
}
