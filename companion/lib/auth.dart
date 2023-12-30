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
import 'package:flutter/services.dart';
import 'package:mastodon_api/mastodon_api.dart' as mApi;
import 'package:mastodon_oauth2/mastodon_oauth2.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:url_launcher/url_launcher.dart';

import 'instances.dart';
import 'complete.dart';

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
  GlobalKey autocompleteKey = GlobalKey();
  FocusNode autocompleteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  void launchOAuth() async {
    final mastodon = mApi.MastodonApi(
        instance: textController.text,
        retryConfig:
            mApi.RetryConfig.ofExponentialBackOffAndJitter(maxAttempts: 5),
        timeout: const Duration(seconds: 20));
    Future<mApi.MastodonResponse<mApi.RegisteredApplication>> clientFuture =
        mastodon.v1.apps.createApplication(
            clientName: "Baby Elephant Staging",
            redirectUri: 'com.mikeasoft.babyelephant.oauth://callback/',
            scopes: [mApi.Scope.read, mApi.Scope.write, mApi.Scope.push],
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
        final response = await oauth2
            .executeAuthCodeFlow(scopes: [Scope.read, Scope.write, Scope.push]);

        sendAuth(response.accessToken, textController.text);

        super.setState(() {
          accessToken = response.accessToken;
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CompletePage()));
        });
      } on PlatformException catch (_) {}
    });
  }

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
        appBar: AppBar(
          title: const Text("Baby Elephant Friend - Log In"),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(image: AssetImage("assets/elephant.png")),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                    "Enter the address of your mastodon instance (server) to log in"),
              ),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    const Text("Instance: "),
                    const SizedBox(width: 10),
                    Expanded(
                        child: RawAutocomplete<String>(
                      key: autocompleteKey,
                      focusNode: autocompleteFocus,
                      textEditingController: textController,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return instances.where((String instance) {
                          return instance.contains(
                                  textEditingValue.text.toLowerCase()) &&
                              instance.isNotEmpty;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            onFieldSubmitted: (value) {
                              launchOAuth();
                            });
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options) {
                        return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  height: 190,
                                  child: ListView.builder(
                                      padding: const EdgeInsets.all(10),
                                      itemCount: options.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final String option =
                                            options.elementAt(index);
                                        return GestureDetector(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child:
                                                ListTile(title: Text(option)));
                                      }),
                                )));
                      },
                    )),
                  ])),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: launchOAuth, child: const Text('Log In')),
              const SizedBox(height: 40),
              const Text("Don't have a mastodon account?"),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse("https://joinmastodon.org/servers"));
                  },
                  child: const Text("Join Mastodon"))
            ]));
  }
}
