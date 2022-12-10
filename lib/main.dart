import 'package:flutter/material.dart';
import "timeline.dart";

void main() {
  runApp(const TootApp());
}

class TootApp extends StatelessWidget {
  const TootApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toot Toot!',
      theme: ThemeData(
          brightness: Brightness.light, primarySwatch: Colors.blueGrey),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          /* dark theme settings */
          scaffoldBackgroundColor: Colors.black,
          primarySwatch: Colors.blueGrey),
      themeMode: ThemeMode.dark,
      home: const TimelinePage(),
    );
  }
}
