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
import 'package:mastodon_api/src/service/entities/user_list.dart';
import 'package:mastodon_api/src/service/base_service.dart';
import 'package:mastodon_api/src/core/client/user_context.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import "timeline.dart";
import "toot.dart";
import "config.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(TootApp());
}


Future<List<UserList>> getLists(String instanceUrl, String bearerToken) async {
  String url = '${instanceUrl.startsWith('http') ? '' : 'https://'}$instanceUrl/api/v1/lists';
  // print('Fetching lists from URL: $url'); // Print the URL being accessed

  var headers = {
    'Authorization': 'Bearer $bearerToken',
  };
  // print('Authorization header: ${headers['Authorization']}'); // Print the auth header

  try {
    var response = await http.get(Uri.parse(url), headers: headers);
    // print('Response status: ${response.statusCode}'); // Print response status
    // print('Response body: ${response.body}'); // Print response body

    if (response.statusCode == 200) {
      List<dynamic> listsJson = json.decode(response.body);
      List<UserList> userLists = listsJson.map((json) => UserList.fromJson(json)).toList();
      // print('Parsed user lists: $userLists'); // Print the parsed lists
      return userLists;
    } else {
      print('Error fetching lists: ${response.statusCode}'); // Print error status
      throw Exception('Failed to fetch lists: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception during fetching lists: $e'); // Print exception details
    rethrow;
  }
}

class TootApp extends StatelessWidget {
  TootApp({super.key});

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

Future<List<Widget>> _buildPages() async {
  // Use the utility function to fetch lists
  List<UserList> userLists = await getLists(instance, accessToken);

  print("Fetched lists: $userLists");

  // Initialize pages with standard timelines
  List<Widget> pages = [
    TootPage(mastodon: mastodon),
    TimelinePage(mastodon: mastodon, statuses: [], timeline: "home"),
    TimelinePage(mastodon: mastodon, statuses: [], timeline: "local"),
    TimelinePage(mastodon: mastodon, statuses: [], timeline: "federated"),
  ];

  // Add a page for each list
  for (var list in userLists) {
    pages.add(TimelinePage(mastodon: mastodon, statuses: [], timeline: "${list.id}_${list.title}"));
  }

  return pages;
}

  
  // This widget is the root of your application.
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
            scaffoldBackgroundColor: Colors.black,
            primarySwatch: Colors.blueGrey),
        themeMode: ThemeMode.dark,
        home: FutureBuilder<List<Widget>>(
          future: _buildPages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return PageView(
                controller: _controller,
                children: snapshot.data!,
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ));
  }
}
