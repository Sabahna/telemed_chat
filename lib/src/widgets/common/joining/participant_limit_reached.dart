import "package:flutter/material.dart";
import "package:telemed_chat/src/utils/spacer.dart";
import "package:videosdk/videosdk.dart";

class ParticipantLimitReached extends StatelessWidget {
  const ParticipantLimitReached({required this.meeting, Key? key})
      : super(key: key);
  final Room meeting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "OOPS!!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const VerticalSpacer(20),
            const Text(
              "Maximun 2 participants can join this meeting",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const VerticalSpacer(10),
            const Text(
              "Please try again later",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const VerticalSpacer(20),
            MaterialButton(
              onPressed: () {
                meeting.leave();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.purple,
              child: const Text("Ok", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}