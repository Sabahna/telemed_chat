import "dart:async";

import "package:flutter/material.dart";
import "package:telemed_chat/src/colors.dart";
import "package:telemed_chat/src/widgets/common/stats/call_stats_bottom_sheet.dart";
import "package:videosdk/videosdk.dart";

class CallStats extends StatefulWidget {
  const CallStats({required this.participant, Key? key}) : super(key: key);
  final Participant participant;

  @override
  State<CallStats> createState() => _CallStatsState();
}

class _CallStatsState extends State<CallStats> {
  Timer? statsTimer;
  bool showFullStats = false;
  int? score;
  PersistentBottomSheetController? bottomSheetController;

  @override
  void initState() {
    statsTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => updateStats());
    super.initState();
    updateStats();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: score != null && !showFullStats
          ? GestureDetector(
              onTap: () async {
                setState(() {
                  showFullStats = !showFullStats;
                });
                bottomSheetController = showBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  context: context,
                  builder: (_) {
                    return CallStatsBottomSheet(
                      participant: widget.participant,
                    );
                  },
                );
                await bottomSheetController?.closed.then((value) {
                  setState(() {
                    showFullStats = !showFullStats;
                  });
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: score! > 7
                      ? green
                      : score! > 4
                          ? yellow
                          : red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.network_cell,
                  size: 17,
                ),
              ),
            )
          : null,
    );
  }

  void updateStats() {
    if (widget.participant.streams.isEmpty) {
      bottomSheetController?.close();
    }
    final audioStats = widget.participant.getAudioStats();
    final videoStats = widget.participant.getVideoStats();
    var vStats;
    videoStats?.forEach((stat) {
      if (vStats == null) {
        vStats = stat;
      } else {
        final tempVStatSize =
            (vStats as Map<String, dynamic>)["size"] as Map<String, dynamic>;
        final tempStat = stat as Map<String, dynamic>;
        final tempStatSize = tempStat["size"] as Map<String, dynamic>;

        if (tempStatSize["width"] != "null" && tempStatSize["width"] != null) {
          if ((tempStatSize["width"] as double) >
              (tempVStatSize["width"] as double)) {
            vStats = stat;
          }
        }
      }
    });
    var stats = {};
    if (audioStats != null) {
      if (audioStats.isNotEmpty) {
        stats = audioStats[0];
      }
    }
    if (vStats != null) {
      stats = vStats;
    }
    num packetLossPercent =
        ((stats["packetsLost"] as int?) ?? 0.0) / (stats["totalPackets"] ?? 1);
    if (packetLossPercent.isNaN) {
      packetLossPercent = 0;
    }
    final num jitter = stats["jitter"] ?? 0;
    final num rtt = stats["rtt"] ?? 0;
    num? tempScore = stats.isNotEmpty ? 100 : null;
    if (tempScore != null) {
      tempScore -= packetLossPercent * 50 > 50 ? 50 : packetLossPercent * 50;
      tempScore -= ((jitter / 30) * 25 > 25 ? 25 : (jitter / 30) * 25);
      tempScore -= ((rtt / 300) * 25 > 25 ? 25 : (rtt / 300) * 25);
    }
    setState(() {
      score = tempScore != null ? tempScore ~/ 10 : null;
    });
  }

  @override
  void dispose() {
    if (statsTimer != null) {
      statsTimer?.cancel();
    }
    if (widget.participant.streams.isEmpty) {
      bottomSheetController?.close();
    }
    super.dispose();
  }
}
