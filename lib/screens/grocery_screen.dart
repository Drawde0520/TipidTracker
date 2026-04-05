import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/grocery_item.dart';
import '../services/hive_service.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  double _budget = 2000.0; // Placeholder for weekly budget

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Grocery Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated Price (₱)')),
            TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              final qty = int.tryParse(qtyController.text) ?? 1;

              if (name.isNotEmpty && price > 0) {
                final item = GroceryItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  estimatedPrice: price,
                  quantity: qty,
                  timestamp: DateTime.now(),
                );
                HiveService.addGrocery(item);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Budget Planner'),
        backgroundColor: Colors.orange[600],
      ),
      body: ValueListenableBuilder<Box<GroceryItem>>(
        valueListenable: HiveService.groceries.listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();
          final totalCost = items.fold<double>(0, (sum, item) => sum + (item.estimatedPrice * item.quantity));
          final remaining = _budget - totalCost;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange[100],
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Weekly Budget:', style: TextStyle(fontSize: 16)),
                        Text('₱${_budget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Estimated Cost:', style: TextStyle(fontSize: 16)),
                        Text('₱${totalCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining Budget:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '₱${remaining.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: remaining < 0 ? Colors.red : Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Wala pang nakalista sa grocery.'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: CheckboxListTile(
                              title: Text(item.name, style: TextStyle(decoration: item.isBought ? TextDecoration.lineThrough : null)),
                              subtitle: Text('Qty: ${item.quantity} | ₱${item.estimatedPrice} ea'),
                              secondary: Text('₱${(item.estimatedPrice * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              value: item.isBought,
                              onChanged: (val) {
                                item.isBought = val ?? false;
                                item.isSynced = false;
                                item.save();
                              },
                            ),
                          );
                        },
                      ),
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange[600],
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
    );
  }
}
