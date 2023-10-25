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
                        padding: EdgeInsets.all(avatarTextSize / 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: avatarBackground,
                        ),
                        child: Text(
                          participant.displayName.characters.first
                              .toUpperCase(),
                          style: TextStyle(fontSize: avatarTextSize),
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
        if (!isMicOn)
          Positioned(
            top: 35,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.mic_off,
                size: avatarTextSize / 2,
              ),
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
        Positioned(
          top: 35,
          left: 4,
          child: CallStats(participant: participant),
        ),
      ],
    );
  }
}
