import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;

  ExpenseChart(this.expenses);

  Map<ExpenseCategory, double> getCategoryTotals() {
    final Map<ExpenseCategory, double> totals = {};
    for (var expense in expenses) {
      totals.update(expense.category, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = getCategoryTotals();
    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    final colors = {
      ExpenseCategory.food: Colors.blue,
      ExpenseCategory.travel: Colors.orange,
      ExpenseCategory.shopping: Colors.purple,
      ExpenseCategory.bills: Colors.red,
      ExpenseCategory.other: Colors.green,
    };

    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        margin: EdgeInsets.all(10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: categoryTotals.entries.map((entry) {
                final percent = (entry.value / total) * 100;
                return PieChartSectionData(
                  color: colors[entry.key],
                  value: entry.value,
                  title: '${percent.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 4,
              centerSpaceRadius: 30,
            ),
          ),
        ),
      ),
    );
  }
}
