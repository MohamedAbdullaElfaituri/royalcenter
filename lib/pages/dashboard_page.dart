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
import 'package:royalcenter/widgets/budget_tables.dart';
import 'package:royalcenter/widgets/custom_app_bar.dart';
import 'package:royalcenter/widgets/save_dialog_utils.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
  final Color _accentColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    filteredTransactions = List.from(todayTransactions);
    searchController.addListener(_filterTransactions);
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() => _isLoading = false);
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

  void _addTransaction(WashTransaction transaction) {
    setState(() {
      todayTransactions.add(transaction);
      _transactionCounter++;
      _filterTransactions();
    });
  }

  void _printTransaction(WashTransaction transaction) {
    InvoiceService.showArabicPDFInvoice(context, transaction);
  }

  // دالة لحساب إجمالي المصاريف
  double _calculateExpensesTotal() {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  void _openBudgetManagement() async {
    double totalIncome = todayTransactions.fold(0, (sum, transaction) => sum + transaction.price);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetManagementScreen(
          expenses: expenses,
          owner1Withdrawn: owner1Withdrawn,
          owner2Withdrawn: owner2Withdrawn,
          onExpensesChanged: (newExpenses) {
            setState(() {
              expenses = newExpenses;
            });
          },
          onWithdrawalsChanged: (owner1, owner2) {
            setState(() {
              owner1Withdrawn = owner1;
              owner2Withdrawn = owner2;
              owner1WithdrawnController.text = owner1.toStringAsFixed(2);
              owner2WithdrawnController.text = owner2.toStringAsFixed(2);
            });
          },
          totalIncome: totalIncome,
          transactions: todayTransactions,
        ),
      ),
    );
  }

  Future<void> _saveDailyRecord() async {
    if (todayTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد معاملات ليوم اليوم'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    double totalIncome = todayTransactions.fold(0, (sum, transaction) => sum + transaction.price);
    int totalCars = todayTransactions.length;
    double expensesTotal = _calculateExpensesTotal();

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

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'تأكيد الحفظ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // جدول الموازنة
                  BudgetTables.buildBudgetTable(
                    totalIncome,
                    expensesTotal,
                    owner1Withdrawn,
                    owner2Withdrawn,
                    _primaryColor,
                  ),

                  const SizedBox(height: 16),
                  Text(
                    'تفاصيل أنواع الغسيل:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SaveDialogUtils.buildWashTypeItem('خارجي', washTypeCounts[WashType.external]!, Colors.blue, _primaryColor),
                  SaveDialogUtils.buildWashTypeItem('داخلي', washTypeCounts[WashType.internal]!, Colors.green, _primaryColor),
                  SaveDialogUtils.buildWashTypeItem('محرك', washTypeCounts[WashType.engine]!, Colors.orange, _primaryColor),
                  SaveDialogUtils.buildWashTypeItem('سفلي', washTypeCounts[WashType.undercarriage]!, Colors.purple, _primaryColor),
                  SaveDialogUtils.buildWashTypeItem('كراسي', washTypeCounts[WashType.seats]!, Colors.red, _primaryColor),
                  SaveDialogUtils.buildWashTypeItem('كامل', washTypeCounts[WashType.complete]!, _primaryColor, _primaryColor),

                  const SizedBox(height: 20),
                  Text(
                    'هل تريد حفظ سجل اليوم؟',
                    style: TextStyle(
                      color: _secondaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: _secondaryColor),
                          ),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(color: _secondaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() => _isLoading = true);

                            // حساب صافي الدخل وحصص المالكين
                            double netIncome = totalIncome - expensesTotal;
                            double owner1Share = netIncome / 2;
                            double owner2Share = netIncome / 2;

                            // حساب الباقي
                            double remainingMoney = netIncome - (owner1Withdrawn + owner2Withdrawn);

                            await Future.delayed(Duration(milliseconds: 800));

                            setState(() {
                              dailyRecords.add(DailyRecord(
                                date: DateTime.now(),
                                totalIncome: totalIncome,
                                employees: [],
                                owner1Share: owner1Share,
                                owner2Share: owner2Share,
                                expenses: List.from(expenses),
                                remainingMoney: remainingMoney,
                                owner1Withdrawn: owner1Withdrawn,
                                owner2Withdrawn: owner2Withdrawn,
                                generalNotes: '',
                                transactions: List.from(todayTransactions),
                              ));

                              // حفظ الإحصائيات
                              DailyStatistics stats = DailyStatistics(
                                date: DateTime.now(),
                                totalIncome: totalIncome,
                                totalCars: totalCars,
                                washTypeCounts: Map.from(washTypeCounts),
                                employees: [],
                                owner1Share: owner1Share,
                                owner2Share: owner2Share,
                                expenses: List.from(expenses),
                                remainingMoney: remainingMoney,
                                owner1Withdrawn: owner1Withdrawn,
                                owner2Withdrawn: owner2Withdrawn,
                                generalNotes: '',
                                transactions: List.from(todayTransactions),
                              );

                              dailyStatistics.add(stats);

                              // إعادة تعيين البيانات
                              todayTransactions.clear();
                              expenses.clear();
                              owner1Withdrawn = 0;
                              owner2Withdrawn = 0;
                              owner1WithdrawnController.clear();
                              owner2WithdrawnController.clear();
                              _transactionCounter = 1;
                              _filterTransactions();
                              _isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم حفظ سجل اليوم بنجاح'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('تأكيد الحفظ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      onClear: () {
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
          onSave: _saveDailyRecord,
          onClear: _clearAllTransactions,
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
            await _loadInitialData();
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

  // بناء أزرار الفعل العائمة
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

  // بناء قسم البحث والتصفية
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

  // بناء محتوى المعاملات
  Widget _buildTransactionsContent() {
    return todayTransactions.isEmpty
        ? _buildEmptyState()
        : TransactionsTable(
      transactions: filteredTransactions,
      sortColumn: sortColumn,
      sortAscending: sortAscending,
      onDelete: (transaction) {
        setState(() {
          todayTransactions.remove(transaction);
          _filterTransactions();
        });
      },
      onPrint: _printTransaction,
    );
  }

  // بناء واجهة الحالة الفارغة
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