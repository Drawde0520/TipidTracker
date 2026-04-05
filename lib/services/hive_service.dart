import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/utang.dart';
import '../models/grocery_item.dart';
import '../models/palengke_price.dart';
import '../models/savings.dart';

class HiveService {
  static const String expenseBoxName = 'expenses';
  static const String utangBoxName = 'utangs';
  static const String groceriesBoxName = 'groceries';
  static const String palengkeBoxName = 'palengke_prices';
  static const String savingsGoalsBoxName = 'savings_goals';
  static const String savingsEntriesBoxName = 'savings_entries';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(UtangAdapter());
    Hive.registerAdapter(GroceryItemAdapter());
    Hive.registerAdapter(PalengkePriceAdapter());
    Hive.registerAdapter(SavingsGoalAdapter());
    Hive.registerAdapter(SavingsEntryAdapter());

    await Hive.openBox<Expense>(expenseBoxName);
    await Hive.openBox<Utang>(utangBoxName);
    await Hive.openBox<GroceryItem>(groceriesBoxName);
    await Hive.openBox<PalengkePrice>(palengkeBoxName);
    await Hive.openBox<SavingsGoal>(savingsGoalsBoxName);
    await Hive.openBox<SavingsEntry>(savingsEntriesBoxName);
  }

  static Box<Expense> get expenses => Hive.box<Expense>(expenseBoxName);
  static Box<Utang> get utangs => Hive.box<Utang>(utangBoxName);
  static Box<GroceryItem> get groceries => Hive.box<GroceryItem>(groceriesBoxName);
  static Box<PalengkePrice> get palengkePrices => Hive.box<PalengkePrice>(palengkeBoxName);
  static Box<SavingsGoal> get savingsGoals => Hive.box<SavingsGoal>(savingsGoalsBoxName);
  static Box<SavingsEntry> get savingsEntries => Hive.box<SavingsEntry>(savingsEntriesBoxName);

  static Future<void> addExpense(Expense expense) async {
    await expenses.put(expense.id, expense);
  }

  static Future<void> addUtang(Utang utang) async {
    await utangs.put(utang.id, utang);
  }

  static Future<void> addGrocery(GroceryItem item) async {
    await groceries.put(item.id, item);
  }

  static Future<void> addPalengkePrice(PalengkePrice price) async {
    await palengkePrices.put(price.id, price);
  }

  static Future<void> addSavingsGoal(SavingsGoal goal) async {
    await savingsGoals.put(goal.id, goal);
  }

  static Future<void> addSavingsEntry(SavingsEntry entry) async {
    await savingsEntries.put(entry.id, entry);
  }
}
