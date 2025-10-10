import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/presentation/pages/main_page.dart'; // UBAH INI
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

  Future<void> _initializeAppAndData() async {
    final mqttService = Provider.of<MqttService>(context, listen: false);

    try {
      await mqttService.connect();
    } catch (e) {
      print("Error selama proses loading: $e");
    }

    if (mounted) {
      // --- MENGARAHKAN KE MAINPAGE SETELAH SELESAI ---
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainPage()), // UBAH INI
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
