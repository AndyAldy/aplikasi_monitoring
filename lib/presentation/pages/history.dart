import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_monitoring/core/constants.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> historyStream = FirebaseFirestore.instance
        .collection('penyiraman_history')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penyiraman', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false, // Menghilangkan tombol kembali otomatis
      ),
      // StreamBuilder adalah widget yang 'mendengarkan' perubahan data dari Firestore.
      // Setiap kali ada data baru, bagian 'builder' akan dijalankan ulang.
      body: StreamBuilder<QuerySnapshot>(
        stream: historyStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // --- Penanganan Status ---
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan memuat data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat penyiraman.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          // --- Tampilan Utama (Jika ada data) ---
          // ListView akan membuat daftar yang bisa di-scroll dari data yang diterima.
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              
              // ================== BAGIAN YANG DIPERBAIKI ==================
              // Deklarasikan 'timestamp' sebagai tipe yang bisa bernilai null (Timestamp?).
              final Timestamp? timestamp = data['timestamp'] as Timestamp?;
              String formattedDate;

              // Lakukan pengecekan: JIKA timestamp TIDAK null, format tanggalnya.
              if (timestamp != null) {
                DateTime dateTime = timestamp.toDate();
                // Format ke format tanggal dan waktu Indonesia.
                formattedDate = DateFormat('EEEE, dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
              } else {
                // JIKA timestamp MASIH null, tampilkan teks sementara.
                formattedDate = "Baru saja...";
              }
              // ==========================================================
              
              // Logika untuk menentukan ikon dan warna berdasarkan alasan penyiraman.
              IconData icon;
              Color iconColor;
              String reason = data['reason'] ?? 'Otomatis';

              if (reason.contains('Terik')) {
                icon = Icons.wb_sunny;
                iconColor = Colors.orange;
              } else { // Asumsi "Tanah Kering"
                icon = Icons.water_drop_outlined;
                iconColor = Colors.lightBlue;
              }

              // Card adalah widget untuk setiap item di dalam daftar riwayat.
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(icon, color: iconColor, size: 40),
                  title: const Text(
                    'Penyiraman Otomatis',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alasan: $reason'),
                      const SizedBox(height: 4),
                      Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

