import 'package:flutter/material.dart';

DataColumn buildDataColumn(
    String label,
    String columnName, {
      bool isSortable = true,
      void Function(String columnName, bool ascending)? onSort,
    }) {
  final Color primaryColor = Colors.teal;
  final Color secondaryColor = Colors.blueGrey;

  return DataColumn(
    label: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          if (isSortable) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.sort,
              size: 16,
              color: primaryColor.withOpacity(0.6),
            ),
          ],
        ],
      ),
    ),
    onSort: isSortable && onSort != null
        ? (_, ascending) => onSort(columnName, ascending)
        : null,
  );
}

// Alternatif modern versiyon with hover effects:
DataColumn buildModernDataColumn(
    String label,
    String columnName, {
      bool isSortable = true,
      void Function(String columnName, bool ascending)? onSort,
      bool isCurrentlySorted = false,
      bool isAscending = true,
    }) {
  final Color primaryColor = Colors.teal;
  final Color accentColor = isCurrentlySorted ? primaryColor : Colors.blueGrey;

  return DataColumn(
    label: MouseRegion(
      cursor: isSortable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentlySorted
              ? primaryColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isCurrentlySorted
              ? Border.all(color: primaryColor.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentlySorted ? primaryColor : Colors.blueGrey[700],
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
            if (isSortable) ...[
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isCurrentlySorted
                    ? Icon(
                  isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: primaryColor,
                  key: ValueKey(isAscending ? 'asc' : 'desc'),
                )
                    : Icon(
                  Icons.unfold_more,
                  size: 16,
                  color: Colors.blueGrey[400],
                  key: const Key('unsorted'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    onSort: isSortable && onSort != null
        ? (_, ascending) => onSort(columnName, ascending)
        : null,
  );
}

// Minimal version for compact tables:
DataColumn buildMinimalDataColumn(
    String label,
    String columnName, {
      bool isSortable = true,
      void Function(String columnName, bool ascending)? onSort,
    }) {
  final Color primaryColor = Colors.teal;

  return DataColumn(
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: primaryColor,
          fontSize: 12,
        ),
      ),
    ),
    onSort: isSortable && onSort != null
        ? (_, ascending) => onSort(columnName, ascending)
        : null,
  );
}