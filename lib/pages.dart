import 'package:flutter/material.dart';
import 'package:mastodon_api/mastodon_api.dart';

import "timeline.dart";
import "toot.dart";
import 'logout.dart';

class Pages extends StatefulWidget {
  const Pages({super.key, required this.instance, required this.accessToken});

  final String instance;
  final String accessToken;

  @override
  State<Pages> createState() => _PagesState();
}

class _PagesState extends State<Pages> {
  final PageController _controller = PageController(initialPage: 1);

  late final MastodonApi mastodon;

  @override
  void initState() {
    super.initState();
    mastodon = MastodonApi(
      instance: widget.instance,
      bearerToken: widget.accessToken,
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
  }

  final List<Status> homeStatuses = [];
  final List<Status> localStatuses = [];
  final List<Status> federatedStatuses = [];

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        TootPage(mastodon: mastodon),
        TimelinePage(
            mastodon: mastodon, statuses: homeStatuses, timeline: "home"),
        TimelinePage(
            mastodon: mastodon, statuses: localStatuses, timeline: "local"),
        TimelinePage(
            mastodon: mastodon,
            statuses: federatedStatuses,
            timeline: "federated"),
        LogoutPage(mastodon: mastodon)
      ],
    );
  }
}
