import 'package:flutter/material.dart';
import 'package:aplikasi_monitoring/core/constants.dart';

class DataGauge extends StatelessWidget {
  final String title;
  final int value;
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
    
    // --- LOGIKA TEKS DETAIL BARU ---
    String detailText;
    if (title == 'Kelembapan Tanah') {
      detailText = value < 30 ? 'Kering' : (value > 70 ? 'Basah' : 'Normal');
    } else { // Asumsi untuk Intensitas Cahaya
      detailText = value < 30 ? 'Gelap' : (value > 70 ? 'Sangat Terang' : 'Normal');
    }
    // --------------------------------

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  detailText,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Row(
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
          ],
        ),
      ),
    );
  }
}