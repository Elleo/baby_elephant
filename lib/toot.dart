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
import 'package:flutter/services.dart';
import 'package:mastodon_api/mastodon_api.dart' as mapi;

class TootPage extends StatefulWidget {
  final mapi.MastodonApi mastodon;
  const TootPage({super.key, required this.mastodon});
  @override
  State<TootPage> createState() => _TootPageState();
}

class _TootPageState extends State<TootPage> {
  FocusNode textFocus = FocusNode();
  TextEditingController textController = TextEditingController();

  _TootPageState() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                onPressed: () {
                  textFocus.requestFocus();
                  SystemChannels.textInput.invokeMethod('TextInput.show');
                },
                child: const Text("Toot! Toot!")),
          ),
          TextField(
              controller: textController,
              focusNode: textFocus,
              onSubmitted: (value) {
                widget.mastodon.v1.statuses.createStatus(text: value);
                textController.clear();
              })
        ]));
  }
}
