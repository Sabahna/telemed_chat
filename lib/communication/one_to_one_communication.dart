import "dart:async";

import "package:flutter/material.dart";
import "package:telemed_chat/src/api/api.dart";
import "package:telemed_chat/telemed_chat.dart";
import "package:telemed_chat/ui/utils/toast.dart";

class OneToOneCommunication {
  OneToOneCommunication({
    required this.oneToOneCall,
    required this.globalKey,
  });

  final OneToOneCall oneToOneCall;

  /// When user join or create call, I have listened to pop widget when call is end.
  /// In the same time, user can also be minimized while calling
  ///
  final GlobalKey globalKey;

  final StreamController<bool> _callEndStream = StreamController<bool>();
  late StreamSubscription<bool> _callEndStreamSubscribe;

  /// You can call this method when calling, otherwise this may be null 😅
  Future<void> Function()? callEnd;

  /// When caller ended at the moment of not answering from partner.
  ///
  FutureOr<void> Function()? _callDeclineCallback;

  /// Call end callback action for client
  ///
  FutureOr<void> Function()? _callEndCallback;

  final callKitVoip = CallKitVOIP();

  /// true -> when screen is minimized while calling
  Future<bool?> createAndJoin({
    required BuildContext context,
    required FutureOr<void> Function(String id) onMeetingId,
    required FutureOr<void> Function() onCallDecline,
    FutureOr<void> Function()? onCallEndAction,
  }) async {
    try {
      final meetingID = await Api.I.createMeeting(oneToOneCall.token);

      onMeetingId(meetingID);

      if (context.mounted) {
        oneToOneCall.meetingId = meetingID;
        _callDeclineCallback = onCallDecline;
        _callEndCallback = onCallEndAction;

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

  /// true -> when screen is minimized while calling
  Future<bool?> join({
    required String meetingId,
    required BuildContext context,
    FutureOr<void> Function()? callEndAction,
  }) async {
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
        _callEndCallback = callEndAction;

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

  /// true -> when screen is minimized while calling
  Future<bool> viewCommunication(BuildContext context) async {
    return await _navigateOneToOneMeeting(
      context,
      justView: true,
    );
  }

  void listenCallEnd(
    FutureOr<void> Function({required bool callEnd}) callBack,
  ) {
    _callEndStreamSubscribe = _callEndStream.stream.listen((event) async {
      callBack(callEnd: event);
    });
  }

  void disposeCallEnd() {
    unawaited(_callEndStreamSubscribe.cancel());
  }

  Future<void> _updateRoomState({
    OneToOneRoomState? roomState,
    bool reset = false,
    bool resetAudioStream = false,
    bool resetVideoStream = false,
  }) async {
    if (reset) {
      oneToOneCall.roomState = OneToOneRoomState();
      OneToOneEventState.I.room = null;
      callEnd = null;
      _callDeclineCallback = null;
      _callEndCallback = null;
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
    _callEndStream.add(false);
    OneToOneEventState.I.isMinimized = false;

    late bool state;
    await Navigator.of(context, rootNavigator: true)
        .push(
      MaterialPageRoute(
        builder: (context) => OneToOneMeetingScreen(
          oneToOneCall: oneToOneCall,
          justView: justView,
          globalKey: globalKey,
          setCallEndFunc: _setCallEndFunc,
          listenCallEnd: _listenCallEnd,
          updateRoom: _updateRoomState,
          callKitVoip: callKitVoip,
          callDeclineCallback: _callDeclineCallback,
          callEndCallback: _callEndCallback,
        ),
      ),
    )
        .then((value) {
      OneToOneEventState.I.isMinimized = value;
      state = value;
    });

    return state;
  }

  void _setCallEndFunc(Future<void> Function() func) {
    callEnd = func;
  }

  void _listenCallEnd({required bool status}) {
    _callEndStream.add(status);
  }
}
