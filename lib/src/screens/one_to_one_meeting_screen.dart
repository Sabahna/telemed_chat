import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:telemed_chat/models/one_to_one_call.dart";
import "package:telemed_chat/src/widgets/common/joining/participant_limit_reached.dart";
import "package:telemed_chat/src/widgets/common/joining/waiting_to_join.dart";
import "package:telemed_chat/src/widgets/common/meeting_controls/meeting_actions.dart";
import "package:telemed_chat/src/widgets/one_to_one/one_to_one_meeting_container.dart";
import "package:videosdk/videosdk.dart";

enum OutputAudioDevices {
  speakerphone("Speakerphone"),
  earpiece("Earpiece");

  const OutputAudioDevices(this.name);

  final String name;
}

class OneToOneMeetingScreen extends StatefulWidget {
  const OneToOneMeetingScreen({
    required this.oneToOneCall,
    required this.justView,
    this.updateRoom,
    Key? key,
  }) : super(key: key);
  final OneToOneCall oneToOneCall;
  final bool justView;
  final void Function(Room value)? updateRoom;

  @override
  _OneToOneMeetingScreenState createState() => _OneToOneMeetingScreenState();
}

class _OneToOneMeetingScreenState extends State<OneToOneMeetingScreen> {
  bool showChatSnackbar = true;
  String recordingState = "RECORDING_STOPPED";

  // Meeting
  late Room meeting;
  bool _joined = false;
  bool _moreThan2Participants = false;
  OutputAudioDevices currentOutputAudioDevice = OutputAudioDevices.earpiece;
  List<MediaDeviceInfo> outputAudioDevices = [];

  // Streams
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

    late Room room;

    if (widget.justView) {
      room = widget.oneToOneCall.room;
    } else {
      // Create instance of Room (Meeting)
      room = VideoSDK.createRoom(
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

      widget.updateRoom!(room);
    }

    // Register meeting events
    registerMeetingEvents(room);

    // update output audio devices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        outputAudioDevices.addAll(room.getAudioOutputDevices());
      });
    });

    // Join meeting
    if (!widget.justView) {
      await room.join();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: _joined
          ? Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: Stack(
                children: [
                  /// one-to-one video renderer
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => {
                        setState(() {
                          fullScreen = !fullScreen;
                        }),
                      },
                      child: Container(
                        width: double.infinity,
                        color: Colors.red,
                        child: OneToOneMeetingContainer(meeting: meeting),
                      ),
                    ),
                  ),

                  // MeetingAppBar(
                  //   meeting: meeting,
                  //   token: widget.oneToOneCall.token,
                  //   recordingState: recordingState,
                  //   isFullScreen: fullScreen,
                  // ),

                  /// Back Button
                  Positioned(
                    top: 35,
                    left: 15,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 400),
                      reverseDuration: const Duration(milliseconds: 400),
                      crossFadeState: !fullScreen
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      secondChild: const SizedBox.shrink(),
                      firstChild: MeetingActionControl(
                        name: widget.oneToOneCall.displayName,
                        isMicEnabled: audioStream != null,
                        isCamEnabled: videoStream != null,
                        isAudioSpeakerEnabled: currentOutputAudioDevice ==
                            OutputAudioDevices.speakerphone,
                        // Called when Call End button is pressed
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

                        onAudioSpeakerButtonPressed: () async {
                          if (currentOutputAudioDevice ==
                              OutputAudioDevices.speakerphone) {
                            final audioDevice = outputAudioDevices.firstWhere(
                              (element) =>
                                  element.label ==
                                  OutputAudioDevices.earpiece.name,
                            );
                            await meeting.switchAudioDevice(audioDevice);
                            setState(() {
                              currentOutputAudioDevice =
                                  OutputAudioDevices.earpiece;
                            });
                          } else {
                            final audioDevice = outputAudioDevices.firstWhere(
                              (element) =>
                                  element.label ==
                                  OutputAudioDevices.speakerphone.name,
                            );
                            await meeting.switchAudioDevice(audioDevice);
                            setState(() {
                              currentOutputAudioDevice =
                                  OutputAudioDevices.speakerphone;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
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
