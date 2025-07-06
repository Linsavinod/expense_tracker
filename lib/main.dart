import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'models/expense.dart';
import 'widgets/expense_chart.dart';
import 'widgets/expense_tile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Expense>('expensesBox');

  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[800],
      ),
      home:ExpenseHomePage(onToggleTheme:_toggleTheme),
  

    );
  }
}

enum SortOption { dateNewest, dateOldest, amountHigh, amountLow }

class ExpenseHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  ExpenseHomePage({required this.onToggleTheme});


  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}
class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final Box<Expense> _expenseBox = Hive.box<Expense>('expensesBox');

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
SortOption _selectedSort = SortOption.dateNewest;
List<Expense> _getSortedExpenses(List<Expense> expenses) {
if(_searchQuery.isNotEmpty){
  expenses=expenses
  .where((e)=>
  e.title.toLowerCase().contains(_searchQuery.toLowerCase()))
  .toList();
}



  switch (_selectedSort) {
    case SortOption.dateOldest:
      expenses.sort((a, b) => a.date.compareTo(b.date));
      break;
    case SortOption.amountHigh:
      expenses.sort((a, b) => b.amount.compareTo(a.amount));
      break;
    case SortOption.amountLow:
      expenses.sort((a, b) => a.amount.compareTo(b.amount));
      break;
    case SortOption.dateNewest:
    default:
      expenses.sort((a, b) => b.date.compareTo(a.date));
      break;
  }
  return expenses;
}


  void _addExpense() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);

    if (enteredTitle.isEmpty || enteredAmount == null) return;

    final newExpense = Expense(
      title: enteredTitle,
      amount: enteredAmount,
      date: DateTime.now(),
      category: _selectedCategory,
    );

    _expenseBox.add(newExpense);

    setState(() {}); // To refresh the list

    _titleController.clear();
    _amountController.clear();
    _selectedCategory = ExpenseCategory.food;
  }




void _showEditExpenseDialog(Expense expense) {
  final _editTitleController = TextEditingController(text: expense.title);
  final _editAmountController = TextEditingController(text: expense.amount.toString());
  ExpenseCategory _editSelectedCategory = expense.category;

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editTitleController,
                decoration: InputDecoration(labelText: 'Expense Title'),
              ),
              TextField(
                controller: _editAmountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<ExpenseCategory>(
                value: _editSelectedCategory,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _editSelectedCategory = val;
                    });
                  }
                },
                items: ExpenseCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = _editTitleController.text;
              final newAmount = double.tryParse(_editAmountController.text);

              if (newTitle.isEmpty || newAmount == null) {
                // You can show error message here if needed
                return;
              }

              // Update expense fields
              expense.title = newTitle;
              expense.amount = newAmount;
              expense.category = _editSelectedCategory;

              expense.save();  // Save changes to Hive

              setState(() {});

              Navigator.of(ctx).pop();
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions:[
          IconButton(icon: Icon(Icons.brightness_6),
          onPressed:widget.onToggleTheme,
          tooltip:'Toggle Theme',
          ),
          PopupMenuButton<SortOption>(onSelected:(SortOption selected){
            setState((){
              _selectedSort=selected;
            });
          },
          icon:Icon(Icons.sort),
          itemBuilder:(context)=>[
            PopupMenuItem(
              value: SortOption.dateNewest,
              child: Text('Date:Oldest first'),

            ),
            PopupMenuItem(
              value:SortOption.amountHigh,
              child:Text('Amount:High to Low'),
            ),
            PopupMenuItem(
             value:SortOption.amountLow,
            child:Text('Amount:Low to High'),
            ),
          ],
          ),

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
  controller: _searchController,
  decoration: InputDecoration(
    labelText: 'Search by Title',
    prefixIcon: Icon(Icons.search),
    suffixIcon: _searchQuery.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          )
        : null,
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    setState(() {
      _searchQuery = value;
    });
  },
),
SizedBox(height: 12),

                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Expense Title'),
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<ExpenseCategory>(
                  value: _selectedCategory,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                  items: ExpenseCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: Text('Add Expense'),
                ),
              ],
            ),
          ),
          Divider(),
Expanded(
  flex: 1,
  child: ValueListenableBuilder(
    valueListenable: _expenseBox.listenable(),
    builder: (context, Box<Expense> box, _) {
      final allExpenses = _getSortedExpenses(box.values.toList());
      return ExpenseChart(allExpenses);
    },
  ),
),


          Expanded(
            flex: 2,
            child: ValueListenableBuilder(
              valueListenable: _expenseBox.listenable(),
              builder: (context, Box<Expense> box, _) {
                if (box.isEmpty) {
                  return Center(child: Text("No Expenses Added"));
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (ctx, i) {
                    final e = box.getAt(i)!;
return ExpenseTile(
  expense: e,
  onDelete: () {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '${e.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Cancel
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              box.deleteAt(i); // delete the item
              Navigator.of(ctx).pop(); // close dialog
            },
            child: Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  },

  onEdit: () => _showEditExpenseDialog(e),
);

                        
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
