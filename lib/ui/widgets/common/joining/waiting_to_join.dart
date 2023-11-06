import "package:flutter/material.dart";
import "package:lottie/lottie.dart";
import "package:telemed_chat/ui/utils/spacer.dart";

class WaitingToJoin extends StatelessWidget {
  const WaitingToJoin({required this.title, this.color, Key? key})
      : super(key: key);

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/calling_lottie.json", width: 100),
            const VerticalSpacer(20),
            Text(
              title,
              style: TextStyle(
                fontSize: 25,
                color: color ?? const Color(0xff088395),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
