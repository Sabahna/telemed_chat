import "package:videosdk/videosdk.dart";

class OneToOneCall {
  OneToOneCall({
    required this.notificationInfo,
    required this.token,
    required this.displayName,
    this.micEnabled = true,
    this.camEnabled = true,
    this.chatEnabled = true,
  });

  /// Notification information when screen sharing or any action
  final NotificationInfo notificationInfo;
  late String meetingId;
  final String token;
  final String displayName;
  final bool micEnabled;
  final bool camEnabled;
  final bool chatEnabled;
}
