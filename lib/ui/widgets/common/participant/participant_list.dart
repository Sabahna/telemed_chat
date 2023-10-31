import "package:flutter/material.dart";
import "package:telemed_chat/src/colors.dart";
import "package:telemed_chat/ui/widgets/common/participant/participant_list_item.dart";
import "package:videosdk/videosdk.dart";

class ParticipantList extends StatefulWidget {
  const ParticipantList({required this.meeting, Key? key}) : super(key: key);
  final Room meeting;

  @override
  State<ParticipantList> createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  Map<String, Participant> _participants = {};

  @override
  void initState() {
    _participants
      ..putIfAbsent(
        widget.meeting.localParticipant.id,
        () => widget.meeting.localParticipant,
      )
      ..addAll(widget.meeting.participants);
    addMeetingListeners(widget.meeting);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        flexibleSpace: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Participants (${widget.meeting.participants.length + 1})",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: secondaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _participants.values.length,
                  itemBuilder: (context, index) => ParticipantListItem(
                    participant: _participants.values.elementAt(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addMeetingListeners(Room meeting) {
    meeting
      ..on(Events.participantJoined, (participant) {
        if (mounted) {
          final tempParticipant = participant as Participant;
          final newParticipants = _participants;
          newParticipants[participant.id] = tempParticipant;
          setState(() => _participants = newParticipants);
        }
      })
      ..on(Events.participantLeft, (participantId) {
        if (mounted) {
          final newParticipants = Map<String, Participant>.from(_participants)
            ..remove(participantId);

          setState(() => _participants = newParticipants);
        }
      });
  }
}
