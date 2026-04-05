import 'package:hive/hive.dart';

class SavingsGoal extends HiveObject {
  final String id;
  String title;
  double targetAmount;
  double currentAmount;
  DateTime? deadline;
  final DateTime timestamp;
  bool isSynced;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
    };
  }
}

class SavingsGoalAdapter extends TypeAdapter<SavingsGoal> {
  @override
  final int typeId = 4;

  @override
  SavingsGoal read(BinaryReader reader) {
    return SavingsGoal(
      id: reader.readString(),
      title: reader.readString(),
      targetAmount: reader.readDouble(),
      currentAmount: reader.readDouble(),
      deadline: reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSynced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoal obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.targetAmount);
    writer.writeDouble(obj.currentAmount);
    writer.writeBool(obj.deadline != null);
    if (obj.deadline != null) {
      writer.writeInt(obj.deadline!.millisecondsSinceEpoch);
    }
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isSynced);
  }
}

class SavingsEntry extends HiveObject {
  final String id;
  final String goalId;
  final double amount;
  final DateTime timestamp;
  bool isSynced;

  SavingsEntry({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'isSynced': isSynced,
    };
  }
}

class SavingsEntryAdapter extends TypeAdapter<SavingsEntry> {
  @override
  final int typeId = 5;

  @override
  SavingsEntry read(BinaryReader reader) {
    return SavingsEntry(
      id: reader.readString(),
      goalId: reader.readString(),
      amount: reader.readDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSynced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, SavingsEntry obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.goalId);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.isSynced);
  }
}
