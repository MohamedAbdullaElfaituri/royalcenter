import 'package:flutter/material.dart';

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
}

// نموذج بيانات الموظف
class Employee {
  final String name;
  final double salary;

  Employee({required this.name, required this.salary});
}

// نموذج بيانات المصاريف
class Expense {
  final String description;
  final double amount;

  Expense({required this.description, required this.amount});
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
}

// نموذج بيانات الإحصائيات اليومية
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
}