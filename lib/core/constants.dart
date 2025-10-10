import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF006A4E);
  static const Color secondary = Color(0xFFFFB000);
  static const Color background = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color accent = Color(0xFF4CAF50);
}

class MqttTopics {
  static const String kelembapan = "/smartfarm/data/kelembapan";
  static const String cahaya = "/smartfarm/data/cahaya";
  static const String hujan = "/smartfarm/data/hujan";
  static const String pompaControl = "/smartfarm/control/pompa";
  static const String mode = "/smartfarm/control/mode";
  static const String statusOnline = "/smartfarm/status";
  static const String riwayatPenyiraman = "/smartfarm/history/penyiraman";
}