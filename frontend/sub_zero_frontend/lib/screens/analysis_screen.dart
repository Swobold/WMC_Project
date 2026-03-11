import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../components/analysis_card.dart';
import '../components/category_bar_item.dart';
import '../models/stats_by_category_item.dart';
import '../providers/subzero_provider.dart';
import '../theme/app_theme.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  static Color _parseColorHex(String hex) {
    try {
      final h = hex.startsWith('#') ? hex.substring(1) : hex;
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF95A5A6);
    }
  }

  static List<PieChartSectionData> _buildPieSections(
    List<StatsByCategoryItem> items,
  ) {
    if (items.isEmpty) return [];
    final total = items.fold<double>(0, (s, i) => s + i.sum);
    if (total <= 0) return [];

    return items.map((item) {
      final color = _parseColorHex(item.colorHex);
      return PieChartSectionData(
        value: item.sum,
        title: '',
        color: color,
        radius: 50,
        showTitle: false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubZeroProvider>(
      builder: (context, provider, child) {
        final statsTotal = provider.statsTotal;
        final statsByCategory = provider.statsByCategory;

        final total = statsTotal?.total ?? 0.0;
        final currency = provider.currencySymbol;
        final pieSections = _buildPieSections(statsByCategory);

        final username = provider.loggedInUsername ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Analysis'),
          ),
          body: statsByCategory.isEmpty && total == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Noch keine Auswertung möglich.\nFüge Abos hinzu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('Hallo, $username!', style: greetingStyle(context)),
                    ),
                    AnalysisCard(
                      totalMonthlySpending: total,
                      currency: currency,
                      pieSections: pieSections,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text('Nach Kategorie', style: sectionTitleStyle(context)),
                    ),
                    ...statsByCategory.map(
                      (item) => CategoryBarItem(
                        categoryName: item.categoryName,
                        percent: item.percent,
                        sum: item.sum,
                        currency: provider.currencySymbol,
                        color: _parseColorHex(item.colorHex),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
