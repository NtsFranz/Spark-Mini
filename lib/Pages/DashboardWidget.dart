import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import '../Model/APIFrame.dart';
import 'package:http/http.dart' as http;
import '../Services/server_score.dart';
import '../main.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class DashboardWidget extends ConsumerStatefulWidget {
  const DashboardWidget({Key key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => DashboardWidgetState();
}

class DashboardWidgetState extends ConsumerState<DashboardWidget> {
  bool findingQuestIP = false;
  double findingQuestIPProgress = 0;

  @override
  Widget build(BuildContext context) {
    final APIFrame frame = ref.watch(frameProvider);
    final bool inGame = ref.watch(inGameProvider);
    final settings = ref.watch(sharedPreferencesProvider);
    final echoVRIP = ref.watch(echoVRIPProvider);
    final echoVRPort = ref.watch(echoVRPortProvider);
    final String sparkLink = ref.watch(sparkLinkProvider);
    final orangeVRMLTeamInfo = ref.watch(orangeTeamVRMLInfoProvider);
    final blueVRMLTeamInfo = ref.watch(blueTeamVRMLInfoProvider);
    final Map<String, dynamic> ipLocation =
        ref.watch(ipLocationResponseProvider);

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
                } else if (frame.err_code == -7) {
                  // In loading screen
                  return Card(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                                heightFactor: 1.5,
                                child: Text(
                                  'In loading screen...',
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
                        ListTile(
                          title: Text(sparkLink),
                          subtitle: Text('Click to copy to clipboard'),
                          onTap: () {
                            String link = sparkLink;
                            Clipboard.setData(new ClipboardData(text: link));

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(link),
                            ));
                          },
                          onLongPress: () {
                            if (!Platform.isWindows) {
                              Share.share(sparkLink);
                            }
                          },
                        ),
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
                                      children: [
                                        TileLayer(
                                            urlTemplate:
                                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                            subdomains: ['a', 'b', 'c']),
                                        MarkerLayer(
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
                                num score = calculateServerScore(
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
                            contentPadding: EdgeInsets.all(0),
                            leading: (() {
                              if (orangeVRMLTeamInfo.containsKey('count') &&
                                  orangeVRMLTeamInfo['count'] > 1) {
                                return Container(
                                    child: Image.network(
                                  orangeVRMLTeamInfo['team_logo'],
                                  width: 40,
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
                              (() {
                                if (orangeVRMLTeamInfo.containsKey('count') &&
                                    orangeVRMLTeamInfo['count'] > 1) {
                                  return orangeVRMLTeamInfo['team_name'];
                                } else {
                                  return 'Orange Team';
                                }
                              }()),
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
                            contentPadding: EdgeInsets.all(0),
                            leading: (() {
                              if (blueVRMLTeamInfo.containsKey('count') &&
                                  blueVRMLTeamInfo['count'] > 1) {
                                return Container(
                                    child: Image.network(
                                  blueVRMLTeamInfo['team_logo'],
                                  width: 40,
                                ));
                              } else {
                                return Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                );
                              }
                            }()),
                            title: Text(
                              (() {
                                if (blueVRMLTeamInfo.containsKey('count') &&
                                    blueVRMLTeamInfo['count'] > 1) {
                                  return blueVRMLTeamInfo['team_name'];
                                } else {
                                  return 'Blue Team';
                                }
                              }()),
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
                  "Not Connected.\n\nMake sure:",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "1. Your Quest is on the same WiFi network as this device\n2. Echo VR is open\n3. You are in a match/lobby",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 10),
                Text(
                  "Then click the button below.",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                (() {
                  if (!findingQuestIP) {
                    return ElevatedButton(
                      onPressed: () async {
                        await findQuestIP();
                      },
                      child:
                          Text("Find Quest IP", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.red, // background
                        // onPrimary: Colors.white, // foreground
                        onPrimary:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        primary: Theme.of(context).colorScheme.primaryContainer,
                        padding: EdgeInsets.all(20),
                      ),
                    );
                  } else {
                    return Center(child: const CircularProgressIndicator());
                  }
                }()),
                SizedBox(height: 20),
                (() {
                  if (findingQuestIP) {
                    return LinearPercentIndicator(
                      percent: findingQuestIPProgress,
                    );
                  } else {
                    return Container();
                  }
                }()),
                SizedBox(height: 20),
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

  Future findQuestIP() async {
    final info = NetworkInfo();

    var wifiIP = await info.getWifiIP(); // 192.168.1.147
    if (wifiIP == null) {
      wifiIP = "192.168.0.1";
    }
    var baseIP = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

    var ips = <String>[];
    for (var i = 0; i < 255; i++) {
      final ip = i;
      ips.add('$baseIP.$ip');
    }
    ips.add('127.0.0.1');

    setState(() {
      findingQuestIPProgress = 0;
      findingQuestIP = true;
    });

    // this is the length of the finding process, since ips within a batch are sequential
    const int ipsPerBatch = 8;
    int numBatches = (ips.length / ipsPerBatch).ceil();
    List<List<String>> batches =
        List<List<String>>.generate(numBatches, (_) => <String>[]);
    for (var i = 0; i < ips.length; i++) {
      print(i % numBatches);
      batches[i % numBatches].add(ips[i]);
    }
    List<Future> futures = <Future>[];
    for (var b in batches) {
      futures.add(checkIPBatch(b, ips.length));
    }
    await Future.wait(futures);
    setState(() {
      findingQuestIP = false;
      print("Failed to find EchoVR IP");
    });
  }

  Future<String> checkIPBatch(List<String> ips, int totalIPs) async {
    for (var i = 0; i < ips.length; i++) {
      if (findingQuestIP) {
        final ip = await checkIP(ips[i]);
        setState(() {
          findingQuestIPProgress += min(1.0 / totalIPs, 1);
        });
        print(findingQuestIPProgress);
        if (ip != "") {
          setState(() {
            findingQuestIP = false;
            print("Found EchoVR IP: $ip");
            final settings = ref.read(sharedPreferencesProvider);
            settings.setString('echoVRIP', ip);
            settings.setString('echoVRPort', '6721');
            ref.refresh(sharedPreferencesProvider);
          });
          return ip;
        }
      }
    }
    return "";
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
      return "";
    }
  }
}
