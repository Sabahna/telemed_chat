import "package:flutter/material.dart";
import "package:telemed_chat/ui/widgets/common/stats/call_stats.dart";
import "package:videosdk/videosdk.dart";

class ParticipantView extends StatelessWidget {
  const ParticipantView({
    required this.stream,
    required this.isMicOn,
    required this.isFrontCamera,
    required this.participant,
    required this.onStopScreenSharePressed,
    Key? key,
    this.avatarTextSize = 50,
  }) : super(key: key);

  final Stream? stream;
  final bool isMicOn;
  final bool isFrontCamera;
  final Participant participant;
  final double avatarTextSize;
  final Function() onStopScreenSharePressed;
  final Color primaryColor = const Color(0xff088395);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        stream != null
            ? RTCVideoView(
                stream!.renderer!,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: isFrontCamera,
              )
            : Center(
                child: Container(
                  padding: EdgeInsets.all(avatarTextSize),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff05bfdb),
                        Color(0xff088395),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    participant.displayName.characters.first.toUpperCase(),
                    style: TextStyle(
                      fontSize: avatarTextSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CallStats(participant: participant),
              const SizedBox(
                height: 10,
              ),
              AnimatedOpacity(
                opacity: !isMicOn ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.mic_off,
                    size: avatarTextSize / 2,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
