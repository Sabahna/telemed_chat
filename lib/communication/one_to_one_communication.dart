import "package:flutter/material.dart";
import "package:telemed_chat/models/one_to_one_call.dart";
import "package:telemed_chat/src/api/api.dart";
import "package:telemed_chat/src/utils/toast.dart";
import "package:telemed_chat/telemed_chat.dart";

class OneToOneCommunication {
  OneToOneCommunication({required this.oneToOneCall});

  final OneToOneCall oneToOneCall;

  Future<void> createAndJoin(BuildContext context) async {
    try {
      final meetingID = await Api.I.createMeeting(oneToOneCall.token);

      if (context.mounted) {
        oneToOneCall.meetingId = meetingID;
        await _navigateOneToOneMeeting(context);
      }
    } catch (error) {
      if (context.mounted) {
        showSnackBarMessage(message: error.toString(), context: context);
      }
    }
  }

  Future<void> join(String meetingId, BuildContext context) async {
    if (meetingId.isEmpty) {
      showSnackBarMessage(
        message: "Please enter Valid Meeting ID",
        context: context,
      );
      return;
    }
    final validMeeting =
        await Api.I.validateMeeting(oneToOneCall.token, meetingId);

    if (validMeeting) {
      if (context.mounted) {
        oneToOneCall.meetingId = meetingId;

        await _navigateOneToOneMeeting(context);
      }
    } else {
      if (context.mounted) {
        showSnackBarMessage(message: "Invalid Meeting ID", context: context);
      }
    }
  }

  Future<void> _navigateOneToOneMeeting(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneToOneMeetingScreen(
          oneToOneCall: oneToOneCall,
        ),
      ),
    );
  }
}
