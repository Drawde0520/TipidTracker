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
import 'grocery_screen.dart';
import 'palengke_prices_screen.dart';
import 'savings_screen.dart';
import '../models/savings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
              const SizedBox(height: 10),
              _buildDailyBudgetStatus(),
              const SizedBox(height: 10),
              _buildQuickActions(),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'gastos_btn',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        label: const Text('Add Gastos', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  Widget _buildDailyBudgetStatus() {
    return ValueListenableBuilder<Box<Expense>>(
      valueListenable: HiveService.expenses.listenable(),
      builder: (context, box, _) {
        final now = DateTime.now();
        // Calculate sweldo day (15th or 30th)
        int targetDay = 15;
        DateTime nextSweldo;
        if (now.day < 15) {
          nextSweldo = DateTime(now.year, now.month, 15);
        } else if (now.day < 30) {
          nextSweldo = DateTime(now.year, now.month, 30);
        } else {
          nextSweldo = DateTime(now.year, now.month + 1, 15);
        }
        
        final daysLeft = nextSweldo.difference(now).inDays;
        
        // Sum expenses since last sweldo
        DateTime lastSweldo;
        if (now.day >= 15 && now.day < 30) {
          lastSweldo = DateTime(now.year, now.month, 15);
        } else if (now.day >= 30) {
          lastSweldo = DateTime(now.year, now.month, 30);
        } else {
          lastSweldo = DateTime(now.year, now.month - 1, 30);
        }

        final recentExpenses = box.values.where((e) => e.timestamp.isAfter(lastSweldo)).toList();
        final totalRecent = recentExpenses.fold(0.0, (sum, e) => sum + e.amount);
        
        // Very basic simple budget estimation status
        String status = "Matipid ka! 💸";
        Color statusColor = Colors.green;
        if (totalRecent > 10000) {
           status = "Medyo magtipid, malayo pa sweldo! 😰";
           statusColor = Colors.orange;
        }
        if (totalRecent > 20000) {
           status = "Ubos na budget! 🚨";
           statusColor = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor)),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: statusColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kaya pa ba hanggang sweldo?', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                    Text('$daysLeft days left • $status', style: TextStyle(fontSize: 12, color: statusColor.withOpacity(0.8))),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildActionBtn('Alkansya', Icons.savings, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()))),
        _buildActionBtn('Grocery', Icons.local_grocery_store, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroceryScreen()))),
        _buildActionBtn('Palengke', Icons.storefront, Colors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PalengkePricesScreen()))),
        _buildActionBtn('Utang', Icons.money_off, Colors.red, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUtangScreen()))),
      ],
    );
  }

  Widget _buildActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: ValueListenableBuilder<Box<Expense>>(
              valueListenable: HiveService.expenses.listenable(),
              builder: (context, box, _) {
                final total = box.values.fold(0.0, (sum, e) => sum + e.amount);
                return _buildCard('Total Gastos', total, Colors.green[700]!, Icons.account_balance_wallet);
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: ValueListenableBuilder<Box<SavingsGoal>>(
              valueListenable: HiveService.savingsGoals.listenable(),
              builder: (context, box, _) {
                final total = box.values.fold(0.0, (sum, e) => sum + e.currentAmount);
                return _buildCard('Ipon (Alkansya)', total, Colors.blue[600]!, Icons.savings);
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: ValueListenableBuilder<Box<Utang>>(
              valueListenable: HiveService.utangs.listenable(),
              builder: (context, box, _) {
                final total = box.values.where((e) => !e.isPaid).fold(0.0, (sum, e) => sum + e.amount);
                return _buildCard('Unpaid Utang', total, Colors.red[600]!, Icons.warning_amber_rounded);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
