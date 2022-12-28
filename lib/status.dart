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

class StatusPage extends StatefulWidget {
  final mApi.MastodonApi mastodon;
  final List<mApi.Status> statuses;

  const StatusPage({super.key, required this.mastodon, required this.statuses});
  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  _StatusPageState() : super();

  @override
  void initState() {
    super.initState();
    fetchReplies();
  }

  void onRefresh() async {
    fetchReplies();
  }

  void fetchReplies() async {
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      controller: refreshController,
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: RotaryScrollController(),
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
                              image: NetworkImage(widget.statuses[i].reblog !=
                                      null
                                  ? widget.statuses[i].reblog!.account.avatar
                                  : widget.statuses[i].account.avatar),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
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
                      child: HtmlWidget(widget.statuses[i].spoilerText != ""
                          ? widget.statuses[i].spoilerText
                          : widget.statuses[i].content)),
                  Visibility(
                      visible: widget.statuses[i].spoilerText != "",
                      child: HtmlWidget(widget.statuses[i].content)),
                  Column(children: [
                    for (var media in widget.statuses[i].reblog != null
                        ? widget.statuses[i].reblog!.mediaAttachments
                        : widget.statuses[i].mediaAttachments)
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image(
                                  image: NetworkImage(media.previewUrl),
                                  width:
                                      MediaQuery.of(context).size.width - 20)))
                  ])
                ]))),
        itemCount: widget.statuses.length,
      ),
    ));
  }
}
