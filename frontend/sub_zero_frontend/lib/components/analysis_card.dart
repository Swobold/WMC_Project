import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Wiederverwendbare Karten-Komponente für die Analysis-Ansicht.
/// Enthält Total Monthly Spending und Pie Chart.
/// Stateless – alle Daten werden von außen übergeben.
class AnalysisCard extends StatelessWidget {
  final double totalMonthlySpending;
  final String currency;
  final List<PieChartSectionData> pieSections;

  const AnalysisCard({
    super.key,
    required this.totalMonthlySpending,
    required this.currency,
    required this.pieSections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedTotal = '$currency${totalMonthlySpending.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Monthly Spending',
            style: theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedTotal,
            style: theme.textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: pieSections.isEmpty
                ? Center(
                    child: Text(
                      'Keine Daten',
                      style: theme.textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sections: pieSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                    duration: const Duration(milliseconds: 300),
                  ),
          ),
        ],
      ),
    );
  }
}
