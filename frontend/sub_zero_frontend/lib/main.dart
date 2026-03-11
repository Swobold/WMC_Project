import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/subzero_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString('theme_mode');
  final themeMode = AppThemeModeX.fromString(stored);

  runApp(ChangeNotifierProvider(
    create: (_) => SubZeroProvider(initialThemeMode: themeMode),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubZeroProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'SubZero',
          theme: AppTheme.themeFor(provider.themeMode),
          home: const LoginScreen(),
        );
      },
    );
  }
}
