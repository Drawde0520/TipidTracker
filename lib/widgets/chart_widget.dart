import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ChartWidget extends StatelessWidget {
  final List<Expense> expenses;

  const ChartWidget({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text("Walang gastos yet!"));
    }

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final colors = [
      Colors.green.shade700,
      Colors.green.shade500,
      Colors.green.shade300,
      Colors.lime.shade500,
      Colors.teal.shade400,
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = categoryTotals.entries.map((e) {
      final data = PieChartSectionData(
        value: e.value,
        title: '\$${e.value.toStringAsFixed(0)}',
        color: colors[colorIndex % colors.length],
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      colorIndex++;
      return data;
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
