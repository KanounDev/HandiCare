import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationPage extends StatefulWidget {
  const ConversationPage({super.key});

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _controller = TextEditingController();
  String? userEmail; // L'email du parent connecté

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  // Récupérer l'email du parent depuis SharedPreferences
  Future<void> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail');
    });
  }

  // Générer l'ID de la conversation en fonction de l'email du parent
  String _generateConversationId(String parentEmail) {
    return parentEmail; // Un parent a une seule conversation partagée avec les responsables.
  }

  // Ajouter un message à la conversation
  Future<void> _sendMessage(String message) async {
    if (userEmail != null && message.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('conversations')
          .doc(_generateConversationId(userEmail!))
          .collection('messages')
          .add({
        'sender': userEmail, // L'email du parent qui envoie le message
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie avec l’Association'),
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Afficher les messages en temps réel
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: userEmail == null
                    ? null
                    : FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(_generateConversationId(userEmail!))
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      var isSender = message['sender'] == userEmail; // Vérifier si le message est envoyé par le parent

                      return Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSender ? Color.fromARGB(255, 139, 222, 161) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            message['message'],
                            style: const TextStyle(color: Colors.black),
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
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
