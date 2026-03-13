import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/monthly_total_card.dart';
import '../components/family_member_card.dart';
import '../providers/subzero_provider.dart';
import '../theme/app_theme.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _formKeyCreate = GlobalKey<FormState>();
  final _formKeyJoin = GlobalKey<FormState>();
  final _createNameController = TextEditingController();
  final _joinCodeController = TextEditingController();

  @override
  void dispose() {
    _createNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
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
        final currency = provider.currencySymbol;

        if (user?.familyId == null) {
          return Scaffold(
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                    child: Text('Familie', style: greetingStyle(context)),
                  ),
                  const SizedBox(height: 16),
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
                  Form(
                    key: _formKeyCreate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _createNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name der Family',
                            hintText: 'z.B. Meine Familie',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Namen eingeben';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKeyCreate.currentState!.validate()) {
                                final name = _createNameController.text.trim();
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
                              }
                            },
                            child: const Text('Family gründen'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Family beitreten', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKeyJoin,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _joinCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Einladungscode',
                            hintText: 'z.B. A7KQ2',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte Code eingeben';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKeyJoin.currentState!.validate()) {
                                final code = _joinCodeController.text.trim();
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
                              }
                            },
                            child: const Text('Beitreten'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                if (user?.familyId != null) {
                  await provider.loadUser(user!.id);
                }
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  family?.name ?? 'Familie',
                  style: greetingStyle(context),
                ),
              ),
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
                child: Text('Mitglieder', style: sectionTitleStyle(context)),
              ),
              if (membersWithStats.isNotEmpty)
                ...membersWithStats.asMap().entries.map((e) {
                  final m = e.value;
                  final percent = total > 0 ? (m.sum / total * 100) : 0.0;
                  final colors = [
                    const Color(0xFFBDE0FE),
                    const Color(0xFFD8C3F5),
                    const Color(0xFFFFC9C9),
                    const Color(0xFFC7EFCF),
                  ];
                  final color = colors[e.key % colors.length];
                  return FamilyMemberCard(
                    member: m,
                    percent: percent,
                    color: color,
                    currency: currency,
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
        ),
        );
      },
    );
  }
}
