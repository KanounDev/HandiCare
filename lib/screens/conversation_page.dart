import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationPage extends StatefulWidget {
  final String person;
  final String email;

  const ConversationPage(
      {super.key, required this.person, required this.email});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _controller = TextEditingController();
  String?
      userEmail; // L'email du responsable qui sera récupéré depuis SharedPreferences.

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  // Récupérer l'email du responsable depuis SharedPreferences
  Future<void> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail');
    });
  }

  // Ajouter un message à la collection Firestore
  Future<void> _sendMessage(String message) async {
    if (userEmail != null) {
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(_generateConversationId(
              widget.email)) // Utilisation de l'email du parent comme ID
          .collection('messages')
          .add({
        'sender': userEmail, // L'email du responsable qui envoie le message
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Générer un identifiant unique pour la conversation basé sur les deux emails
  String _generateConversationId(String parentEmail) {
    return parentEmail; // L'ID de la conversation est simplement l'email du parent.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person),
        backgroundColor: Color.fromARGB(255, 139, 222, 161),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Afficher les messages en temps réel
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(_generateConversationId(widget
                        .email)) // Utilisation uniquement de l'email du parent
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      var isSender = message['sender'] ==
                          userEmail; // Vérifie si c'est l'utilisateur qui a envoyé le message
                      return Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSender
                                ? Color.fromARGB(255, 139, 222, 161)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message['message'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(8),
                    ),
                    maxLines: 3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Envoyer le message lorsque l'utilisateur appuie sur le bouton "Envoyer"
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller
                          .clear(); // Réinitialiser le champ de texte après l'envoi
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
