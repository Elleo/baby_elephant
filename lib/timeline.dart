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
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mastodon_api/mastodon_api.dart' as mApi;
import 'package:wearable_rotary/wearable_rotary.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TimelinePage extends StatefulWidget {
  final mApi.MastodonApi mastodon;
  final List<mApi.Status> statuses;
  final String timeline;
  const TimelinePage(
      {super.key,
      required this.mastodon,
      required this.statuses,
      required this.timeline});
  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<String> revealedStatuses = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  _TimelinePageState() : super();

  @override
  void initState() {
    super.initState();
    updateTimeline(false);
    Fluttertoast.showToast(
        msg: widget.timeline[0].toUpperCase() + widget.timeline.substring(1),
        gravity: ToastGravity.BOTTOM);
  }

  void onRefresh() async {
    updateTimeline(true);
  }

  void updateTimeline(bool refresh) async {
    String? maxId;
    String? minId;
    if (widget.statuses.isNotEmpty) {
      if (refresh) {
        minId = widget.statuses.first.id;
      } else {
        maxId = widget.statuses.last.id;
      }
    }
    try {
      Future<mApi.MastodonResponse<List<mApi.Status>>> tlFuture;
      if (widget.timeline == "home") {
        tlFuture = widget.mastodon.v1.timelines
            .lookupHomeTimeline(minStatusId: minId, maxStatusId: maxId);
      } else if (widget.timeline == "local") {
        tlFuture = widget.mastodon.v1.timelines.lookupPublicTimeline(
            onlyLocal: true, minStatusId: minId, maxStatusId: maxId);
      } else if (widget.timeline == "federated") {
        tlFuture = widget.mastodon.v1.timelines.lookupPublicTimeline(
            onlyLocal: false, minStatusId: minId, maxStatusId: maxId);
      } else {
        return;
      }
      tlFuture.then((timeline) => {
            if (mounted)
              {
                setState(() {
                  timeline.data.forEach((status) {
                    if (status.content.isNotEmpty) {
                      if (refresh) {
                        widget.statuses.insert(0, status);
                      } else {
                        widget.statuses.add(status);
                      }
                    }
                  });
                  if (refresh) {
                    refreshController.refreshCompleted();
                  } else {
                    refreshController.loadComplete();
                  }
                })
              }
          });
    } on mApi.DataNotFoundException catch (_) {
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
      controller: refreshController,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: widget.statuses.isEmpty
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
                                        widget.statuses[i].account.avatar),
                                    width: 32,
                                    height: 32)),
                            const SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    widget.statuses[i].account.displayName != ""
                                        ? widget.statuses[i].account.displayName
                                        : widget.statuses[i].account.username,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  "@${widget.statuses[i].account.username}",
                                  style: const TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.left,
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                            child: HtmlWidget(
                                widget.statuses[i].spoilerText != ""
                                    ? widget.statuses[i].spoilerText
                                    : widget.statuses[i].content)),
                        Visibility(
                            visible: widget.statuses[i].spoilerText != "" &&
                                !revealedStatuses
                                    .contains(widget.statuses[i].id),
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    revealedStatuses.add(widget.statuses[i].id);
                                  });
                                },
                                child: const Text("Show More"))),
                        Visibility(
                            visible: revealedStatuses
                                .contains(widget.statuses[i].id),
                            child: HtmlWidget(widget.statuses[i].content))
                      ]))),
              itemCount: widget.statuses.length,
            ),
    ));
  }
}
