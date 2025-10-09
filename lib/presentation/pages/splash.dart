import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/presentation/pages/dashboard.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initializeAppAndData();
  }

  // Fungsi yang menangani semua operasi asinkron
  Future<void> _initializeAppAndData() async {
    Provider.of<SensorData>(context, listen: false);
    final mqttService = Provider.of<MqttService>(context, listen: false);

    try {
      // 1. Inisialisasi Firebase (jika belum diinisialisasi di main)
      // Karena kita sudah menginisialisasinya di main, langkah ini di lewati

      // 2. Menunggu koneksi MQTT selesai dan data pertama masuk dari ESP32
      await mqttService.connect();
      
      // Catatan: isOnline akan otomatis menjadi TRUE setelah connect() berhasil 
      // dan ESP32 mengirim data pertamanya.

    } catch (e) {
      print("Error selama proses loading: $e");
      // Opsional: Tampilkan dialog error jika koneksi gagal
    }

    // Navigasi ke DashboardPage setelah semua loading selesai
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan sederhana Splash Screen
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              "Memuat Data Kebun Cerdas...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}