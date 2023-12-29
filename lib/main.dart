/*
 * This file is part of Baby Elephant, a Mastodon client for smartwatches.
 *
 * Copyright (c) 2022-2023 Mike Sheldon <mike@mikeasoft.com>
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
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';

import 'pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TootApp());
}

class TootApp extends StatefulWidget {
  const TootApp({super.key});

  @override
  State<TootApp> createState() => _TootAppState();
}

class _TootAppState extends State<TootApp> {
  String? accessToken;
  String? instance;

  void loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken");
    instance = prefs.getString("instance");
  }

  void auth() async {
    const platform = MethodChannel('com.mikeasoft.baby_elephant/native');

    FlutterWearOsConnectivity phoneConnection = FlutterWearOsConnectivity();

    phoneConnection.configureWearableAPI();

    phoneConnection
        .dataChanged(
            pathURI: Uri(scheme: "wear", host: "*", path: "/auth-data"))
        .listen((dataEvents) {
      for (var event in dataEvents) {
        print(event.dataItem.mapData);
        setState(() {
          instance = event.dataItem.mapData['instance'];
          accessToken = event.dataItem.mapData['accessToken'];
        });
      }
    });

    CapabilityInfo? capabilityInfo =
        await phoneConnection.findCapabilityByName("baby_elephany_auth");

    if (capabilityInfo == null) {
      platform.invokeMethod("launchStore", {});
      phoneConnection
          .capabilityChanged(capabilityName: "baby_elephany_auth")
          .listen((capabilityInfo) {
        launchPhoneAuthentication(phoneConnection, capabilityInfo);
      });
    } else {
      launchPhoneAuthentication(phoneConnection, capabilityInfo);
    }
  }

  void launchPhoneAuthentication(FlutterWearOsConnectivity phoneConnection,
      CapabilityInfo capabilityInfo) {}

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
          home: accessToken != null && instance != null
              ? Pages(accessToken: accessToken!, instance: instance!)
              : ElevatedButton(
                  onPressed: () {
                    auth();
                  },
                  child: const Text("Log in on phone")),
        ));
  }
}
