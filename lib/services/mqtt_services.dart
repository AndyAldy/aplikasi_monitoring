// lib/services/mqtt_services.dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart'; // Import model data

class MqttService {
  late MqttServerClient client;
  final SensorData _sensorData; // Tambahkan referensi ke SensorData
  
  // Constructor baru untuk menerima SensorData
  MqttService({required SensorData sensorData}) : _sensorData = sensorData; 
  
  final String server = 'broker.hivemq.com'; 
  final String clientId = 'AplikasiMonitoringClient-${DateTime.now().millisecondsSinceEpoch}';

  Future<void> connect() async {
    client = MqttServerClient(server, clientId);
    client.logging(on: true);
    client.keepAlivePeriod = 20;

    try {
      await client.connect();
    } on Exception catch (e) {
      print('MQTT connection failed: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      _sensorData.updateStatus(true); // Update status koneksi di UI
      
      client.subscribe(MqttTopics.kelembapan, MqttQos.atMostOnce);
      client.subscribe(MqttTopics.statusOnline, MqttQos.atMostOnce);
      client.subscribe(MqttTopics.pompaControl, MqttQos.atMostOnce); // Langganan untuk balasan/konfirmasi
      
      // Setup listener untuk pesan masuk
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final String topic = c[0].topic;
        
        print('Received message on topic: $topic, payload: $payload');
        _handleIncomingMessage(topic, payload);
      });
    } else {
      _sensorData.updateStatus(false);
      print('ERROR: MQTT connection failed - status ${client.connectionStatus}');
    }
  }

  void _handleIncomingMessage(String topic, String payload) {
    if (topic == MqttTopics.kelembapan) {
        try {
            int kelembapanValue = int.parse(payload);
            _sensorData.updateKelembapan(kelembapanValue);
        } catch (e) {
            print("Error parsing kelembapan payload: $e");
        }
    } else if (topic == MqttTopics.statusOnline) {
         _sensorData.updateStatus(payload == 'online');
    } else if (topic == MqttTopics.pompaControl) {
        // Update status pompa berdasarkan pesan dari ESP32
        _sensorData.setPompaStatus(payload == 'ON');
    }
  }

  // Ganti nama publish menjadi publishControl agar lebih jelas fungsinya
  void publishControl(String topic, String message) { 
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      
      // Update status pompa secara optimistik di UI (opsional, tapi baik)
      if (topic == MqttTopics.pompaControl) {
          _sensorData.setPompaStatus(message == 'ON');
      }
    } else {
       print('MQTT client not connected. Command not sent.');
    }
  }
}