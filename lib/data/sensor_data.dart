// lib/data/sensor_data.dart (SUDAH DISESUAIKAN)
import 'package:flutter/material.dart';

class SensorData extends ChangeNotifier {
  // Nilai 0-100%
  int _kelembapan = 0; 
  // Nilai 0-100% (Konversi dari ADC ESP32)
  int _cahaya = 0; 
  
  bool _isHujan = false;
  bool _isPompaOn = false;
  bool _isOnline = false;
  bool _isManualMode = false;

  int get kelembapan => _kelembapan;
  int get cahaya => _cahaya;
  bool get isHujan => _isHujan;
  bool get isPompaOn => _isPompaOn;
  bool get isOnline => _isOnline;
  bool get isManualMode => _isManualMode;

  // --- METHODS UNTUK UPDATE DATA SENSOR ---

  void updateKelembapan(int newValue) {
    // Memastikan nilai Kelembapan di batas 0-100%
    _kelembapan = newValue.clamp(0, 100); 
    notifyListeners(); // Kondisi 'if' dihapus, notifikasi selalu dipanggil
  }

  void updateCahaya(int newValue) {
    // Memastikan nilai Cahaya di batas 0-100%
    _cahaya = newValue.clamp(0, 100);
    notifyListeners(); // Kondisi 'if' dihapus, notifikasi selalu dipanggil
  }
  
  // --- METHODS UNTUK UPDATE STATUS KONTROL ---

  void updateHujan(bool isHujan) {
    _isHujan = isHujan;
    notifyListeners(); // Kondisi 'if' dihapus, notifikasi selalu dipanggil
  }

  void setPompaStatus(bool status) {
    _isPompaOn = status;
    notifyListeners(); // Kondisi 'if' dihapus, notifikasi selalu dipanggil
  }

  void setMode(bool isManual) {
    _isManualMode = isManual;
    notifyListeners(); // Kondisi 'if' dihapus, notifikasi selalu dipanggil
  }

  void updateStatus(bool online) {
    _isOnline = online;
    notifyListeners(); // Kondisi 'if' dihapus, notifikasi selalu dipanggil
  }
}