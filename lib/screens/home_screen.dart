import 'package:flutter/material.dart';
import 'child_list_screen.dart';  // For the list of children
import 'conversation_page_parent.dart';  // For messaging with responsible
import 'settings_screen.dart';    // For changing password and logging out
import 'welcome_screen.dart';     // Optionally a home page screen
import 'people_list_screen.dart'; // For responsible
import 'dashboard_screen.dart';   // For responsible
import 'messaging_screen.dart';   // For responsible
import 'sign_in.dart';            // To get the user role, assume it's stored in shared preferences
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  String userRole = '';  // Role of the user, either "responsable" or "parent"

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // Load the user role from shared preferences
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? '';  // Set the role to empty if not found
    });
  }

  // Lists of screens for both Parent and Responsable
  static const List<Widget> _parentScreens = <Widget>[
    ChildListScreen(),
    ConversationPage(),
    WelcomeScreen(),
    SettingsScreen(),
  ];

  static const List<Widget> _responsableScreens = <Widget>[
    PeopleListScreen(),
    DashboardScreen(),
    WelcomeScreen(),
    MessagingScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the screens based on user role
    List<Widget> screens = userRole == 'responsable' ? _responsableScreens : _parentScreens;

    return Scaffold(
      body: screens[_selectedIndex], // Show the correct screen based on user role
      bottomNavigationBar: BottomNavigationBar(
        items: userRole == 'responsable'
            ? const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Liste des Enfants',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Tableau de Bord',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Messagerie',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Paramètres',
                ),
              ]
            : const <BottomNavigationBarItem>[
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
