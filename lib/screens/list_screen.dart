import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../services/hive_service.dart';
import '../models/expense.dart';
import '../models/utang.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

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
  const _ExpenseList({Key? key}) : super(key: key);

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
                trailing: Text('₱\${e.amount.toStringAsFixed(2)}', 
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
  const _UtangList({Key? key}) : super(key: key);

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
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red[100],
                  child: Icon(Icons.person, color: Colors.red[700]),
                ),
                title: Text(u.personName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(u.timestamp)),
                trailing: Text('₱\${u.amount.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            );
          },
        );
      },
    );
  }
}
