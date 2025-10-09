import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:aplikasi_monitoring/core/constants.dart';
import 'package:aplikasi_monitoring/data/sensor_data.dart';
import 'dart:io'; 

class MqttService {
 late MqttServerClient client;
 final SensorData _sensorData; 
 
// --- KREDENSIAL CLOUD AMAN ---
 String server = 'a845939b5e3b46399f4ede06dfc0ee83.s1.eu.hivemq.cloud'; 
 int port = 8883; // PORT AMAN (TLS)
 String username = 'hivemq.webclient.1759421888488'; // Username dari Access Management
 String password = 'rHN&;na40bB>AP1i2M:h'; // Password
 String clientId = 'SmartFarmAppClient-${DateTime.now().millisecondsSinceEpoch}';

MqttService({required SensorData sensorData}) : _sensorData = sensorData; 

Future<void> connect() async {
 client = MqttServerClient(server, clientId);
 client.logging(on: true);
 client.keepAlivePeriod = 20;
 
 // --- KONFIGURASI TLS WAJIB ---
 client.port = port;
 client.secure = true; // DIPERBAIKI: Harus TRUE untuk Port 8883
 client.securityContext = SecurityContext.defaultContext; // Gunakan konteks default
 // -----------------------------

 try {
 // DIPERBAIKI: Memanggil connect() dengan username dan password
 await client.connect(username, password); 
 } on Exception catch (e) {
 print('MQTT connection failed: $e');
 client.disconnect();
 _sensorData.updateStatus(false); 
 return;
 }

 if (client.connectionStatus!.state == MqttConnectionState.connected) {
 print('MQTT client connected to $server on port $port');
 _sensorData.updateStatus(true);
 
 // Berlangganan semua topik
 client.subscribe(MqttTopics.kelembapan, MqttQos.atMostOnce);
 client.subscribe(MqttTopics.cahaya, MqttQos.atMostOnce);
 client.subscribe(MqttTopics.hujan, MqttQos.atMostOnce);
 client.subscribe(MqttTopics.pompaControl, MqttQos.atMostOnce);
 client.subscribe(MqttTopics.mode, MqttQos.atMostOnce);
 client.subscribe(MqttTopics.statusOnline, MqttQos.atMostOnce);
 
 client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
 MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
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
 } else if (topic == MqttTopics.cahaya) {
 try {
 int cahayaValue = int.parse(payload);
 _sensorData.updateCahaya(cahayaValue);
 } catch (e) {
 print("Error parsing cahaya payload: $e");
 }
 } else if (topic == MqttTopics.hujan) {
 _sensorData.updateHujan(payload == 'Hujan');
 } else if (topic == MqttTopics.statusOnline) {
 _sensorData.updateStatus(payload == 'online');
 } else if (topic == MqttTopics.pompaControl) {
 _sensorData.setPompaStatus(payload == 'ON');
 } else if (topic == MqttTopics.mode) {
 _sensorData.setMode(payload == 'MANUAL');
 }
}

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