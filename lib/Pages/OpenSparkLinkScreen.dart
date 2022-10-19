import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Keys.dart';
import '../MatchJoiner.dart';
import '../Model/APIFrame.dart';
import '../Services/spark_links.dart';
import '../main.dart';

class OpenSparkLinkScreen extends ConsumerStatefulWidget {
  final String link;
  const OpenSparkLinkScreen({Key key, this.link}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      OpenSparkLinkScreenState();
}

class OpenSparkLinkScreenState extends ConsumerState<OpenSparkLinkScreen> {
  bool joiningPage = false;
  bool joining = false;
  String errorText = "";
  bool keepTrying = true;

  @override
  void initState() {
    super.initState();

    final APIFrame initFrame = ref.read(frameProvider);
  }

  @override
  void dispose() {
    // setState(() {
    //   keepTrying = false;
    // });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final APIFrame frame = ref.watch(frameProvider);
    final bool inGame = ref.watch(inGameProvider);
    final echoVRIP = ref.watch(echoVRIPProvider);
    final echoVRPort = ref.watch(echoVRPortProvider);
    final Map<String, dynamic> ipLocation =
        ref.watch(ipLocationResponseProvider);

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Join spark:// Link"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
        // toolbarHeight: 40,
      ),
      body: (() {
        if (joiningPage) {
          return Container(
            child: Center(
                child: (() {
              if (joining) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Trying to join match...",
                      textScaleFactor: 1.3,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(),
                    SizedBox(height: 40),
                    Text(
                      "You will join the link as soon as you join a lobby or match on your Quest.\n\nIf you have not connected Spark Mini to your Quest yet, cancel and set it up.",
                      textScaleFactor: 1.3,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        textScaleFactor: 1.3,
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(26),
                        minimumSize: Size.fromHeight(40),
                      ),
                    ),
                  ],
                );
              } else {
                return Text(
                  errorText,
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                );
              }
            }())),
            margin: EdgeInsets.all(20),
          );
        } else if (!inGame) {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: <Widget>[
              SizedBox(height: 30),
              Container(
                child: Center(
                    child: Text(
                  "Choose a Team",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                )),
                margin: EdgeInsets.all(20),
              ),
              Column(children: [
                Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(.75),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(26),
                          minimumSize: Size.fromHeight(40),
                        ),
                        onPressed: () => {joinMatch(0, widget.link)},
                        child:
                            Text("Blue Team", style: TextStyle(fontSize: 20)))),
                Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.withOpacity(.75),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(26),
                          minimumSize: Size.fromHeight(40),
                        ),
                        onPressed: () => {joinMatch(1, widget.link)},
                        child: Text("Orange Team",
                            style: TextStyle(fontSize: 20)))),
                Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(.75),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(26),
                          minimumSize: Size.fromHeight(40),
                        ),
                        onPressed: () => {joinMatch(-1, widget.link)},
                        child: Text("Random Team",
                            style: TextStyle(fontSize: 20)))),
                Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(26),
                          minimumSize: Size.fromHeight(40),
                        ),
                        onPressed: () => {joinMatch(2, widget.link)},
                        child:
                            Text("Spectator", style: TextStyle(fontSize: 20)))),
              ])
            ],
          );
        } else {
          return Container(
            child: Center(
                child: Column(
              children: [
                Text(
                  "Not in a match or lobby.\nCan't join spark:// link.",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Back to Spark Mini"))
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            )),
            margin: EdgeInsets.all(20),
          );
        }
      }()),
    );
  }

  Future<void> joinMatch(int teamIdx, String link) async {
    setState(() {
      joiningPage = true;
      joining = true;
    });

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
      errorText = 'Invalid Match Link:\n$link';

      setState(() {
        joining = false;
      });
    } else {
      final settings = ref.read(sharedPreferencesProvider);
      var echoVRIP = settings.getString('echoVRIP');
      var echoVRPort = settings.setString('echoVRPort', '6721');

      while (mounted) {
        try {
          final response = await http
              .post(Uri.http('${echoVRIP}:${echoVRPort}', 'join_session'),
                  body: json
                      .encode({'session_id': matchedText, 'team_idx': teamIdx}))
              .timeout(Duration(seconds: 2));
          if (response.statusCode == 200) {
            setState(() {
              keepTrying = false;
              joining = false;
              errorText = "Success! Joining...";
            });

            await Future.delayed(Duration(seconds: 3));

            Navigator.pop(context);
            break;
          }
        } catch (e) {
          print("failed to send match");
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }
}
