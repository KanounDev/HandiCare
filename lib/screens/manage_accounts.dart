import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({Key? key}) : super(key: key);

  @override
  _ManageAccountsScreenState createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour supprimer un responsable
  Future<void> _deleteResponsible(String email) async {
    try {
      // Chercher l'ID du document en utilisant l'email
      QuerySnapshot querySnapshot = await _firestore
          .collection('responsable')
          .where('email', isEqualTo: email)
          .get();

      // Si un document est trouvé, on le supprime
      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id; // L'ID du document trouvé
        await _firestore.collection('responsable').doc(docId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Responsable $email supprimé")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Aucun responsable trouvé avec cet email")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les comptes des responsables'),
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('responsable')
            .snapshots(), // La collection est 'responsable'
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun responsable trouvé.'));
          }

          final responsables = snapshot.data!.docs;

          // Filtrer pour ne pas afficher l'admin
          final filteredResponsables = responsables.where((responsable) {
            return responsable['email'] != 'admin@utaim.tn';
          }).toList();

          return ListView.builder(
            itemCount: filteredResponsables.length,
            itemBuilder: (context, index) {
              var responsable = filteredResponsables[index];
              var email = responsable['email'];
              var nom = responsable['nom'];
              var prenom = responsable['prenom'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  title: Text(
                    '$prenom $nom', // Affiche le prénom et le nom du responsable
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(email ?? 'Email non disponible'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Confirmation avant suppression
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Confirmation"),
                            content: Text(
                                "Êtes-vous sûr de vouloir supprimer $prenom $nom ?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Ferme le dialogue
                                },
                                child: const Text("Annuler"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteResponsible(
                                      email); // Supprime le responsable
                                  Navigator.pop(context); // Ferme le dialogue
                                },
                                child: const Text("Supprimer"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
