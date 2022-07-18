import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'Keys.dart';
import 'main.dart';

class MatchJoiner extends StatefulWidget {
  final bool inGame;
  final String echoVRIP;
  final String echoVRPort;

  const MatchJoiner({Key key, this.inGame, this.echoVRIP, this.echoVRPort})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => MatchJoinerState();
}

class MatchJoinerState extends State<MatchJoiner> {
  final linkInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    linkInputController.dispose();
    super.dispose();
  }

  Future<void> joinMatch(String link) async {
    print(link);
    final sessionIdRegex = RegExp(
        "([A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12})");

    // find the first match though you could also do `allMatches`
    final match = sessionIdRegex.firstMatch(link);

    // group(0) is the full matched text
    // if your regex had groups (using parentheses) then you could get the
    // text from them by using group(1), group(2), etc.
    final String matchedText = match?.group(0); // 25F8

    if (matchedText == null) {
      final snackBar = SnackBar(
        content: Text('Invalid Match Link.'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(
        content: Text('Joining Match...    $matchedText'),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      try {
        final response = await http
            .post(
                Uri.http(
                    '${widget.echoVRIP}:${widget.echoVRPort}', 'join_session'),
                body: json.encode({'session_id': matchedText, 'team_idx': 0}))
            .timeout(Duration(seconds: 2));
        if (response.statusCode == 200) {}
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return (() {
      if (widget.inGame) {
        return Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // const ListTile(
              //   // leading: Icon(Icons.arrow_back_ios),
              //   // trailing: Icon(Icons.arrow_forward_ios),
              //   // title: Text('Join Match'),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 0.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 0.0),
                        ),
                        hintText: 'Paste a spark:// link or a session id.',
                      ),
                      controller: linkInputController,
                    ),
                  ),
                  TextButton(
                    child: const Text('JOIN MATCH'),
                    style: TextButton.styleFrom(
                      primary: Colors.red, // background
                      padding: EdgeInsets.all(20),
                    ),
                    onPressed: () async {
                      await joinMatch(linkInputController.text);
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    }());
  }
}
