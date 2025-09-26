import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:aplikasi_monitoring/core/constants.dart';

// Import model untuk memperbarui data

class MqttService {
  late MqttServerClient client;
  
  // Konfigurasi ini harus disesuaikan dengan broker Anda
  final String server = 'broker.hivemq.com'; // Contoh Broker Publik
  final String clientId = 'Aplikasi Monitoring Jeruk';

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
      // Berlangganan (Subscribe) ke topik yang relevan
      client.subscribe(MqttTopics.kelembapan, MqttQos.atMostOnce);
      client.subscribe(MqttTopics.statusOnline, MqttQos.atMostOnce);
      
      // Setup listener untuk pesan masuk
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final String topic = c[0].topic;
        
        print('Received message on topic: $topic, payload: $payload');

      });
    } else {
      print('ERROR: MQTT connection failed - status ${client.connectionStatus}');
    }
  }

  void publish(String topic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    }
  }
}