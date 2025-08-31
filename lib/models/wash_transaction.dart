import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum CarSize { small, medium, large }
enum WashType { external, internal, engine, undercarriage, seats, complete }

class WashTransaction {
  final int transactionNumber;
  final DateTime date;
  final TimeOfDay time;
  final WashType washType;
  final CarSize carSize;
  final String carModel;
  final double price;
  final String notes;

  WashTransaction({
    required this.transactionNumber,
    required this.date,
    required this.time,
    required this.washType,
    required this.carSize,
    required this.carModel,
    required this.price,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'transactionNumber': transactionNumber,
    'date': date.toIso8601String(),
    'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    'washType': washType.index,
    'carSize': carSize.index,
    'carModel': carModel,
    'price': price,
    'notes': notes,
  };

  factory WashTransaction.fromJson(Map<String, dynamic> json) {
    List<String> parts = (json['time'] as String).split(':');
    return WashTransaction(
      transactionNumber: json['transactionNumber'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
      washType: WashType.values[json['washType']],
      carSize: CarSize.values[json['carSize']],
      carModel: json['carModel'],
      price: (json['price'] as num).toDouble(),
      notes: json['notes'],
    );
  }

  // ✅ حفظ قائمة المعاملات في SharedPreferences
  static Future<void> saveTransactionsToPrefs(List<WashTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions.map((t) => t.toJson()).toList();
    await prefs.setString('washTransactions', jsonEncode(transactionsJson));
  }

  // ✅ تحميل قائمة المعاملات من SharedPreferences
  static Future<List<WashTransaction>> loadTransactionsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('washTransactions');
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = jsonDecode(transactionsJson);
      return transactionsList.map((t) => WashTransaction.fromJson(t)).toList();
    }
    return [];
  }

  // ✅ مسح جميع المعاملات من SharedPreferences
  static Future<void> clearTransactionsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('washTransactions');
  }
}

class Employee {
  final String name;
  final double salary;

  Employee({required this.name, required this.salary});

  Map<String, dynamic> toJson() => {
    'name': name,
    'salary': salary,
  };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    name: json['name'],
    salary: (json['salary'] as num).toDouble(),
  );

  // ✅ حفظ قائمة الموظفين في SharedPreferences
  static Future<void> saveEmployeesToPrefs(List<Employee> employees) async {
    final prefs = await SharedPreferences.getInstance();
    final employeesJson = employees.map((e) => e.toJson()).toList();
    await prefs.setString('employees', jsonEncode(employeesJson));
  }

  // ✅ تحميل قائمة الموظفين من SharedPreferences
  static Future<List<Employee>> loadEmployeesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final employeesJson = prefs.getString('employees');
    if (employeesJson != null) {
      final List<dynamic> employeesList = jsonDecode(employeesJson);
      return employeesList.map((e) => Employee.fromJson(e)).toList();
    }
    return [];
  }
}

class Expense {
  final String description;
  final double amount;

  Expense({required this.description, required this.amount});

  Map<String, dynamic> toJson() => {
    'description': description,
    'amount': amount,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    description: json['description'],
    amount: (json['amount'] as num).toDouble(),
  );

  // ✅ حفظ قائمة المصاريف في SharedPreferences
  static Future<void> saveExpensesToPrefs(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = expenses.map((e) => e.toJson()).toList();
    await prefs.setString('expenses', jsonEncode(expensesJson));
  }

  // ✅ تحميل قائمة المصاريف من SharedPreferences
  static Future<List<Expense>> loadExpensesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> expensesList = jsonDecode(expensesJson);
      return expensesList.map((e) => Expense.fromJson(e)).toList();
    }
    return [];
  }

  // ✅ مسح جميع المصاريف من SharedPreferences
  static Future<void> clearExpensesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('expenses');
  }
}

class DailyRecord {
  final DateTime date;
  final double totalIncome;
  final List<Employee> employees;
  final double owner1Share;
  final double owner2Share;
  final List<Expense> expenses;
  final double remainingMoney;
  final double owner1Withdrawn;
  final double owner2Withdrawn;
  final String generalNotes;
  final List<WashTransaction> transactions;

  DailyRecord({
    required this.date,
    required this.totalIncome,
    required this.employees,
    required this.owner1Share,
    required this.owner2Share,
    required this.expenses,
    required this.remainingMoney,
    required this.owner1Withdrawn,
    required this.owner2Withdrawn,
    required this.generalNotes,
    required this.transactions,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalIncome': totalIncome,
    'employees': employees.map((e) => e.toJson()).toList(),
    'owner1Share': owner1Share,
    'owner2Share': owner2Share,
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'remainingMoney': remainingMoney,
    'owner1Withdrawn': owner1Withdrawn,
    'owner2Withdrawn': owner2Withdrawn,
    'generalNotes': generalNotes,
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
    date: DateTime.parse(json['date']),
    totalIncome: (json['totalIncome'] as num).toDouble(),
    employees: (json['employees'] as List)
        .map((e) => Employee.fromJson(e))
        .toList(),
    owner1Share: (json['owner1Share'] as num).toDouble(),
    owner2Share: (json['owner2Share'] as num).toDouble(),
    expenses: (json['expenses'] as List)
        .map((e) => Expense.fromJson(e))
        .toList(),
    remainingMoney: (json['remainingMoney'] as num).toDouble(),
    owner1Withdrawn: (json['owner1Withdrawn'] as num).toDouble(),
    owner2Withdrawn: (json['owner2Withdrawn'] as num).toDouble(),
    generalNotes: json['generalNotes'],
    transactions: (json['transactions'] as List)
        .map((e) => WashTransaction.fromJson(e))
        .toList(),
  );

  // ✅ حفظ قائمة السجلات اليومية في SharedPreferences
  static Future<void> saveDailyRecordsToPrefs(List<DailyRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = records.map((r) => r.toJson()).toList();
    await prefs.setString('dailyRecords', jsonEncode(recordsJson));
  }

  // ✅ تحميل قائمة السجلات اليومية من SharedPreferences
  static Future<List<DailyRecord>> loadDailyRecordsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString('dailyRecords');
    if (recordsJson != null) {
      final List<dynamic> recordsList = jsonDecode(recordsJson);
      return recordsList.map((r) => DailyRecord.fromJson(r)).toList();
    }
    return [];
  }

  // ✅ مسح جميع السجلات اليومية من SharedPreferences
  static Future<void> clearDailyRecordsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dailyRecords');
  }
}

class DailyStatistics {
  final DateTime date;
  final double totalIncome;
  final int totalCars;
  final Map<WashType, int> washTypeCounts;
  final List<Employee> employees;
  final double owner1Share;
  final double owner2Share;
  final List<Expense> expenses;
  final double remainingMoney;
  final double owner1Withdrawn;
  final double owner2Withdrawn;
  final String generalNotes;
  final List<WashTransaction> transactions;

  DailyStatistics({
    required this.date,
    required this.totalIncome,
    required this.totalCars,
    required this.washTypeCounts,
    required this.employees,
    required this.owner1Share,
    required this.owner2Share,
    required this.expenses,
    required this.remainingMoney,
    required this.owner1Withdrawn,
    required this.owner2Withdrawn,
    required this.generalNotes,
    required this.transactions,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalIncome': totalIncome,
    'totalCars': totalCars,
    'washTypeCounts': washTypeCounts.map((key, value) => MapEntry(key.index, value)),
    'employees': employees.map((e) => e.toJson()).toList(),
    'owner1Share': owner1Share,
    'owner2Share': owner2Share,
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'remainingMoney': remainingMoney,
    'owner1Withdrawn': owner1Withdrawn,
    'owner2Withdrawn': owner2Withdrawn,
    'generalNotes': generalNotes,
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };

  factory DailyStatistics.fromJson(Map<String, dynamic> json) => DailyStatistics(
    date: DateTime.parse(json['date']),
    totalIncome: (json['totalIncome'] as num).toDouble(),
    totalCars: json['totalCars'],
    washTypeCounts: (json['washTypeCounts'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(WashType.values[int.parse(key)], value),
    ),
    employees: (json['employees'] as List)
        .map((e) => Employee.fromJson(e))
        .toList(),
    owner1Share: (json['owner1Share'] as num).toDouble(),
    owner2Share: (json['owner2Share'] as num).toDouble(),
    expenses: (json['expenses'] as List)
        .map((e) => Expense.fromJson(e))
        .toList(),
    remainingMoney: (json['remainingMoney'] as num).toDouble(),
    owner1Withdrawn: (json['owner1Withdrawn'] as num).toDouble(),
    owner2Withdrawn: (json['owner2Withdrawn'] as num).toDouble(),
    generalNotes: json['generalNotes'],
    transactions: (json['transactions'] as List)
        .map((e) => WashTransaction.fromJson(e))
        .toList(),
  );

  // ✅ حفظ الإحصائيات اليومية في SharedPreferences
  static Future<void> saveDailyStatisticsToPrefs(List<DailyStatistics> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = stats.map((s) => s.toJson()).toList();
    await prefs.setString('dailyStatistics', jsonEncode(statsJson));
  }

  // ✅ تحميل الإحصائيات اليومية من SharedPreferences
  static Future<List<DailyStatistics>> loadDailyStatisticsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('dailyStatistics');
    if (statsJson != null) {
      final List<dynamic> statsList = jsonDecode(statsJson);
      return statsList.map((s) => DailyStatistics.fromJson(s)).toList();
    }
    return [];
  }
}

// ✅ فائدة مساعدة لحفظ السحوبات
class WithdrawalHelper {
  static Future<void> saveWithdrawalsToPrefs(double owner1Withdrawn, double owner2Withdrawn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('owner1Withdrawn', owner1Withdrawn);
    await prefs.setDouble('owner2Withdrawn', owner2Withdrawn);
  }

  static Future<Map<String, double>> loadWithdrawalsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'owner1Withdrawn': prefs.getDouble('owner1Withdrawn') ?? 0,
      'owner2Withdrawn': prefs.getDouble('owner2Withdrawn') ?? 0,
    };
  }

  static Future<void> clearWithdrawalsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('owner1Withdrawn');
    await prefs.remove('owner2Withdrawn');
  }
}

// ✅ فائدة مساعدة لحفظ عداد المعاملات
class TransactionCounterHelper {
  static Future<void> saveTransactionCounter(int counter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('transactionCounter', counter);
  }

  static Future<int> loadTransactionCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('transactionCounter') ?? 1;
  }

  static Future<void> clearTransactionCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactionCounter');
  }
}