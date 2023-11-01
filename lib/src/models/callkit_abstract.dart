import "dart:async";

import "package:flutter_callkit_incoming/entities/call_kit_params.dart";

abstract class CallKitVOIPAbstract {
  late CallKitParams callKitParams;

  /// To show up the incoming call alert
  ///
  /// [callerName] is the name of the caller to display
  ///
  /// [callerHandle] may be email or phone number or None
  ///
  /// [callerAvatar] works only in Android to show the avatar of the caller profile.
  /// You can use as an example of avatar at [here](https://i.pravatar.cc/100)
  ///
  /// [duration] is to end and missed call in second, default is `45`s
  ///
  /// [isVideo] is the boolean and default is audio `false`
  ///
  Future<void> inComingCall({
    required String callerName,
    required String appName,
    String? callerHandle,
    String? callerAvatar,
    String? missedCallTitle,
    String? missedCallText,
    int? duration,
    String? ringtonePath,
    bool isVideo = false,
  });

  /// Listen to the call kit event
  Future<void> listenerEvent({
    required FutureOr<void> Function() onDecline,
    required FutureOr<void> Function() onJoin,
  });

  /// Listen to the background call kit event
  Future<void> listenerEventBackground({
    required FutureOr<void> Function() onDecline,
  });

  Future<void> callEnd();

  /// Get device push token VoIP. iOS: return deviceToken, Android: Empty
  Future<String> getDevicePushTokenVoIP();
}
