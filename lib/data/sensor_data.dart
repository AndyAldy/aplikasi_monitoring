import 'package:flutter/material.dart';

class SensorData extends ChangeNotifier {
int _kelembapan = 0; // Nilai Kelembapan sudah dalam 0-100%
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
// Nilai Kelembapan sekarang diasumsikan sudah dikonversi (0-100)
void updateKelembapan(int newValue) {
 // Pastikan nilai tetap di batas 0-100
 newValue = newValue.clamp(0, 100); 
 if (_kelembapan != newValue) {
 _kelembapan = newValue;
 notifyListeners(); 
 }
}
// Sisanya tetap sama
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