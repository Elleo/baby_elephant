/*
 * This file is part of Baby Elephant, a Mastodon client for smartwatches.
 *
 * Copyright (c) 2023 Mike Sheldon <mike@mikeasoft.com>
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
import 'package:flutter/services.dart';

class CompletePage extends StatefulWidget {
  const CompletePage({super.key});
  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  _CompletePageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Baby Elephant Friend"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(image: AssetImage("assets/elephant.png")),
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 40, 30, 10),
                child: Text("Login complete! Please continue on your watch."),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text("Close"))
            ]));
  }
}
