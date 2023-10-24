import "package:flutter/material.dart";
import "package:telemed_chat/src/colors.dart";
import "package:telemed_chat/src/utils/spacer.dart";
import "package:touch_ripple_effect/touch_ripple_effect.dart";

// Meeting ActionBar
class MeetingActionBar extends StatelessWidget {
  const MeetingActionBar({
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isScreenShareEnabled,
    required this.recordingState,
    required this.onCallEndButtonPressed,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onSwitchMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onMoreOptionSelected,
    required this.onChatButtonPressed,
    Key? key,
  }) : super(key: key);

  // control states
  final bool isMicEnabled;
  final bool isCamEnabled;
  final bool isScreenShareEnabled;
  final String recordingState;

  // callback functions
  final void Function() onCallEndButtonPressed;
  final void Function() onCallLeaveButtonPressed;
  final void Function() onMicButtonPressed;
  final void Function() onCameraButtonPressed;
  final void Function() onChatButtonPressed;

  final void Function(String) onMoreOptionSelected;

  final void Function(TapDownDetails) onSwitchMicButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton(
            position: PopupMenuPosition.under,
            padding: const EdgeInsets.all(0),
            color: Colors.black87,
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red),
                color: Colors.red,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.call_end,
                size: 30,
                color: Colors.white,
              ),
            ),
            offset: const Offset(0, -185),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) => {
              if (value == "leave")
                onCallLeaveButtonPressed()
              else if (value == "end")
                onCallEndButtonPressed(),
            },
            itemBuilder: (context) => <PopupMenuEntry>[
              _buildMeetingPoupItem(
                "leave",
                "Leave",
                "Only you will leave the call",
                const Icon(Icons.exit_to_app),
              ),
              const PopupMenuDivider(),
              _buildMeetingPoupItem(
                "end",
                "End",
                "End call for all participants",
                const Icon(Icons.call_end_outlined),
              ),
            ],
          ),

          // Mic Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: isMicEnabled ? primaryColor : Colors.white,
            onTap: onMicButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: isMicEnabled ? primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    isMicEnabled ? Icons.mic : Icons.mic_off,
                    size: 30,
                    color: isMicEnabled ? Colors.white : primaryColor,
                  ),
                  GestureDetector(
                    onTapDown: (details) => {onSwitchMicButtonPressed(details)},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: isMicEnabled ? Colors.white : primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Camera Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: primaryColor,
            onTap: onCameraButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: isCamEnabled ? primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(10),
              child: isCamEnabled
                  ? const Icon(
                      Icons.videocam_rounded,
                      size: 26,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.videocam_off_rounded,
                      size: 26,
                      color: primaryColor,
                    ),
            ),
          ),

          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: primaryColor,
            onTap: onChatButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: primaryColor,
              ),
              padding: const EdgeInsets.all(10),
              child: const Icon(
                Icons.chat_bubble,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),

          // More options
          PopupMenuButton(
            position: PopupMenuPosition.under,
            padding: const EdgeInsets.all(0),
            color: black700,
            icon: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                // color: red,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.more_vert,
                size: 30,
                color: Colors.white,
              ),
            ),
            offset: const Offset(0, -250),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) => {onMoreOptionSelected(value.toString())},
            itemBuilder: (context) => <PopupMenuEntry>[
              _buildMeetingPoupItem(
                "recording",
                recordingState == "RECORDING_STARTED"
                    ? "Stop Recording"
                    : recordingState == "RECORDING_STARTING"
                        ? "Recording is starting"
                        : "Start Recording",
                null,
                const Icon(Icons.video_camera_back_outlined),
              ),
              const PopupMenuDivider(),
              _buildMeetingPoupItem(
                "screenshare",
                isScreenShareEnabled
                    ? "Stop Screen Share"
                    : "Start Screen Share",
                null,
                const Icon(Icons.screen_share),
              ),
              const PopupMenuDivider(),
              _buildMeetingPoupItem(
                "participants",
                "Participants",
                null,
                const Icon(Icons.supervised_user_circle_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<dynamic> _buildMeetingPoupItem(
    String value,
    String title,
    String? description,
    Widget leadingIcon,
  ) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
      child: Row(
        children: [
          leadingIcon,
          const HorizontalSpacer(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              if (description != null) const VerticalSpacer(4),
              if (description != null)
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: black400,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
