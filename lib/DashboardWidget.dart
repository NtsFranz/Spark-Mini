import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'main.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class DashboardWidget extends StatelessWidget {
  final bool inGame;
  final APIFrame frame;
  final Map<String, dynamic> ipLocation;
  final Map<String, dynamic> orangeVRMLTeamInfo;
  final Map<String, dynamic> blueVRMLTeamInfo;
  final setEchoVRIP;
  final setEchoVRPort;

  // String directory;
  // final List file;
  // final int atlasLinkStyle;
  // final bool atlasLinkUseAngleBrackets;
  // final bool atlasLinkShowTeamNames;
  // final SharedPreferences prefs;
  // final Settings settings;
  DashboardWidget(
      this.inGame,
      this.frame,
      this.ipLocation,
      this.orangeVRMLTeamInfo,
      this.blueVRMLTeamInfo,
      this.setEchoVRIP,
      this.setEchoVRPort);

  Future<String> findQuestIP() async {
    final info = NetworkInfo();

    var wifiIP = await info.getWifiIP(); // 192.168.1.147
    if (wifiIP == null) {
      wifiIP = "192.168.1.1";
    }
    var baseIP = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

    var requests = <Future>[];
    for (var i = 0; i < 255; i++) {
      final ip = i;
      requests.add(checkIP('$baseIP.$ip'));
    }
    requests.add(checkIP('127.0.0.1'));

    final finalIP = await Future.any(requests);
    // final successIndex = results.indexWhere((value) => value);
    // var finalIP = "";
    // if (successIndex == 255) {
    //   finalIP = "127.0.0.1";
    // } else if (successIndex > -1) {
    //   finalIP = "$baseIP.$successIndex";
    // }
    print("Found EchoVR IP: $finalIP");
    setEchoVRIP(finalIP);
    setEchoVRPort("6721");
    return finalIP;
  }

  // Returns the IP parameter quickly if correct, slowly if not
  Future<String> checkIP(String ip) async {
    try {
      final response = await http
          .get(Uri.http('$ip:6721', 'session'))
          .timeout(Duration(seconds: 5), onTimeout: () {
        return http.Response('Error', 408);
      });
      if (response.statusCode == 408) {
        print("Timed out: $ip");
        return "";
      } else {
        print(response.statusCode);

        print("SUCCESS: $ip");
        return ip;
      }
    } on SocketException catch (e) {
      print("Socket Exception: $ip");
      print(e);
      return ip;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (frame != null && frame.err_code != null) {
      return Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            (() {
              if (!inGame) {
                // not in game
                return Card(
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    ListTile(
                      title: Center(
                          child: Text(
                        'Not in Game. Data is out of date.',
                      )),
                    )
                  ]),
                  color: Colors.red,
                );
              } else {
                return Container();
              }
            }()),
            (() {
              if (frame.sessionid == null) {
                if (frame.err_code == -6) {
                  // in lobby
                  return Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                                heightFactor: 2,
                                child: Text(
                                  'In Lobby',
                                  textScaleFactor: 2,
                                )),
                          )
                        ]),
                  );
                } else if (frame.err_code == -2) {
                  // API not enabled
                  return Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                                heightFactor: 1.5,
                                child: Text(
                                  'API Access not enabled. Please enable it in the EchoVR settings menu.',
                                  textScaleFactor: 1.5,
                                )),
                          )
                        ]),
                  );
                }
              } else {
                // in game
                return Column(children: <Widget>[
                  // spark link
                  Card(
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(15.0),
                    // ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Consumer<Settings>(
                          builder: (context, settings, child) => ListTile(
                            title: Text(settings.getFormattedLink(
                                frame.sessionid,
                                orangeVRMLTeamInfo,
                                blueVRMLTeamInfo)),
                            subtitle: Text('Click to copy to clipboard'),
                            onTap: () {
                              String link = settings.getFormattedLink(
                                  frame.sessionid,
                                  orangeVRMLTeamInfo,
                                  blueVRMLTeamInfo);
                              Clipboard.setData(new ClipboardData(text: link));

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(link),
                              ));
                            },
                            onLongPress: () {
                              if (!Platform.isWindows) {
                                Share.share(settings.getFormattedLink(
                                    frame.sessionid,
                                    orangeVRMLTeamInfo,
                                    blueVRMLTeamInfo));
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  // server location
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ExpansionTile(
                          title: ListTile(
                            title: Text('Server Location'),
                            subtitle: Text((() {
                              if (frame != null) {
                                if (ipLocation != null &&
                                    ipLocation['ip-api'] != null &&
                                    ipLocation['ip-api']['status'] ==
                                        'success') {
                                  return '${ipLocation['ip-api']['city']}, ${ipLocation['ip-api']['region']}';
                                } else {
                                  return 'IP: ${frame.sessionip}';
                                }
                              } else {
                                return '---';
                              }
                            })()),
                            leading: Icon(Icons.map),
                          ),
                          children: [
                            (() {
                              if (ipLocation != null &&
                                  ipLocation['ip-api'] != null &&
                                  ipLocation['ip-api']['lat'] != null) {
                                final LatLng latLon = LatLng(
                                    ipLocation['ip-api']['lat'],
                                    ipLocation['ip-api']['lon']);
                                return Container(
                                    height: 200,
                                    child: FlutterMap(
                                      options: MapOptions(
                                        center: latLon,
                                        zoom: 3.5,
                                        // interactive: false
                                      ),
                                      layers: [
                                        TileLayerOptions(
                                            urlTemplate:
                                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                            subdomains: ['a', 'b', 'c']),
                                        MarkerLayerOptions(
                                          markers: [
                                            Marker(
                                              width: 10.0,
                                              height: 10.0,
                                              point: latLon,
                                              builder: (ctx) => Container(
                                                margin: EdgeInsets.all(0.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ));
                              } else {
                                return Text('No location found');
                              }
                            }())
                          ],
                        ),
                      ],
                    ),
                  ),
                  // points and time
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: [
                            Container(
                              child: Card(
                                child: Text(
                                  '${frame.orange_points}',
                                  textScaleFactor: 2,
                                  textAlign: TextAlign.center,
                                ),
                                color: Colors.orange.withOpacity(.75),
                                elevation: 5,
                                margin: EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              width: 100,
                            ),
                            Expanded(
                                child: Text(
                              '${frame.game_clock_display}',
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                            )),
                            Container(
                              child: Card(
                                child: Text(
                                  '${frame.blue_points}',
                                  textScaleFactor: 2,
                                  textAlign: TextAlign.center,
                                ),
                                color: Colors.blue.withOpacity(.75),
                                elevation: 5,
                                margin: EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              width: 100,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Last throw
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ExpansionTile(
                          title: ListTile(
                            title: Text('Last Throw'),
                            subtitle: Text(frame.last_throw.total_speed
                                    .toStringAsFixed(2) +
                                ' m/s\n'),
                            trailing: Column(
                              children: [
                                Text('Arm: ' +
                                    frame.last_throw.speed_from_arm
                                        .toStringAsFixed(2) +
                                    ' m/s'),
                                Text('Movement: ' +
                                    frame.last_throw.speed_from_movement
                                        .toStringAsFixed(2) +
                                    ' m/s'),
                                Text('Wrist: ' +
                                    frame.last_throw.speed_from_wrist
                                        .toStringAsFixed(2) +
                                    ' m/s'),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.end,
                            ),
                          ),
                          children: [
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(label: Text('Speeds')),
                                DataColumn(label: Text('')),
                              ],
                              rows: <DataRow>[
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Total Speed')),
                                  DataCell(Text('' +
                                      frame.last_throw.total_speed
                                          .toStringAsFixed(2) +
                                      ' m/s'))
                                ]),
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Arm Speed')),
                                  DataCell(Text('' +
                                      frame.last_throw.speed_from_arm
                                          .toStringAsFixed(2) +
                                      ' m/s'))
                                ]),
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Wrist Speed')),
                                  DataCell(Text('' +
                                      frame.last_throw.speed_from_wrist
                                          .toStringAsFixed(2) +
                                      ' m/s'))
                                ]),
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Movement Speed')),
                                  DataCell(Text('' +
                                      frame.last_throw.speed_from_movement
                                          .toStringAsFixed(2) +
                                      ' m/s'))
                                ]),
                              ],
                              columnSpacing: 10,
                              dataRowHeight: 35,
                              headingRowHeight: 30,
                              headingTextStyle: TextStyle(color: Colors.orange),
                            ),
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(label: Text('Touch Data')),
                                DataColumn(label: Text('')),
                              ],
                              rows: <DataRow>[
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Arm Speed')),
                                  DataCell(Text('' +
                                      frame.last_throw.arm_speed
                                          .toStringAsFixed(2) +
                                      ' m/s'))
                                ]),
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Rots/second')),
                                  DataCell(Text('' +
                                      frame.last_throw.rot_per_sec
                                          .toStringAsFixed(2) +
                                      ' r/s'))
                                ]),
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Pot spd from rot')),
                                  DataCell(Text('' +
                                      frame.last_throw.pot_speed_from_rot
                                          .toStringAsFixed(2) +
                                      ' m/s'))
                                ]),
                              ],
                              columnSpacing: 10,
                              dataRowHeight: 35,
                              headingRowHeight: 30,
                              headingTextStyle: TextStyle(color: Colors.orange),
                            ),
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(label: Text('Alignment Analysis')),
                                DataColumn(label: Text('')),
                              ],
                              rows: <DataRow>[
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Off Axis Spin')),
                                  DataCell(Text('' +
                                      frame.last_throw.off_axis_spin_deg
                                          .toStringAsFixed(1) +
                                      ' deg'))
                                ]),
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Wrist align')),
                                  DataCell(Text('' +
                                      frame.last_throw.wrist_align_to_throw_deg
                                          .toStringAsFixed(1) +
                                      ' deg'))
                                ]),
                                DataRow(cells: <DataCell>[
                                  DataCell(Text('Movement align')),
                                  DataCell(Text('' +
                                      frame.last_throw
                                          .throw_align_to_movement_deg
                                          .toStringAsFixed(1) +
                                      ' deg'))
                                ]),
                              ],
                              columnSpacing: 10,
                              dataRowHeight: 35,
                              headingRowHeight: 30,
                              headingTextStyle: TextStyle(color: Colors.orange),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // server score
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ExpansionTile(
                          title: ListTile(
                            title: Text('Server Score'),
                            subtitle: Text((() {
                              if (frame.teams[0].players != null &&
                                  frame.teams[1].players != null) {
                                double score = calculateServerScore(
                                    frame.teams[0].players
                                        .map<int>((p) => p.ping)
                                        .toList(),
                                    frame.teams[1].players
                                        .map<int>((p) => p.ping)
                                        .toList());
                                if (score == -1) {
                                  return "No player's ping can be over 150";
                                } else if (score == -2) {
                                  return "Not enough players";
                                } else if (score == -3) {
                                  return "Too many players";
                                } else if (score == -4) {
                                  return "Teams have different numbers of players";
                                }
                                return score.toStringAsFixed(2);
                              } else {
                                return 'Not enough players';
                              }
                            })()),
                            trailing: Text('Player Pings'),
                          ),
                          children: [
                            Row(
                              children: [
                                DataTable(
                                  columns: const <DataColumn>[
                                    DataColumn(label: Text('Player Name')),
                                    DataColumn(label: Text('Ping'))
                                  ],
                                  rows: frame.teams[0].players
                                      .map<DataRow>((p) =>
                                          DataRow(cells: <DataCell>[
                                            DataCell(Text(p.name)),
                                            DataCell(Text(p.ping.toString()))
                                          ]))
                                      .toList(),
                                  sortColumnIndex: 1,
                                  sortAscending: false,
                                  columnSpacing: 10,
                                  dataRowHeight: 35,
                                  headingRowHeight: 40,
                                  headingTextStyle:
                                      TextStyle(color: Colors.orange),
                                ),
                                DataTable(
                                  columns: const <DataColumn>[
                                    DataColumn(label: Text('Ping')),
                                    DataColumn(label: Text('Player Name')),
                                  ],
                                  rows: frame.teams[1].players
                                      .map<DataRow>((p) =>
                                          DataRow(cells: <DataCell>[
                                            DataCell(Text(p.ping.toString())),
                                            DataCell(Text(p.name)),
                                          ]))
                                      .toList(),
                                  sortColumnIndex: 0,
                                  sortAscending: false,
                                  columnSpacing: 10,
                                  dataRowHeight: 35,
                                  headingRowHeight: 40,
                                  headingTextStyle:
                                      TextStyle(color: Colors.blue),
                                )
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  // orange team members
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ExpansionTile(
                          title: ListTile(
                            leading: (() {
                              if (orangeVRMLTeamInfo.containsKey('count') &&
                                  orangeVRMLTeamInfo['count'] > 1) {
                                return Container(
                                    child: Image.network(
                                  orangeVRMLTeamInfo['team_logo'],
                                ));
                              } else {
                                return Icon(
                                  Icons.person,
                                  color: Colors.orange,
                                );
                              }
                            }()),
                            // trailing: Row(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       Text("Ignite"),
                            //       Image.network(
                            //         "https://vrmasterleague.com/images/logos/teams/09093858-5626-404d-97a3-10b8353fcc47.png",
                            //         height: 50,
                            //       ),
                            //     ]),
                            // tileColor: Colors.orange,
                            title: Text(
                              'Orange Team',
                              style: TextStyle(color: Colors.orange),
                            ),
                            subtitle: Text(() {
                              if (frame.teams[1].players != null) {
                                return '${frame.teams[1].players.map((p) => p.name).join('\n')}';
                              } else {
                                return '';
                              }
                            }()),
                          ),
                          children: [
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Points')),
                                DataColumn(label: Text('Assists')),
                                DataColumn(label: Text('Saves')),
                                DataColumn(label: Text('Steals')),
                                DataColumn(label: Text('Stuns')),
                              ],
                              rows: frame.teams[1].players
                                  .map<DataRow>((p) =>
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text(p.name)),
                                        DataCell(
                                            Text(p.stats.points.toString())),
                                        DataCell(
                                            Text(p.stats.assists.toString())),
                                        DataCell(
                                            Text(p.stats.saves.toString())),
                                        DataCell(
                                            Text(p.stats.steals.toString())),
                                        DataCell(
                                            Text(p.stats.stuns.toString())),
                                      ]))
                                  .toList(),
                              columnSpacing: 10,
                              dataRowHeight: 35,
                              headingRowHeight: 40,
                              headingTextStyle: TextStyle(color: Colors.orange),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  // blue team members
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ExpansionTile(
                          title: ListTile(
                            leading: (() {
                              if (blueVRMLTeamInfo.containsKey('count') &&
                                  blueVRMLTeamInfo['count'] > 1) {
                                return Container(
                                    child: Image.network(
                                  blueVRMLTeamInfo['team_logo'],
                                ));
                              } else {
                                return Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                );
                              }
                            }()),
                            title: Text(
                              'Blue Team',
                              style: TextStyle(color: Colors.blue),
                            ),
                            subtitle: Text(() {
                              if (frame.teams[0].players != null) {
                                return '${frame.teams[0].players.map((p) => p.name).join('\n')}';
                              } else {
                                return '';
                              }
                            }()),
                          ),
                          children: [
                            DataTable(
                              columns: const <DataColumn>[
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Points')),
                                DataColumn(label: Text('Assists')),
                                DataColumn(label: Text('Saves')),
                                DataColumn(label: Text('Steals')),
                                DataColumn(label: Text('Stuns')),
                              ],
                              rows: frame.teams[0].players
                                  .map<DataRow>((p) =>
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text(p.name)),
                                        DataCell(
                                            Text(p.stats.points.toString())),
                                        DataCell(
                                            Text(p.stats.assists.toString())),
                                        DataCell(
                                            Text(p.stats.saves.toString())),
                                        DataCell(
                                            Text(p.stats.steals.toString())),
                                        DataCell(
                                            Text(p.stats.stuns.toString())),
                                      ]))
                                  .toList(),
                              columnSpacing: 10,
                              dataRowHeight: 35,
                              headingRowHeight: 40,
                              headingTextStyle: TextStyle(color: Colors.blue),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  // spectators
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.camera),
                          // tileColor: Colors.grey.withOpacity(.2),
                          title: Text('Spectators'),
                          subtitle: Text(() {
                            if (frame.teams[2].players != null) {
                              return '${frame.teams[2].players.map((p) => p.name).join('\n')}';
                            } else {
                              return '';
                            }
                          }()),
                        ),
                      ],
                    ),
                  ),
                ]);
              }
            }()),
          ],
        ),
        // floatingActionButton: Consumer<Settings>(
        //   builder: (context, settings, child) => FloatingActionButton(
        //     onPressed: () {},
        //     child: const Icon(Icons.refresh),
        //     tooltip: "Refresh Data",
        //   ),
        // ),
      );
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.all(20),
          // child: ListView.builder(
          //     itemCount: file.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return Text(file[index].toString());
          //     }),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Not Connected.\n\nMake sure your Quest is on the same WiFi network as this device and EchoVR is open and in a match/lobby, then click the button below.",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                    onPressed: () async {
                      await findQuestIP();
                    },
                    child:
                        Text("Find Quest IP", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                      onPrimary: Colors.white, // foreground
                      padding: EdgeInsets.all(20),
                    )),
                SizedBox(height: 40),
                Text(
                  "Or enter your Quest IP manually on the settings page.",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                ),
              ]),
        ),
      );
    }
  }

  // Make New Function
  void _listofFiles() async {
    // setState(() {
    //   file = Directory("$directory/resume/").listSync();  //use your folder name insted of resume.
    // });
  }

  /// <summary>
  /// This method is based on the python code that is used in the VRML Discord bot for calculating server score.
  /// </summary>
  /// <returns>
  /// The server score
  /// -1: Ping over 150
  /// -2: Too few players
  /// -3: Too many players
  /// -4: Teams have different number of players
  /// </returns>
  static double calculateServerScore(
      List<int> bluePings, List<int> orangePings) {
    if (bluePings == null || orangePings == null) {
      return -100;
    }

    // configurable parameters for tuning
    int ppt = bluePings.length; // players per team - can be set to 5 for NEPA
    int min_ping = 10; // you don't lose points for being higher than this value
    int max_ping = 150; // won't compute if someone is over this number
    int ping_threshold =
        100; // you lose extra points for being higher than this

    // points_distribution dictates how many points come from each area:
    //   0 - difference in sum of pings between teams
    //   1 - within-team variance
    //   2 - overall server variance
    //   3 - overall high/low pings for server
    final points_distribution = [30, 30, 30, 10];

    // sanity check for ping values
    if (bluePings.length < 4) {
      return -2;
    } else if (bluePings.length > 5) {
      return -4;
    }

    if (bluePings.length != orangePings.length) {
      return -4;
    }

    if (bluePings.reduce(max) > max_ping ||
        orangePings.reduce(max) > max_ping) {
      return -1;
    }

    // determine max possible server/team variance and max possible sum diff,
    // given the min/max allowable ping
    double max_server_var = variance(new List<int>.generate(
        ppt * 2, (i) => i % 2 == 0 ? min_ping : max_ping));
    var l1 = new List<int>.generate(
        ((ppt as double) / 2.0).floor(), (i) => min_ping);
    l1.addAll(new List<int>.generate(
        ((ppt as double) / 2.0).ceil(), (i) => max_ping));
    double max_team_var = variance(l1);
    double max_sum_diff =
        ((ppt as double) * max_ping) - ((ppt as double) * min_ping);

    // calculate points for sum diff
    double blueSum = bluePings.reduce((a, b) => a + b) as double;
    double orangeSum = orangePings.reduce((a, b) => a + b) as double;
    double sum_diff = (blueSum - orangeSum).abs();
    double sum_points =
        (1 - (sum_diff / max_sum_diff)) * points_distribution[0];

    // calculate points for team variances
    double blueVariance = variance(bluePings);
    double orangeVariance = variance(orangePings);

    double mean_var = (blueVariance + orangeVariance) / 2.0;
    double team_points =
        (1 - (mean_var / max_team_var)) * points_distribution[1];

    List<int> bothPings = new List.from(bluePings)..addAll(orangePings);

    // calculate points for server variance
    double server_var = variance(bothPings);
    double server_points =
        (1 - (server_var / max_server_var)) * points_distribution[2];

    // calculate points for high/low ping across server
    double hilo = ((blueSum + orangeSum) - (min_ping * ppt * 2)) /
        ((ping_threshold * ppt * 2) - (min_ping * ppt * 2));
    double hilo_points = (1 - hilo) * points_distribution[3];

    // add up points
    double result = sum_points + team_points + server_points + hilo_points;

    return result;
  }

  static double variance(List<int> values) {
    double avg = values.reduce((a, b) => a + b) / values.length;
    return values.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b);
  }
}
