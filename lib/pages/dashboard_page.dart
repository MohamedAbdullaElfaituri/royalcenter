import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import 'package:royalcenter/pages/budget_management_screen.dart';
import 'package:royalcenter/services/invoice_service.dart';
import 'package:royalcenter/utils/add_transaction_dialog.dart';
import 'package:royalcenter/utils/car_size_utils.dart';
import 'package:royalcenter/utils/clear_transactions_dialog.dart';
import 'package:royalcenter/utils/filter_dialog_utils.dart';
import 'package:royalcenter/utils/statistics_card.dart';
import 'package:royalcenter/utils/transactions_table.dart';
import 'package:royalcenter/utils/wash_type_utils.dart';
import 'package:royalcenter/widgets/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
  const DashboardPage({super.key, required this.onLogout});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<DailyRecord> dailyRecords = [];
  List<DailyStatistics> dailyStatistics = [];
  List<WashTransaction> todayTransactions = [];
  List<WashTransaction> filteredTransactions = [];
  TextEditingController searchController = TextEditingController();
  String sortColumn = 'date';
  bool sortAscending = true;
  bool _isLoading = false;
  int _transactionCounter = 1;

  // متغيرات جديدة لحفظ بيانات السحب والمصاريف
  double owner1Withdrawn = 0;
  double owner2Withdrawn = 0;
  List<Expense> expenses = [];
  TextEditingController expenseDescriptionController = TextEditingController();
  TextEditingController expenseAmountController = TextEditingController();
  TextEditingController owner1WithdrawnController = TextEditingController();
  TextEditingController owner2WithdrawnController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final Color _primaryColor = Colors.teal;
  final Color _secondaryColor = Colors.blueGrey;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    searchController.addListener(_filterTransactions);
  }

  // تحميل جميع البيانات المحفوظة
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    // تحميل المعاملات
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsJson);
      setState(() {
        todayTransactions = transactionsList.map((e) => WashTransaction.fromJson(e)).toList();
      });
    }

    // تحميل عداد المعاملات
    _transactionCounter = prefs.getInt('transactionCounter') ?? 1;

    // تحميل المصاريف
    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> expensesList = jsonDecode(expensesJson);
      setState(() {
        expenses = expensesList.map((e) => Expense.fromJson(e)).toList();
      });
    }

    // تحميل السحوبات
    setState(() {
      owner1Withdrawn = prefs.getDouble('owner1Withdrawn') ?? 0;
      owner2Withdrawn = prefs.getDouble('owner2Withdrawn') ?? 0;
      owner1WithdrawnController.text = owner1Withdrawn.toStringAsFixed(2);
      owner2WithdrawnController.text = owner2Withdrawn.toStringAsFixed(2);
    });

    // تحديث القائمة المصفاة
    filteredTransactions = List.from(todayTransactions);
    _sortTransactions();

    setState(() => _isLoading = false);
  }

  // حفظ جميع البيانات
  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();

    // حفظ المعاملات
    final transactionsJson = todayTransactions.map((e) => e.toJson()).toList();
    await prefs.setString('transactions', jsonEncode(transactionsJson));

    // حفظ عداد المعاملات
    await prefs.setInt('transactionCounter', _transactionCounter);

    // حفظ المصاريف
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString('expenses', jsonEncode(expensesJson));

    // حفظ السحوبات
    await prefs.setDouble('owner1Withdrawn', owner1Withdrawn);
    await prefs.setDouble('owner2Withdrawn', owner2Withdrawn);
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    expenseDescriptionController.dispose();
    expenseAmountController.dispose();
    owner1WithdrawnController.dispose();
    owner2WithdrawnController.dispose();
    super.dispose();
  }

  void _filterTransactions() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredTransactions = List.from(todayTransactions);
      } else {
        filteredTransactions = todayTransactions.where((transaction) {
          return transaction.date.toString().toLowerCase().contains(query) ||
              getCarSizeName(transaction.carSize).toLowerCase().contains(query) ||
              transaction.carModel.toLowerCase().contains(query) ||
              getWashTypeName(transaction.washType).toLowerCase().contains(query);
        }).toList();
      }
      _sortTransactions();
    });
  }

  void _sortTransactions() {
    filteredTransactions.sort((a, b) {
      int comparison;
      switch (sortColumn) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'time':
          comparison = a.time.hour * 60 + a.time.minute
              .compareTo(b.time.hour * 60 + b.time.minute);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'carSize':
          comparison = a.carSize.index.compareTo(b.carSize.index);
          break;
        case 'washType':
          comparison = a.washType.index.compareTo(b.washType.index);
          break;
        default:
          comparison = 0;
      }
      return sortAscending ? comparison : -comparison;
    });
  }

  void _onSort(String column, bool ascending) {
    setState(() {
      sortColumn = column;
      sortAscending = ascending;
      _sortTransactions();
    });
  }

  _addTransaction(WashTransaction transaction) async {
    setState(() {
      todayTransactions.add(transaction);
      _transactionCounter++;
      _filterTransactions();
    });

    // حفظ جميع البيانات بعد إضافة معاملة جديدة
    await _saveAllData();
  }

  void _printTransaction(WashTransaction transaction) {
    InvoiceService.showArabicPDFInvoice(context, transaction);
  }

  void _openBudgetManagement() async {
    double totalIncome = todayTransactions.fold(0, (sum, transaction) => sum + transaction.price);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetManagementScreen(
          dailyRecords: dailyRecords,
          expenses: expenses,
          owner1Withdrawn: owner1Withdrawn,
          owner2Withdrawn: owner2Withdrawn,
          onExpensesChanged: (newExpenses) {
            setState(() {
              expenses = newExpenses;
              _saveAllData(); // حفظ جميع البيانات بعد التغيير
            });
          },
          onWithdrawalsChanged: (owner1, owner2) {
            setState(() {
              owner1Withdrawn = owner1;
              owner2Withdrawn = owner2;
              owner1WithdrawnController.text = owner1.toStringAsFixed(2);
              owner2WithdrawnController.text = owner2.toStringAsFixed(2);
              _saveAllData(); // حفظ جميع البيانات بعد التغيير
            });
          },
          totalIncome: totalIncome,
          transactions: todayTransactions,
        ),
      ),
    );
  }

  void _showAddTransactionDialog() {
    showAddTransactionDialog(
      context: context,
      transactionCounter: _transactionCounter,
      onAddTransaction: _addTransaction,
    );
  }

  void _clearAllTransactions() {
    showClearAllTransactionsDialog(
      context: context,
      onClear: () async {
        setState(() {
          todayTransactions.clear();
          filteredTransactions.clear();
          expenses.clear();
          owner1Withdrawn = 0;
          owner2Withdrawn = 0;
          owner1WithdrawnController.clear();
          owner2WithdrawnController.clear();
          _transactionCounter = 1;
        });

        // مسح جميع البيانات المحفوظة
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('transactions');
        await prefs.remove('transactionCounter');
        await prefs.remove('expenses');
        await prefs.remove('owner1Withdrawn');
        await prefs.remove('owner2Withdrawn');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم مسح جميع المعاملات والمصاريف'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  // دالة تسجيل الخروج
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = todayTransactions.fold(0, (sum, transaction) => sum + transaction.price);

    Map<WashType, int> washTypeCounts = {
      WashType.external: 0,
      WashType.internal: 0,
      WashType.engine: 0,
      WashType.undercarriage: 0,
      WashType.seats: 0,
      WashType.complete: 0,
    };

    for (var transaction in todayTransactions) {
      washTypeCounts[transaction.washType] = washTypeCounts[transaction.washType]! + 1;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          hasTransactions: todayTransactions.isNotEmpty,
          onClear: _clearAllTransactions,
          onLogout: _logout,
        ),
        floatingActionButton: _buildFloatingActionButtons(),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: _primaryColor,
            strokeWidth: 3,
          ),
        )
            : RefreshIndicator(
          color: _primaryColor,
          onRefresh: () async {
            await _loadAllData();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                if (todayTransactions.isNotEmpty)
                  StatisticsCard(
                    transactionCount: todayTransactions.length,
                    totalIncome: totalIncome,
                    washTypeCounts: washTypeCounts,
                  ),
                _buildSearchAndFilterSection(),
                _buildTransactionsContent(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (todayTransactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton.extended(
              onPressed: _openBudgetManagement,
              icon: Icon(Icons.account_balance_wallet, size: 24),
              label: Text('إدارة الميزانية'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        FloatingActionButton(
          heroTag: 'add_transaction',
          onPressed: _showAddTransactionDialog,
          child: Icon(Icons.add, size: 28),
          backgroundColor: _primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث في معاملات اليوم...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.search, color: _primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: TextStyle(color: _secondaryColor),
                ),
              ),
              if (todayTransactions.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.filter_list, color: _primaryColor),
                  tooltip: 'خيارات التصفية والترتيب',
                  onPressed: () {
                    showFilterOptionsDialog(
                      context: context,
                      sortColumn: sortColumn,
                      sortAscending: sortAscending,
                      onSort: _onSort,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsContent() {
    return todayTransactions.isEmpty
        ? _buildEmptyState()
        : TransactionsTable(
      transactions: filteredTransactions,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      onDelete: (transaction) async {
        setState(() {
          todayTransactions.remove(transaction);
          _filterTransactions();
        });
        // حفظ البيانات بعد الحذف
        await _saveAllData();
      },
      onPrint: _printTransaction,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_car_wash,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد معاملات حتى الآن',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'انقر على زر (+) لإضافة معاملة جديدة',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}