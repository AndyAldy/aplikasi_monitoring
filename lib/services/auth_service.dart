import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance Firestore
  final LocalAuthentication _localAuth = LocalAuthentication();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // **SINKRONISASI**: Fungsi registrasi diubah untuk menerima dan menyimpan username
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan data tambahan ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'username': username,
      });

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut(MqttService mqttService) async {
    if (mqttService.client.connectionStatus?.state == MqttConnectionState.connected) {
      mqttService.client.disconnect();
    }
    await _firebaseAuth.signOut();
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        return false;
      }
      return await _localAuth.authenticate(
        localizedReason: 'Pindai sidik jari Anda untuk melanjutkan',
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