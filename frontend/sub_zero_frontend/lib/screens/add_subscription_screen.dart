import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/subzero_provider.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _firstPaymentController = TextEditingController();

  int? _categoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _firstPaymentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubZeroProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Abo hinzufügen'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'z.B. Netflix',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Bitte Name eingeben';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Preis',
                      hintText: 'z.B. 9.99',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Bitte Preis eingeben';
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      if (n == null || n < 0) return 'Ungültiger Preis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Kategorie',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Bitte Kategorie wählen' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstPaymentController,
                    decoration: InputDecoration(
                      labelText: 'Nächstes Zahlungsdatum',
                      hintText: 'YYYY-MM-DD',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _pickDate(context, _firstPaymentController),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Bitte Datum eingeben';
                      final d = DateTime.tryParse(v.trim());
                      if (d == null) return 'Ungültiges Datum (YYYY-MM-DD)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        if (_categoryId == null) return;

                        final dateStr = _firstPaymentController.text.trim();
                        final ok = await provider.addSubscription(SubscriptionInput(
                          title: _titleController.text.trim(),
                          price: double.parse(_priceController.text.replaceAll(',', '.')),
                          billingCycle: 'monthly',
                          firstPaymentDate: dateStr,
                          nextReminderDate: dateStr,
                          categoryId: _categoryId!,
                        ));
                        if (!mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Abo hinzugefügt!')),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fehler beim Hinzufügen – Backend prüfen'),
                            ),
                          );
                        }
                      },
                      child: const Text('Abo speichern'),
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
