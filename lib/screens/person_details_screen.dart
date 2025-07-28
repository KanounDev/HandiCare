import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonDetailsScreen extends StatefulWidget {
  final String personName;
  final String enfantId;
  final String personAge;
  final String personDiagnostic;
  const PersonDetailsScreen(
      {super.key,
      required this.personName,
      required this.personAge,
      required this.personDiagnostic,
      required this.enfantId});

  @override
  _PersonDetailsScreenState createState() => _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends State<PersonDetailsScreen> {
  String personName = '';
  String age = '';
  String diagnosis = '';
  String enfantId = '';

  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    personName = widget.personName;
    age = widget.personAge;
    diagnosis = widget.personDiagnostic;
    enfantId = widget.enfantId;
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('activites')
        .where('enfantId', isEqualTo: widget.enfantId)
        .get();

    setState(() {
      activities = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> _showEditDetailsDialog() async {
    final nameController = TextEditingController(text: personName);
    final ageController = TextEditingController(text: age);
    final diagnosisController = TextEditingController(text: diagnosis);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier les Détails'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: 'Âge'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: diagnosisController,
                    decoration: const InputDecoration(labelText: 'Diagnostic'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Vérification des champs non vides
                if (nameController.text.isNotEmpty &&
                    ageController.text.isNotEmpty &&
                    diagnosisController.text.isNotEmpty) {
                  try {
                    // Mise à jour dans Firestore
                    await FirebaseFirestore.instance
                        .collection('enfants')
                        .doc(enfantId)
                        .update({
                      'nom': nameController.text.split(' ').first,
                      'prenom':
                          nameController.text.split(' ').skip(1).join(' '),
                      'age': int.parse(ageController.text),
                      'diagnostic': diagnosisController.text,
                    });

                    // Mise à jour des variables locales avec setState pour rafraîchir l'UI
                    setState(() {
                      personName = nameController.text;
                      age = ageController.text;
                      diagnosis = diagnosisController.text;
                    });

                    // Fermer la boîte de dialogue
                    Navigator.pop(context);
                  } catch (e) {
                    print("Erreur lors de la mise à jour des détails : $e");
                    // Affichage d'un message d'erreur si la mise à jour échoue
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur de mise à jour')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tous les champs doivent être remplis.')),
                  );
                }
              },
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 139, 222, 161),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddActivityDialog() async {
    final titleController = TextEditingController();
    final progressController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une Activité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre')),
              TextField(
                  controller: progressController,
                  decoration: const InputDecoration(labelText: 'Progrès (%)'),
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.black),
                )),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    progressController.text.isNotEmpty) {
                  final activity = {
                    'libelle': titleController.text,
                    'progress': int.parse(progressController.text),
                    'enfantId': enfantId,
                  };
                  print(enfantId);
                  await FirebaseFirestore.instance
                      .collection('activites')
                      .add(activity);
                  _fetchActivities();
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditActivityDialog(int index) async {
    final activity = activities[index];
    final titleController = TextEditingController(text: activity['libelle']);
    final progressController =
        TextEditingController(text: activity['progress'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier l\'Activité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre')),
              TextField(
                  controller: progressController,
                  decoration: const InputDecoration(labelText: 'Progrès (%)'),
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.black),
                )),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    progressController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('activites')
                      .doc(activity['id'])
                      .update({
                    'libelle': titleController.text,
                    'progress': int.parse(progressController.text),
                  });
                  _fetchActivities();
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 139, 222, 161),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteActivity(int index) async {
    final activity = activities[index];
    await FirebaseFirestore.instance
        .collection('activites')
        .doc(activity['id'])
        .delete();
    _fetchActivities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de $personName',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Color.fromARGB(255, 139, 222, 161),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit), onPressed: _showEditDetailsDialog)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Nom : $personName\nÂge : $age\nDiagnostic : $diagnosis',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Activités associées',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: activities.isEmpty
                  ? const Center(child: Text('Aucune activité trouvée'))
                  : ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return Card(
                          child: ListTile(
                            title: Text(activity['libelle']),
                            subtitle: Text('Progrès: ${activity['progress']}%'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showEditActivityDialog(index)),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteActivity(index)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showAddActivityDialog,
                child: const Text('Ajouter une Activité',
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
