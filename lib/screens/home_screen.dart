import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/hive_service.dart';
import '../models/expense.dart';
import '../models/utang.dart';
import '../widgets/chart_widget.dart';
import 'add_expense_screen.dart';
import 'add_utang_screen.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad Unit ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('TipidTracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('Uy ginagamit ko tong TipidTracker para sa gastos at utang 😄 Try mo din!');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 20),
              const Text('Gastos Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: ValueListenableBuilder<Box<Expense>>(
                  valueListenable: HiveService.expenses.listenable(),
                  builder: (context, box, _) {
                    final expenses = box.values.toList();
                    return ChartWidget(expenses: expenses);
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ListScreen())),
                icon: const Icon(Icons.history),
                label: const Text('Tingnan ang History'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green[100],
                  foregroundColor: Colors.green[900],
                ),
              ),
              if (_isAdLoaded && _bannerAd != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'utang_btn',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUtangScreen())),
            label: const Text('Add Utang'),
            icon: const Icon(Icons.money_off),
            backgroundColor: Colors.red[400],
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'gastos_btn',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
            label: const Text('Add Gastos'),
            icon: const Icon(Icons.add_shopping_cart),
            backgroundColor: Colors.green[600],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<Box<Expense>>(
            valueListenable: HiveService.expenses.listenable(),
            builder: (context, box, _) {
              final total = box.values.fold(0.0, (sum, e) => sum + e.amount);
              return _buildCard('Total Gastos', total, Colors.green[700]!, Icons.account_balance_wallet);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ValueListenableBuilder<Box<Utang>>(
            valueListenable: HiveService.utangs.listenable(),
            builder: (context, box, _) {
              final total = box.values.fold(0.0, (sum, e) => sum + e.amount);
              return _buildCard('Total Utang', total, Colors.red[600]!, Icons.warning_amber_rounded);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 4),
          Text('₱${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
