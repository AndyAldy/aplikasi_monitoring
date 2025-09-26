// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Wajib diimpor
// Wajib: Import file yang dibuat oleh flutterfire configure
import 'package:aplikasi_monitoring/firebase_options.dart'; 

import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/presentation/pages/dashboard.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';

void main() async { 
  // 1. Wajib: Memastikan binding widget sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized(); 

  // 2. Wajib: Inisialisasi Firebase menggunakan options dari file yang di-generate
  // Kegagalan di sini adalah penyebab utama hang/stuck.
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, 
    );
  } catch (e) {
    // Tambahkan log untuk melihat error yang tersembunyi
    print("FATAL FIREBASE INIT ERROR: $e"); 
    // Jika gagal, pastikan aplikasi tetap berjalan (opsional, tapi disarankan)
  }

  // 3. Inisialisasi Model dan Service
  final sensorData = SensorData();
  final mqttService = MqttService(sensorData: sensorData);

  // Sambungkan MQTT (tidak perlu await, jalankan di background)
  mqttService.connect(); 
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sensorData),
        Provider<MqttService>.value(value: mqttService), 
      ],
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