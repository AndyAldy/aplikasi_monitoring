// lib/core/constants.dart
import 'package:flutter/material.dart';

// Palet Warna
class AppColors {
  static const Color primary = Color(0xFF006A4E); // Hijau Tua
  static const Color secondary = Color(0xFFFFB000); // Kuning Amber
  static const Color background = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color accent = Color(0xFF4CAF50); // Hijau Cerah
}

// Topik MQTT
class MqttTopics {
  static const String kelembapan = "/smartfarm/data/kelembapan";
  static const String pompaControl = "/smartfarm/control/pompa";
  static const String statusOnline = "/smartfarm/status";
}