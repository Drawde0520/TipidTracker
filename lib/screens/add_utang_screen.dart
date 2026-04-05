import 'package:flutter/material.dart';
import '../models/utang.dart';
import '../services/hive_service.dart';

class AddUtangScreen extends StatefulWidget {
  const AddUtangScreen({Key? key}) : super(key: key);

  @override
  State<AddUtangScreen> createState() => _AddUtangScreenState();
}

class _AddUtangScreenState extends State<AddUtangScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  void _saveUtang() {
    final name = _nameController.text;
    final amountText = _amountController.text;
    
    if (name.isEmpty || amountText.isEmpty) return;
    
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
    );

    HiveService.addUtang(utang);
    Navigator.pop(context);
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
