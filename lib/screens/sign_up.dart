import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.black87),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Création de l'utilisateur avec Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Ajout des données du parent dans Firestore
      await FirebaseFirestore.instance
          .collection('parent')
          .doc(userCredential.user!.uid)
          .set({
        'email': _emailController.text.trim(),
        'nom': _nameController.text.split(' ').first,
        'prenom': _nameController.text.split(' ').skip(1).join(' '),
      });

      // Stocker les informations dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', 'parent');
      await prefs.setString('userEmail', _emailController.text.trim());

      // Rediriger vers la page d'accueil après inscription réussie
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = 'Erreur inconnue';

      if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé';
      } else if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible';
      } else if (e.code == 'invalid-email') {
        message = 'Format d\'email invalide';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: const Color.fromARGB(255, 139, 222, 161),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.person_add,
                size: 80,
                color: Color.fromARGB(255, 139, 222, 161),
              ),
              const SizedBox(height: 20),
              const Text(
                'Créer un compte',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nom et Prénom', Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom et prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email', Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration('Mot de passe', Icons.lock),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'S\'inscrire',
                        style: TextStyle(color: Colors.black87, fontSize: 18),
                      ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color.fromARGB(255, 139, 222, 161),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
