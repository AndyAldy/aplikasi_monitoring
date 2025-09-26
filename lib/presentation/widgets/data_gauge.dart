// lib/presentation/widgets/data_gauge.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_monitoring/core/constants.dart';

class DataGauge extends StatelessWidget {
  final String title;
  final int value; // Nilai persentase 0-100
  final String unit;
  
  const DataGauge({
    required this.title,
    required this.value,
    this.unit = '%',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = value > 60 ? AppColors.accent : AppColors.secondary;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value / 100,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Colors.grey[300],
              color: indicatorColor,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}