import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'hive_service.dart';

class SyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static StreamSubscription? _subscription;

  static void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        _syncData();
      }
    });
  }

  static Future<void> _syncData() async {
    try {
      final expenses = HiveService.expenses.values.where((e) => !e.isSynced).toList();
      for (var expense in expenses) {
        await _firestore.collection('expenses').doc(expense.id).set(expense.toMap());
        expense.isSynced = true;
        await expense.save();
      }

      final utangs = HiveService.utangs.values.where((u) => !u.isSynced).toList();
      for (var utang in utangs) {
        await _firestore.collection('utangs').doc(utang.id).set(utang.toMap());
        utang.isSynced = true;
        await utang.save();
      }
      debugPrint('Sync successful');
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
