import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/presentation/pages/dashboard.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';

void main() {
  // Inisialisasi Service dan sambungkan MQTT
  final mqttService = MqttService();
  mqttService.connect();
  
  runApp(
    // Menggunakan ChangeNotifierProvider untuk SensorData
    ChangeNotifierProvider(
      create: (context) => SensorData(),
      child: const SmartFarmApp(),
    ),
  );
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farm IoT',
      theme: ThemeData(
        primarySwatch: const MaterialColor(
          0xFF006A4E,
          <int, Color>{
            50: Color(0xFFE0EAE7), 100: Color(0xFFB3CDB9), 200: Color(0xFF80AB8B), 300: Color(0xFF4D895D),
            400: Color(0xFF266E43), 500: Color(0xFF006A4E), 600: Color(0xFF005E46), 700: Color(0xFF00503D),
            800: Color(0xFF004334), 900: Color(0xFF003024),
          },
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}