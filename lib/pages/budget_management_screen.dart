// budget_management_screen.dart
import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import 'package:intl/intl.dart';

class BudgetManagementScreen extends StatefulWidget {
  final List<Expense> expenses;
  final double owner1Withdrawn;
  final double owner2Withdrawn;
  final Function(List<Expense>) onExpensesChanged;
  final Function(double, double) onWithdrawalsChanged;
  final double totalIncome; // إضافة دخل اليوم
  final List<WashTransaction> transactions; // إضافة المعاملات

  const BudgetManagementScreen({
    Key? key,
    required this.expenses,
    required this.owner1Withdrawn,
    required this.owner2Withdrawn,
    required this.onExpensesChanged,
    required this.onWithdrawalsChanged,
    required this.totalIncome,
    required this.transactions,
  }) : super(key: key);

  @override
  _BudgetManagementScreenState createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends State<BudgetManagementScreen> {
  late List<Expense> _expenses;
  late double _owner1Withdrawn;
  late double _owner2Withdrawn;
  final TextEditingController _expenseDescriptionController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _owner1Controller = TextEditingController();
  final TextEditingController _owner2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
    _owner1Withdrawn = widget.owner1Withdrawn;
    _owner2Withdrawn = widget.owner2Withdrawn;
    _owner1Controller.text = _owner1Withdrawn.toStringAsFixed(2);
    _owner2Controller.text = _owner2Withdrawn.toStringAsFixed(2);
  }

  void _addExpense() {
    final description = _expenseDescriptionController.text;
    final amount = double.tryParse(_expenseAmountController.text) ?? 0;

    if (description.isNotEmpty && amount > 0) {
      setState(() {
        _expenses.add(Expense(description: description, amount: amount));
        _expenseDescriptionController.clear();
        _expenseAmountController.clear();
        widget.onExpensesChanged(_expenses);
      });
    }
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
      widget.onExpensesChanged(_expenses);
    });
  }

  void _updateWithdrawals() {
    final owner1 = double.tryParse(_owner1Controller.text) ?? 0;
    final owner2 = double.tryParse(_owner2Controller.text) ?? 0;

    setState(() {
      _owner1Withdrawn = owner1;
      _owner2Withdrawn = owner2;
      widget.onWithdrawalsChanged(_owner1Withdrawn, _owner2Withdrawn);
    });
  }

  double _calculateExpensesTotal() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    double expensesTotal = _calculateExpensesTotal();
    double remainingMoney = widget.totalIncome - expensesTotal - _owner1Withdrawn - _owner2Withdrawn;

    return Scaffold(

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // جدول المبيعات اليومية
                _buildDailySalesTable(expensesTotal, remainingMoney),
                SizedBox(height: 20),

                // جدول السحوبات
                _buildWithdrawalsTable(),
                SizedBox(height: 20),

                // جدول المصاريف
                _buildExpensesTable(),
                SizedBox(height: 20),

                // زر الحفظ
                ElevatedButton(
                  onPressed: () {
                    _updateWithdrawals();
                    Navigator.pop(context);
                  },
                  child: Text('حفظ التغييرات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
    );

  }

  Widget _buildDailySalesTable(double expensesTotal, double remainingMoney) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المبيعات اليومية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              headingRowHeight: 45,
              columns: [
                DataColumn(
                  label: Text(
                    'ت',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'التاريخ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'الدخل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'العمال',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'زبير',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'فراس',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'المصاريف',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'الباقي',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'سحب فراس',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'سحب زبير',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'المصروفات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text('1')),
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(DateTime.now()))),
                    DataCell(Text(widget.totalIncome.toStringAsFixed(2))),
                    DataCell(Text('0')), // العمال - يمكن تعديله حسب الحاجة
                    DataCell(Text(_owner1Withdrawn.toStringAsFixed(2))), // زبير
                    DataCell(Text(_owner2Withdrawn.toStringAsFixed(2))), // فراس
                    DataCell(Text(expensesTotal.toStringAsFixed(2))), // المصاريف
                    DataCell(Text(remainingMoney.toStringAsFixed(2))), // الباقي
                    DataCell(Text(_owner2Withdrawn.toStringAsFixed(2))), // سحب فراس
                    DataCell(Text(_owner1Withdrawn.toStringAsFixed(2))), // سحب زبير
                    DataCell(
                      Tooltip(
                        message: _expenses.map((e) => '${e.description}: ${e.amount.toStringAsFixed(2)}').join('\n'),
                        child: Text(
                          expensesTotal.toStringAsFixed(2),
                          style: TextStyle(
                            decoration: _expenses.isNotEmpty ? TextDecoration.underline : null,
                            color: _expenses.isNotEmpty ? Colors.blue : null,
                          ),
                        ),
                      ),
                    ), // المصروفات
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalsTable() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سحوبات المالكين',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 16),

          Table(
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('زبير:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _owner1Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00 دينار',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _owner1Withdrawn = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('فراس:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _owner2Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.00 دينار',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _owner2Withdrawn = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTable() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المصاريف',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 16),

          if (_expenses.isEmpty)
            Center(
                child: Text('لا توجد مصاريف مضافة', style: TextStyle(color: Colors.grey))
            )
          else
            Table(
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(0.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('المبلغ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                for (int i = 0; i < _expenses.length; i++)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(_expenses[i].description),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('${_expenses[i].amount.toStringAsFixed(2)} دينار',
                            textAlign: TextAlign.end),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _removeExpense(i),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _expenseDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'وصف المصروف',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _expenseAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'المبلغ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addExpense,
                child: Text('إضافة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}