import 'package:flutter/material.dart';
import 'package:spark_mini/FlutterPlayercard.dart';
import 'package:spark_mini/IgniteStatsPage.dart';
import 'Keys.dart';
import 'Model/IgniteStatsPlayer.dart';
import 'dart:convert';
import 'SizeConfig.dart';
import 'package:searchfield/searchfield.dart';
import 'package:http/http.dart' as http;

class IgniteStatsWidget extends StatefulWidget {
  IgniteStatsWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IgniteStatsState();
}

class IgniteStatsState extends State<IgniteStatsWidget> {
  IgniteStatsPlayer playerData;
  Map<String, dynamic> playerDataMap;
  String playerName;
  List<String> playerList = ['NtsFranz', 'Far', 'Dual-', 'VTSxKING', 'Wolf_23'];

  @override
  void initState() {
    super.initState();

    print('here');
    // fetchData('NtsFranz');
  }

  void fetchPlayerList() async {
    final response = await http.get(
      Uri.parse('https://ignitevr.gg/cgi-bin/EchoStats.cgi/get_player_list'),
      headers: {
        'x-api-key': Keys.simpleReadKey,
        'User-Agent': 'Spark-Mini/1.0'
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      if (!mounted) return;
      setState(() {
        String jsonString = response.body;
        playerData = IgniteStatsPlayer.fromJson(jsonDecode(jsonString));
        playerDataMap = jsonDecode(jsonString);
      });
    } else {
      print(response.statusCode);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get player data');
    }
  }

  void fetchData(String playerName) async {
    final response = await http.get(
      Uri.parse(
          'https://ignitevr.gg/cgi-bin/EchoStats.cgi/get_player_stats?fuzzy_search=true&player_name=NtsFranz'),
      headers: {
        'x-api-key': Keys.simpleReadKey,
        'User-Agent': 'Spark-Mini/1.0'
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      if (!mounted) return;
      setState(() {
        String jsonString = response.body;
        playerData = IgniteStatsPlayer.fromJson(jsonDecode(jsonString));
        playerDataMap = jsonDecode(jsonString);
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
    SizeConfig().init(context);
    return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
      SearchField(
        suggestions: playerList,
        hint: 'Search for a Player',
        onTap: (value) {
          setState(() {
            playerName = value;
          });
        },
      ),
      SizedBox(height: 30),
      // ElevatedButton(
      //   onPressed: () {
      //     // fetchData('NtsFranz');
      //     setState(() {
      //       playerName =
      //     });
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
      // IgniteStatsPage(playerDataMap),
      // FlutterPlayercard(),
      Container(
        child: () {
          if (playerName == null) {
            return Center(
                child: Text(
              'No Player Specified',
              textScaleFactor: 1.5,
            ));
          } else {
            return Image.network(
                'https://ignitevr.gg/cgi-bin/EchoStats.cgi/get_playercard/' +
                    playerName);
          }
        }(),
      ),
    ]);
  }
}
