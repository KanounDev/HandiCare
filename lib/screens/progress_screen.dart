import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progrès'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Suivi de votre progrès',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Nombre d\'activités terminées: 5'),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: 0.5),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logique de navigation pour voir les détails
              },
              child: const Text('Voir les détails du progrès'),
            ),
          ],
        ),
      ),
    );
  }
}
