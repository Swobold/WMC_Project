import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subzero_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static Color _parseColorHex(String hex) {
    if (hex.isEmpty) return const Color(0xFF95A5A6);
    try {
      final h = hex.startsWith('#') ? hex.substring(1) : hex;
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF95A5A6);
    }
  }

  static String _formatNotificationDate(String nextReminderDateIso, int daysBefore) {
    if (daysBefore <= 0) return 'Keine Erinnerung';
    try {
      final due = DateTime.parse(nextReminderDateIso);
      final notificationDate = due.subtract(Duration(days: daysBefore));
      const months = ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
      return '${notificationDate.day}. ${months[notificationDate.month - 1]}';
    } catch (_) {
      return '–';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubZeroProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: SafeArea(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Einstellungen',
                    style: greetingStyle(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Abmelden',
                    style: sectionTitleStyle(context),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Von Konto abmelden'),
                  onTap: () {
                    provider.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Benachrichtigungen',
                    style: sectionTitleStyle(context),
                  ),
                ),
                if (provider.subscriptions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Keine Abos – füge Abos hinzu, um Erinnerungen zu setzen.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                else
                  ...provider.subscriptions.map((sub) {
                    final raw = provider.getReminderDays(sub.id);
                    final days = [0, 1, 3, 7].contains(raw) ? raw : 0;
                    final badgeColor = _parseColorHex(sub.category.colorHex);
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: badgeColor,
                        child: Text(
                          sub.title.isNotEmpty ? sub.title[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(sub.title),
                      subtitle: Text(_formatNotificationDate(sub.nextReminderDate, days)),
                      trailing: DropdownButton<int>(
                        value: days,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Keine')),
                          DropdownMenuItem(value: 1, child: Text('1 Tag davor')),
                          DropdownMenuItem(value: 3, child: Text('3 Tage davor')),
                          DropdownMenuItem(value: 7, child: Text('7 Tage davor')),
                        ],
                        onChanged: (v) {
                          if (v != null) provider.setReminderPref(sub.id, v);
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
