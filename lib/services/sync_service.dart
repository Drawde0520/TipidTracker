import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';
import '../models/palengke_price.dart' as import_palengke;

class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static StreamSubscription? _subscription;

  static void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((dynamic results) {
      bool isConnected = false;
      if (results is List) {
        isConnected = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi);
      } else if (results is ConnectivityResult) {
        isConnected = results == ConnectivityResult.mobile || results == ConnectivityResult.wifi;
      }
      
      if (isConnected) {
        _syncData();
      }
    });
  }

  static Future<void> _syncData() async {
    if (kIsWeb) return; // Basic guard
    try {
      await _pushExpenses();
      await _pushUtangs();
      await _pushGroceries();
      await _pushSavingsGoals();
      await _pushSavingsEntries();
      await _pullPalengkePrices();
      debugPrint('Sync successful');
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  static Future<void> _pushExpenses() async {
    final items = HiveService.expenses.values.where((e) => !e.isSynced).toList();
    for (var item in items) {
      final doc = await _firestore.collection('expenses').doc(item.id).get();
      if (doc.exists && DateTime.parse(doc.data()!['timestamp']).isAfter(item.timestamp)) continue;
      await _firestore.collection('expenses').doc(item.id).set(item.toMap());
      item.isSynced = true;
      await item.save();
    }
  }

  static Future<void> _pushUtangs() async {
    final items = HiveService.utangs.values.where((e) => !e.isSynced).toList();
    for (var item in items) {
      final doc = await _firestore.collection('utangs').doc(item.id).get();
      if (doc.exists && DateTime.parse(doc.data()!['timestamp']).isAfter(item.timestamp)) continue;
      await _firestore.collection('utangs').doc(item.id).set(item.toMap());
      item.isSynced = true;
      await item.save();
    }
  }

  static Future<void> _pushGroceries() async {
    final items = HiveService.groceries.values.where((e) => !e.isSynced).toList();
    for (var item in items) {
      final doc = await _firestore.collection('groceries').doc(item.id).get();
      if (doc.exists && DateTime.parse(doc.data()!['timestamp']).isAfter(item.timestamp)) continue;
      await _firestore.collection('groceries').doc(item.id).set(item.toMap());
      item.isSynced = true;
      await item.save();
    }
  }

  static Future<void> _pushSavingsGoals() async {
    final items = HiveService.savingsGoals.values.where((e) => !e.isSynced).toList();
    for (var item in items) {
      final doc = await _firestore.collection('savings_goals').doc(item.id).get();
      if (doc.exists && DateTime.parse(doc.data()!['timestamp']).isAfter(item.timestamp)) continue;
      await _firestore.collection('savings_goals').doc(item.id).set(item.toMap());
      item.isSynced = true;
      await item.save();
    }
  }

  static Future<void> _pushSavingsEntries() async {
    final items = HiveService.savingsEntries.values.where((e) => !e.isSynced).toList();
    for (var item in items) {
      final doc = await _firestore.collection('savings_entries').doc(item.id).get();
      if (doc.exists && DateTime.parse(doc.data()!['timestamp']).isAfter(item.timestamp)) continue;
      await _firestore.collection('savings_entries').doc(item.id).set(item.toMap());
      item.isSynced = true;
      await item.save();
    }
  }

  static Future<void> _pullPalengkePrices() async {
    // We fetch global prices
    final snap = await _firestore.collection('palengke_prices').get();
    for (var doc in snap.docs) {
      // Assuming PalengkePrice has fromMap
      try {
        final data = doc.data();
        final price = HiveService.palengkePrices.get(doc.id);
        if (price == null) {
          HiveService.palengkePrices.put(doc.id, import_palengke.PalengkePrice.fromMap(data, doc.id));
        }
      } catch (e) {
        debugPrint('Error pulling palengke entry: $e');
      }
    }
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
