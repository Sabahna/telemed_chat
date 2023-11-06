import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

// Meeting ActionBar
class MeetingActionControl extends StatelessWidget {
  const MeetingActionControl({
    required this.isMicEnabled,
    required this.isCamEnabled,
    required this.isAudioSpeakerEnabled,
    required this.isFrontCamera,
    required this.onCallLeaveButtonPressed,
    required this.onMicButtonPressed,
    required this.onCameraButtonPressed,
    required this.onCameraSwitchButtonPressed,
    required this.onAudioSpeakerButtonPressed,
    required this.name,
    Key? key,
  }) : super(key: key);

  // control states
  final bool isMicEnabled;
  final bool isCamEnabled;
  final bool isAudioSpeakerEnabled;
  final bool isFrontCamera;

  // callback functions
  final void Function() onCallLeaveButtonPressed;
  final void Function() onMicButtonPressed;
  final void Function() onCameraButtonPressed;
  final void Function() onCameraSwitchButtonPressed;
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
          Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mic Control
              GestureDetector(
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
              GestureDetector(
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
              GestureDetector(
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
              GestureDetector(
                onTap: onCameraSwitchButtonPressed,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: isFrontCamera ? primaryColor : Colors.white,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ImageIcon(
                    const AssetImage("assets/switch-camera.png"),
                    color: isFrontCamera ? Colors.white : primaryColor,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
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
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
