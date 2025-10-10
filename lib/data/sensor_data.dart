// lib/data/sensor_data.dart (SUDAH DISESUAIKAN DENGAN LOGIKA BARU)
import 'package:flutter/material.dart';

class SensorData extends ChangeNotifier {
  int _kelembapan = 0;
  int _cahaya = 0;
  bool _isHujan = false;
  bool _isPompaOn = false;
  bool _isOnline = false;
  bool _isManualMode = false;

  // Variabel baru untuk melacak apakah data pertama sudah diterima
  bool _hasReceivedData = false;

  int get kelembapan => _kelembapan;
  int get cahaya => _cahaya;
  bool get isHujan => _isHujan;
  bool get isPompaOn => _isPompaOn;
  bool get isOnline => _isOnline;
  bool get isManualMode => _isManualMode;
  // Getter untuk variabel baru
  bool get hasReceivedData => _hasReceivedData;

  // Fungsi internal untuk menandai data telah diterima
  void _confirmDataReceived() {
    if (!_hasReceivedData) {
      _hasReceivedData = true;
    }
  }

  void updateKelembapan(int newValue) {
    _confirmDataReceived(); // Tandai data sudah diterima
    _kelembapan = newValue.clamp(0, 100);
    notifyListeners();
  }

  void updateCahaya(int newValue) {
    _confirmDataReceived(); // Tandai data sudah diterima
    _cahaya = newValue.clamp(0, 100);
    notifyListeners();
  }

  void updateHujan(bool isHujan) {
    _confirmDataReceived(); // Tandai data sudah diterima
    _isHujan = isHujan;
    notifyListeners();
  }

  void setPompaStatus(bool status) {
    _isPompaOn = status;
    notifyListeners();
  }

  void setMode(bool isManual) {
    _isManualMode = isManual;
    notifyListeners();
  }

  void updateStatus(bool online) {
    _isOnline = online;
    // Jika offline, reset status penerimaan data
    if (!online) {
      _hasReceivedData = false;
    }
    notifyListeners();
  }
}