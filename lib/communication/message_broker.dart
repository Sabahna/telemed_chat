import "dart:math";

import "package:flutter/cupertino.dart";
import "package:mqtt_client/mqtt_client.dart";
import "package:mqtt_client/mqtt_server_client.dart";

class MessageBroker {
  factory MessageBroker() {
    return I;
  }

  MessageBroker._();

  static final MessageBroker I = MessageBroker._();

  late MqttServerClient client;

  bool isConnected = false;

  Future<MqttServerClient> connect() async {
    final random = Random().nextInt(10);

    client = MqttServerClient.withPort(
      "192.168.100.3",
      "mqttx_1ce08829",
      1883,
      maxConnectionAttempts: 10,
    );
    client
      ..logging(on: true)
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onUnsubscribed = _onUnsubscribed
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail
      ..pongCallback = _pong
      ..connectTimeoutPeriod = 5000
      ..keepAlivePeriod = 60
      ..autoReconnect = true;

    final connMessage = MqttConnectMessage()
        // .authenticateAs('admin', 'public')
        .withWillTopic("willtopic")
        .withWillMessage("Will message")
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;
    try {
      await client.connect();
      isConnected = true;
    } catch (e) {
      debugPrint("Exception: $e");
      client.disconnect();
      isConnected = false;
    }

    client.updates?.listen((c) {
      for (final i in c) {
        debugPrint(
          "------message broker----------------${i.topic}--${MqttPublishPayload.bytesToStringAsString(((i.payload) as MqttPublishMessage).payload.message)}--------------------",
        );
      }

      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      debugPrint("Received message:$payload from topic: ${c[0].topic}>");
      final queueMessage = QueueMessage(topic: c[0].topic, message: payload);
    });

    return client;
  }

  void subscribe() {
    final Subscription? a = client.subscribe("topic_test", MqttQos.atLeastOnce);
  }

  void publish() {
    const pubTopic = "topic_test";
    final builder = MqttClientPayloadBuilder()..addString("Hello MQTT");
    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!);
  }

  // connection succeeded
  void _onConnected() {
    debugPrint("Connected");
  }

  // unconnected
  void _onDisconnected() {
    debugPrint("Disconnected");
  }

  // subscribe to topic succeeded
  void _onSubscribed(String topic) {
    debugPrint("Subscribed topic: $topic");
  }

  // subscribe to topic failed
  void _onSubscribeFail(String topic) {
    debugPrint("Failed to subscribe $topic");
  }

  // unsubscribe succeeded
  void _onUnsubscribed(String? topic) {
    debugPrint("Unsubscribed topic: $topic");
  }

  // PING response received
  void _pong() {
    debugPrint("Ping response client callback invoked");
  }
}

class QueueMessage {
  QueueMessage({
    required this.topic,
    required this.message,
  });

  final String topic;
  final dynamic message;
}
