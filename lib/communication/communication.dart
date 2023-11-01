import "dart:async";

import "package:videosdk/videosdk.dart";

class Communication {
  factory Communication() {
    return I;
  }

  Communication._();

  static final Communication I = Communication._();

  late Room room;

  /// Events methods
  /// Events listen once while calling and function references miss when minimized call screen
  /// So, store events methods
  ///
  FutureOr<void> Function()? _onRoomJoined;
  FutureOr<void> Function(dynamic error)? _onRoomLeft;
  FutureOr<void> Function(Stream stream)? _onStreamEnabled;
  FutureOr<void> Function(Stream stream)? _onStreamDisabled;
  FutureOr<void> Function(String id)? _onPresenterChanged;
  FutureOr<void> Function()? _onParticipantLeft;

  /// Create instance of Room (Meeting)
  ///
  Room createRoom({
    required String meetingId,
    required String token,
    required String name,
    required bool camEnabled,
    required NotificationInfo notificationInfo,
  }) {
    room = VideoSDK.createRoom(
      roomId: meetingId,
      token: token,
      displayName: name,
      camEnabled: camEnabled,
      maxResolution: "hd",
      multiStream: false,
      defaultCameraIndex: 1,
      notification: notificationInfo,
    );
    return room;
  }

  Future<void> registerEvents({
    FutureOr<void> Function()? onRoomJoined,
    FutureOr<void> Function(dynamic error)? onRoomLeft,
    FutureOr<void> Function(Stream stream)? onStreamEnabled,
    FutureOr<void> Function(Stream stream)? onStreamDisabled,
    FutureOr<void> Function(String id)? onPresenterChanged,
    FutureOr<void> Function()? onParticipantLeft,
  }) async {
    _onRoomJoined = onRoomJoined;
    _onRoomLeft = onRoomLeft;
    _onStreamEnabled = onStreamEnabled;
    _onStreamDisabled = onStreamDisabled;
    _onPresenterChanged = onPresenterChanged;
    _onParticipantLeft = onParticipantLeft;

    // Called when joined in meeting
    room
      ..on(
        Events.roomJoined,
        () {
          _onRoomJoined?.call();
        },
      )

      // Called when meeting is ended
      ..on(Events.roomLeft, (errorMsg) {
        _onRoomLeft?.call(errorMsg);
      });

    // Called when stream is enabled
    room.localParticipant.on(Events.streamEnabled, (stream) {
      final tempStream = stream as Stream;
      _onStreamEnabled?.call(tempStream);
    });

    // Called when stream is disabled
    room.localParticipant.on(Events.streamDisabled, (stream) {
      final tempStream = stream as Stream;

      _onStreamDisabled?.call(tempStream);
    });

    // Called when presenter is changed
    room
      ..on(Events.presenterChanged, (activePresenterId) {
        _onPresenterChanged?.call(activePresenterId.toString());
      })
      ..on(
        Events.participantLeft,
        (participant) {
          _onParticipantLeft?.call();
        },
      )

      // Called when error
      ..on(
        Events.error,
        (error) => {
          // TODO(jack): show error
          // showSnackBarMessage(
          //     message: "${error['name']} :: ${error['message']}",
          //     context: context),
        },
      );
  }
}
