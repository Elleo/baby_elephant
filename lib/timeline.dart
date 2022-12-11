import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mastodon_api/mastodon_api.dart';
import "config.dart";

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});
  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final mastodon = MastodonApi(
    instance: instance,
    bearerToken: accessToken,
    retryConfig: RetryConfig.ofExponentialBackOffAndJitter(maxAttempts: 5),
    timeout: const Duration(seconds: 20),
  );

  String? newestStatus;
  String? oldestStatus;
  List<Status> items = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void onRefresh() async {
    updateTimeline(true);
  }

  void updateTimeline(bool refresh) async {
    String? maxId;
    String? minId;
    if (refresh) {
      minId = newestStatus;
    } else {
      maxId = oldestStatus;
    }
    var tlFuture = mastodon.v1.timelines
        .lookupHomeTimeline(minStatusId: minId, maxStatusId: maxId);
    tlFuture.then((timeline) => {
          setState(() {
            if (refresh && timeline.data.isNotEmpty) {
              newestStatus = timeline.data[0].id;
            }
            timeline.data.forEach((status) {
              if (status.content.isNotEmpty) {
                if (refresh) {
                  items.insert(0, status);
                } else {
                  items.add(status);
                }
              }
              if (!refresh) {
                oldestStatus = status.id;
              }
            });
            if (refresh) {
              refreshController.refreshCompleted();
            } else {
              refreshController.loadComplete();
            }
          })
        });
  }

  void onLoading() async {
    updateTimeline(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      controller: refreshController,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: ListView.builder(
        itemBuilder: (c, i) => Card(
            clipBehavior: Clip.hardEdge,
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(children: [
                  Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                              image: NetworkImage(items[i].account.avatar),
                              width: 32,
                              height: 32)),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              items[i].account.displayName != ""
                                  ? items[i].account.displayName
                                  : items[i].account.username,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.clip,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "@${items[i].account.username}",
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.left,
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(child: HtmlWidget(items[i].content)),
                ]))),
        itemCount: items.length,
      ),
    ));
  }
}
