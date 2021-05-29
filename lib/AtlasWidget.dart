import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'Keys.dart';
import 'main.dart';

class AtlasWidget extends StatefulWidget {
  final APIFrame frame;
  final Map<String, dynamic> ipLocation;

  const AtlasWidget({Key key, this.frame, this.ipLocation}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AtlasState();
}

class AtlasState extends State<AtlasWidget> {
  final List<String> linkTypes = <String>['Choose', 'Player', 'Spectator'];
  Map<String, dynamic> ogAtlasMatches;
  Map<String, dynamic> igniteAtlasMatches;
  bool fetchingIgniteAtlas = false;
  bool fetchingOGAtlas = false;

  @override
  void initState() {
    super.initState();
    fetchIgniteAtlasMatches(widget.frame.client_name);
    fetchOGAtlasMatches(widget.frame.client_name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          (() {
            if (widget.frame.private_match != null &&
                widget.frame.private_match) {
              return Container(
                child: ElevatedButton(
                  onPressed: (() {
                    hostMatch(widget.frame, widget.ipLocation);
                  }),
                  child: Text('Host Match'),
                ),
                margin: EdgeInsets.all(8),
              );
            } else {
              return Container();
            }
          }()),
          (() {
            if (widget.frame.private_match != null &&
                widget.frame.private_match) {
              return Container(
                child: ElevatedButton(
                  onPressed: (() {
                    unhostMatch(widget.frame);
                  }),
                  child: Text('Remove Hosted Match'),
                ),
                margin: EdgeInsets.all(8),
              );
            } else {
              return Container(
                child: Center(
                    child: Text(
                  'Not in Match.\n\nWhen you are in a private match, you can post your match here for others to see.',
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                )),
                margin: EdgeInsets.all(20),
              );
            }
          }()),
          (() {
            if (fetchingIgniteAtlas || fetchingOGAtlas) {
              return Center(child: const CircularProgressIndicator());
            } else {
              return Container();
            }
          }()),
          (() {
            var matches = <dynamic>[];
            if (igniteAtlasMatches != null &&
                igniteAtlasMatches.containsKey('matches')) {
              matches = matches + igniteAtlasMatches['matches'];
            }
            if (ogAtlasMatches != null &&
                ogAtlasMatches.containsKey('matches')) {
              matches = matches + ogAtlasMatches['matches'];
            }
            return Column(
              children: matches
                  .map<Card>((match) => Card(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: <
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
                                                    match['matchid'],
                                                    match['blue_team_info'],
                                                    match['orange_team_info']);
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
                                            primary:
                                                Colors.black12, // background
                                            onPrimary:
                                                Colors.white, // foreground
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
                                              ['team_logo']),
                                      height: 50,
                                    );
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
                                  headingTextStyle:
                                      TextStyle(color: Colors.blue),
                                ),
                                (() {
                                  if (match['blue_team_info'] != null &&
                                      match['blue_team_info']['team_logo'] !=
                                          '') {
                                    return Container(
                                      child: Image.network(
                                          match['blue_team_info']['team_logo']),
                                      height: 50,
                                    );
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
        ],
      ),
      floatingActionButton: Consumer<Settings>(
        builder: (context, settings, child) => FloatingActionButton(
          onPressed: () {
            fetchOGAtlasMatches(widget.frame.client_name);
            fetchIgniteAtlasMatches(widget.frame.client_name);
          },
          child: const Icon(Icons.refresh),
          tooltip: "Refresh Matches",
        ),
      ),
    );
  }

  void fetchOGAtlasMatches(String playerName) async {
    setState(() {
      fetchingOGAtlas = true;
    });
    final response = await http.post(
        Uri.https('echovrconnect.appspot.com', 'api/v1/player/$playerName'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      if (!mounted) return;
      setState(() {
        ogAtlasMatches = jsonDecode(response.body);
        fetchingOGAtlas = false;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get og atlas matches');
    }
  }

  void fetchIgniteAtlasMatches(String playerName) async {
    setState(() {
      fetchingIgniteAtlas = true;
    });
    final response = await http.get(Uri.https(
        'ignitevr.gg', 'cgi-bin/EchoStats.cgi/atlas_matches_v2/$playerName'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      if (!mounted) return;
      setState(() {
        igniteAtlasMatches = jsonDecode(response.body);
        fetchingIgniteAtlas = false;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get ignite atlas matches');
    }
  }

  void hostMatch(APIFrame frame, Map<String, dynamic> ipLocation) async {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['matchid'] = frame.sessionid;
    data['username'] = frame.client_name;
    if (frame.teams[0].players != null) {
      data['blue_team'] =
          frame.teams[0].players.map<String>((p) => p.name).toList();
    } else {
      data['blue_team'] = [];
    }
    if (frame.teams[1].players != null) {
      data['orange_team'] =
          frame.teams[1].players.map<String>((p) => p.name).toList();
    } else {
      data['orange_team'] = [];
    }
    data['is_protected'] = false;
    data['visible_to_casters'] = true;
    if (ipLocation != null) {
      data['server_location'] =
          '${ipLocation['city']}, ${ipLocation['regionName']}';
    } else {
      data['server_location'] = '';
    }
    data['server_score'] = 0;
    data['private_match'] = frame.private_match;
    data['whitelist'] = [];
    data['blue_points'] = frame.blue_points;
    data['orange_points'] = frame.orange_points;
    data['slots'] = data['blue_team'].length +
        data['orange_team'].length +
        frame.teams[2].players.map<String>((p) => p.name).length;
    data['allow_spectators'] = false;
    data['game_status'] = frame.game_status;
    data['game_clock'] = frame.game_clock;

    Map<String, String> headers = new Map<String, String>();
    headers['x-api-key'] = Keys.atlasKey;

    print(json.encode(data));

    final response = await http.post(
        Uri.https('ignitevr.gg', 'cgi-bin/EchoStats.cgi/host_atlas_match_v2'),
        headers: headers,
        body: json.encode(data));

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      fetchIgniteAtlasMatches(frame.client_name);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get ignite atlas matches');
    }
  }

  void unhostMatch(APIFrame frame) async {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['matchid'] = frame.sessionid;
    data['username'] = frame.client_name;
    if (frame.teams[0].players != null) {
      data['blue_team'] =
          frame.teams[0].players.map<String>((p) => p.name).toList();
    } else {
      data['blue_team'] = [];
    }
    if (frame.teams[1].players != null) {
      data['orange_team'] =
          frame.teams[1].players.map<String>((p) => p.name).toList();
    } else {
      data['orange_team'] = [];
    }
    data['is_protected'] = false;
    data['visible_to_casters'] = true;
    data['server_location'] = '';
    data['server_score'] = 0;
    data['private_match'] = frame.private_match;
    data['whitelist'] = [];
    data['blue_points'] = frame.blue_points;
    data['orange_points'] = frame.orange_points;
    data['slots'] = data['blue_team'].length +
        data['orange_team'].length +
        frame.teams[2].players.map<String>((p) => p.name).length;
    data['allow_spectators'] = false;
    data['game_status'] = frame.game_status;
    data['game_clock'] = frame.game_clock;

    Map<String, String> headers = new Map<String, String>();
    headers['x-api-key'] = Keys.atlasKey;

    print(json.encode(data));

    final response = await http.post(
        Uri.https('ignitevr.gg', 'cgi-bin/EchoStats.cgi/unhost_atlas_match_v2'),
        headers: headers,
        body: json.encode(data));

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      fetchIgniteAtlasMatches(frame.client_name);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get ignite atlas matches');
    }
  }
}
