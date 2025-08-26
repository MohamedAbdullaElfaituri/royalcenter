// wash_transaction.dart
import 'package:flutter/material.dart';

enum WashType {
  external,
  internal,
  engine,
  undercarriage,
  seats,
  complete
}

enum CarSize {
  small,
  medium,
  large
}

class WashTransaction {
  final int transactionNumber; // Kaçıncı işlem
  final DateTime date; // Tarih
  final TimeOfDay time; // Saat
  final WashType washType; // İşlemin türü
  final CarSize carSize; // Arabanın büyüklüğü
  final String carModel; // Arabanın modeli
  final double price; // Fiyat (kullanıcı girecek)
  final String notes; // Notlar

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

// daily_record.dart
class Employee {
  final String name;
  double earnedMoney;

  Employee({required this.name, this.earnedMoney = 0});
}

class Expense {
  final double amount;
  final String description;
  final DateTime date;

  Expense({
    required this.amount,
    required this.description,
    required this.date,
  });
}

class DailyRecord {
  final DateTime date;
  final double totalIncome; // Toplam elde edilen para
  final List<Employee> employees; // Çalışanlar
  final double owner1Share; // 1. patron payı
  final double owner2Share; // 2. patron payı
  final List<Expense> expenses; // Harcamalar
  final double remainingMoney; // Kalan para
  final double owner1Withdrawn; // 1. patron çektiği miktar
  final double owner2Withdrawn; // 2. patron çektiği miktar
  final String generalNotes; // Genel notlar (neler alındı, para nereye harcandı)
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

  // Toplam harcamayı hesaplayan yardımcı metod
  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }
}