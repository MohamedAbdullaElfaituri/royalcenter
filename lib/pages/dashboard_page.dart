import 'package:flutter/material.dart';
import 'package:royalcenter/models/wash_transaction.dart';
import 'package:royalcenter/utils/add_transaction_dialog.dart';
import 'package:royalcenter/utils/car_size_utils.dart';
import 'package:royalcenter/utils/clear_transactions_dialog.dart';
import 'package:royalcenter/utils/fatura.dart';
import 'package:royalcenter/utils/filter_dialog_utils.dart';
import 'package:royalcenter/utils/statistics_card.dart';
import 'package:royalcenter/utils/transactions_table.dart';
import 'package:royalcenter/utils/wash_type_utils.dart';
import 'package:royalcenter/widgets/custom_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DailyRecord> dailyRecords = [];
  List<WashTransaction> todayTransactions = [];
  List<WashTransaction> filteredTransactions = [];
  TextEditingController searchController = TextEditingController();
  String sortColumn = 'date';
  bool sortAscending = true;
  bool _isLoading = false;
  int _transactionCounter = 1;

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
    showArabicPDFInvoice(context, transaction);
  }


  Future<void> _saveDailyRecord() async {
    if (todayTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد معاملات ليوم اليوم'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double totalIncome = todayTransactions.fold(0, (sum, transaction) => sum + transaction.price);
    int totalCars = todayTransactions.length;

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
        child: AlertDialog(
          title: Center(child: Text('تأكيد الحفظ', style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إجمالي الدخل: ${totalIncome.toStringAsFixed(2)} دينار'),
              Text('عدد السيارات: $totalCars'),
              SizedBox(height: 10),
              Text('تفاصيل أنواع الغسيل:'),
              Text('- خارجي: ${washTypeCounts[WashType.external]}'),
              Text('- داخلي: ${washTypeCounts[WashType.internal]}'),
              Text('- محرك: ${washTypeCounts[WashType.engine]}'),
              Text('- سفلي: ${washTypeCounts[WashType.undercarriage]}'),
              Text('- كراسي: ${washTypeCounts[WashType.seats]}'),
              Text('- كامل: ${washTypeCounts[WashType.complete]}'),
              SizedBox(height: 10),
              Text('هل تريد حفظ سجل اليوم؟'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);

                await Future.delayed(Duration(milliseconds: 800));

                setState(() {
                  dailyRecords.add(DailyRecord(
                    date: DateTime.now(),
                    totalIncome: totalIncome,
                    employees: [],
                    owner1Share: 0,
                    owner2Share: 0,
                    expenses: [],
                    remainingMoney: totalIncome,
                    owner1Withdrawn: 0,
                    owner2Withdrawn: 0,
                    generalNotes: '',
                    transactions: List.from(todayTransactions),
                  ));

                  todayTransactions.clear();
                  _transactionCounter = 1;
                  _filterTransactions();
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حفظ سجل اليوم بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('تأكيد الحفظ'),
            ),
          ],
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
          _transactionCounter = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم مسح جميع المعاملات'),
            backgroundColor: Colors.green,
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
        appBar: CustomAppBar(
          hasTransactions: todayTransactions.isNotEmpty,
          onSave: _saveDailyRecord,
          onClear: _clearAllTransactions,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTransactionDialog,
          child: Icon(Icons.add),
          backgroundColor: Colors.teal[700],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            if (todayTransactions.isNotEmpty)
              StatisticsCard(
                transactionCount: todayTransactions.length,
                totalIncome: totalIncome,
                washTypeCounts: washTypeCounts,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث في معاملات اليوم...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  if (todayTransactions.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.filter_list),
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
            Expanded(
              child: todayTransactions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_car_wash, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'لا توجد معاملات حتى الآن',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'انقر على زر (+) لإضافة معاملة جديدة',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
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
                onPrint: (transaction) {
                  _printTransaction(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}