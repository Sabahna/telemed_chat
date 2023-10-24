import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:telemed_chat/models/one_to_one_call.dart";
import "package:telemed_chat/src/widgets/common/app_bar/meeting_app_bar.dart";
import "package:telemed_chat/src/widgets/common/joining/participant_limit_reached.dart";
import "package:telemed_chat/src/widgets/common/joining/waiting_to_join.dart";
import "package:telemed_chat/src/widgets/common/meeting_controls/meeting_action_bar.dart";
import "package:telemed_chat/src/widgets/common/participant/participant_list.dart";
import "package:telemed_chat/src/widgets/one_to_one/one_to_one_meeting_container.dart";
import "package:videosdk/videosdk.dart";

class OneToOneMeetingScreen extends StatefulWidget {
  const OneToOneMeetingScreen({
    required this.oneToOneCall,
    Key? key,
  }) : super(key: key);
  final OneToOneCall oneToOneCall;

  @override
  _OneToOneMeetingScreenState createState() => _OneToOneMeetingScreenState();
}

class _OneToOneMeetingScreenState extends State<OneToOneMeetingScreen> {
  bool isRecordingOn = false;
  bool showChatSnackbar = true;
  String recordingState = "RECORDING_STOPPED";

  // Meeting
  late Room meeting;
  bool _joined = false;
  bool _moreThan2Participants = false;

  // Streams
  Stream? shareStream;
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  bool fullScreen = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    unawaited(initiative());
  }

  Future<void> initiative() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Create instance of Room (Meeting)
    final Room room = VideoSDK.createRoom(
      roomId: widget.oneToOneCall.meetingId,
      token: widget.oneToOneCall.token,
      displayName: widget.oneToOneCall.displayName,
      micEnabled: widget.oneToOneCall.micEnabled,
      camEnabled: widget.oneToOneCall.camEnabled,
      maxResolution: "hd",
      multiStream: false,
      defaultCameraIndex: 1,
      notification: widget.oneToOneCall.notificationInfo,
    );

    // Register meeting events
    registerMeetingEvents(room);

    // Join meeting
    await room.join();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined
          ? SafeArea(
              child: Scaffold(
                backgroundColor: Theme.of(context).primaryColor,
                body: Column(
                  children: [
                    MeetingAppBar(
                      meeting: meeting,
                      token: widget.oneToOneCall.token,
                      recordingState: recordingState,
                      isFullScreen: fullScreen,
                    ),
                    const Divider(),
                    Expanded(
                      child: GestureDetector(
                        onDoubleTap: () => {
                          setState(() {
                            fullScreen = !fullScreen;
                          }),
                        },
                        child: OneToOneMeetingContainer(meeting: meeting),
                      ),
                    ),
                    Column(
                      children: [
                        const Divider(),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: !fullScreen
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          secondChild: const SizedBox.shrink(),
                          firstChild: MeetingActionBar(
                            isMicEnabled: audioStream != null,
                            isCamEnabled: videoStream != null,
                            isScreenShareEnabled: shareStream != null,
                            recordingState: recordingState,
                            // Called when Call End button is pressed
                            onCallEndButtonPressed: () {
                              meeting.end();
                            },

                            onCallLeaveButtonPressed: () {
                              meeting.leave();
                            },
                            // Called when mic button is pressed
                            onMicButtonPressed: () async {
                              if (audioStream != null) {
                                await meeting.muteMic();
                              } else {
                                await meeting.unmuteMic();
                              }
                            },
                            // Called when camera button is pressed
                            onCameraButtonPressed: () async {
                              if (videoStream != null) {
                                await meeting.disableCam();
                              } else {
                                await meeting.enableCam();
                              }
                            },

                            onSwitchMicButtonPressed: (details) async {
                              final List<MediaDeviceInfo> outptuDevice =
                                  meeting.getAudioOutputDevices();
                              final double bottomMargin =
                                  (70.0 * outptuDevice.length);
                              final screenSize = MediaQuery.of(context).size;
                              await showMenu(
                                context: context,
                                color: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                position: RelativeRect.fromLTRB(
                                  screenSize.width - details.globalPosition.dx,
                                  details.globalPosition.dy - bottomMargin,
                                  details.globalPosition.dx,
                                  (bottomMargin),
                                ),
                                items: outptuDevice.map((e) {
                                  return PopupMenuItem(
                                    value: e,
                                    child: Text(e.label),
                                  );
                                }).toList(),
                                elevation: 8.0,
                              ).then((value) {
                                if (value != null) {
                                  meeting.switchAudioDevice(value);
                                }
                              });
                            },

                            onChatButtonPressed: () async {
                              debugPrint(
                                "----------------------chat button clicked----------------------",
                              );
                            },

                            // Called when more options button is pressed
                            onMoreOptionSelected: (option) async {
                              // Showing more options dialog box
                              if (option == "screenshare") {
                                if (remoteParticipantShareStream == null) {
                                  if (shareStream == null) {
                                    await meeting.enableScreenShare();
                                  } else {
                                    await meeting.disableScreenShare();
                                  }
                                } else {
                                  // TODO(jack): show already presenting
                                  // showSnackBarMessage(
                                  //   message: "Someone is already presenting",
                                  //   context: context,
                                  // );
                                }
                              } else if (option == "recording") {
                                if (recordingState == "RECORDING_STOPPING") {
                                  // TODO(jack): show recording is stopping
                                  // showSnackBarMessage(
                                  //   message: "Recording is in stopping state",
                                  //   context: context,
                                  // );
                                } else if (recordingState ==
                                    "RECORDING_STARTED") {
                                  await meeting.stopRecording();
                                } else if (recordingState ==
                                    "RECORDING_STARTING") {
                                  // TODO(jack): show start recording
                                  // showSnackBarMessage(
                                  //   message: "Recording is in starting state",
                                  //   context: context,
                                  // );
                                } else {
                                  await meeting.startRecording();
                                }
                              } else if (option == "participants") {
                                await showModalBottomSheet(
                                  context: context,
                                  // constraints: BoxConstraints(
                                  //     maxHeight: MediaQuery.of(context).size.height -
                                  //         statusbarHeight),
                                  isScrollControlled: false,
                                  builder: (context) =>
                                      ParticipantList(meeting: meeting),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : _moreThan2Participants
              ? ParticipantLimitReached(
                  meeting: meeting,
                )
              : const WaitingToJoin(),
    );
  }

  void registerMeetingEvents(Room roomMeeting) {
    // Called when joined in meeting
    roomMeeting
      ..on(
        Events.roomJoined,
        () async {
          if (roomMeeting.participants.length > 1) {
            setState(() {
              meeting = roomMeeting;
              _moreThan2Participants = true;
            });
          } else {
            setState(() {
              meeting = roomMeeting;
              _joined = true;
            });

            await subscribeToChatMessages(roomMeeting);
          }
        },
      )

      // Called when meeting is ended
      ..on(Events.roomLeft, (errorMsg) async {
        if (errorMsg != null) {
          // TODO(jack): reason meeting left
          // showSnackBarMessage(
          //     message: "Meeting left due to $errorMsg !!", context: context);
        }

        // TODO(jack): Navigate to screen when room end
        Navigator.of(context).pop();
        // await Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(builder: (context) => const JoinScreen()),
        //     (route) => false,);
      })

      // Called when recording is started
      ..on(Events.recordingStateChanged, (status) {
        // showSnackBarMessage(
        //     message:
        //         "Meeting recording ${status == "RECORDING_STARTING" ? "is starting" : status == "RECORDING_STARTED" ? "started" : status == "RECORDING_STOPPING" ? "is stopping" : "stopped"}",
        //     context: context,);

        setState(() {
          recordingState = status;
        });
      });

    // Called when stream is enabled
    roomMeeting.localParticipant.on(Events.streamEnabled, (stream) {
      final tempStream = stream as Stream;
      if (stream.kind == "video") {
        setState(() {
          videoStream = tempStream;
        });
      } else if (stream.kind == "audio") {
        setState(() {
          audioStream = tempStream;
        });
      } else if (stream.kind == "share") {
        setState(() {
          shareStream = tempStream;
        });
      }
    });

    // Called when stream is disabled
    roomMeeting.localParticipant.on(Events.streamDisabled, (stream) {
      final tempStream = stream as Stream;
      if (stream.kind == "video" && videoStream?.id == stream.id) {
        setState(() {
          videoStream = null;
        });
      } else if (stream.kind == "audio" && audioStream?.id == stream.id) {
        setState(() {
          audioStream = null;
        });
      } else if (stream.kind == "share" && shareStream?.id == stream.id) {
        setState(() {
          shareStream = null;
        });
      }
    });

    // Called when presenter is changed
    roomMeeting
      ..on(Events.presenterChanged, (activePresenterId) {
        final Participant? activePresenterParticipant =
            roomMeeting.participants[activePresenterId];

        // Get Share Stream
        final Stream? stream = activePresenterParticipant?.streams.values
            .singleWhere((e) => e.kind == "share");

        setState(() => remoteParticipantShareStream = stream);
      })
      ..on(
        Events.participantLeft,
        (participant) async => {
          if (_moreThan2Participants)
            {
              if (roomMeeting.participants.length < 2)
                {
                  setState(() {
                    _joined = true;
                    _moreThan2Participants = false;
                  }),
                  subscribeToChatMessages(roomMeeting),
                },
            },
        },
      )
      ..on(
        Events.error,
        (error) => {
          // TODO(jack): show error
          // showSnackBarMessage(
          //     message: "${error['name']} :: ${error['message']}",
          //     context: context),
        },
      );
  }

  Future<void> subscribeToChatMessages(Room meeting) async {
    await meeting.pubSub.subscribe("CHAT", (message) {
      if (message.senderId != meeting.localParticipant.id) {
        if (mounted) {
          if (showChatSnackbar) {
            // TODO(jack): chat message log
            // showSnackBarMessage(
            //     message: message.senderName + ": " + message.message,
            //     context: context);
          }
        }
      }
    });
  }

  Future<bool> _onWillPopScope() async {
    meeting.leave();
    return true;
  }

  @override
  void dispose() {
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
    );
    super.dispose();
  }
}
