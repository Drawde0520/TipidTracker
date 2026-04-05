import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../services/hive_service.dart';
import '../models/expense.dart';
import '../models/utang.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: Colors.green[700],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Gastos'),
              Tab(text: 'Utang'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ExpenseList(),
            _UtangList(),
          ],
        ),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Expense>>(
      valueListenable: HiveService.expenses.listenable(),
      builder: (context, box, _) {
        final expenses = box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        if (expenses.isEmpty) {
          return const Center(child: Text('Wala pang gastos na na-log.'));
        }

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final e = expenses[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.shopping_bag, color: Colors.green[700]),
                ),
                title: Text(e.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(e.timestamp)),
                trailing: Text('₱${e.amount.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            );
          },
        );
      },
    );
  }
}

class _UtangList extends StatelessWidget {
  const _UtangList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Utang>>(
      valueListenable: HiveService.utangs.listenable(),
      builder: (context, box, _) {
        final utangs = box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        if (utangs.isEmpty) {
          return const Center(child: Text('Wala pang utang na na-log.'));
        }

        return ListView.builder(
          itemCount: utangs.length,
          itemBuilder: (context, index) {
            final u = utangs[index];
            bool isOverdue = false;
            if (u.dueDate != null && !u.isPaid) {
              isOverdue = DateTime.now().isAfter(u.dueDate!.add(const Duration(days: 1)));
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ExpansionTile(
                leading: Checkbox(
                  value: u.isPaid,
                  onChanged: (val) {
                    u.isPaid = val ?? false;
                    u.isSynced = false;
                    u.save();
                  },
                  activeColor: Colors.green,
                ),
                title: Text(
                  u.personName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: u.isPaid ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: u.dueDate != null
                    ? Text('Due: ${DateFormat.yMMMd().format(u.dueDate!)}',
                        style: TextStyle(color: isOverdue ? Colors.red : Colors.grey[600], fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal))
                    : Text(DateFormat.yMMMd().format(u.timestamp)),
                trailing: Text(
                  '₱${u.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: u.isPaid ? Colors.grey : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: u.isPaid ? TextDecoration.lineThrough : null,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(u.note.isNotEmpty ? 'Note: ${u.note}' : 'No note added.'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.blue),
                          onPressed: () {
                            String message = 'Hi ${u.personName}, pa-remind lang po ng utang na ₱${u.amount.toStringAsFixed(2)}.';
                            if (u.dueDate != null) {
                              message += ' Ang due date nito ay sa ${DateFormat.yMMMd().format(u.dueDate!)}.';
                            }
                            message += ' Salamat!';
                            Share.share(message);
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
