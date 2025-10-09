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
    newValue = newValue.clamp(0, 100); 
    if (_kelembapan != newValue) {
      _kelembapan = newValue;
      notifyListeners(); 
    }
  }

  void updateCahaya(int newValue) {
    // Memastikan nilai Cahaya di batas 0-100%
    newValue = newValue.clamp(0, 100);
    if (_cahaya != newValue) {
      _cahaya = newValue;
      notifyListeners(); 
    }
  }
  
  // --- METHODS UNTUK UPDATE STATUS KONTROL ---

  void updateHujan(bool isHujan) {
    if (_isHujan != isHujan) {
      _isHujan = isHujan;
      notifyListeners(); 
    }
  }

  void setPompaStatus(bool status) {
    if (_isPompaOn != status) {
      _isPompaOn = status;
      notifyListeners();
    }
  }

  void setMode(bool isManual) {
    if (_isManualMode != isManual) {
      _isManualMode = isManual;
      notifyListeners();
    }
  }

  void updateStatus(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }
}
