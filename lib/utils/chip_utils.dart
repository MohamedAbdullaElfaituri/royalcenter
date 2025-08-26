import 'package:flutter/material.dart';

Widget buildWashTypeChip(String label, int count, Color color) {
  return Chip(
    label: Text('$label: $count'),
    backgroundColor: color.withOpacity(0.2),
    labelStyle: TextStyle(color: color),
    avatar: CircleAvatar(
      backgroundColor: color,
      child: Text(
        count.toString(),
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
    ),
  );
}
