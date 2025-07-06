import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
enum ExpenseCategory {
  @HiveField(0)
  food,

  @HiveField(1)
  travel,

  @HiveField(2)
  shopping,

  @HiveField(3)
  bills,

  @HiveField(4)
  other,
}

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  ExpenseCategory category;

  @HiveField(3)
  DateTime date;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}
