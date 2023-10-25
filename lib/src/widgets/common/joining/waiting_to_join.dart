import "package:flutter/material.dart";
import "package:lottie/lottie.dart";
import "package:telemed_chat/src/utils/spacer.dart";

class WaitingToJoin extends StatelessWidget {
  const WaitingToJoin({Key? key}) : super(key: key);

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
            const Text(
              "Calling...",
              style: TextStyle(
                fontSize: 25,
                color: Color(0xff088395),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
