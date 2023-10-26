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
    required this.globalKey,
    required this.updateCallEndFunc,
    required this.updateRoom,
    Key? key,
  }) : super(key: key);
  final OneToOneCall oneToOneCall;
  final bool justView;
  final GlobalKey globalKey;

  /// update method
  ///
  final void Function(void Function()? func) updateCallEndFunc;
  final void Function({
    OneToOneRoomState? roomState,
    bool reset,
    bool resetAudioStream,
    bool resetVideoStream,
  }) updateRoom;

  @override
  _OneToOneMeetingScreenState createState() => _OneToOneMeetingScreenState();
}

class _OneToOneMeetingScreenState extends State<OneToOneMeetingScreen> {
  // Meeting
  late Room meeting;
  bool _joined = false;
  bool _moreThan2Participants = false;
  List<MediaDeviceInfo> outputAudioDevices = [];
  List<MediaDeviceInfo> cameras = [];

  // Streams
  Stream? videoStream;
  Stream? audioStream;
  Stream? remoteParticipantShareStream;

  bool fullScreen = false;
  OutputAudioDevices currentOutputAudioDevice = OutputAudioDevices.earpiece;
  bool isSwitchingCamera = false;
  bool isFrontCamera = true;

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
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );

    late Room room;

    if (widget.justView) {
      currentOutputAudioDevice =
          widget.oneToOneCall.roomState.currentOutputAudioDevice!;
      room = widget.oneToOneCall.roomState.room!;
      meeting = room;
      _joined = true;
      audioStream = widget.oneToOneCall.roomState.audioStream;
      videoStream = widget.oneToOneCall.roomState.videoStream;
      isFrontCamera = widget.oneToOneCall.roomState.isFrontCamera;
      updateRemoteParticipantStream(
        widget.oneToOneCall.roomState.activePresenterId,
      );

      updateDeviceList(room);
    } else {
      if (widget.oneToOneCall.speakerEnabled) {
        currentOutputAudioDevice = OutputAudioDevices.speakerphone;
      }
      // Create instance of Room (Meeting)
      room = VideoSDK.createRoom(
        roomId: widget.oneToOneCall.meetingId,
        token: widget.oneToOneCall.token,
        displayName: widget.oneToOneCall.displayName,
        camEnabled: widget.oneToOneCall.camEnabled,
        maxResolution: "hd",
        multiStream: false,
        defaultCameraIndex: 1,
        notification: widget.oneToOneCall.notificationInfo,
      );

      // Register meeting events
      registerMeetingEvents(room);

      widget.updateRoom(
        roomState: widget.oneToOneCall.roomState.copyWith(
          room: room,
          currentOutputAudioDevice: currentOutputAudioDevice,
          isFrontCamera: isFrontCamera,
        ),
      );

      // Join meeting
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
                      child: SizedBox(
                        width: double.infinity,
                        child: OneToOneMeetingContainer(
                          meeting: meeting,
                          isFrontCamera: isFrontCamera,
                        ),
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
                    top: 50,
                    left: 15,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xff088395),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 25,
                          color: Colors.white,
                        ),
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
                        isFrontCamera: isFrontCamera,
                        // Called when Call End button is pressed
                        onCallLeaveButtonPressed: meetingCallEnd,

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

                        // Called when camera switch button is pressed
                        onCameraSwitchButtonPressed: () async {
                          final MediaDeviceInfo newCam = cameras.firstWhere(
                            (camera) =>
                                camera.deviceId != meeting.selectedCamId,
                          );
                          isSwitchingCamera = true;
                          await meeting.changeCam(newCam.deviceId);
                          isSwitchingCamera = false;

                          setState(() {
                            isFrontCamera = !isFrontCamera;
                          });
                          widget.updateRoom(
                            roomState: widget.oneToOneCall.roomState.copyWith(
                              isFrontCamera: isFrontCamera,
                            ),
                          );
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
                            widget.updateRoom(
                              roomState: widget.oneToOneCall.roomState.copyWith(
                                currentOutputAudioDevice:
                                    OutputAudioDevices.earpiece,
                              ),
                            );
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
                            widget.updateRoom(
                              roomState: widget.oneToOneCall.roomState.copyWith(
                                currentOutputAudioDevice:
                                    OutputAudioDevices.speakerphone,
                              ),
                            );
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

          updateDeviceList(roomMeeting);
          widget.updateCallEndFunc(meetingCallEnd);
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
        Navigator.of(widget.globalKey.currentContext!).pop(false);
      });

    // Called when stream is enabled
    roomMeeting.localParticipant.on(Events.streamEnabled, (stream) {
      final tempStream = stream as Stream;
      if (stream.kind == "video") {
        setState(() {
          videoStream = tempStream;
        });

        widget.updateRoom(
          roomState:
              widget.oneToOneCall.roomState.copyWith(videoStream: tempStream),
        );
      } else if (stream.kind == "audio") {
        setState(() {
          audioStream = tempStream;
        });
        widget.updateRoom(
          roomState:
              widget.oneToOneCall.roomState.copyWith(audioStream: tempStream),
        );
      }
    });

    // Called when stream is disabled
    roomMeeting.localParticipant.on(Events.streamDisabled, (stream) {
      final tempStream = stream as Stream;

      if (!isSwitchingCamera) {
        if (stream.kind == "video" && videoStream?.id == stream.id) {
          setState(() {
            videoStream = null;
          });
          widget.updateRoom(
            resetVideoStream: true,
          );
        } else if (stream.kind == "audio" && audioStream?.id == stream.id) {
          setState(() {
            audioStream = null;
          });

          widget.updateRoom(
            resetAudioStream: true,
          );
        }
      }
    });

    // Called when presenter is changed
    roomMeeting
      ..on(Events.presenterChanged, (activePresenterId) {
        updateRemoteParticipantStream(activePresenterId);
        widget.updateRoom(
          roomState: widget.oneToOneCall.roomState.copyWith(
            activePresenterId: activePresenterId,
          ),
        );
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

  void updateRemoteParticipantStream(dynamic activePresenterId) {
    final Participant? activePresenterParticipant =
        meeting.participants[activePresenterId];

    // Get Share Stream
    final Stream? stream = activePresenterParticipant?.streams.values
        .singleWhere((e) => e.kind == "share");

    setState(() => remoteParticipantShareStream = stream);
  }

  Future<bool> _onWillPopScope() async {
    meetingCallEnd();
    return true;
  }

  // update output audio devices
  void updateDeviceList(Room roomMeeting) {
    final deviceList = roomMeeting.getAudioOutputDevices();
    setState(() {
      outputAudioDevices.addAll(deviceList);
    });

    // Holds available cameras info
    cameras = roomMeeting.getCameras();
  }

  /// meeting call end
  ///
  void meetingCallEnd() {
    widget.updateRoom(reset: true);
    meeting.end();
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
