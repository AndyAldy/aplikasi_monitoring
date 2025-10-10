import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplikasi_monitoring/services/auth_service.dart';
import 'package:aplikasi_monitoring/services/mqtt_services.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final mqttService = Provider.of<MqttService>(context, listen: false);
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Future untuk mengambil data user dari Firestore
    Future<DocumentSnapshot> getUserData() {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat data pengguna.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data pengguna tidak ditemukan.'));
          }

          // Ambil data dari dokumen Firestore
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final username = userData['username'] ?? 'Tanpa Nama';
          final email = userData['email'] ?? 'Tanpa Email';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  username,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await authService.signOut(mqttService);
                  // AuthGate akan otomatis mengarahkan ke halaman login
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }
}