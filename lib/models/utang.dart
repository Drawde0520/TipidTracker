import 'package:hive/hive.dart';

class Utang extends HiveObject {
  final String id;
  final String personName;
  final double amount;
  final DateTime timestamp;
  bool isSynced;

  Utang({
    required this.id,
    required this.personName,
    required this.amount,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
    };
  }
}

class UtangAdapter extends TypeAdapter<Utang> {
  @override
  final int typeId = 1;

  @override
  Utang read(BinaryReader reader) {
    return Utang(
      id: reader.readString(),
      personName: reader.readString(),
      amount: reader.readDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSynced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Utang obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.personName);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isSynced);
  }
}
