// lib/data/sensor_data.dart
import 'package:flutter/material.dart';

class SensorData extends ChangeNotifier {
  int _kelembapan = 0;
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

  void updateKelembapan(int newValue) {
    if (_kelembapan != newValue) {
      _kelembapan = newValue;
      notifyListeners(); 
    }
  }

  void updateCahaya(int newValue) {
    if (_cahaya != newValue) {
      _cahaya = newValue;
      notifyListeners(); 
    }
  }

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