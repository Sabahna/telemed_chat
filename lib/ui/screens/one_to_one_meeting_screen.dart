import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:telemed_chat/communication/communication.dart";
import "package:telemed_chat/src/callkit/callkit.dart";
import "package:telemed_chat/src/models/one_to_one_call.dart";
import "package:telemed_chat/src/models/output_audio_device.dart";
import "package:telemed_chat/ui/widgets/common/joining/participant_limit_reached.dart";
import "package:telemed_chat/ui/widgets/common/joining/waiting_to_join.dart";
import "package:telemed_chat/ui/widgets/common/meeting_controls/meeting_actions.dart";
import "package:telemed_chat/ui/widgets/one_to_one/one_to_one_meeting_container.dart";
import "package:videosdk/videosdk.dart";

class OneToOneMeetingScreen extends StatefulWidget {
  const OneToOneMeetingScreen({
    required this.oneToOneCall,
    required this.justView,
    required this.globalKey,
    required this.callKitVoip,
    required this.setCallEndFunc,
    required this.listenCallEnd,
    required this.updateRoom,
    this.callDeclineCallback,
    this.callEndCallback,
    Key? key,
  }) : super(key: key);

  final OneToOneCall oneToOneCall;
  final bool justView;
  final GlobalKey globalKey;
  final CallKitVOIP callKitVoip;

  final void Function(Future<void> Function() func) setCallEndFunc;
  final void Function({required bool status}) listenCallEnd;
  final void Function({
    OneToOneRoomState? roomState,
    bool reset,
    bool resetAudioStream,
    bool resetVideoStream,
  }) updateRoom;

  /// Callback functions for client
  final FutureOr<void> Function()? callDeclineCallback;
  final FutureOr<void> Function()? callEndCallback;

  @override
  _OneToOneMeetingScreenState createState() => _OneToOneMeetingScreenState();
}

class _OneToOneMeetingScreenState extends State<OneToOneMeetingScreen> {
  // Communication instance
  Communication communication = Communication();

  // Meeting
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

  // Event state data
  OneToOneEventState eventState = OneToOneEventState();

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

  /// Meeting screen initiative by creating room and join
  ///
  Future<void> initiative() async {
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );

    if (widget.justView) {
      currentOutputAudioDevice =
          widget.oneToOneCall.roomState.currentOutputAudioDevice!;
      final room = eventState.room!;
      communication.room = room;
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
      communication.createRoom(
        meetingId: widget.oneToOneCall.meetingId,
        token: widget.oneToOneCall.token,
        name: widget.oneToOneCall.displayName,
        camEnabled: widget.oneToOneCall.camEnabled,
        notificationInfo: widget.oneToOneCall.notificationInfo,
      );

      widget.updateRoom(
        roomState: widget.oneToOneCall.roomState.copyWith(
          currentOutputAudioDevice: currentOutputAudioDevice,
          isFrontCamera: isFrontCamera,
        ),
      );

      eventState.room = communication.room;

      // Join meeting
      await communication.room.join();
    }

    // Register meeting events
    unawaited(
      // registerEvents(),
      communication.registerEvents(
        onRoomJoined: _roomJoined,
        onRoomLeft: _roomLeft,
        onStreamEnabled: _streamEnabled,
        onStreamDisabled: _streamDisabled,
        onPresenterChanged: _presenterChanged,
        onParticipantLeft: _participantLeft,
      ),
    );
  }

  /// -------------------------------- Room Events -------------------------
  ///

  void _roomJoined() {
    if (mounted) {
      final room = communication.room;
      if (room.participants.length > 1) {
        setState(() {
          _moreThan2Participants = true;
        });
      } else {
        setState(() {
          _joined = true;
        });
      }

      updateDeviceList(room);
      widget.setCallEndFunc(meetingCallEnd);
    }
  }

  void _roomLeft(errorMsg) {
    if (mounted) {
      if (errorMsg != null) {
        // TODO(jack): reason meeting left
        // showSnackBarMessage(
        //     message: "Meeting left due to $errorMsg !!", context: context);
      }
      debugPrint("----------------------room left----------------------");

      // TODO(jack): This event called whoever left from the meeting including yourself. This may take effect in group meeting but still ok 😅. Tips:=> Events.participantLeft
      widget.listenCallEnd(status: true);
      widget.updateRoom(reset: true);

      if (!eventState.isMinimized) {
        if (mounted) {
          Navigator.of(widget.globalKey.currentContext!).pop(false);
        }
      }
    }
  }

  void _streamEnabled(Stream stream) {
    if (mounted) {
      if (stream.kind == "video") {
        setState(() {
          videoStream = stream;
        });

        widget.updateRoom(
          roomState:
              widget.oneToOneCall.roomState.copyWith(videoStream: stream),
        );
      } else if (stream.kind == "audio") {
        setState(() {
          audioStream = stream;
        });
        widget.updateRoom(
          roomState:
              widget.oneToOneCall.roomState.copyWith(audioStream: stream),
        );
      }
    }
  }

  void _streamDisabled(Stream stream) {
    if (mounted) {
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
    }
  }

  void _presenterChanged(activePresenterId) {
    if (mounted) {
      updateRemoteParticipantStream(activePresenterId);
      widget.updateRoom(
        roomState: widget.oneToOneCall.roomState.copyWith(
          activePresenterId: activePresenterId,
        ),
      );
    }
  }

  void _participantLeft() {
    if (mounted) {
      if (_moreThan2Participants) {
        if (communication.room.participants.length < 2) {
          setState(() {
            _joined = true;
            _moreThan2Participants = false;
          });
        }
      }
    }
  }

  /// -----------------------------------------------------------------

  /// -------------------------------- Call action controls -------------------------
  ///

  // Do when call end
  Future<void> _onCallLeaveButtonPressed() async {
    /// for just caller to notify call decline at the moment of not answering from receiver
    if (communication.room.participants.isEmpty) {
      widget.callDeclineCallback?.call();
      await _roomEnd();
    } else {
      await meetingCallEnd();
    }
  }

  // To be enable or disable of Mic
  Future<void> _onMicButtonPressed() async {
    final room = communication.room;
    if (audioStream != null) {
      await room.muteMic();
    } else {
      await room.unmuteMic();
    }
  }

  // To switch the front or back camera
  Future<void> _onSwitchCameraButtonPressed() async {
    final room = communication.room;

    final MediaDeviceInfo newCam = cameras.firstWhere(
      (camera) => camera.deviceId != room.selectedCamId,
    );
    isSwitchingCamera = true;
    await room.changeCam(newCam.deviceId);
    isSwitchingCamera = false;

    setState(() {
      isFrontCamera = !isFrontCamera;
    });
    widget.updateRoom(
      roomState: widget.oneToOneCall.roomState.copyWith(
        isFrontCamera: isFrontCamera,
      ),
    );
  }

  // To be enable or disable of Camera
  Future<void> _onCameraButtonPressed() async {
    final room = communication.room;

    if (videoStream != null) {
      await room.disableCam();
    } else {
      await room.enableCam();
    }
  }

  // To open or close of speaker
  Future<void> _onAudioSpeakerButtonPressed() async {
    final room = communication.room;

    if (currentOutputAudioDevice == OutputAudioDevices.speakerphone) {
      final audioDevice = outputAudioDevices.firstWhere(
        (element) => element.label == OutputAudioDevices.earpiece.name,
      );
      await room.switchAudioDevice(audioDevice);
      setState(() {
        currentOutputAudioDevice = OutputAudioDevices.earpiece;
      });
      widget.updateRoom(
        roomState: widget.oneToOneCall.roomState.copyWith(
          currentOutputAudioDevice: OutputAudioDevices.earpiece,
        ),
      );
    } else {
      final audioDevice = outputAudioDevices.firstWhere(
        (element) => element.label == OutputAudioDevices.speakerphone.name,
      );
      await room.switchAudioDevice(audioDevice);
      setState(() {
        currentOutputAudioDevice = OutputAudioDevices.speakerphone;
      });
      widget.updateRoom(
        roomState: widget.oneToOneCall.roomState.copyWith(
          currentOutputAudioDevice: OutputAudioDevices.speakerphone,
        ),
      );
    }
  }

  /// -----------------------------------------------------------------
  ///

  /// Updating remote participant stream
  ///
  void updateRemoteParticipantStream(dynamic activePresenterId) {
    final Participant? activePresenterParticipant =
        communication.room.participants[activePresenterId];

    // Get Share Stream
    final Stream? stream = activePresenterParticipant?.streams.values
        .singleWhere((e) => e.kind == "share");

    setState(() => remoteParticipantShareStream = stream);
  }

  /// WillPopScope function
  Future<bool> _onWillPopScope() async {
    Navigator.of(context).pop(true);
    return false;
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
  Future<void> meetingCallEnd() async {
    widget.callEndCallback?.call();
    await _roomEnd();
  }

  /// room end
  ///
  Future<void> _roomEnd() async {
    widget.updateRoom(reset: true);
    communication.room.end();
    await widget.callKitVoip.callEnd();
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
                          meeting: communication.room,
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
                        onCallLeaveButtonPressed: _onCallLeaveButtonPressed,
                        onMicButtonPressed: _onMicButtonPressed,
                        onCameraButtonPressed: _onCameraButtonPressed,
                        onCameraSwitchButtonPressed:
                            _onSwitchCameraButtonPressed,
                        onAudioSpeakerButtonPressed:
                            _onAudioSpeakerButtonPressed,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _moreThan2Participants
              ? ParticipantLimitReached(
                  meeting: communication.room,
                )
              : const WaitingToJoin(),
    );
  }
}
