// lib/presentation/pages/dashboard.dart (VERSI FINAL YANG BENAR)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/presentation/widgets/control_tile.dart';
import 'package:aplikasi_monitoring/presentation/widgets/data_gauge.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Akses MqttService dengan listen: false karena kita hanya butuh fungsinya
    final mqttService = Provider.of<MqttService>(context, listen: false); 
    
    // Consumer digunakan untuk membaca data SensorData
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
                // ================== DATA SENSOR ===================
                const Text(
                  "Status Sensor Saat Ini:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                
                DataGauge(
                  title: 'Kelembapan Tanah',
                  value: sensorData.kelembapan,
                ),
                const SizedBox(height: 10),
                
                DataGauge(
                  title: 'Intensitas Cahaya',
                  value: sensorData.cahaya,
                  unit: ' lx',
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          sensorData.isHujan ? Icons.grain : Icons.wb_sunny,
                          size: 30,
                          color: sensorData.isHujan ? Colors.blue : AppColors.secondary,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Status Hujan: ${sensorData.isHujan ? "Hujan" : "Kering"}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "Fast Control from Home:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    // TILE 1: Pompa Air (Kontrol ON/OFF)
                    ControlTile(
                      title: 'Pompa Air',
                      icon: Icons.water_drop,
                      isActive: sensorData.isPompaOn,
                      color: AppColors.primary,
                      onTap: () {
                        // Akses state saat ini melalui sensorData
                        String newCommand = sensorData.isPompaOn ? "OFF" : "ON";
                        // Kirim perintah via MqttService
                        mqttService.publishControl(MqttTopics.pompaControl, newCommand);
                      },
                    ),
                    
                    // TILE 2: Mode Otomatis
                    ControlTile(
                      title: 'Mode Otomatis',
                      icon: Icons.auto_mode,
                      isActive: !sensorData.isManualMode, // TRUE jika mode OTOMATIS
                      color: AppColors.accent,
                      onTap: () {
                        // Akses state saat ini
                        String newMode = sensorData.isManualMode ? "OTOMATIS" : "MANUAL";
                        // Kirim perintah via MqttService
                        mqttService.publishControl(MqttTopics.mode, newMode);
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