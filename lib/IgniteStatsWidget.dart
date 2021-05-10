import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'Model/igniteStatsPlayer.dart';
import 'dart:convert';
import 'main.dart';
import 'package:searchfield/searchfield.dart';
import 'package:http/http.dart' as http;

class IgniteStatsWidget extends StatefulWidget {
  IgniteStatsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IgniteStatsState();
}

class IgniteStatsState extends State<IgniteStatsWidget> {
  IgniteStatsPlayer playerData;

  @override
  void initState() {
    super.initState();

    print('here');
    fetchData('NtsFranz');
  }

  void fetchData(String playerName) async {
    final response = await http.get(
      Uri.https('ignitevr.gg',
          'cgi-bin/EchoStats.cgi/get_player_stats?fuzzy_search=true&player_name=NtsFranz'),
      headers: {'x-api-key': "9e895614-6e70-4552-b43a-a058d71bbe4c"},
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        playerData = IgniteStatsPlayer.fromJson(jsonDecode(response.body));
      });
    } else {
      print(response.statusCode);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get player data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
      SearchField(
        suggestions: [],
        hint: 'Search for a Player',
      ),
      Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.web,
                  size: 200,
                ),
              ],
            ),
            ListTile(
              title: Text(playerData == null ? 'None' : playerData.player_name),
              subtitle: Text('Ignite'),
            ),
          ],
        ),
      )
    ]);
  }
}
