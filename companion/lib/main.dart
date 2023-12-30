/*
 * This file is part of Baby Elephant, a Mastodon client for smartwatches.
 *
 * Copyright (c) 2022 Mike Sheldon <mike@mikeasoft.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_intent/receive_intent.dart' as ri;

import 'auth.dart';

void main() {
  runApp(const Friend());
}

class Friend extends StatelessWidget {
  const Friend({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Elephant Friend',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    initReceiveIntent();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  Future<void> initReceiveIntent() async {
    final receivedIntent = await ri.ReceiveIntent.getInitialIntent();
    if (receivedIntent != null && receivedIntent.isNotNull) {
      if (receivedIntent.data == "babyelephant://auth") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AuthPage()));
      }
    }
    sub = ri.ReceiveIntent.receivedIntentStream.listen((ri.Intent? intent) {
      if (receivedIntent?.data == "babyelephant://auth") {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AuthPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Baby Elephant Friend"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Image(image: AssetImage("assets/elephant.png")),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                  'This app is a companion to the Baby Elephant app for Wear OS smartwatches.\n\nStart Baby Elephant on your watch and this app will help you log in to your Mastodon account.'),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
