import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mastodon_api/mastodon_api.dart';
import 'package:wearable_rotary/wearable_rotary.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TimelinePage extends StatefulWidget {
  final MastodonApi mastodon;
  final List<Status> statuses;
  final String timeline;
  const TimelinePage(
      {super.key,
      required this.mastodon,
      required this.statuses,
      required this.timeline});
  @override
  State<TimelinePage> createState() => _TimelinePageState(
      mastodon: mastodon, statuses: statuses, timeline: timeline);
}

class _TimelinePageState extends State<TimelinePage> {
  final MastodonApi mastodon;
  final List<Status> statuses;
  final String timeline;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  _TimelinePageState(
      {required this.mastodon,
      required this.statuses,
      required this.timeline}) {
    updateTimeline(false);
    Fluttertoast.showToast(
        msg: timeline[0].toUpperCase() + timeline.substring(1),
        gravity: ToastGravity.BOTTOM);
  }

  void onRefresh() async {
    updateTimeline(true);
  }

  void updateTimeline(bool refresh) async {
    String? maxId;
    String? minId;
    if (statuses.isNotEmpty) {
      if (refresh) {
        minId = statuses.first.id;
      } else {
        maxId = statuses.last.id;
      }
    }
    try {
      Future<MastodonResponse<List<Status>>> tlFuture;
      if (timeline == "home") {
        tlFuture = mastodon.v1.timelines
            .lookupHomeTimeline(minStatusId: minId, maxStatusId: maxId);
      } else if (timeline == "local") {
        tlFuture = mastodon.v1.timelines.lookupPublicTimeline(
            onlyLocal: true, minStatusId: minId, maxStatusId: maxId);
      } else if (timeline == "federated") {
        tlFuture = mastodon.v1.timelines.lookupPublicTimeline(
            onlyLocal: false, minStatusId: minId, maxStatusId: maxId);
      } else {
        return;
      }
      tlFuture.then((timeline) => {
            setState(() {
              timeline.data.forEach((status) {
                if (status.content.isNotEmpty) {
                  if (refresh) {
                    statuses.insert(0, status);
                  } else {
                    statuses.add(status);
                  }
                }
              });
              if (refresh) {
                refreshController.refreshCompleted();
              } else {
                refreshController.loadComplete();
              }
            })
          });
    } on DataNotFoundException catch (_) {
      if (refresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }
    }
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
      header: const MaterialClassicHeader(distance: 10),
      controller: refreshController,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: statuses.isEmpty
          ? const Center(
              child: SizedBox(
                  height: 64, width: 64, child: CircularProgressIndicator()))
          : ListView.builder(
              controller: RotaryScrollController(),
              itemBuilder: (c, i) => Card(
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 5, bottom: 5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(children: [
                        Row(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                    image: NetworkImage(
                                        statuses[i].account.avatar),
                                    width: 32,
                                    height: 32)),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    statuses[i].account.displayName != ""
                                        ? statuses[i].account.displayName
                                        : statuses[i].account.username,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  "@${statuses[i].account.username}",
                                  style: const TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.left,
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(child: HtmlWidget(statuses[i].content)),
                      ]))),
              itemCount: statuses.length,
            ),
    ));
  }
}
