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

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:wearable_communicator/wearable_communicator.dart';

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
  @override
  Widget build(BuildContext context) {
    WearableListener.listenForMessage((msg) {
      print(msg);
      if (msg['command'] == "triggerAuth") {
        print("TRIGGERING AUTH");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      }
    });
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
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 20)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthPage()),
                  );
                },
                child: const Text("Launch Auth")),
          ],
        ),
      ),
    );
  }
}
