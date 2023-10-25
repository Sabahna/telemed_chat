import "package:flutter/material.dart";
import "package:telemed_chat/src/utils/spacer.dart";
import "package:telemed_chat/src/widgets/common/stats/call_stats.dart";
import "package:videosdk/videosdk.dart";

class ParticipantView extends StatelessWidget {
  const ParticipantView({
    required this.stream,
    required this.isMicOn,
    required this.avatarBackground,
    required this.participant,
    required this.isScreenShare,
    required this.onStopScreenSharePressed,
    Key? key,
    this.isLocalScreenShare = false,
    this.avatarTextSize = 50,
  }) : super(key: key);
  final Stream? stream;
  final bool isMicOn;
  final Color? avatarBackground;
  final Participant participant;
  final bool isLocalScreenShare;
  final bool isScreenShare;
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
                mirror: true,
              )
            : Center(
                child: !isLocalScreenShare
                    ? Container(
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
                          participant.displayName.characters.first
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: avatarTextSize,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.screen_share_outlined,
                            size: 40,
                          ),
                          const VerticalSpacer(20),
                          const Text(
                            "You are presenting to everyone",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const VerticalSpacer(20),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 30,
                            ),
                            color: Colors.purple,
                            onPressed: onStopScreenSharePressed,
                            child: const Text(
                              "Stop Presenting",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
              ),
        Positioned(
          top: 50,
          right: 12,
          child: Column(
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
        if (isScreenShare)
          Positioned(
            bottom: 35,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black87,
              ),
              child: Text(
                isScreenShare
                    ? "${isLocalScreenShare ? "You" : participant.displayName} is presenting"
                    : participant.displayName,
              ),
            ),
          ),
      ],
    );
  }
}
