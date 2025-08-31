import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetManagementScreen extends StatefulWidget {
  final List<DailyRecord> dailyRecords;
  final List<Expense> expenses;
  final double owner1Withdrawn;
  final double owner2Withdrawn;
  final Function(List<Expense>) onExpensesChanged;
  final Function(double, double) onWithdrawalsChanged;
  final double totalIncome;
  final List<WashTransaction> transactions;

  const BudgetManagementScreen({
    Key? key,
    required this.dailyRecords,
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

  // بيانات الأيام المختلفة
  List<DailySalesData> dailySalesData = [];

  @override
  void initState() {
    super.initState();
    _expenses = List.from(widget.expenses);
    _owner1Withdrawn = widget.owner1Withdrawn;
    _owner2Withdrawn = widget.owner2Withdrawn;
    _owner1Controller.text = _owner1Withdrawn.toStringAsFixed(2);
    _owner2Controller.text = _owner2Withdrawn.toStringAsFixed(2);

    // إضافة متعقبين لحقول السحوبات
    _owner1Controller.addListener(_updateWithdrawals);
    _owner2Controller.addListener(_updateWithdrawals);

    // حساب حصص الموظفين والمالكين
    _calculateShares();

    // إنشاء بيانات نموذجية للأيام المختلفة
    _initializeDailySalesData();
  }

  @override
  void dispose() {
    _owner1Controller.removeListener(_updateWithdrawals);
    _owner2Controller.removeListener(_updateWithdrawals);
    _owner1Controller.dispose();
    _owner2Controller.dispose();
    _expenseDescriptionController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  // تهيئة بيانات المبيعات اليومية
  void _initializeDailySalesData() {
    // بيانات اليوم الحالي
    double expensesTotal = _calculateExpensesTotal();

    dailySalesData.add(DailySalesData(
      date: DateTime.now(),
      income: widget.totalIncome,
      employeesTotal: _employeesTotal,
      zubairShare: _zubairShare,
      firasShare: _firasShare,
      expenses: expensesTotal,
      remaining: _remainingMoney,
    ));

    for (var record in widget.dailyRecords) {
      // حساب حصص الموظفين والمالكين لكل يوم
      double employeesTotalDay = record.totalIncome * (1 / 3);
      double zubairShareDay = (record.totalIncome - employeesTotalDay);
      double firasShareDay = zubairShareDay * 0.2;
      double expensesTotalDay = record.expenses.fold(0, (sum, expense) => sum + expense.amount);
      double remainingDay = record.totalIncome - expensesTotalDay - employeesTotalDay - record.owner1Withdrawn - record.owner2Withdrawn;

      dailySalesData.add(DailySalesData(
        date: record.date,
        income: record.totalIncome,
        employeesTotal: employeesTotalDay,
        zubairShare: zubairShareDay,
        firasShare: firasShareDay,
        expenses: expensesTotalDay,
        remaining: remainingDay,
      ));
    }

    // ترتيب البيانات حسب التاريخ (من الأحدث إلى الأقدم)
    dailySalesData.sort((a, b) => b.date.compareTo(a.date));
  }

  // حساب حصص الموظفين والمالكين
  void _calculateShares() {
    // حساب إجمالي أجر الموظفين (33% من إجمالي الدخل)
    _employeesTotal = widget.totalIncome * (1 / 3);

    // حساب حصة زبير (50% من الباقي بعد خصم أجر الموظفين)
    _zubairShare = (widget.totalIncome - _employeesTotal);

    // حساب حصة فراس (20% من حصة زبير)
    _firasShare = _zubairShare * 0.2;

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

  // حساب الحد الأقصى المسموح سحبه لكل مالك
  double get _maxZubairWithdrawal => _zubairShare;
  double get _maxFirasWithdrawal => _firasShare;

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

              // جدول المبيعات اليومية لجميع الأيام
              _buildDailySalesTable(),
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
              'ملخص الميزانية - اليوم',
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
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سحب زبير:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_owner1Withdrawn.toStringAsFixed(2)} دينار',
                    style: TextStyle(
                      color: _owner1Withdrawn > _maxZubairWithdrawal ? Colors.red : Colors.purple,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سحب فراس:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_owner2Withdrawn.toStringAsFixed(2)} دينار',
                    style: TextStyle(
                      color: _owner2Withdrawn > _maxFirasWithdrawal ? Colors.red : Colors.purple,
                      fontWeight: FontWeight.bold,
                    )),
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

  Widget _buildDailySalesTable() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل المبيعات اليومية لجميع الأيام',
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
                    label: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: false,
                  ),
                  DataColumn(
                    label: Text('الدخل', style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('أجر الموظفين', style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('حصة زبير', style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('حصة فراس', style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('المصاريف', style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('المتبقي', style: TextStyle(fontWeight: FontWeight.bold)),
                    numeric: true,
                  ),
                ],
                rows: dailySalesData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(DateFormat('yyyy-MM-dd').format(data.date))),
                      DataCell(Text(data.income.toStringAsFixed(2))),
                      DataCell(Text(data.employeesTotal.toStringAsFixed(2))),
                      DataCell(Text(data.zubairShare.toStringAsFixed(2))),
                      DataCell(Text(data.firasShare.toStringAsFixed(2))),
                      DataCell(Text(data.expenses.toStringAsFixed(2))),
                      DataCell(
                        Text(
                          data.remaining.toStringAsFixed(2),
                          style: TextStyle(
                            color: data.remaining >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
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
                // صف زبير
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('زبير:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'الحد الأقصى: ${_maxZubairWithdrawal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          TextField(
                            controller: _owner1Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00 دينار',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              _owner1Withdrawn = double.tryParse(value) ?? 0;
                              setState(() {});
                            },
                          ),
                          SizedBox(height: 4),
                          Text(
                            'المتبقي: ${(_maxZubairWithdrawal - _owner1Withdrawn).toStringAsFixed(2)} دينار',
                            style: TextStyle(
                              color: (_owner1Withdrawn > _maxZubairWithdrawal) ? Colors.red : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // صف فراس
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('فراس:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'الحد الأقصى: ${_maxFirasWithdrawal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          TextField(
                            controller: _owner2Controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '0.00 دينار',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              _owner2Withdrawn = double.tryParse(value) ?? 0;
                              setState(() {});
                            },
                          ),
                          SizedBox(height: 4),
                          Text(
                            'المتبقي: ${(_maxFirasWithdrawal - _owner2Withdrawn).toStringAsFixed(2)} دينار',
                            style: TextStyle(
                              color: (_owner2Withdrawn > _maxFirasWithdrawal) ? Colors.red : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
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
            onPressed: () async {
              // حفظ التغييرات في SharedPreferences
              final prefs = await SharedPreferences.getInstance();

              // حفظ المصاريف
              final expensesJson = _expenses.map((e) => e.toJson()).toList();
              await prefs.setString('expenses', jsonEncode(expensesJson));

              // حفظ السحوبات
              await prefs.setDouble('owner1Withdrawn', _owner1Withdrawn);
              await prefs.setDouble('owner2Withdrawn', _owner2Withdrawn);

              if (mounted) {
                Navigator.pop(context);
              }
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

// نموذج بيانات المبيعات اليومية
class DailySalesData {
  final DateTime date;
  final double income;
  final double employeesTotal;
  final double zubairShare;
  final double firasShare;
  final double expenses;
  final double remaining;

  DailySalesData({
    required this.date,
    required this.income,
    required this.employeesTotal,
    required this.zubairShare,
    required this.firasShare,
    required this.expenses,
    required this.remaining,
  });
}