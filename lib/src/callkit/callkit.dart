import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_callkit_incoming/entities/entities.dart";
import "package:flutter_callkit_incoming/flutter_callkit_incoming.dart";
import "package:telemed_chat/models/callkit_abstract.dart";
import "package:uuid/uuid.dart";

class CallKitVOIP extends CallKitVOIPAbstract {
  String? _currentUuid;

  @override
  Future<void> inComingCall({
    required String callerName,
    required String callerId,
    required String appName,
    String? callerHandle,
    String? callerAvatar,
    String? missedCallTitle,
    String? missedCallText,
    int? duration,
    String? ringtonePath,
    bool isVideo = false,
  }) async {
    _currentUuid = const Uuid().v4();
    debugPrint(
      "----------------------incomming call $_currentUuid----------------------",
    );
    final params = CallKitParams(
      id: _currentUuid,
      nameCaller: callerName,
      appName: appName,
      avatar: callerAvatar,
      handle: callerHandle,
      type: isVideo ? 1 : 0,
      duration: duration ?? 45000,
      textAccept: "Accept",
      textDecline: "Decline",
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: missedCallTitle,
        callbackText: missedCallText,
      ),
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: ringtonePath,
        backgroundColor: "#0955fa",
        backgroundUrl: callerAvatar ?? "assets/test.png",
        actionColor: "#4CAF50",
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call",
      ),
      ios: IOSParams(
        // iconName: 'CallKitLogo',
        handleType: callerHandle,
        supportsVideo: isVideo,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: "videoChat",
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: ringtonePath, // "sabahna_ringtone"
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
    callKitParams = params;
  }

  @override
  Future<void> listenerEvent({
    required FutureOr<void> Function() join,
    required FutureOr<void> Function() decline,
  }) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        switch (event!.event) {
          case Event.actionCallIncoming:
            debugPrint(
              "----------------------incoming call----------------------",
            );
            break;
          case Event.actionCallAccept:
            debugPrint(
              "----------------------accept call----------------------",
            );
            join();
            if (_currentUuid != null) {
              await FlutterCallkitIncoming.setCallConnected(_currentUuid!);
            }

            break;
          case Event.actionCallDecline:
            decline();
            await callEnd();
            break;
          case Event.actionCallTimeout:
            debugPrint(
              "----------------------missed called----------------------",
            );
            await FlutterCallkitIncoming.showMissCallNotification(
              callKitParams,
            );

            break;
          case Event.actionCallToggleMute:
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            break;
          default:
            break;
        }
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> callEnd() async {
    if (_currentUuid != null) {
      await FlutterCallkitIncoming.endCall(_currentUuid!);
      _currentUuid = null;
    } else {
      debugPrint(
        "----------------------There is no incoming call----------------------",
      );
    }
  }

  Future<dynamic> _getCurrentCall() async {
    //check current call from pushkit if possible
    final calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        debugPrint("callDATA: $calls[0]");
        if (_currentUuid == (calls[0] as Map<String, dynamic>)["id"]) {
          return calls[0];
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<String> getDevicePushTokenVoIP() async {
    final devicePushTokenVoIP =
        await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    debugPrint(
      "----------------------Device Push Token VoIP----$devicePushTokenVoIP------------------",
    );
    return devicePushTokenVoIP;
  }
}
