// lib/presentation/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/presentation/widgets/control_tile.dart';
import 'package:aplikasi_monitoring/presentation/widgets/data_gauge.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart'; // Wajib diimpor

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Akses MqttService (digunakan untuk ACTION/publish)
    // listen: false karena kita hanya butuh MqttService untuk memanggil fungsi, bukan membangun UI
    final mqttService = Provider.of<MqttService>(context, listen: false); 
    
    // Gunakan Consumer untuk mendengarkan perubahan pada SensorData
    return Consumer<SensorData>(
      builder: (context, sensorData, child) {
        return Scaffold(
          // ... (AppBar tetap sama) ...
          appBar: AppBar(
            title: const Text('SmartFarm Dashboard', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primary,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  children: [
                    Text(
                      sensorData.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: sensorData.isOnline ? Colors.white : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      sensorData.isOnline ? Icons.wifi_outlined : Icons.wifi_off_outlined,
                      color: sensorData.isOnline ? AppColors.accent : AppColors.error,
                    ),
                  ],
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Status Lahan Saat Ini:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                // --- Visualisasi Kelembapan
                DataGauge(
                  title: 'Kelembapan Tanah',
                  value: sensorData.kelembapan,
                ),
                
                const SizedBox(height: 24),
                const Text(
                  "Kontrol Cepat Aktuator:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                // --- Kontrol Pompa dan lainnya
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    ControlTile(
                      title: 'Pompa Air',
                      icon: Icons.water_drop,
                      isActive: sensorData.isPompaOn,
                      color: AppColors.primary,
                      onTap: () {
                        // Tentukan perintah berdasarkan status saat ini
                        String newCommand = sensorData.isPompaOn ? "OFF" : "ON";
                        
                        // Kirim perintah via MQTT Service
                        mqttService.publishControl(MqttTopics.pompaControl, newCommand);
                      },
                    ),
                    ControlTile(
                      title: 'Lampu Tumbuh',
                      icon: Icons.lightbulb,
                      isActive: false, 
                      color: AppColors.secondary,
                      onTap: () {
                        // Logika kontrol lampu tumbuh
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}