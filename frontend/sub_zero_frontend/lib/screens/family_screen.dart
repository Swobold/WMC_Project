import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/monthly_total_card.dart';
import '../components/family_member_card.dart';
import '../providers/subzero_provider.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _createNameController = TextEditingController();
  final _joinCodeController = TextEditingController();

  @override
  void dispose() {
    _createNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  static String _currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubZeroProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        final family = provider.family;
        final members = provider.familyMembers;
        final membersWithStats = provider.familyMembersWithStats;
        final total = provider.familyTotal ?? 0.0;
        final currency = _currencySymbol(provider.familyCurrency);

        if (user?.familyId == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Family'),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Du bist noch in keiner Family.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gründe eine neue oder trete mit einem Code bei.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  const Text('Family gründen', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _createNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name der Family',
                      hintText: 'z.B. Meine Familie',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = _createNameController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bitte Namen eingeben')),
                          );
                          return;
                        }
                        final error = await provider.createFamily(name);
                        if (!mounted) return;
                        if (error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Family erstellt! Code: ${provider.family?.inviteCode ?? ""}',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        }
                      },
                      child: const Text('Family gründen'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Family beitreten', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _joinCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Einladungscode',
                      hintText: 'z.B. A7KQ2',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final code = _joinCodeController.text.trim();
                        if (code.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bitte Code eingeben')),
                          );
                          return;
                        }
                        final error = await provider.joinFamily(code);
                        if (!mounted) return;
                        if (error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Family beigetreten!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        }
                      },
                      child: const Text('Beitreten'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(family?.name ?? 'Family'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (user?.familyId != null) {
                await provider.loadUser(user!.id);
              }
            },
            child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (family != null)
                MonthlyTotalCard(
                  monthlyTotal: total,
                  currency: currency,
                  activeSubscriptionsCount: members.length,
                  subtitleOverride: members.length == 1
                      ? '1 Mitglied'
                      : '${members.length} Mitglieder',
                  inviteCode: family.inviteCode,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              if (membersWithStats.isNotEmpty)
                ...membersWithStats.asMap().entries.map((e) {
                  final m = e.value;
                  final percent = total > 0 ? (m.sum / total * 100) : 0.0;
                  final colors = [
                    const Color(0xFF3498DB),
                    const Color(0xFF9B59B6),
                    const Color(0xFFE74C3C),
                    const Color(0xFF2ECC71),
                  ];
                  final color = colors[e.key % colors.length];
                  return FamilyMemberCard(
                    member: m,
                    percent: percent,
                    color: color,
                  );
                })
              else
                ...members.map(
                  (m) => ListTile(
                    leading: CircleAvatar(
                      child: Text(m.username.isNotEmpty ? m.username[0].toUpperCase() : '?'),
                    ),
                    title: Text(m.username),
                    subtitle: Text(m.email),
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
