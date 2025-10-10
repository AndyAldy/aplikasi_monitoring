// lib/services/mqtt_services.dart (FINAL - VERSI STABIL)
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';

class MqttService {
  late MqttServerClient client;
  final SensorData _sensorData;

  String server = 'a845939b5e3b46399f4ede06dfc0ee83.s1.eu.hivemq.cloud';
  int port = 8883;
  String username = 'hivemq.webclient.1759421888488';
  String password = 'rHN&;na40bB>AP1i2M:h';
  String clientId = 'SmartFarmAppClient-${DateTime.now().millisecondsSinceEpoch}';

  MqttService({required SensorData sensorData}) : _sensorData = sensorData;

  Future<void> connect() async {
    // Membuat instance client dengan cara yang benar
    client = MqttServerClient.withPort(server, clientId, port);

    // Konfigurasi dasar
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    
    // Konfigurasi Keamanan (SSL/TLS)
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.onBadCertificate = (dynamic certificate) => true; // Tetap diperlukan

    // Callbacks
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
    
    // Subscribe ke semua topik
    client.subscribe(MqttTopics.kelembapan, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.cahaya, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.hujan, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.pompaControl, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.mode, MqttQos.atLeastOnce);
    client.subscribe(MqttTopics.statusOnline, MqttQos.atLeastOnce);

    // Listener untuk pesan masuk
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