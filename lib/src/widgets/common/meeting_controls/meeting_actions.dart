import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:telemed_chat/src/colors.dart";
import "package:telemed_chat/src/utils/spacer.dart";
import "package:touch_ripple_effect/touch_ripple_effect.dart";

// Meeting ActionBar
class MeetingActionControl extends StatelessWidget {
  const MeetingActionControl({
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isAudioSpeakerEnabled,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onAudioSpeakerButtonPressed,
    Key? key,
  }) : super(key: key);

  // control states
  final bool isMicEnabled;
  final bool isCamEnabled;
  final bool isAudioSpeakerEnabled;

  // callback functions
  final void Function() onCallLeaveButtonPressed;
  final void Function() onMicButtonPressed;
  final void Function() onCameraButtonPressed;
  final void Function() onAudioSpeakerButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: onCallLeaveButtonPressed,
            child: Container(
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
              child: Icon(
                isMicEnabled ? Icons.mic : Icons.mic_off,
                size: 30,
                color: isMicEnabled ? Colors.white : primaryColor,
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

          // Audio output Control
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(12),
            rippleColor: isAudioSpeakerEnabled ? primaryColor : Colors.white,
            onTap: onAudioSpeakerButtonPressed,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: secondaryColor),
                color: isAudioSpeakerEnabled ? primaryColor : Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(
                isAudioSpeakerEnabled
                    ? CupertinoIcons.speaker_2_fill
                    : CupertinoIcons.speaker_1,
                size: 30,
                color: isAudioSpeakerEnabled ? Colors.white : primaryColor,
              ),
            ),
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
