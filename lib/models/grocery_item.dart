import 'package:hive/hive.dart';

class GroceryItem extends HiveObject {
  final String id;
  String name;
  double estimatedPrice;
  int quantity;
  bool isBought;
  final DateTime timestamp;
  bool isSynced;

  GroceryItem({
    required this.id,
    required this.name,
    required this.estimatedPrice,
    required this.quantity,
    this.isBought = false,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'estimatedPrice': estimatedPrice,
      'quantity': quantity,
      'isBought': isBought,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
    };
  }
}

class GroceryItemAdapter extends TypeAdapter<GroceryItem> {
  @override
  final int typeId = 2;

  @override
  GroceryItem read(BinaryReader reader) {
    return GroceryItem(
      id: reader.readString(),
      name: reader.readString(),
      estimatedPrice: reader.readDouble(),
      quantity: reader.readInt(),
      isBought: reader.readBool(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSynced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, GroceryItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeDouble(obj.estimatedPrice);
    writer.writeInt(obj.quantity);
    writer.writeBool(obj.isBought);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isSynced);
  }
}
