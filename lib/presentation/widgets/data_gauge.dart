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
    // Tentukan warna indikator berdasarkan nilai
    final Color indicatorColor = value > 60 ? AppColors.accent : AppColors.secondary;
    
    // Tentukan nilai tampilan dan progres bar
    final displayValue = value == 0 ? '--' : '$value';
    final progressValue = value == 0 ? 0.0 : value / 100;
    
    // Teks keterangan saat nilai nol
    final detailText = value == 0 
      ? 'Menunggu data...' 
      : (value < 30 ? 'Kering' : (value > 70 ? 'Basah' : 'Normal'));

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
              value: progressValue,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Colors.grey[300],
              color: indicatorColor,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Diubah menjadi spaceBetween
              children: [
                Text(
                  detailText,
                  style: TextStyle(fontSize: 14, color: value == 0 ? Colors.grey : Colors.black87),
                ),
                Row(
                  children: [
                    Text(
                      displayValue,
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
