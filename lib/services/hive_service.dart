import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/utang.dart';

class HiveService {
  static const String expenseBoxName = 'expenses';
  static const String utangBoxName = 'utangs';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(UtangAdapter());

    await Hive.openBox<Expense>(expenseBoxName);
    await Hive.openBox<Utang>(utangBoxName);
  }

  static Box<Expense> get expenses => Hive.box<Expense>(expenseBoxName);
  static Box<Utang> get utangs => Hive.box<Utang>(utangBoxName);

  static Future<void> addExpense(Expense expense) async {
    await expenses.put(expense.id, expense);
  }

  static Future<void> addUtang(Utang utang) async {
    await utangs.put(utang.id, utang);
  }
}
