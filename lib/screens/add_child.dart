import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddChildPage extends StatefulWidget {
  @override
  _AddChildPageState createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  // Contrôleurs pour les champs du formulaire
  TextEditingController _childNameController = TextEditingController();
  TextEditingController _childAgeController = TextEditingController();
  TextEditingController _childDiagnosisController = TextEditingController();
  TextEditingController _parentEmailController = TextEditingController();

  // Référence à Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour ajouter un enfant dans Firestore
  Future<void> _addChild(
      String name, String age, String diagnosis, String parentEmail) async {
    try {
      DocumentReference childRef = _firestore.collection('enfants').doc();
      await childRef.set({
        'id': childRef.id, // 🔥 Ajout de l'ID unique
        'nom': name.split(' ').first,
        'prenom': name.split(' ').skip(1).join(' '),
        'age': int.parse(age),
        'diagnostic': diagnosis,
        'parentEmail': parentEmail, // 🔥 Même si l'email du parent n'existe pas
        'dateAjout': Timestamp.now(),
      });

      print('Enfant ajouté avec succès');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enfant ajouté avec succès')),
      );
      Navigator.of(context).pop(); // Retour à la page précédente
    } catch (e) {
      print("Erreur lors de l'ajout de l'enfant : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'ajout de l'enfant")),
      );
    }
  }

  // Affichage d'un dialogue d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Enfant'),
        backgroundColor: Color.fromARGB(255, 139, 222, 161),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _childNameController,
              decoration: const InputDecoration(labelText: 'Nom de l\'enfant'),
            ),
            TextField(
              controller: _childAgeController,
              decoration: const InputDecoration(labelText: 'Âge de l\'enfant'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _childDiagnosisController,
              decoration: const InputDecoration(labelText: 'Diagnostic'),
            ),
            TextField(
              controller: _parentEmailController,
              decoration: const InputDecoration(labelText: 'Email du parent'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_childNameController.text.isEmpty ||
                    _childAgeController.text.isEmpty ||
                    _childDiagnosisController.text.isEmpty ||
                    _parentEmailController.text.isEmpty) {
                  _showErrorDialog(
                      'Tous les champs sont obligatoires pour ajouter un enfant.');
                  return;
                }
                _addChild(
                  _childNameController.text,
                  _childAgeController.text,
                  _childDiagnosisController.text,
                  _parentEmailController.text,
                );
              },
              child: const Text(
                'Ajouter Enfant',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 139, 222, 161),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
