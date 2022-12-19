import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mastodon_api/mastodon_api.dart' as mapi;

class TootPage extends StatefulWidget {
  final mapi.MastodonApi mastodon;
  const TootPage({super.key, required this.mastodon});
  @override
  State<TootPage> createState() => _TootPageState();
}

class _TootPageState extends State<TootPage> {
  FocusNode textFocus = FocusNode();
  TextEditingController textController = TextEditingController();

  _TootPageState() : super();

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
                  textFocus.requestFocus();
                  SystemChannels.textInput.invokeMethod('TextInput.show');
                },
                child: const Text("Toot! Toot!")),
          ),
          TextField(
              controller: textController,
              focusNode: textFocus,
              onSubmitted: (value) {
                widget.mastodon.v1.statuses.createStatus(text: value);
                textController.clear();
              })
        ]));
  }
}
