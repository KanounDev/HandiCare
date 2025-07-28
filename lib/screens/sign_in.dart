import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>(); 
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _role = 'parent'; // Par défaut, le rôle est 'parent'

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black87),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  /// 📌 **Connexion Firebase + Firestore + Sauvegarde SharedPreferences**
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // 🔐 Connexion avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔍 Vérification dans Firestore
      String collectionName = _role == 'responsable' ? 'responsable' : 'parent';
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // ✅ Sauvegarde des infos dans SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
        await prefs.setString('userRole', _role);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion réussie en tant que ${_role == 'responsable' ? 'Responsable' : 'Parent'}')),
        );

        // 🔀 Redirection vers l'interface correspondante
        Navigator.pushReplacementNamed(context, _role == 'responsable' ? '/home' : '/parentHome');
      } else {
        // ❌ Compte introuvable dans Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Compte introuvable dans la base de données des ${_role == 'responsable' ? 'responsables' : 'parents'}")),
        );
        await FirebaseAuth.instance.signOut(); // Déconnexion automatique
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion : ${e.toString()}")),
      );
    }
  }

  /// 📌 **Récupérer l'email et le rôle enregistrés**
  Future<Map<String, String?>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('userEmail'),
      'role': prefs.getString('userRole'),
    };
  }

  /// 📌 **Déconnexion et suppression des données stockées**

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Se connecter'),
        backgroundColor: Color.fromARGB(255, 139, 222, 161),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.login,
                size: 80,
                color: Color.fromARGB(255, 139, 222, 161),
              ),
              SizedBox(height: 20),
              Text(
                'Se connecter en tant que:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text('Parent'),
                    selected: _role == 'parent',
                    onSelected: (selected) => setState(() => _role = 'parent'),
                    selectedColor: Color.fromARGB(255, 139, 222, 161),
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    label: Text('Responsable'),
                    selected: _role == 'responsable',
                    onSelected: (selected) => setState(() => _role = 'responsable'),
                    selectedColor: Color.fromARGB(255, 139, 222, 161),
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email', Icons.email),
                validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Veuillez entrer un email valide' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration('Mot de passe', Icons.lock),
                validator: (value) => (value == null || value.isEmpty || value.length < 6) ? 'Le mot de passe doit contenir au moins 6 caractères' : null,
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: _signIn,
                child: Text('Se connecter', style: TextStyle(color: Colors.black87, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Color.fromARGB(255, 139, 222, 161),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
