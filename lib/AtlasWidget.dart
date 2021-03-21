import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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
        (() {
          var matches = <dynamic>[];
          if (igniteAtlasMatches != null &&
              igniteAtlasMatches.containsKey('matches')) {
            matches = matches + igniteAtlasMatches['matches'];
          }
          if (ogAtlasMatches != null && ogAtlasMatches.containsKey('matches')) {
            matches = matches + ogAtlasMatches['matches'];
          }
          return Column(
            children: matches
                .map<Card>((match) => Card(
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        Container(
                          margin: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text(
                                match['username'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              (() {
                                if (match['server_location'] != null) {
                                  return Text(match['server_location']);
                                } else {
                                  return Text('From Atlas app');
                                }
                              }()),
                              Consumer<Settings>(
                                  builder: (context, settings, child) =>
                                      ElevatedButton(
                                        onPressed: () {
                                          String link =
                                              settings.getFormattedLink(
                                                  match['matchid'], null, null);
                                          Clipboard.setData(
                                              new ClipboardData(text: link));
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(link),
                                          ));
                                        },
                                        child: Row(children: [
                                          Text("Copy Join Link"),
                                          Container(
                                              margin: EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.copy,
                                                size: 16,
                                              ))
                                        ]),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.black12, // background
                                          onPrimary: Colors.white, // foreground
                                        ),
                                      ))
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (() {
                                if (match['orange_team_info'] != null &&
                                    match['orange_team_info']['team_logo'] !=
                                        '') {
                                  return Container(
                                      child: Image.network(
                                          match['orange_team_info']
                                              ['team_logo']));
                                } else {
                                  return Icon(Icons.person);
                                }
                              }()),
                              DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Orange Team')),
                                ],
                                rows: match['orange_team']
                                    .map<DataRow>(
                                        (p) => DataRow(cells: <DataCell>[
                                              DataCell(Text(p)),
                                            ]))
                                    .toList(),
                                columnSpacing: 10,
                                dataRowHeight: 35,
                                headingRowHeight: 40,
                                headingTextStyle:
                                    TextStyle(color: Colors.orange),
                              ),
                              DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Blue Team')),
                                ],
                                rows: match['blue_team']
                                    .map<DataRow>(
                                        (p) => DataRow(cells: <DataCell>[
                                              DataCell(Text(p)),
                                            ]))
                                    .toList(),
                                columnSpacing: 10,
                                dataRowHeight: 35,
                                headingRowHeight: 40,
                                headingTextStyle: TextStyle(color: Colors.blue),
                              ),
                              (() {
                                if (match['blue_team_info'] != null &&
                                    match['blue_team_info']['team_logo'] !=
                                        '') {
                                  return Container(
                                      child: Image.network(
                                          match['blue_team_info']
                                              ['team_logo']));
                                } else {
                                  return Icon(Icons.person);
                                }
                              }())
                            ]),
                      ]),
                    ))
                .toList(),
          );
        }()),
        Container(
          child: ElevatedButton(
            onPressed: (() {
              fetchOGAtlasMatches(widget.frame.client_name);
              fetchIgniteAtlasMatches(widget.frame.client_name);
            }),
            child: Text('Refresh'),
          ),
          margin: EdgeInsets.all(8),
        )
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
