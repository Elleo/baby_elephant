import 'package:flutter/material.dart';
import 'package:mastodon_api/mastodon_api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import "timeline.dart";
import "toot.dart";
import "config.dart";

void main() {
  runApp(TootApp());
}

class TootApp extends StatelessWidget {
  TootApp({super.key});

  final PageController _controller = PageController(initialPage: 1);

  final mastodon = MastodonApi(
    instance: instance,
    bearerToken: accessToken,
    retryConfig: RetryConfig.ofExponentialBackOffAndJitter(maxAttempts: 5),
    timeout: const Duration(seconds: 20),
  );

  final List<Status> homeStatuses = [];
  final List<Status> localStatuses = [];
  final List<Status> federatedStatuses = [];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
        headerTriggerDistance: 40,
        footerTriggerDistance: 15,
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
