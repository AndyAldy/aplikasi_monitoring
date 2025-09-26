// lib/data/sensor_data.dart
import 'package:flutter/material.dart';

class SensorData extends ChangeNotifier {
  int _kelembapan = 0;
  bool _isPompaOn = false;
  bool _isOnline = false;

  int get kelembapan => _kelembapan;
  bool get isPompaOn => _isPompaOn;
  bool get isOnline => _isOnline;

  // Dipanggil oleh MqttService saat ada data sensor baru
  void updateKelembapan(int newValue) {
    if (_kelembapan != newValue) {
      _kelembapan = newValue;
      notifyListeners(); 
    }
  }

  // Dipanggil oleh MqttService (dari ESP32) untuk menyinkronkan status
  void setPompaStatus(bool status) {
    if (_isPompaOn != status) {
        _isPompaOn = status;
        notifyListeners();
    }
  }

  // Dipanggil oleh DashboardPage untuk mengirim perintah ke Pompa (statusnya dibalik)
  // (Fungsi ini akan kita hapus dan pindahkan logikanya ke DashboardPage)
  // void togglePompa() {
  //   _isPompaOn = !_isPompaOn;
  //   notifyListeners();
  // }

  // Metode untuk memperbarui status koneksi ESP32
  void updateStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }
}