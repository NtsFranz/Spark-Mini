import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spark_mini/Pages/OpenSparkLinkScreen.dart';
import '../Keys.dart';
import '../MatchJoiner.dart';
import '../Model/APIFrame.dart';
import '../Services/spark_links.dart';
import '../main.dart';

class ShareWidget extends ConsumerStatefulWidget {
  final String defaultSparkLink;
  const ShareWidget({Key key, this.defaultSparkLink = ''}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ShareWidgetState();
}

class ShareWidgetState extends ConsumerState<ShareWidget> {
  Map<String, dynamic> hostedMatches;
  bool fetching = false;

  @override
  void initState() {
    super.initState();

    final APIFrame initFrame = ref.read(frameProvider);
    fetchMatches(initFrame?.client_name ?? "_");
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
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          MatchJoiner(
              inGame: inGame, echoVRIP: echoVRIP, echoVRPort: echoVRPort),
          (() {
            if (frame?.private_match != null && frame.private_match) {
              return Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: EdgeInsets.all(24),
                  ),
                  onPressed: (() {
                    hostMatch(frame, ipLocation);
                  }),
                  child: Text('Post Match'),
                ),
                margin: EdgeInsets.all(8),
              );
            } else {
              return Container(
                child: Center(
                    child: Text(
                  'Not in Private Match.\n\nWhen you are in a private match, you can post your match here for others to see.',
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                )),
                margin: EdgeInsets.all(20),
              );
            }
          }()),
          (() {
            var matches = <dynamic>[];
            if (hostedMatches != null && hostedMatches.containsKey('matches')) {
              matches = matches + hostedMatches['matches'];
            }

            if (frame?.private_match != null &&
                frame.private_match &&
                matches.length > 0) {
              return Container(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: EdgeInsets.all(14),
                  ),
                  onPressed: (() {
                    unhostMatch(frame);
                  }),
                  child: Text('Remove Posted Match'),
                ),
                margin: EdgeInsets.all(8),
              );
            } else {
              return Container();
            }
          }()),
          (() {
            if (fetching) {
              return Center(child: const CircularProgressIndicator());
            } else {
              return Container();
            }
          }()),
          (() {
            var matches = <dynamic>[];
            if (hostedMatches != null && hostedMatches.containsKey('matches')) {
              matches = matches + hostedMatches['matches'];
            }

            if (matches.length > 0) {
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  (() {
                                    if (match['server_location'] != null) {
                                      return Text(match['server_location']);
                                    } else {
                                      return Text('From Atlas app');
                                    }
                                  }()),
                                  ElevatedButton(
                                    onPressed: () {
                                      String link = getFormattedLink(
                                          match['matchid'],
                                          true,
                                          0,
                                          true,
                                          match['blue_team_info'],
                                          match['orange_team_info']);
                                      Clipboard.setData(
                                          new ClipboardData(text: link));
                                      final snackBar =
                                          SnackBar(content: Text(link));
                                      // Find the ScaffoldMessenger in the widget tree
                                      // and use it to show a SnackBar.
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
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
                                  )
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                              ),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (() {
                                    if (match['orange_team_info'] != null &&
                                        match['orange_team_info']
                                                ['team_logo'] !=
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
                                    rows: (() {
                                      if (match['orange_team'] == '[]') {
                                        match['orange_team'] = [];
                                      }
                                      return match['orange_team']
                                          .map<DataRow>(
                                              (p) => DataRow(cells: <DataCell>[
                                                    DataCell(Text(p)),
                                                  ]))
                                          .toList();
                                    }()),
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
                                    rows: (() {
                                      if (match['blue_team'] == '[]') {
                                        match['blue_team'] = [];
                                      }
                                      return match['blue_team']
                                          .map<DataRow>(
                                              (p) => DataRow(cells: <DataCell>[
                                                    DataCell(Text(p)),
                                                  ]))
                                          .toList();
                                    }()),
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
                                            match['blue_team_info']
                                                ['team_logo']),
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
            } else {
              return Container(
                child: Center(
                    child: Text(
                  'No available matches.\nUse the button in the bottom right to refresh.',
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                )),
                margin: EdgeInsets.all(20),
              );
            }
          }()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchMatches(frame?.client_name ?? "_");
          Navigator.pushNamed(
            context,
            "/129743838098",
          );

          // showDialog<String>(
          //   context: context,
          //   builder: (BuildContext context) => AlertDialog(
          //     title: const Text('AlertDialog Title'),
          //     content: const Text('AlertDialog description'),
          //     actions: <Widget>[
          //       TextButton(
          //         onPressed: () => Navigator.pop(context, 'Cancel'),
          //         child: const Text('Cancel'),
          //       ),
          //       CircularProgressIndicator()
          //     ],
          //   ),
          // );

          // showBottomSheet(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return Container(
          //       height: 200,
          //       color: Colors.amber,
          //       child: Center(
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           mainAxisSize: MainAxisSize.min,
          //           children: <Widget>[
          //             const Text('Modal BottomSheet'),
          //             ElevatedButton(
          //               child: const Text('Close BottomSheet'),
          //               onPressed: () => Navigator.pop(context),
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // );
        },
        child: const Icon(Icons.refresh),
        tooltip: "Refresh Matches",
        // backgroundColor: Colors.red,
      ),
    );
  }

  void fetchMatches(String playerName) async {
    setState(() {
      fetching = true;
    });
    final response = await http
        .get(Uri.https('api.ignitevr.gg', 'hosted_matches/$playerName'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      if (!mounted) return;
      setState(() {
        hostedMatches = jsonDecode(response.body);
        fetching = false;
      });
    } else {
      print(response.statusCode);
      setState(() {
        fetching = false;
      });

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
          '${ipLocation['ip-api']['city']}, ${ipLocation['ip-api']['regionName']}';
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

    final response = await http.post(Uri.https('api.ignitevr.gg', 'host_match'),
        headers: headers, body: json.encode(data));

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      fetchMatches(frame.client_name);
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
        Uri.https('api.ignitevr.gg', 'unhost_match'),
        headers: headers,
        body: json.encode(data));

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      fetchMatches(frame.client_name);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get ignite atlas matches');
    }
  }
}
