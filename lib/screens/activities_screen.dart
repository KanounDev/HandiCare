import 'package:flutter/material.dart';
import 'add_activity_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Bienvenue dans la section Activités !',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddActivityScreen(),
                  ),
                );
            },
            child: const Text('Commencer une activité'),
          ),
        ],
      ),
    );
  }
}
