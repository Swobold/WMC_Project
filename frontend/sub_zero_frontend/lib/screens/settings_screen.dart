import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subzero_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _reminderDays = 5;

  @override
  Widget build(BuildContext context) {
    return Consumer<SubZeroProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: SafeArea(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Benachrichtigungen',
                    style: sectionTitleStyle(context),
                  ),
                ),
                ListTile(
                  title: const Text('Erinnerung vor Zahlungstermin'),
                  subtitle: Text('$_reminderDays Tage davor'),
                  trailing: DropdownButton<int>(
                    value: _reminderDays,
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 Tage')),
                      DropdownMenuItem(value: 4, child: Text('4 Tage')),
                      DropdownMenuItem(value: 5, child: Text('5 Tage')),
                      DropdownMenuItem(value: 6, child: Text('6 Tage')),
                      DropdownMenuItem(value: 7, child: Text('7 Tage')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _reminderDays = v);
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Währung',
                    style: sectionTitleStyle(context),
                  ),
                ),
                if (provider.user != null)
                  ListTile(
                    leading: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
                    title: const Text('Währung'),
                    subtitle: Text(provider.user!.isEur ? 'Euro (€)' : 'Dollar (\$)'),
                    trailing: DropdownButton<bool>(
                      value: provider.user!.isEur,
                      items: const [
                        DropdownMenuItem(value: true, child: Text('€ Euro')),
                        DropdownMenuItem(value: false, child: Text('\$ Dollar')),
                      ],
                      onChanged: (v) {
                        if (v != null) provider.updateUserCurrency(v);
                      },
                    ),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Darstellung',
                    style: sectionTitleStyle(context),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Erscheinungsbild'),
                  subtitle: Text(provider.themeMode.label),
                  trailing: DropdownButton<AppThemeMode>(
                    value: provider.themeMode,
                    items: AppThemeMode.values
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) provider.setThemeMode(v);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
