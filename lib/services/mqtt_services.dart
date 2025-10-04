import 'package:mqtt_client/mqtt_client.dart';

import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:aplikasi_monitoring/core/constants.dart';

import 'package:aplikasi_monitoring/data/sensor_data.dart';



class MqttService {

  late MqttServerClient client;

  final SensorData _sensorData; 

  

  // Constructor dan koneksi tetap sama

  MqttService({required SensorData sensorData}) : _sensorData = sensorData; 

  

  final String server = 'mqtt-dashboard.com'; 

  final String clientId = 'esp32  ';



  Future<void> connect() async {

    // ... (Kode koneksi tetap sama) ...

    client = MqttServerClient(server, clientId);

    client.logging(on: true);

    client.keepAlivePeriod = 20;



    try {

      await client.connect();

    } on Exception catch (e) {

      print('MQTT connection failed: $e');

      client.disconnect();

      _sensorData.updateStatus(false); 

    }



    if (client.connectionStatus!.state == MqttConnectionState.connected) {

      print('MQTT client connected');

      _sensorData.updateStatus(true);

      

      // Berlangganan semua topik (termasuk yang disimulasikan)

      client.subscribe(MqttTopics.kelembapan, MqttQos.atMostOnce);

      client.subscribe(MqttTopics.cahaya, MqttQos.atMostOnce);

      client.subscribe(MqttTopics.hujan, MqttQos.atMostOnce);

      client.subscribe(MqttTopics.pompaControl, MqttQos.atMostOnce);

      client.subscribe(MqttTopics.mode, MqttQos.atMostOnce);

      client.subscribe(MqttTopics.statusOnline, MqttQos.atMostOnce);

      

      // ... (Listener tetap sama) ...

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



  // --- FUNGSI PENTING YANG DIUBAH ---

  void _handleIncomingMessage(String topic, String payload) {

    if (topic == MqttTopics.kelembapan) {

        try {

            // Kelembapan sekarang dikirim sebagai nilai 0-100%

            int kelembapanValue = int.parse(payload);

            _sensorData.updateKelembapan(kelembapanValue);

        } catch (e) {

            print("Error parsing kelembapan payload: $e");

        }

    } else if (topic == MqttTopics.cahaya) {

        try {

            // Catatan: Anda mungkin perlu mengkonversi nilai ADC (0-4095) ke Lux di sini

            int cahayaValue = int.parse(payload);

            _sensorData.updateCahaya(cahayaValue);

        } catch (e) {

            print("Error parsing cahaya payload: $e");

        }

    } else if (topic == MqttTopics.hujan) {

        // ESP32 mengirim "Hujan" atau "Kering"

        _sensorData.updateHujan(payload == 'Hujan');

    } else if (topic == MqttTopics.statusOnline) {

        _sensorData.updateStatus(payload == 'online');

    } else if (topic == MqttTopics.pompaControl) {

        _sensorData.setPompaStatus(payload == 'ON');

    } else if (topic == MqttTopics.mode) {

        _sensorData.setMode(payload == 'MANUAL');

    }

  }



  // ... (Metode publishControl tetap sama) ...

  void publishControl(String topic, String message) {

    if (client.connectionStatus?.state == MqttConnectionState.connected) {

      final builder = MqttClientPayloadBuilder();

      builder.addString(message);

      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

      

      if (topic == MqttTopics.pompaControl) {

          _sensorData.setPompaStatus(message == 'ON');

      } else if (topic == MqttTopics.mode) {

          _sensorData.setMode(message == 'MANUAL');

      }

    } else {

       print('MQTT client not connected. Command not sent.');

    }

  }

}

