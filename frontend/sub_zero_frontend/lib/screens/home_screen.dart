import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/monthly_total_card.dart';
import '../components/subscription_list_item.dart';
import '../models/subscription.dart';
import '../providers/subzero_provider.dart';
import '../theme/app_theme.dart';
import 'add_subscription_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _formatDueDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return 'Due ${_monthNames[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return 'Due –';
    }
  }

  static String _formatFrequency(String billingCycle) {
    final lower = billingCycle.toLowerCase();
    if (lower.contains('month')) return '/month';
    if (lower.contains('year')) return '/year';
    if (lower.contains('week')) return '/week';
    return '/$billingCycle';
  }

  static Color _parseColorHex(String hex) {
    try {
      final h = hex.startsWith('#') ? hex.substring(1) : hex;
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF95A5A6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubZeroProvider>(
      builder: (context, provider, child) {
        final stats = provider.statsTotal;
        final subs = provider.subscriptions;

        final username = provider.loggedInUsername ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: const Text('SubZero – Dashboard'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Hallo, $username!', style: greetingStyle(context)),
              ),
              if (stats != null)
                MonthlyTotalCard(
                  monthlyTotal: stats.total,
                  currency: provider.currencySymbol,
                  activeSubscriptionsCount: subs.length,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Your Subscriptions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Expanded(
                child: subs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                            child: Text(
                            'Noch alles ruhig hier…\n\nFüge dein erstes Abo hinzu.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: subs.length,
                        itemBuilder: (context, index) {
                          final sub = subs[index];
                          return SubscriptionListItem(
                            title: sub.title,
                            price: sub.price,
                            currency: provider.currencySymbol,
                            dueDateLabel: _formatDueDate(sub.nextReminderDate),
                            frequencyLabel: _formatFrequency(sub.billingCycle),
                            badgeColor: _parseColorHex(sub.category.colorHex),
                            badgeLetter: sub.title.isNotEmpty
                                ? sub.title[0]
                                : '?',
                            onDelete: () => provider.deleteSubscription(sub.id),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
          ),
        );
      },
    );
  }
}
