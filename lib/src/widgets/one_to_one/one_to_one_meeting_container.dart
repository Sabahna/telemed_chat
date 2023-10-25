import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:telemed_chat/src/widgets/one_to_one/participant_view.dart";
import "package:videosdk/videosdk.dart";

class OneToOneMeetingContainer extends StatefulWidget {
  const OneToOneMeetingContainer({required this.meeting, Key? key})
      : super(key: key);
  final Room meeting;

  @override
  State<OneToOneMeetingContainer> createState() =>
      _OneToOneMeetingContainerState();
}

class _OneToOneMeetingContainerState extends State<OneToOneMeetingContainer> {
  Stream? localVideoStream;
  Stream? localShareStream;
  Stream? localAudioStream;
  Stream? remoteAudioStream;
  Stream? remoteVideoStream;
  Stream? remoteShareStream;

  Stream? largeViewStream;
  Stream? smallViewStream;
  Participant? largeParticipant;
  Participant? smallParticipant;
  Participant? localParticipant;
  Participant? remoteParticipant;
  String? activeSpeakerId;
  String? presenterId;

  bool isSmallViewLeftAligned = false;

  @override
  void initState() {
    localParticipant = widget.meeting.localParticipant;
    // Setting meeting event listeners
    setMeetingListeners(widget.meeting);

    try {
      remoteParticipant = widget.meeting.participants.isNotEmpty
          ? widget.meeting.participants.entries.first.value
          : null;
      if (remoteParticipant != null) {
        addParticipantListener(remoteParticipant!, isRemote: true);
      }
    } catch (_) {}
    addParticipantListener(localParticipant!, isRemote: false);
    super.initState();
    updateView();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void updateView() {
    Stream? tempLargeViewStream;
    Stream? tempSmallViewStream;
    if (remoteParticipant != null) {
      if (remoteShareStream != null) {
        tempLargeViewStream = remoteShareStream;
      } else if (localShareStream != null) {
        tempLargeViewStream = null;
      } else {
        tempLargeViewStream = remoteVideoStream;
      }
      if (remoteShareStream != null || localShareStream != null) {
        if (remoteVideoStream != null) {
          tempSmallViewStream = remoteVideoStream;
        }
      } else {
        tempSmallViewStream = localVideoStream;
      }
    } else {
      if (localShareStream != null) {
        tempSmallViewStream = localVideoStream;
      } else {
        tempLargeViewStream = localVideoStream;
      }
    }
    setState(() {
      largeViewStream = tempLargeViewStream;
      smallViewStream = tempSmallViewStream;
    });
  }

  void addParticipantListener(
    Participant participant, {
    required bool isRemote,
  }) {
    participant.streams.forEach((key, stream) {
      setState(() {
        if (stream.kind == "video") {
          if (isRemote) {
            remoteVideoStream = stream;
          } else {
            localVideoStream = stream;
          }
        } else if (stream.kind == "share") {
          if (isRemote) {
            remoteShareStream = stream;
          } else {
            localShareStream = stream;
          }
        } else if (stream.kind == "audio") {
          if (isRemote) {
            remoteAudioStream = stream;
          } else {
            localAudioStream = stream;
          }
        }
        updateView();
      });
    });
    participant
      ..on(Events.streamEnabled, (stream) {
        final tempStream = stream as Stream;
        setState(() {
          if (stream.kind == "video") {
            if (isRemote) {
              remoteVideoStream = tempStream;
            } else {
              localVideoStream = tempStream;
            }
          } else if (stream.kind == "share") {
            if (isRemote) {
              remoteShareStream = tempStream;
            } else {
              localShareStream = tempStream;
            }
          } else if (stream.kind == "audio") {
            if (isRemote) {
              remoteAudioStream = tempStream;
            } else {
              localAudioStream = tempStream;
            }
          }
          updateView();
        });
      })
      ..on(Events.streamDisabled, (stream) {
        final tempStream = stream as Stream;
        setState(() {
          if (stream.kind == "video") {
            if (isRemote) {
              remoteVideoStream = null;
            } else {
              localVideoStream = null;
            }
          } else if (stream.kind == "share") {
            if (isRemote) {
              remoteShareStream = null;
            } else {
              localShareStream = null;
            }
          } else if (stream.kind == "audio") {
            if (isRemote) {
              remoteAudioStream = null;
            } else {
              localAudioStream = null;
            }
          }
          updateView();
        });
      });
  }

  void setMeetingListeners(Room roomMeeting) {
    // Called when participant joined meeting
    roomMeeting
      ..on(
        Events.participantJoined,
        (participant) {
          setState(() {
            remoteParticipant = widget.meeting.participants.isNotEmpty
                ? widget.meeting.participants.entries.first.value
                : null;
            updateView();

            if (remoteParticipant != null) {
              addParticipantListener(remoteParticipant!, isRemote: true);
            }
          });
        },
      )

      // Called when participant left meeting
      ..on(
        Events.participantLeft,
        (participantId) {
          if (remoteParticipant?.id == participantId) {
            setState(() {
              remoteParticipant = null;
              remoteShareStream = null;
              remoteVideoStream = null;
              updateView();
            });
          }
          setState(() {
            remoteParticipant = widget.meeting.participants.isNotEmpty
                ? widget.meeting.participants.entries.first.value
                : null;
            if (remoteParticipant != null) {
              addParticipantListener(remoteParticipant!, isRemote: true);
              updateView();
            }
          });
        },
      )
      ..on(Events.presenterChanged, (newPresenterId) {
        setState(() {
          presenterId = newPresenterId;
        });
      })

      // Called when speaker is changed
      ..on(Events.speakerChanged, (newActiveSpeakerId) {
        setState(() {
          activeSpeakerId = newActiveSpeakerId;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    final bool isWebMobile = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Container(
              width: maxWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.5),
                    const Color(0xff088395).withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ParticipantView(
                avatarBackground: Colors.black87,
                stream: largeViewStream,
                isMicOn: remoteParticipant != null
                    ? remoteAudioStream != null
                    : localAudioStream != null,
                onStopScreenSharePressed: () async =>
                    widget.meeting.disableScreenShare(),
                participant: remoteParticipant != null
                    ? remoteParticipant!
                    : localParticipant!,
                isLocalScreenShare: localShareStream != null,
                isScreenShare:
                    remoteShareStream != null || localShareStream != null,
                avatarTextSize: 40,
              ),
            ),
            if (remoteParticipant != null || localShareStream != null)
              Positioned(
                right: isSmallViewLeftAligned ? null : 8,
                left: isSmallViewLeftAligned ? 8 : null,
                bottom: 8,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // Note: Sensitivity is integer used when you don't want to mess up vertical drag
                    const int sensitivity = 8;
                    if (details.delta.dx > sensitivity) {
                      // Right Swipe
                      setState(() {
                        isSmallViewLeftAligned = false;
                      });
                    } else if (details.delta.dx < -sensitivity) {
                      //Left Swipe
                      setState(() {
                        isSmallViewLeftAligned = true;
                      });
                    }
                  },
                  child: Container(
                    height: maxHeight / 4,
                    width: maxWidth / 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black54,
                    ),
                    child: ParticipantView(
                      avatarTextSize: 30,
                      avatarBackground: Colors.black54,
                      stream: smallViewStream,
                      isMicOn: (localAudioStream != null &&
                              remoteShareStream == null) ||
                          (remoteAudioStream != null &&
                              remoteShareStream != null),
                      onStopScreenSharePressed: () async =>
                          widget.meeting.disableScreenShare(),
                      participant: remoteShareStream != null
                          ? remoteParticipant!
                          : localParticipant!,
                      isScreenShare: false,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
