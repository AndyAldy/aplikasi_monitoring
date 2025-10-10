import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aplikasi_monitoring/firebase_options.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';
import 'package:aplikasi_monitoring/services/notif.dart';
import 'package:aplikasi_monitoring/services/auth_service.dart';
import 'package:aplikasi_monitoring/services/auth_gate.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final notificationService = NotificationService();
  await notificationService.init();

  await initializeDateFormatting('id_ID', null);
  
  final sensorData = SensorData();
  final authService = AuthService();
  final mqttService = MqttService(
    sensorData: sensorData,
    notificationService: notificationService,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sensorData),
        Provider<MqttService>.value(value: mqttService),
        // **SINKRONISASI**: Daftarkan AuthService di sini
        Provider<AuthService>.value(value: authService), 
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
      home: const AuthGate(),
    );
  }
}