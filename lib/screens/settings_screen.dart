import 'package:flutter/material.dart';
import 'help.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manage_accounts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail');
    });
  }

 // Ajouter cette fonction dans _SettingsScreenState
Future<void> _changePassword(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Changer le mot de passe"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Entrez le nouveau mot de passe'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le dialogue
            },
            child: const Text("Annuler",style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isNotEmpty) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.updatePassword(passwordController.text); // Met à jour le mot de passe
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mot de passe mis à jour")),
                  );
                  Navigator.pop(context); // Ferme le dialogue
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur : $e")),
                  );
                }
              }
            },
            child: const Text("Sauvegarder" ,style: TextStyle(color: Colors.black),
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


  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Déconnexion réussie")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de la déconnexion : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Changer le mot de passe'),
              leading: const Icon(Icons.lock),
              onTap: () => _changePassword(context),
            ),
            ListTile(
              title: const Text('Aide et Guide'),
              leading: const Icon(Icons.help_outline),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                );
              },
            ),
            const Divider(),
            if (userEmail == "admin@utaim.tn") ...[
              ListTile(
                title: const Text('Créer un compte responsable'),
                leading: const Icon(Icons.person_add, color: Colors.green),
                textColor: Colors.green,
                onTap: () {
                  Navigator.of(context).pushNamed('/createAccount');
                },
              ),
              ListTile(
                title: const Text('Gérer les comptes des responsables'),
                leading: const Icon(Icons.settings_applications, color: Colors.blue),
                textColor: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ManageAccountsScreen(),
                  ));
                },
              ),
              const Divider(),
            ],
            ListTile(
              title: const Text('Se Déconnecter'),
              leading: const Icon(Icons.logout, color: Colors.red),
              textColor: Colors.red,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
