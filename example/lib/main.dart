import 'dart:math';

import 'package:flutter/material.dart';
import 'package:telemed_chat/communication/one_to_one_communication.dart';
import 'package:telemed_chat/models/one_to_one_call.dart';
import 'package:telemed_chat/telemed_chat.dart';

void main() {
  runApp(const MyApp());
}

final globalKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      navigatorKey: globalKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String meetingId = "";

  int generateRandomNumber() {
    final random = Random();
    return random.nextInt(10000000);
  }

  late OneToOneCommunication oneToOneCommunication;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    oneToOneCommunication = OneToOneCommunication(
      globalKey: globalKey,
      oneToOneCall: OneToOneCall(
        notificationInfo: const NotificationInfo(
          title: "Example App",
          message: "Screen sharing from example app",
          icon: '',
        ),
        token:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiJiM2Q2ZGMxYS0yNTc1LTRmMDEtOWViMS1hYzYyZDY2MDQ2Y2UiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTY5ODAzNDY1OCwiZXhwIjoxNzI5NTcwNjU4fQ.ReiYciVKh80xLr8-F6mMYs5AjcHs5X5AqdpTVa8N3kk",
        displayName: generateRandomNumber().toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onChanged: (value) {
                setState(() {
                  meetingId = value;
                });
              },
            ),
            const SizedBox(
              height: 70,
            ),
            ElevatedButton(
              onPressed: () {
                oneToOneCommunication.createAndJoin(context, (meetingId) {
                  debugPrint(
                      "----------------------meetingId $meetingId----------------------");
                });
              },
              child: const Text("Create Meeting"),
            ),
            ElevatedButton(
              onPressed: () {
                oneToOneCommunication.viewCommunication(context);
              },
              child: const Text("View Communication"),
            ),
            ElevatedButton(
              onPressed: () {
                oneToOneCommunication.join(meetingId, context);
              },
              child: const Text("Join Meeting"),
            ),
          ],
        ),
      ),
    );
  }
}
