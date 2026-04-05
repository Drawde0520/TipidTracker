import 'package:flutter/material.dart';
import '../models/utang.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class AddUtangScreen extends StatefulWidget {
  const AddUtangScreen({super.key});

  @override
  State<AddUtangScreen> createState() => _AddUtangScreenState();
}

class _AddUtangScreenState extends State<AddUtangScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDueDate;

  void _saveUtang() {
    final name = _nameController.text.trim();
    final note = _noteController.text.trim();
    final amountText = _amountController.text;
    
    if (name.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pangalan at amount ay kailangan')));
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }

    final utang = Utang(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      personName: name,
      amount: amount,
      timestamp: DateTime.now(),
      dueDate: _selectedDueDate,
      note: note,
    );

    HiveService.addUtang(utang);
    if (utang.dueDate != null) {
      NotificationService.scheduleUtangReminder(utang);
    }
    
    Navigator.pop(context);
  }

  void _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magdagdag ng Utang'), backgroundColor: Colors.red[600]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pangalan ng Tao',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (₱)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDueDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(_selectedDueDate == null ? 'Piliin kailan babayaran' : '${_selectedDueDate!.toLocal()}'.split(' ')[0]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _saveUtang,
              child: const Text('I-Save', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
