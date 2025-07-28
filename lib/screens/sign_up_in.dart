import 'package:flutter/material.dart';

class SignUpInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bienvenue ! Veuillez choisir une option pour continuer.',
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 300, // Prend toute la largeur disponible
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the SignInPage
                  Navigator.pushNamed(context, '/signIn');
                },
                child: Text(
                  'Se connecter',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Color.fromARGB(255, 205, 220, 250),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300, // Prend toute la largeur disponible
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the SignUpPage
                  Navigator.pushNamed(context, '/signUp');
                },
                child: Text(
                  'Créer un compte',
                  style: TextStyle(color: Colors.black87),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Color.fromARGB(255, 173, 236, 190),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
