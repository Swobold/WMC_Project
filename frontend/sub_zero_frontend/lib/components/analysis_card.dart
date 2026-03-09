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
    final formattedTotal = '$currency${totalMonthlySpending.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Monthly Spending',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formattedTotal,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: pieSections.isEmpty
                ? Center(
                    child: Text(
                      'Keine Daten',
                      style: TextStyle(color: Colors.grey[600]),
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
