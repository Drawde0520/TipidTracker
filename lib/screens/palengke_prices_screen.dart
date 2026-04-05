import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/palengke_price.dart';
import '../services/hive_service.dart';

class PalengkePricesScreen extends StatefulWidget {
  const PalengkePricesScreen({super.key});

  @override
  State<PalengkePricesScreen> createState() => _PalengkePricesScreenState();
}

class _PalengkePricesScreenState extends State<PalengkePricesScreen> {
  final List<String> _commonItems = ['Bigas', 'Itlog', 'Manok', 'Baboy', 'Gulay (Talong)', 'Gulay (Pechay)'];
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedItem;

  void _showAddPriceDialog() {
    _selectedItem = _commonItems.first;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Palengke Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedItem,
              items: _commonItems.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedItem = val),
              decoration: const InputDecoration(labelText: 'Item'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₱)')),
            TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location (Ex. Pasig Palengke)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(_priceController.text) ?? 0.0;
              final loc = _locationController.text.trim();

              if (_selectedItem != null && price > 0 && loc.isNotEmpty) {
                final entry = PalengkePrice(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  item: _selectedItem!,
                  price: price,
                  location: loc,
                  timestamp: DateTime.now(),
                );
                HiveService.addPalengkePrice(entry);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salamat! Price submitted globally.')));
              }
            },
            child: const Text('Submit'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Palengke Tracker'), backgroundColor: Colors.green[800]),
      body: ValueListenableBuilder<Box<PalengkePrice>>(
        valueListenable: HiveService.palengkePrices.listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();
          items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (items.isEmpty) {
            return const Center(child: Text('Wala pang palengke data. Be the first to submit!'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green[100], child: const Icon(Icons.storefront, color: Colors.green)),
                title: Text('${item.item} - ₱${item.price.toStringAsFixed(2)}'),
                subtitle: Text('${item.location} • ${item.timestamp.toString().split(' ')[0]}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[800],
        onPressed: _showAddPriceDialog,
        icon: const Icon(Icons.upload, color: Colors.white),
        label: const Text('Share Price', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
