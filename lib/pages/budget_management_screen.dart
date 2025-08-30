import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import 'package:intl/intl.dart';
import 'package:royalcenter/utils/wash_type_utils.dart';

class BudgetManagementScreen extends StatefulWidget {
  final List<Expense> expenses;
  final double owner1Withdrawn;
  final double owner2Withdrawn;
  final Function(List<Expense>) onExpensesChanged;
  final Function(double, double) onWithdrawalsChanged;
  final double totalIncome;
  final List<WashTransaction> transactions;

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

  // حسابات الموظفين
  double _employeesTotal = 0;
  double _zubairShare = 0;
  double _firasShare = 0;
  double _remainingMoney = 0;

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
    _owner1Withdrawn = widget.owner1Withdrawn;
    _owner2Withdrawn = widget.owner2Withdrawn;
    _owner1Controller.text = _owner1Withdrawn.toStringAsFixed(2);
    _owner2Controller.text = _owner2Withdrawn.toStringAsFixed(2);

    // حساب حصص الموظفين والمالكين
    _calculateShares();
  }

  // حساب حصص الموظفين والمالكين
  void _calculateShares() {
    // حساب إجمالي أجر الموظفين (33% من إجمالي الدخل)
    _employeesTotal = widget.totalIncome * (1 / 3);

    // حساب حصة زبير (50% من الباقي بعد خصم أجر الموظفين)
    _zubairShare = (widget.totalIncome - _employeesTotal) ;

    // حساب حصة فراس (50% من الباقي بعد خصم أجر الموظفين)
    _firasShare = _zubairShare *  0.2;

    // حساب المبلغ المتبقي
    double expensesTotal = _calculateExpensesTotal();
    _remainingMoney = widget.totalIncome - expensesTotal - _employeesTotal - _owner1Withdrawn - _owner2Withdrawn;
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
        _calculateShares(); // إعادة حساب الحصص
      });
    }
  }

  void _removeExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
      widget.onExpensesChanged(_expenses);
      _calculateShares(); // إعادة حساب الحصص
    });
  }

  void _updateWithdrawals() {
    final owner1 = double.tryParse(_owner1Controller.text) ?? 0;
    final owner2 = double.tryParse(_owner2Controller.text) ?? 0;

    setState(() {
      _owner1Withdrawn = owner1;
      _owner2Withdrawn = owner2;
      widget.onWithdrawalsChanged(_owner1Withdrawn, _owner2Withdrawn);
      _calculateShares(); // إعادة حساب الحصص
    });
  }

  double _calculateExpensesTotal() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    double expensesTotal = _calculateExpensesTotal();

    return Scaffold(
        appBar: AppBar(
          title: Text('إدارة الميزانية', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // بطاقة ملخص الميزانية
                _buildBudgetSummaryCard(expensesTotal),
                SizedBox(height: 20),

                // جدول المبيعات اليومية
                _buildDailySalesTable(expensesTotal),
                SizedBox(height: 20),

                // جدول السحوبات
                _buildWithdrawalsTable(),
                SizedBox(height: 20),

                // جدول المصاريف
                _buildExpensesTable(),
                SizedBox(height: 20),

                // أزرار الحفظ والإلغاء
                _buildActionButtons(),
              ],
            ),
          ),
        ),
    );
  }

  // بطاقة ملخص الميزانية
  Widget _buildBudgetSummaryCard(double expensesTotal) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'ملخص الميزانية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('إجمالي الدخل:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${widget.totalIncome.toStringAsFixed(2)} دينار',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('أجر الموظفين (33%):', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_employeesTotal.toStringAsFixed(2)} دينار',
                    style: TextStyle(color: Colors.blue)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('حصة زبير:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_zubairShare.toStringAsFixed(2)} دينار',
                    style: TextStyle(color: Colors.orange)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('حصة فراس:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_firasShare.toStringAsFixed(2)} دينار',
                    style: TextStyle(color: Colors.orange)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المصاريف:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${expensesTotal.toStringAsFixed(2)} دينار',
                    style: TextStyle(color: Colors.red)),
              ],
            ),
            Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المبلغ المتبقي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_remainingMoney.toStringAsFixed(2)} دينار',
                    style: TextStyle(color: _remainingMoney >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySalesTable(double expensesTotal) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل المبيعات',
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
                  DataColumn(label: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('الدخل', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('أجر الموظفين', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('حصة زبير', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('حصة فراس', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المصاريف', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المتبقي', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(Text(DateFormat('yyyy-MM-dd').format(DateTime.now()))),
                      DataCell(Text(widget.totalIncome.toStringAsFixed(2))),
                      DataCell(Text(_employeesTotal.toStringAsFixed(2))),
                      DataCell(Text(_zubairShare.toStringAsFixed(2))),
                      DataCell(Text(_firasShare.toStringAsFixed(2))),
                      DataCell(Text(expensesTotal.toStringAsFixed(2))),
                      DataCell(Text(_remainingMoney.toStringAsFixed(2))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalsTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              Center(child: Text('لا توجد مصاريف مضافة', style: TextStyle(color: Colors.grey)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _expenses.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_expenses[index].description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${_expenses[index].amount.toStringAsFixed(2)} دينار',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _removeExpense(index),
                        ),
                      ],
                    ),
                  );
                },
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
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addExpense,
                  child: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.teal),
            ),
            child: Text('إلغاء', style: TextStyle(color: Colors.teal)),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _updateWithdrawals();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('حفظ التغييرات', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}