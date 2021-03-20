import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class AtlasWidget extends StatefulWidget {
  final APIFrame frame;

  const AtlasWidget({Key key, this.frame}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AtlasState();
}

class AtlasState extends State<AtlasWidget> {
  final List<String> linkTypes = <String>['Choose', 'Player', 'Spectator'];
  Map<String, dynamic> ogAtlasMatches;
  Map<String, dynamic> igniteAtlasMatches;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Center(
          child: Container(
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 16),
              ),
              margin: const EdgeInsets.only(top: 20)),
        ),
        ElevatedButton(
            onPressed: (() {
              fetchOGAtlasMatches(widget.frame.client_name);
              fetchIgniteAtlasMatches(widget.frame.client_name);
            }),
            child: Text('Refresh'))
      ],
    );
  }

  void fetchOGAtlasMatches(String playerName) async {
    final response = await http.post(
        Uri.https('echovrconnect.appspot.com', 'api/v1/player/$playerName'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        ogAtlasMatches = jsonDecode(response.body);
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get og atlas matches');
    }
  }

  void fetchIgniteAtlasMatches(String playerName) async {
    final response = await http.get(Uri.https(
        'ignitevr.gg', 'cgi-bin/EchoStats.cgi/atlas_matches_v2/$playerName'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        igniteAtlasMatches = jsonDecode(response.body);
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get ignite atlas matches');
    }
  }
}
