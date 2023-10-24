import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:telemed_chat/src/api/api.dart";
import "package:telemed_chat/src/utils/spacer.dart";
import "package:telemed_chat/src/widgets/common/app_bar/recording_indicator.dart";
import "package:videosdk/videosdk.dart";

class MeetingAppBar extends StatefulWidget {
  const MeetingAppBar({
    required this.meeting,
    required this.token,
    required this.isFullScreen,
    required this.recordingState,
    Key? key,
  }) : super(key: key);
  final String token;
  final Room meeting;
  final String recordingState;
  final bool isFullScreen;

  @override
  State<MeetingAppBar> createState() => MeetingAppBarState();
}

class MeetingAppBarState extends State<MeetingAppBar> {
  Duration? elapsedTime;
  Timer? sessionTimer;

  List<MediaDeviceInfo> cameras = [];

  @override
  void initState() {
    unawaited(startTimer());

    // Holds available cameras info
    cameras = widget.meeting.getCameras();
    super.initState();
  }

  Future<void> startTimer() async {
    final session = await Api.I.fetchSession(widget.token, widget.meeting.id);
    final DateTime sessionStartTime = DateTime.parse(session["start"]);
    final difference = DateTime.now().difference(sessionStartTime);

    setState(() {
      elapsedTime = difference;
      sessionTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            elapsedTime = Duration(
              seconds: elapsedTime != null ? elapsedTime!.inSeconds + 1 : 0,
            );
          });
        },
      );
    });
    // log("session start time" + session.data[0].start.toString());
  }

  @override
  void dispose() {
    if (sessionTimer != null) {
      sessionTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: !widget.isFullScreen
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      secondChild: const SizedBox.shrink(),
      firstChild: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 8.0, 0.0),
        child: Row(
          children: [
            if (widget.recordingState == "RECORDING_STARTING" ||
                widget.recordingState == "RECORDING_STOPPING" ||
                widget.recordingState == "RECORDING_STARTED")
              RecordingIndicator(recordingState: widget.recordingState),
            if (widget.recordingState == "RECORDING_STARTING" ||
                widget.recordingState == "RECORDING_STOPPING" ||
                widget.recordingState == "RECORDING_STARTED")
              const HorizontalSpacer(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.meeting.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          child: Icon(
                            Icons.copy,
                            size: 16,
                          ),
                        ),
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: widget.meeting.id),
                          );
                          // TODO(jack): to show snackbar
                          // showSnackBarMessage(
                          //     message: "Meeting ID has been copied.",
                          //     context: context);
                        },
                      ),
                    ],
                  ),
                  Text(
                    elapsedTime == null
                        ? "00:00:00"
                        : elapsedTime.toString().split(".").first,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 24,
              ),
              onPressed: () async {
                final MediaDeviceInfo newCam = cameras.firstWhere(
                  (camera) => camera.deviceId != widget.meeting.selectedCamId,
                );
                await widget.meeting.changeCam(newCam.deviceId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
