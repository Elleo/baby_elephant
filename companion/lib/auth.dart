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
import 'package:mastodon_api/mastodon_api.dart' as mApi;
import 'package:mastodon_oauth2/mastodon_oauth2.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  _AuthPageState() : super();
  String? accessToken;
  String? refreshToken;

  TextEditingController textController = TextEditingController();

  void sendAuth(String accessToken, String instance) async {
    FlutterWearOsConnectivity phoneConnection = FlutterWearOsConnectivity();

    phoneConnection.configureWearableAPI();

    await phoneConnection.syncData(
        path: "/auth-data",
        data: {"accessToken": accessToken, "instance": instance},
        isUrgent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                const Text("Instance: "),
                const SizedBox(width: 10),
                Flexible(
                    child: TextField(
                  controller: textController,
                )),
              ])),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                final mastodon = mApi.MastodonApi(
                    instance: textController.text,
                    retryConfig: mApi.RetryConfig.ofExponentialBackOffAndJitter(
                        maxAttempts: 5),
                    timeout: const Duration(seconds: 20));
                Future<mApi.MastodonResponse<mApi.RegisteredApplication>>
                    clientFuture = mastodon.v1.apps.createApplication(
                        clientName: "Baby Elephant Staging",
                        redirectUri:
                            'com.mikeasoft.babyelephant.oauth://callback/',
                        scopes: [
                          mApi.Scope.read,
                          mApi.Scope.write,
                          mApi.Scope.push
                        ],
                        websiteUrl: "https://github.com/Elleo/baby_elephant");

                clientFuture.then((client) async {
                  final oauth2 = MastodonOAuth2Client(
                    instance: textController.text,
                    clientId: client.data.clientId,
                    clientSecret: client.data.clientSecret,
                    redirectUri: 'com.mikeasoft.babyelephant.oauth://callback/',
                    customUriScheme: 'com.mikeasoft.babyelephant.oauth',
                  );

                  try {
                    final response = await oauth2.executeAuthCodeFlow(
                        scopes: [Scope.read, Scope.write, Scope.push]);

                    sendAuth(response.accessToken, textController.text);

                    super.setState(() {
                      accessToken = response.accessToken;
                      print(accessToken);
                      Navigator.pop(context);
                    });
                  } on PlatformException catch (_) {}
                });
              },
              child: const Text('Log In'))
        ]));
  }
}
