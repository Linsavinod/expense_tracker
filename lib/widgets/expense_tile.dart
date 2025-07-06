import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExpenseTile({
    Key? key,
    required this.expense,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.travel:
        return Icons.directions_car;
      case ExpenseCategory.shopping:
        return Icons.shopping_cart;
      case ExpenseCategory.bills:
        return Icons.receipt;
      case ExpenseCategory.other:
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getCategoryIcon(expense.category),
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(expense.title),
      subtitle: Text(
        '${DateFormat.yMMMd().format(expense.date)} • ${expense.category.name[0].toUpperCase()}${expense.category.name.substring(1)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('₹${expense.amount.toStringAsFixed(2)}'),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            label: const Text("Delete"),
            icon: const Icon(Icons.delete, size: 18, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
