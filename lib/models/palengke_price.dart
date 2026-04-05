import 'package:hive/hive.dart';

class PalengkePrice extends HiveObject {
  final String id;
  final String item;
  final double price;
  final String location;
  final DateTime timestamp;
  bool isSynced;

  PalengkePrice({
    required this.id,
    required this.item,
    required this.price,
    required this.location,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'price': price,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory PalengkePrice.fromMap(Map<String, dynamic> map, String docId) {
    return PalengkePrice(
      id: docId,
      item: map['item'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isSynced: true,
    );
  }
}

class PalengkePriceAdapter extends TypeAdapter<PalengkePrice> {
  @override
  final int typeId = 3;

  @override
  PalengkePrice read(BinaryReader reader) {
    return PalengkePrice(
      id: reader.readString(),
      item: reader.readString(),
      price: reader.readDouble(),
      location: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSynced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, PalengkePrice obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.item);
    writer.writeDouble(obj.price);
    writer.writeString(obj.location);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isSynced);
  }
}
