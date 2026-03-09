import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/subzero_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => SubZeroProvider(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubZero',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LoginScreen(),
    );
  }
}
