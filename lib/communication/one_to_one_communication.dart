import "dart:async";

import "package:flutter/material.dart";
import "package:telemed_chat/models/one_to_one_call.dart";
import "package:telemed_chat/src/api/api.dart";
import "package:telemed_chat/src/utils/toast.dart";
import "package:telemed_chat/telemed_chat.dart";

class OneToOneCommunication {
  OneToOneCommunication({required this.oneToOneCall, required this.globalKey});

  final OneToOneCall oneToOneCall;

  /// When user join or create call, I have listened to pop widget when call is end.
  /// In the same time, user can also be minimized while calling
  ///
  final GlobalKey globalKey;

  Future<bool?> createAndJoin(
    BuildContext context,
    FutureOr<void> Function(String meetingId) callBack,
  ) async {
    try {
      final meetingID = await Api.I.createMeeting(oneToOneCall.token);

      callBack(meetingID);

      if (context.mounted) {
        oneToOneCall.meetingId = meetingID;
        return await _navigateOneToOneMeeting(
          context,
        );
      }
    } catch (error) {
      if (context.mounted) {
        showSnackBarMessage(message: error.toString(), context: context);
      }
      throw error.toString();
    }

    return null;
  }

  Future<bool?> join(String meetingId, BuildContext context) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
        message: "Please enter Valid Meeting ID",
        context: context,
      );
      return null;
    }
    final validMeeting =
        await Api.I.validateMeeting(oneToOneCall.token, meetingId);

    if (validMeeting) {
      if (context.mounted) {
        oneToOneCall.meetingId = meetingId;

        return await _navigateOneToOneMeeting(
          context,
        );
      }
    } else {
      if (context.mounted) {
        showSnackBarMessage(message: "Invalid Meeting ID", context: context);
      }
      return null;
    }
    return null;
  }

  Future<bool> viewCommunication(BuildContext context) async {
    return await _navigateOneToOneMeeting(
      context,
      justView: true,
    );
  }

  void _updateRoomState({
    OneToOneRoomState? roomState,
    bool reset = false,
    bool resetAudioStream = false,
    bool resetVideoStream = false,
  }) {
    if (reset) {
      oneToOneCall.roomState = OneToOneRoomState();
      return;
    } else if (resetAudioStream) {
      oneToOneCall.roomState.audioStream = null;
    } else if (resetVideoStream) {
      oneToOneCall.roomState.videoStream = null;
    } else if (roomState != null) {
      oneToOneCall.roomState = roomState;
    }
  }

  Future<bool> _navigateOneToOneMeeting(
    BuildContext context, {
    bool justView = false,
  }) async {
    late bool isMinimized;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneToOneMeetingScreen(
          oneToOneCall: oneToOneCall,
          justView: justView,
          globalKey: globalKey,
          updateRoom: _updateRoomState,
        ),
      ),
    ).then((value) {
      isMinimized = value;
    });

    return isMinimized;
  }
}
