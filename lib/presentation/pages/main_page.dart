import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'package:aplikasi_monitoring/presentation/pages/dashboard.dart';
import 'package:aplikasi_monitoring/presentation/pages/history.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _isPompaOnPrev = false;

  // **PERBAIKAN BAGIAN 1**: Simpan referensi SensorData di sini
  late SensorData _sensorData;

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // **PERBAIKAN BAGIAN 2**: Ambil SensorData sekali saja
    _sensorData = Provider.of<SensorData>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPompaOnPrev = _sensorData.isPompaOn;
      // Gunakan variabel yang sudah disimpan untuk menambah listener
      _sensorData.addListener(_showPumpBanner);
    });
  }

  @override
  void dispose() {
    // **PERBAIKAN BAGIAN 3**: Gunakan variabel yang sudah disimpan untuk menghapus listener
    // Ini aman karena tidak lagi mencari Provider di dalam context yang mungkin sudah tidak aktif.
    _sensorData.removeListener(_showPumpBanner);
    super.dispose();
  }

  // Fungsi ini tidak perlu diubah
  void _showPumpBanner() {
    // Cek mounted untuk keamanan tambahan jika ada notifikasi yang tertunda
    if (!mounted) return;
    final isPompaOnNow = _sensorData.isPompaOn;

    if (isPompaOnNow && !_isPompaOnPrev) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.water_drop_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('Penyiraman sedang berlangsung...'),
          ]),
          backgroundColor: AppColors.primary.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }
    _isPompaOnPrev = isPompaOnNow;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}