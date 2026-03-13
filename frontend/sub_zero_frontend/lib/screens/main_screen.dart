import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_subscription_screen.dart';
import 'analysis_screen.dart';
import 'family_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../providers/subzero_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    AnalysisScreen(),
    FamilyScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) {
            final provider = context.read<SubZeroProvider>();
            if (provider.user?.familyId != null) {
              provider.loadFamilyData();
            }
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Start'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Auswertung'),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Familie'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}
