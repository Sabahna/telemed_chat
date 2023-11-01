import "dart:async";

import "package:videosdk/videosdk.dart";

class Communication {
  factory Communication() {
    return I;
  }

  Communication._();

  static final Communication I = Communication._();

  late Room room;

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
    FutureOr<void> Function(String error)? onRoomLeft,
    FutureOr<void> Function(Stream stream)? onStreamEnabled,
    FutureOr<void> Function(Stream stream)? onStreamDisabled,
    FutureOr<void> Function(String id)? onPresenterChanged,
    FutureOr<void> Function()? onParticipantLeft,
  }) async {
    // Called when joined in meeting
    room
      ..on(
        Events.roomJoined,
        () {
          onRoomJoined?.call();
        },
      )

      // Called when meeting is ended
      ..on(Events.roomLeft, (errorMsg) {
        onRoomLeft?.call(errorMsg);
      });

    // Called when stream is enabled
    room.localParticipant.on(Events.streamEnabled, (stream) {
      final tempStream = stream as Stream;
      onStreamEnabled?.call(tempStream);
    });

    // Called when stream is disabled
    room.localParticipant.on(Events.streamDisabled, (stream) {
      final tempStream = stream as Stream;

      onStreamDisabled?.call(tempStream);
    });

    // Called when presenter is changed
    room
      ..on(Events.presenterChanged, (activePresenterId) {
        onPresenterChanged?.call(activePresenterId.toString());
      })
      ..on(
        Events.participantLeft,
        (participant) {
          onParticipantLeft?.call();
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
