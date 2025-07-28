import 'package:flutter/material.dart';
import 'child_list_screen.dart';  // For the list of children
import 'conversation_page_parent.dart';   // For messaging with responsible
import 'settings_screen.dart';    // For changing password and logging out
import 'welcome_screen.dart';     // Optionally a home page screen

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _selectedIndex = 2;

  static const List<Widget> _screens = <Widget>[
    ChildListScreen(),       // Page showing the list of children
    ConversationPage(),       // Page for messaging with responsible
    WelcomeScreen(),         // Home page (or info page)
    SettingsScreen(),        // Page for changing password and logging out
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Mes Enfants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messagerie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 139, 222, 161),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
