import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subzero_provider.dart';

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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Benachrichtigungen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Währung',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (provider.user != null)
                  ListTile(
                    leading: Icon(Icons.attach_money, color: Colors.blue[700]),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Themes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const ListTile(
                  title: Text('Farb-Schemes'),
                  subtitle: Text('Kommt später – 3 Schemas auswählbar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
