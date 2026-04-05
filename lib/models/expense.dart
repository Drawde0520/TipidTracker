import 'package:hive/hive.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime timestamp;
  bool isSynced;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
    };
  }
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    return Expense(
      id: reader.readString(),
      amount: reader.readDouble(),
      category: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSynced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isSynced);
  }
}
