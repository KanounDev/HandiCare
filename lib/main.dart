import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sign_up_in.dart';
import 'screens/sign_up.dart';
import 'screens/sign_in.dart';
import 'screens/parent_home_screen.dart';
import 'screens/create_account.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Suivi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(), // Gère la redirection selon l'état de connexion
      routes: {
        '/signUp': (context) => SignUpPage(),
        '/signIn': (context) => SignInPage(),
        '/parentHome':(context) => ParentHomeScreen(),
        '/home': (context) => HomeScreen(),
        '/createAccount': (context) => CreateAccountScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Affichage en attendant la vérification
        }
        if (snapshot.hasData) {
          return HomeScreen(); // L'utilisateur est déjà connecté, on le redirige vers Home
        }
        return SignUpInPage(); // L'utilisateur n'est pas connecté, on le redirige vers la page d'authentification
      },
    );
  }
}
