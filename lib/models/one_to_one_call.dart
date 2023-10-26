import "package:telemed_chat/telemed_chat.dart";
import "package:videosdk/videosdk.dart";

class OneToOneCall {
  OneToOneCall({
    required this.notificationInfo,
    required this.token,
    required this.displayName,
    this.micEnabled = true,
    this.camEnabled = true,
  });

  /// Notification information when screen sharing or any action
  final NotificationInfo notificationInfo;
  final String token;
  final String displayName;
  final bool micEnabled;
  final bool camEnabled;

  late String meetingId;
  OneToOneRoomState roomState = OneToOneRoomState();
}

class OneToOneRoomState {
  OneToOneRoomState({
    this.audioStream,
    this.videoStream,
    this.activePresenterId,
    this.room,
    this.currentOutputAudioDevice,
    this.isFrontCamera = true,
  });

  Stream? videoStream;
  Stream? audioStream;
  bool isFrontCamera;
  OutputAudioDevices? currentOutputAudioDevice;

  Room? room;
  dynamic activePresenterId;

  OneToOneRoomState copyWith({
    Stream? videoStream,
    Stream? audioStream,
    bool? isFrontCamera,
    OutputAudioDevices? currentOutputAudioDevice,
    Room? room,
    dynamic activePresenterId,
  }) {
    return OneToOneRoomState(
      videoStream: videoStream ?? this.videoStream,
      audioStream: audioStream ?? this.audioStream,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      currentOutputAudioDevice:
          currentOutputAudioDevice ?? this.currentOutputAudioDevice,
      room: room ?? this.room,
      activePresenterId: activePresenterId ?? this.activePresenterId,
    );
  }
}
