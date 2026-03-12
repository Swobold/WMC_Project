import 'package:flutter/material.dart';

/// Wiederverwendbare Karten-Komponente für die monatliche Gesamtsumme.
/// Stateless – alle Daten werden von außen übergeben.
class MonthlyTotalCard extends StatelessWidget {
  final double monthlyTotal;
  final String currency;
  final int activeSubscriptionsCount;
  final String? subtitleOverride;
  final String? inviteCode;

  const MonthlyTotalCard({
    super.key,
    required this.monthlyTotal,
    required this.currency,
    required this.activeSubscriptionsCount,
    this.subtitleOverride,
    this.inviteCode,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTotal = '$currency${monthlyTotal.toStringAsFixed(2)}';
    final countText = subtitleOverride ??
        (activeSubscriptionsCount == 1
            ? '1 aktives Abo'
            : '$activeSubscriptionsCount aktive Abos');

    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF27AE60),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                'Monthly Total',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedTotal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                countText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                'assets/images/chip.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (inviteCode != null && inviteCode!.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 52, bottom: 2),
                child: Text(
                  'Code: $inviteCode',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
