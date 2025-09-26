// lib/data/sensor_data.dart
import 'package:flutter/material.dart';

class SensorData extends ChangeNotifier {
  int _kelembapan = 0;
  bool _isPompaOn = false;
  bool _isOnline = false;

  int get kelembapan => _kelembapan;
  bool get isPompaOn => _isPompaOn;
  bool get isOnline => _isOnline;

  // Metode untuk memperbarui data sensor
  void updateKelembapan(int newValue) {
    if (_kelembapan != newValue) {
      _kelembapan = newValue;
      notifyListeners(); // Memberi tahu widget untuk refresh
    }
  }

  // Metode untuk memperbarui status aktuator
  void togglePompa() {
    _isPompaOn = !_isPompaOn;
    notifyListeners();
    // Di sini Anda seharusnya memanggil MqttService untuk mengirim perintah ke ESP32
    // Misalnya: MqttService().publish(MqttTopics.pompaControl, _isPompaOn ? "1" : "0");
  }

  // Metode untuk memperbarui status koneksi ESP32
  void updateStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }
}