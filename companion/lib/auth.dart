import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mastodon_api/mastodon_api.dart' as mApi;
import 'package:mastodon_oauth2/mastodon_oauth2.dart';

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
                        scopes: mApi.Scope.values,
                        websiteUrl: "https://github.com/Elleo/baby_elephant");

                clientFuture.then((client) async {
                  print(client);
                  final oauth2 = MastodonOAuth2Client(
                    instance: textController.text,
                    clientId: client.data.clientId,
                    clientSecret: client.data.clientSecret,
                    redirectUri: 'com.mikeasoft.babyelephant.oauth://callback/',
                    customUriScheme: 'com.mikeasoft.babyelephant.oauth',
                  );

                  try {
                    final response =
                        await oauth2.executeAuthCodeFlow(scopes: [Scope.read]);

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
