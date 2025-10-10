import 'dart:async'; // Diperlukan untuk menggunakan kelas 'Timer' yang berjalan secara periodik.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk berinteraksi dengan database Firestore.
import 'package:intl/intl.dart'; // Untuk memformat tanggal dan waktu ke format yang mudah dibaca (misal: "Senin, 13 Okt 2025").
import 'package:aplikasi_monitoring/core/constants.dart';

// Mengubah widget dari StatelessWidget menjadi StatefulWidget.
// Ini PENTING karena kita butuh halaman ini untuk 'membangun ulang' dirinya sendiri
// secara berkala (setiap menit) untuk memperbarui teks waktu seperti "1 menit yang lalu".
// StatelessWidget tidak bisa melakukan ini.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // 'late' menandakan bahwa variabel _timer ini PASTI akan diinisialisasi nanti,
  // tepatnya di dalam initState().
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // initState() adalah fungsi yang pertama kali dijalankan saat widget ini dibuat.
    // Kita memanfaatkannya untuk memulai timer.
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Kode di dalam ini akan dijalankan setiap 60 detik.
      
      // Memanggil setState({}) akan memberitahu Flutter untuk menjalankan ulang
      // fungsi build() pada widget ini. Inilah mekanisme yang membuat
      // tampilan waktu "X menit yang lalu" selalu ter-update.
      if (mounted) { // 'mounted' adalah pengecekan untuk memastikan widget masih ada di layar.
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Fungsi utilitas untuk mengubah objek Timestamp dari Firestore menjadi String yang dinamis.
  String formatTimestamp(Timestamp? timestamp) {
    // Penanganan jika data timestamp masih null (belum disinkronkan oleh server Firestore).
    if (timestamp == null) {
      return "Baru saja...";
    }
    
    // Ambil waktu saat ini dan konversi timestamp dari Firestore ke format DateTime Dart.
    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    
    // Hitung selisih antara waktu sekarang dan waktu data dibuat.
    final difference = now.difference(dateTime);

    // Logika untuk menampilkan format waktu yang berbeda berdasarkan selisihnya.
    if (difference.inMinutes < 1) {
      return "Baru saja";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} menit yang lalu";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} jam yang lalu";
    } else {
      // Jika sudah lebih dari sehari, tampilkan tanggal dan waktu lengkap dalam format Indonesia.
      return DateFormat('EEEE, dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Membuat query ke Firestore untuk mengambil data riwayat.
    final Stream<QuerySnapshot> historyStream = FirebaseFirestore.instance
        .collection('penyiraman_history') // Mengambil dari koleksi 'penyiraman_history'.
        .orderBy('timestamp', descending: true) // Mengurutkan dari yang paling baru.
        .limit(50) // Hanya mengambil 50 data terakhir untuk efisiensi.
        .snapshots(); // '.snapshots()' membuat query ini menjadi sebuah Stream, artinya ia akan otomatis 'mendengarkan' setiap perubahan.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penyiraman', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: historyStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

          // --- Tampilan Utama Jika Data Ditemukan ---
          return ListView(
            padding: const EdgeInsets.all(8.0),
            // .map() akan melakukan iterasi (looping) untuk setiap dokumen yang ada di dalam snapshot data.
            // Setiap dokumen akan diubah menjadi sebuah widget Card.
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              
              final Timestamp? timestamp = data['timestamp'] as Timestamp?;
              // Memanggil fungsi format waktu yang kita buat di atas.
              final String formattedDate = formatTimestamp(timestamp);
              
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

              // Card adalah widget yang akan menjadi setiap baris dalam daftar riwayat.
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
            }).toList(), // .toList() mengubah hasil dari .map() menjadi sebuah List<Widget>.
          );
        },
      ),
    );
  }
}

