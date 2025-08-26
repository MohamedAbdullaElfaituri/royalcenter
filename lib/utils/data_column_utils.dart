import 'package:flutter/material.dart';

DataColumn buildDataColumn(
    String label,
    String columnName, {
      bool isSortable = true,
      void Function(String columnName, bool ascending)? onSort,
    }) {
  return DataColumn(
    label: Text(
      label,
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[900]),
    ),
    onSort: isSortable && onSort != null ? (_, ascending) => onSort(columnName, ascending) : null,
  );
}
