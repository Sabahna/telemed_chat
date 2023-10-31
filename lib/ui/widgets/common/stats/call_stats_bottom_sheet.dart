import "dart:async";

import "package:flutter/material.dart";
import "package:telemed_chat/src/colors.dart";
import "package:videosdk/videosdk.dart";

class CallStatsBottomSheet extends StatefulWidget {
  const CallStatsBottomSheet({required this.participant, Key? key})
      : super(key: key);
  final Participant participant;

  @override
  State<CallStatsBottomSheet> createState() => _CallStatsBottomSheetState();
}

class _CallStatsBottomSheetState extends State<CallStatsBottomSheet> {
  Timer? statsTimer;

  Map<dynamic, dynamic>? audioStats;
  Map<dynamic, dynamic>? videoStats;
  int? score;

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
    return Wrap(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: black700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: score == null
                      ? black700
                      : score! > 7
                          ? Colors.red
                          : score! > 4
                              ? yellow
                              : red,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            " ${widget.participant.displayName} - Quality Metrics : ${score == null ? '-' : score! > 7 ? 'Good' : score! > 4 ? 'Average' : 'Poor'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Table(
                border: TableBorder.all(width: 0.5, color: Colors.white10),
                children: [
                  const TableRow(
                    children: [
                      Padding(padding: EdgeInsets.all(4), child: Text("")),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text("Audio"),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text("Video"),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("Latency"),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            audioStats?["rtt"] != null
                                ? "${(audioStats?["rtt"] as double).toInt()} ms"
                                : "-",
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            videoStats?["rtt"] != null
                                ? "${(videoStats?['rtt'] as double).toInt()} ms"
                                : "-",
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("Jitter"),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            audioStats?["jitter"] != null
                                ? "${(audioStats?['jitter']).toString().split('.')[0]} ms"
                                : "-",
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            videoStats?["jitter"] != null
                                ? "${(videoStats?['jitter']).toString().split('.')[0]} ms"
                                : "-",
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("Packet Loss"),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            audioStats?["packetsLost"] != null
                                ? "${(((audioStats?["packetsLost"] as double?) ?? 0.0) / (audioStats?["totalPackets"] ?? 1)).toStringAsFixed(2)} %"
                                : "-",
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            videoStats?["packetsLost"] != null
                                ? "${(((videoStats?['packetsLost'] as double?) ?? 0.0) / (videoStats?['totalPackets'] ?? 1)).toStringAsFixed(2)} %"
                                : "-",
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("Bitrate"),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            audioStats?["bitrate"] != null
                                ? "${(audioStats?["bitrate"]).toString().split('.')[0]} kb/s"
                                : "-",
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            videoStats?["bitrate"] != null
                                ? "${(videoStats?['bitrate'] as double).toStringAsFixed(2)} kb/s"
                                : "-",
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("Frame Rate"),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text("-"),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Builder(
                            builder: (context) {
                              final size =
                                  videoStats?["size"] as Map<String, dynamic>?;
                              return Text(
                                size?["framerate"] != null
                                    ? "${size?["framerate"]}"
                                    : "-",
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("Resolution"),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text("-"),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Builder(
                            builder: (context) {
                              final size =
                                  videoStats?["size"] as Map<String, dynamic>?;
                              return Text(
                                size?["width"] != null &&
                                        size?["height"] != null &&
                                        size?["height"] != "null"
                                    ? "${size?["width"]}x${size?['height']}"
                                    : "-",
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(4),
                        child: Text("Codec"),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            audioStats?["codec"] != null
                                ? (audioStats?["codec"]).toString()
                                : "-",
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            videoStats?["codec"] != null
                                ? (videoStats?["codec"]).toString()
                                : "-",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateStats() {
    final tempAudioStats = widget.participant.getAudioStats();
    final tempVideoStats = widget.participant.getVideoStats();
    var vStats;
    tempVideoStats?.forEach((stat) {
      if (vStats == null) {
        vStats = stat;
      } else {
        final tempVStatSize =
            (vStats as Map<String, dynamic>)["size"] as Map<String, dynamic>;
        final tempStat = stat as Map<String, dynamic>;
        final tempStatSize = tempStat["size"] as Map<String, dynamic>;

        if (tempStatSize["width"] != "null" &&
            tempStatSize["width"] != null &&
            tempStatSize["framerate"] != null) {
          if ((tempStatSize["width"] as double) >
              (tempVStatSize["width"] as double)) {
            vStats = stat;
          }
        }
      }
    });
    var stats = {};
    if (tempAudioStats != null) {
      if (tempAudioStats.isNotEmpty) {
        stats = tempAudioStats[0];
      }
    }
    if (vStats != null) {
      stats = vStats;
    }

    double packetLossPercent =
        ((stats["packetsLost"] as int?) ?? 0.0) / (stats["totalPackets"] ?? 1);
    if (packetLossPercent.isNaN) {
      packetLossPercent = 0;
    }
    final double jitter = stats["jitter"] ?? 0;
    final double rtt = stats["rtt"] ?? 0;
    double? tempScore = stats.isNotEmpty ? 100 : null;
    if (tempScore != null) {
      tempScore -= packetLossPercent * 50 > 50 ? 50 : packetLossPercent * 50;
      tempScore -= ((jitter / 30) * 25 > 25 ? 25 : (jitter / 30) * 25);
      tempScore -= ((rtt / 300) * 25 > 25 ? 25 : (rtt / 300) * 25);
    }

    setState(() {
      score = tempScore != null ? tempScore ~/ 10 : null;
      audioStats = tempAudioStats?[0];
      videoStats = vStats;
    });
  }

  @override
  void dispose() {
    if (statsTimer != null) {
      statsTimer?.cancel();
    }
    super.dispose();
  }
}
