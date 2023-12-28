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
import 'package:mastodon_api/mastodon_api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/services.dart';
import 'package:wearable_communicator/wearable_communicator.dart';

import "timeline.dart";
import "toot.dart";
import "config.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TootApp());
}

class TootApp extends StatelessWidget {
  TootApp({super.key}) {
    auth();
  }

  final PageController _controller = PageController(initialPage: 1);

  final mastodon = MastodonApi(
    instance: instance,
    bearerToken: accessToken,
    retryConfig: RetryConfig(
      maxAttempts: 5,
      jitter: Jitter(
        minInSeconds: 2,
        maxInSeconds: 5,
      ),
      onExecute: (event) => print(
        'Retry after ${event.intervalInSeconds} seconds...'
        '[${event.retryCount} times]',
      ),
    ),
    timeout: const Duration(seconds: 20),
  );

  final List<Status> homeStatuses = [];
  final List<Status> localStatuses = [];
  final List<Status> federatedStatuses = [];

  void auth() async {
    const platform = MethodChannel('com.mikeasoft.baby_elephant/native');
    await platform.invokeMethod("triggerAuth", {});
    WearableCommunicator.sendMessage({
      "command": "triggerAuth",
    });
    WearableListener.listenForMessage((msg) {
      print(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
        headerTriggerDistance: 40,
        dragSpeedRatio: 0.91,
        headerBuilder: () => const MaterialClassicHeader(),
        footerBuilder: () => const ClassicFooter(),
        enableLoadingWhenNoData: false,
        enableRefreshVibrate: false,
        enableLoadMoreVibrate: false,
        child: MaterialApp(
          title: 'Toot Toot!',
          theme: ThemeData(
              brightness: Brightness.light, primarySwatch: Colors.blueGrey),
          darkTheme: ThemeData(
              brightness: Brightness.dark,
              /* dark theme settings */
              scaffoldBackgroundColor: Colors.black,
              primarySwatch: Colors.blueGrey),
          themeMode: ThemeMode.dark,
          home: PageView(
            controller: _controller,
            children: [
              TootPage(mastodon: mastodon),
              TimelinePage(
                  mastodon: mastodon, statuses: homeStatuses, timeline: "home"),
              TimelinePage(
                  mastodon: mastodon,
                  statuses: localStatuses,
                  timeline: "local"),
              TimelinePage(
                  mastodon: mastodon,
                  statuses: federatedStatuses,
                  timeline: "federated"),
            ],
          ),
        ));
  }
}
