import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/presentation/pages/dashboard.dart';
import 'package:aplikasi_monitoring/presentation/pages/history.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/services/auth_service.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart'; 

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isPompaOnPrev = false; // Variabel untuk menyimpan status pompa sebelumnya

  // Daftar halaman yang akan ditampilkan di setiap tab
  static const List<Widget> _pages = <Widget>[
    DashboardPage(), // Halaman Home (Dashboard Anda yang sudah ada)
    HistoryPage(),   // Halaman History
  ];

  @override
  void initState() {
    super.initState();
    // Gunakan addPostFrameCallback untuk memastikan context sudah siap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorData = Provider.of<SensorData>(context, listen: false);
      // Inisialisasi status awal pompa
      _isPompaOnPrev = sensorData.isPompaOn;
      // Tambahkan listener untuk mendeteksi perubahan data
      sensorData.addListener(_showPumpNotification);
    });
  }

  @override
  void dispose() {
    // Hapus listener saat widget dihancurkan untuk mencegah kebocoran memori
    Provider.of<SensorData>(context, listen: false).removeListener(_showPumpNotification);
    super.dispose();
  }

  // Fungsi yang akan dipanggil setiap kali ada perubahan di SensorData
  void _showPumpNotification() {
    final sensorData = Provider.of<SensorData>(context, listen: false);
    final isPompaOnNow = sensorData.isPompaOn;

    // Tampilkan notifikasi HANYA jika pompa baru saja menyala (dari OFF ke ON)
    if (isPompaOnNow && !_isPompaOnPrev) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.water_drop_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Penyiraman sedang berlangsung...'),
            ],
          ),
          backgroundColor: AppColors.primary.withOpacity(0.9),
          behavior: SnackBarBehavior.floating, // Notifikasi mengambang
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
    // Perbarui status pompa sebelumnya untuk pengecekan berikutnya
    _isPompaOnPrev = isPompaOnNow;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final mqttService = Provider.of<MqttService>(context, listen: false); // Ambil MqttService

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'SmartFarm Dashboard' : 'Riwayat Penyiraman', style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Panggil signOut dengan memberikan MqttService
              await authService.signOut(mqttService); 
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}