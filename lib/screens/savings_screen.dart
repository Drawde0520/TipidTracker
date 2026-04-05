import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/savings.dart';
import '../services/hive_service.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gawa ng Alkansya'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Goal (Ex. Emergency Fund)')),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount (₱)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (title.isNotEmpty && amount > 0) {
                final goal = SavingsGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  targetAmount: amount,
                  timestamp: DateTime.now(),
                );
                HiveService.addSavingsGoal(goal);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  void _showHulogDialog(SavingsGoal goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Maghulog sa ${goal.title}'),
        content: TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₱)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                final entry = SavingsEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  goalId: goal.id,
                  amount: amount,
                  timestamp: DateTime.now(),
                );
                HiveService.addSavingsEntry(entry);
                goal.currentAmount += amount;
                goal.isSynced = false;
                goal.save();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Hulog'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alkansya'), backgroundColor: Colors.blue[600]),
      body: ValueListenableBuilder<Box<SavingsGoal>>(
        valueListenable: HiveService.savingsGoals.listenable(),
        builder: (context, box, _) {
          final goals = box.values.toList();
          if (goals.isEmpty) {
            return const Center(child: Text('Wala pang ipon. Gumawa na ng Alkansya!'));
          }

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final double percent = (goal.targetAmount > 0) ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percent,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        color: percent >= 1.0 ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₱${goal.currentAmount.toStringAsFixed(0)} / ₱${goal.targetAmount.toStringAsFixed(0)}'),
                          Text('${(percent * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _showHulogDialog(goal),
                          icon: const Icon(Icons.savings),
                          label: const Text('Maghulog'),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[600],
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Goal', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
