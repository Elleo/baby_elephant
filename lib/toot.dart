import 'package:flutter/material.dart';
import 'package:mastodon_api/mastodon_api.dart' as mapi;

class TootPage extends StatefulWidget {
  final mapi.MastodonApi mastodon;
  const TootPage({super.key, required this.mastodon});
  @override
  State<TootPage> createState() => _TootPageState(mastodon: mastodon);
}

class _TootPageState extends State<TootPage> {
  final mapi.MastodonApi mastodon;

  FocusNode textFocus = FocusNode();
  TextEditingController textController = TextEditingController();

  _TootPageState({required this.mastodon}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                onPressed: () {
                  textFocus.unfocus();
                  textFocus.requestFocus();
                },
                child: const Text("Toot! Toot!")),
          ),
          TextField(
            controller: textController,
            focusNode: textFocus,
            onSubmitted: (value) {
              mastodon.v1.statuses.createStatus(text: value);
              textController.clear();
            },
          )
        ]));
  }
}
