import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
// Pastikan path ini benar sesuai nama file Anda
import 'package:aplikasi_monitoring/services/notif.dart'; 

class MqttService {
  late MqttServerClient client;
  final SensorData _sensorData;
  // TAMBAHKAN: Properti untuk menyimpan instance NotificationService
  final NotificationService _notificationService; 

  String server = 'a845939b5e3b46399f4ede06dfc0ee83.s1.eu.hivemq.cloud';
  int port = 8883;
  String username = 'hivemq.webclient.1759421888488';
  String password = 'rHN&;na40bB>AP1i2M:h';
  String clientId = 'SmartFarmAppClient-${DateTime.now().millisecondsSinceEpoch}';

  // UBAH: Constructor sekarang menerima 'notificationService'
  MqttService({
    required SensorData sensorData,
    required NotificationService notificationService,
  })  : _sensorData = sensorData,
        _notificationService = notificationService;

  Future<void> connect() async {
    client = MqttServerClient.withPort(server, clientId, port);
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.onBadCertificate = (dynamic certificate) => true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    try {
      print('>>> [MQTT] Mencoba terhubung...');
      await client.connect(username, password);
    } catch (e) {
      print('>>> [MQTT ERROR] Pengecualian saat connect: $e');
      client.disconnect();
    }
  }

  void onConnected() {
    print('>>> [MQTT] Terhubung!');
    _sensorData.updateStatus(true);
    
    // Subscribe ke semua topik yang relevan
    client.subscribe(MqttTopics.kelembapan, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.cahaya, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.hujan, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.pompaControl, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.mode, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.statusOnline, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.riwayatPenyiraman, MqttQos.atLeastOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c != null && c.isNotEmpty) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final topic = c[0].topic;

        print('>>> [MQTT RECEIVED] Topik: $topic, Payload: $payload');
        _handleIncomingMessage(topic, payload);
      }
    });
  }

  void onDisconnected() {
    print('>>> [MQTT] Terputus.');
    _sensorData.updateStatus(false);
  }

  void onSubscribed(String topic) {
    print('>>> [MQTT] Berlangganan ke topik: $topic');
  }
  
  void pong() {
    print('>>> [MQTT] Ping response diterima');
  }

  void _handleIncomingMessage(String topic, String payload) {
    // Panggil notifikasi ponsel saat ada riwayat baru
    if (topic == MqttTopics.riwayatPenyiraman) {
      FirebaseFirestore.instance.collection('penyiraman_history').add({
        'reason': payload,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _notificationService.showNotification(
        'Penyiraman Otomatis Aktif',
        'Pompa menyala karena: $payload',
      );
      return; 
    }
    
    // Update data sensor lainnya
    if (topic == MqttTopics.kelembapan) {
      _sensorData.updateKelembapan(int.tryParse(payload) ?? 0);
    } else if (topic == MqttTopics.cahaya) {
      _sensorData.updateCahaya(int.tryParse(payload) ?? 0);
    } else if (topic == MqttTopics.hujan) {
      _sensorData.updateHujan(payload.toLowerCase() == 'hujan');
    } else if (topic == MqttTopics.statusOnline) {
      _sensorData.updateStatus(payload.toLowerCase() == 'online');
    } else if (topic == MqttTopics.pompaControl) {
      _sensorData.setPompaStatus(payload.toUpperCase() == 'ON');
    } else if (topic == MqttTopics.mode) {
      _sensorData.setMode(payload.toUpperCase() == 'MANUAL');
    }
  }

  void publishControl(String topic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('>>> [MQTT PUBLISH] Mengirim ke topik $topic: $message');
    } else {
      print('>>> [MQTT ERROR] Klien tidak terhubung. Perintah tidak terkirim.');
    }
  }
}