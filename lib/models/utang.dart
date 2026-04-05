import 'package:hive/hive.dart';

class Utang extends HiveObject {
  final String id;
  final String personName;
  final double amount;
  final DateTime timestamp;
  bool isSynced;
  DateTime? dueDate;
  bool isPaid;
  String note;

  Utang({
    required this.id,
    required this.personName,
    required this.amount,
    required this.timestamp,
    this.isSynced = false,
    this.dueDate,
    this.isPaid = false,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
      'dueDate': dueDate?.toIso8601String(),
      'isPaid': isPaid,
      'note': note,
    };
  }
}

class UtangAdapter extends TypeAdapter<Utang> {
  @override
  final int typeId = 1;

  @override
  Utang read(BinaryReader reader) {
    int numFields = reader.readByte();
    Map<int, dynamic> fields = {};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    
    return Utang(
      id: fields[0] as String,
      personName: fields[1] as String,
      amount: fields[2] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      isSynced: fields[4] as bool,
      dueDate: fields[5] != null && fields[5] as bool ? DateTime.fromMillisecondsSinceEpoch(fields[6] as int) : null,
      isPaid: fields.containsKey(7) ? fields[7] as bool : false,
      note: fields.containsKey(8) ? fields[8] as String : '',
    );
  }

  @override
  void write(BinaryWriter writer, Utang obj) {
    writer.writeByte(9); // total fields
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.personName);
    writer.writeByte(2); writer.write(obj.amount);
    writer.writeByte(3); writer.write(obj.timestamp.millisecondsSinceEpoch);
    writer.writeByte(4); writer.write(obj.isSynced);
    writer.writeByte(5); writer.write(obj.dueDate != null);
    writer.writeByte(6); writer.write(obj.dueDate?.millisecondsSinceEpoch ?? 0);
    writer.writeByte(7); writer.write(obj.isPaid);
    writer.writeByte(8); writer.write(obj.note);
  }
}
