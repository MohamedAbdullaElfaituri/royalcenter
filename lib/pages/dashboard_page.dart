import 'package:flutter/material.dart';
import '../models/wash_transaction.dart';
import '../utils/car_size_utils.dart';
import '../utils/chip_utils.dart';
import '../utils/data_column_utils.dart';
import '../utils/dialog_utils.dart';
import '../utils/filter_dialog_utils.dart';
import '../utils/sort_utils.dart';
import '../utils/wash_type_utils.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<DailyRecord> dailyRecords = [];
  List<WashTransaction> todayTransactions = [];
  List<WashTransaction> filteredTransactions = [];
  TextEditingController searchController = TextEditingController();
  String sortColumn = 'date';
  bool sortAscending = true;
  bool _isLoading = false;
  int _transactionCounter = 1; // عداد لرقم المعاملة

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    filteredTransactions = List.from(todayTransactions);
    searchController.addListener(_filterTransactions);
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    // محاكاة تحميل البيانات
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
      _transactionCounter++; // زيادة عداد المعاملات
      _filterTransactions();
    });
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

    // حساب عدد كل نوع غسيل
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

                // محاكاة عملية الحفظ
                await Future.delayed(Duration(milliseconds: 800));

                setState(() {
                  dailyRecords.add(DailyRecord(
                    date: DateTime.now(),
                    totalIncome: totalIncome,
                    employees: [], // سيتم إضافة الموظفين لاحقاً
                    owner1Share: 0, // سيتم حسابها لاحقاً
                    owner2Share: 0, // سيتم حسابها لاحقاً
                    expenses: [], // سيتم إضافة المصروفات لاحقاً
                    remainingMoney: totalIncome, // سيتم حسابها لاحقاً
                    owner1Withdrawn: 0, // سيتم إضافتها لاحقاً
                    owner2Withdrawn: 0, // سيتم إضافتها لاحقاً
                    generalNotes: '', // سيتم إضافتها لاحقاً
                    transactions: List.from(todayTransactions),
                  ));

                  todayTransactions.clear();
                  _transactionCounter = 1; // إعادة تعيين العداد
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
    WashType selectedWashType = WashType.external;
    CarSize selectedCarSize = CarSize.medium;
    TextEditingController carModelController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController notesController = TextEditingController();

    // حساب السعر المقترح بناءً على النوع والحجم
    double suggestedPrice = _getSuggestedPrice(selectedWashType, selectedCarSize);

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text('إضافة معاملة غسيل',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[700])),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('رقم المعاملة: $_transactionCounter',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    DropdownButtonFormField<WashType>(
                      value: selectedWashType,
                      decoration: InputDecoration(
                        labelText: 'نوع الغسيل',
                        prefixIcon: Icon(Icons.local_car_wash, color: Colors.teal),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: WashType.external,
                          child: Text('غسيل خارجي'),
                        ),
                        DropdownMenuItem(
                          value: WashType.internal,
                          child: Text('غسيل داخلي'),
                        ),
                        DropdownMenuItem(
                          value: WashType.engine,
                          child: Text('غسيل محرك'),
                        ),
                        DropdownMenuItem(
                          value: WashType.undercarriage,
                          child: Text('غسيل سفلي'),
                        ),
                        DropdownMenuItem(
                          value: WashType.seats,
                          child: Text('غسيل كراسي'),
                        ),
                        DropdownMenuItem(
                          value: WashType.complete,
                          child: Text('غسيل كامل'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedWashType = value!;
                          suggestedPrice = _getSuggestedPrice(selectedWashType, selectedCarSize);
                          priceController.text = suggestedPrice.toStringAsFixed(2);
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<CarSize>(
                      value: selectedCarSize,
                      decoration: InputDecoration(
                        labelText: 'حجم السيارة',
                        prefixIcon: Icon(Icons.directions_car, color: Colors.teal),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: CarSize.small,
                          child: Text('صغير'),
                        ),
                        DropdownMenuItem(
                          value: CarSize.medium,
                          child: Text('وسط'),
                        ),
                        DropdownMenuItem(
                          value: CarSize.large,
                          child: Text('كبير'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCarSize = value!;
                          suggestedPrice = _getSuggestedPrice(selectedWashType, selectedCarSize);
                          priceController.text = suggestedPrice.toStringAsFixed(2);
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: carModelController,
                      decoration: InputDecoration(
                        labelText: 'موديل السيارة (اختياري)',
                        prefixIcon: Icon(Icons.description, color: Colors.teal),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'السعر',
                        prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        // تحديث السعر عند التغيير
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        prefixIcon: Icon(Icons.note, color: Colors.teal),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 15),
                    Card(
                      color: Colors.teal[50],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('السعر المقترح:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${suggestedPrice.toStringAsFixed(2)} دينار',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[700])),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    double price = double.tryParse(priceController.text) ?? suggestedPrice;

                    _addTransaction(WashTransaction(
                      transactionNumber: _transactionCounter,
                      date: DateTime.now(),
                      time: TimeOfDay.now(),
                      washType: selectedWashType,
                      carSize: selectedCarSize,
                      carModel: carModelController.text,
                      price: price,
                      notes: notesController.text,
                    ));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة المعاملة بنجاح'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text('إضافة'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _getSuggestedPrice(WashType washType, CarSize carSize) {
    switch (washType) {
      case WashType.internal:
        switch (carSize) {
          case CarSize.medium: return 15.0;
          case CarSize.large: return 20.0;
          default: return 15.0;
        }
      case WashType.external:
        switch (carSize) {
          case CarSize.medium: return 15.0;
          case CarSize.large: return 20.0;
          default: return 10.0;
        }
      case WashType.complete:
        switch (carSize) {
          case CarSize.medium: return 30.0;
          case CarSize.large: return 40.0;
          default: return 30.0;
        }
      case WashType.engine: return 15.0;
      case WashType.undercarriage: return 15.0;
      case WashType.seats: return 80.0;
      default: return 15.0;
    }
  }

  void _clearAllTransactions() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تأكيد المسح'),
          content: Text('هل أنت متأكد من رغبتك في مسح جميع معاملات اليوم؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  todayTransactions.clear();
                  filteredTransactions.clear();
                  _transactionCounter = 1; // إعادة تعيين العداد
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم مسح جميع المعاملات'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('تأكيد المسح'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalIncome = todayTransactions.fold(0, (sum, transaction) => sum + transaction.price);

    // حساب عدد كل نوع غسيل
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
        appBar: AppBar(
          title: Text('نظام غسيل السيارات', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.teal[700],
          actions: [
            if (todayTransactions.isNotEmpty) ...[
              IconButton(
                icon: Icon(Icons.save),
                onPressed: _saveDailyRecord,
                tooltip: 'حفظ السجل اليومي',
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: _clearAllTransactions,
                tooltip: 'مسح جميع المعاملات',
              ),
            ],
          ],
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
            // إحصائيات سريعة
            if (todayTransactions.isNotEmpty)
              Card(
                margin: EdgeInsets.all(12),
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text('إحصائيات اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('عدد المعاملات', style: TextStyle(fontSize: 14)),
                              Text(todayTransactions.length.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('إجمالي الدخل', style: TextStyle(fontSize: 14)),
                              Text('${totalIncome.toStringAsFixed(2)} دينار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[700])),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          buildWashTypeChip('خارجي', washTypeCounts[WashType.external]!, Colors.blue),
                          buildWashTypeChip('داخلي', washTypeCounts[WashType.internal]!, Colors.green),
                          buildWashTypeChip('محرك', washTypeCounts[WashType.engine]!, Colors.orange),
                          buildWashTypeChip('سفلي', washTypeCounts[WashType.undercarriage]!, Colors.brown),
                          buildWashTypeChip('كراسي', washTypeCounts[WashType.seats]!, Colors.pink),
                          buildWashTypeChip('كامل', washTypeCounts[WashType.complete]!, Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
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
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                    dataRowColor: MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.selected)
                          ? Colors.teal.withOpacity(0.2)
                          : Colors.grey.shade50;
                    }),
                    columnSpacing: 16,
                    sortColumnIndex: getSortColumnIndex('carSize'),
                    sortAscending: sortAscending,
                    columns: [
                      buildDataColumn('م', 'index'),
                      buildDataColumn('الوقت', 'time'),
                      buildDataColumn('نوع الغسيل', 'washType'),
                      buildDataColumn('حجم السيارة', 'carSize'),
                      buildDataColumn('الموديل', 'model'),
                      buildDataColumn('السعر', 'price'),
                      buildDataColumn('ملاحظات', 'notes', isSortable: false),
                      buildDataColumn('الإجراءات', 'actions', isSortable: false),
                    ],
                    rows: filteredTransactions.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      WashTransaction transaction = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(transaction.transactionNumber.toString())),
                          DataCell(Text("${transaction.time.hour}:${transaction.time.minute.toString().padLeft(2, '0')}")),
                          DataCell(Text(getWashTypeName(transaction.washType))),
                          DataCell(Text(getCarSizeName(transaction.carSize))),
                          DataCell(Text(transaction.carModel.isNotEmpty ? transaction.carModel : '-')),
                          DataCell(Text('${transaction.price.toStringAsFixed(2)} دينار')),
                          DataCell(
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 150),
                              child: Text(
                                transaction.notes.isNotEmpty ? transaction.notes : '-',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDeleteTransactionDialog
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}