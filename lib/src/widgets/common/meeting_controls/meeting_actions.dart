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
    required this.name,
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

  final String name;

  final Color primaryColor = const Color(0xff088395);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TouchRippleEffect(
            borderRadius: BorderRadius.circular(0),
            rippleColor: Colors.white.withOpacity(0),
            onTap: () {},
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  "10:00",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mic Control
              TouchRippleEffect(
                borderRadius: BorderRadius.circular(200),
                rippleColor: isMicEnabled ? primaryColor : Colors.white,
                onTap: onMicButtonPressed,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: isMicEnabled ? primaryColor : Colors.white,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    isMicEnabled ? Icons.mic : Icons.mic_off,
                    size: 30,
                    color: isMicEnabled ? Colors.white : primaryColor,
                  ),
                ),
              ),

              // Camera Control
              TouchRippleEffect(
                borderRadius: BorderRadius.circular(200),
                rippleColor: primaryColor,
                onTap: onCameraButtonPressed,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: isCamEnabled ? primaryColor : Colors.white,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: isCamEnabled
                      ? const Icon(
                          Icons.videocam_rounded,
                          size: 30,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.videocam_off_rounded,
                          size: 30,
                          color: primaryColor,
                        ),
                ),
              ),

              // Audio output Control
              TouchRippleEffect(
                borderRadius: BorderRadius.circular(200),
                rippleColor:
                    isAudioSpeakerEnabled ? primaryColor : Colors.white,
                onTap: onAudioSpeakerButtonPressed,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: isAudioSpeakerEnabled ? primaryColor : Colors.white,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    isAudioSpeakerEnabled
                        ? CupertinoIcons.speaker_2_fill
                        : CupertinoIcons.speaker_1,
                    size: 30,
                    color: isAudioSpeakerEnabled ? Colors.white : primaryColor,
                  ),
                ),
              ),
              // Camera Reverse
              TouchRippleEffect(
                borderRadius: BorderRadius.circular(200),
                rippleColor: primaryColor,
                onTap: onCameraButtonPressed,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ImageIcon(
                    const AssetImage("assets/switch-camera.png"),
                    color: primaryColor,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          TouchRippleEffect(
            child: GestureDetector(
              onTap: onCallLeaveButtonPressed,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(color: Colors.red),
                  color: Colors.red,
                ),
                padding: const EdgeInsets.all(14),
                child: const Icon(
                  Icons.call_end,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 40,
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
          const HorizontalSpacer(200),
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
                    fontSize: 200,
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
