import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_subscription_screen.dart';
import 'analysis_screen.dart';
import 'family_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../providers/subzero_provider.dart';

/// Haupt-Screen mit Bottom-Navigation (Tabs) wie in der PDF
/// "120-flutter-navigation-and-routing.pdf" beschrieben.
/// Verwendet IndexedStack, um den Tab-State zu erhalten.
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
        selectedItemColor: const Color(0xFF2ECC71),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: 'Family'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
