import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  // Récupérer le rôle de l'utilisateur depuis SharedPreferences
  Future<void> _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et Guide d’Utilisation'),
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: userRole == 'parent' ? _parentHelp() : _responsableHelp(),
      ),
    );
  }

  // 🔹 **Aide pour les Parents**
  Widget _parentHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('📌 Bienvenue, Parent !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text('Cette application vous permet de suivre le parcours et l’évolution de votre enfant au sein de l’association.', 
          style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),

        Text('🟢 **1. Accéder à la liste de vos enfants**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Consultez les informations de vos enfants (âge, diagnostic, progrès, etc.).'),
        Text('  • Vous pouvez rechercher un enfant en tapant son nom dans la barre de recherche.'),

        SizedBox(height: 15),
        Text('💬 **2. Communiquer avec les responsables**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Utilisez la messagerie pour discuter avec les responsables et poser des questions.'),
        Text('  • Vous pouvez envoyer et recevoir des messages en temps réel.'),

        SizedBox(height: 15),
        Text('📊 **3. Suivre le diagnostic et l’évolution de votre enfant**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Consultez les évaluations et rapports mis à jour par l’équipe de l’association.'),
        Text('  • Vérifiez les progrès de votre enfant et discutez avec les responsables en cas de besoin.'),

        SizedBox(height: 15),
        Text('⚙️ **4. Gérer votre compte**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Vous pouvez modifier vos informations personnelles et votre mot de passe dans les paramètres.'),
      ],
    );
  }

  // 🔹 **Aide pour les Responsables**
  Widget _responsableHelp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('📌 Bienvenue, Responsable !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text('Cette application vous permet de gérer et suivre les enfants de l’association, et de communiquer avec leurs parents.', 
          style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),

        Text('🟢 **1. Accéder à la liste des enfants**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Consultez la liste des enfants sous votre responsabilité.'),
        Text('  • Recherchez un enfant en tapant son nom dans la barre de recherche.'),

        SizedBox(height: 15),
        Text('💬 **2. Communiquer avec les parents**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Répondez aux questions des parents et tenez-les informés des progrès de leurs enfants.'),
        Text('  • Assurez une communication claire et bienveillante.'),

        SizedBox(height: 15),
        Text('📝 **3. Ajouter et mettre à jour les diagnostics**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Remplissez les évaluations et diagnostics pour suivre l’évolution des enfants.'),
        Text('  • Partagez les informations avec les parents pour les aider à mieux comprendre les besoins de leurs enfants.'),

        SizedBox(height: 15),
        Text('⚙️ **4. Gérer votre compte**', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('  • Vous pouvez modifier vos informations personnelles et votre mot de passe dans les paramètres.'),
      ],
    );
  }
}
