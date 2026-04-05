import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'services/hive_service.dart';
import 'services/sync_service.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage First (Offline Priority)
  await HiveService.init();
  
  // Initialize Timezone
  tz.initializeTimeZones();

  // Try Initialize Firebase (Will fail if no google-services.json but app will still open)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed (expected without config): $e");
  }

  // Initialize Ads
  MobileAds.instance.initialize();

  // Initialize Notifications
  await NotificationService.init();
  NotificationService.showDailyGastosReminder();
  NotificationService.showSavingsReminder();

  // Initialize Sync Service Listener
  SyncService.init();

  runApp(const TipidTrackerApp());
}

class TipidTrackerApp extends StatelessWidget {
  const TipidTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TipidTracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
