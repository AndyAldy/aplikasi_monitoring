import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';
import 'package:mqtt_client/mqtt_client.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Stream untuk status login
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Login dengan Email dan Password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow; // Lempar kembali error untuk ditangani di UI
    }
  }

  // Registrasi dengan Email dan Password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Logout (Fungsi yang disesuaikan)
  Future<void> signOut(MqttService mqttService) async {
    // Cek dulu apakah MQTT client terkoneksi sebelum mencoba disconnect
    if (mqttService.client.connectionStatus?.state == MqttConnectionState.connected) {
      mqttService.client.disconnect();
    }
    // Setelah itu, baru logout dari Firebase
    await _firebaseAuth.signOut();
  }

  // Otentikasi dengan Biometrik (Sidik Jari)
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Silakan pindai sidik jari Anda untuk login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print(e);
      return false;
    }
  }
}