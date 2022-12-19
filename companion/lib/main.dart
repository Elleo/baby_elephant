import 'package:flutter/material.dart';

void main() {
  runApp(const Friend());
}

class Friend extends StatelessWidget {
  const Friend({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Elephant Friend',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Baby Elephant Friend"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const <Widget>[
            Image(image: AssetImage("assets/elephant.png")),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                  'This app is a companion to the Baby Elephant app for Wear OS smartwatches.\n\nStart Baby Elephant on your watch and this app will help you log in to your Mastodon account.'),
            ),
            SizedBox(height: 100)
          ],
        ),
      ),
    );
  }
}
