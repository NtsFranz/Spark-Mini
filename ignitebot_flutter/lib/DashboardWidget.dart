import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:latlong/latlong.dart';

class DashboardWidget extends StatelessWidget {
  final APIFrame frame;
  final Map<String, dynamic> ipLocation;
  // final int atlasLinkStyle;
  // final bool atlasLinkUseAngleBrackets;
  // final bool atlasLinkShowTeamNames;
  // final SharedPreferences prefs;
  // final Settings settings;
  DashboardWidget(this.frame, this.ipLocation);

  @override
  Widget build(BuildContext context) {
    if (frame != null && frame.sessionid != null) {
      return ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Consumer<Settings>(
                  builder: (context, settings, child) => ListTile(
                    title: Text(getFormattedLink(
                        frame.sessionid,
                        settings.atlasLinkStyle,
                        settings.atlasLinkUseAngleBrackets)),
                    subtitle: Text('Click to copy to clipboard'),
                    onTap: () {
                      Clipboard.setData(new ClipboardData(
                          text: getFormattedLink(
                              frame.sessionid,
                              settings.atlasLinkStyle,
                              settings.atlasLinkUseAngleBrackets)));
                    },
                    onLongPress: () {
                      Share.share(getFormattedLink(
                          frame.sessionid,
                          settings.atlasLinkStyle,
                          settings.atlasLinkUseAngleBrackets));
                    },
                  ),
                )
              ],
            ),
          ),
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
                            ipLocation['status'] == 'success') {
                          return '${ipLocation['city']}, ${ipLocation['region']}';
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
                      if (ipLocation != null) {
                        double lat = ipLocation['lat'];
                        double lon = ipLocation['lon'];
                        print('$lat $lon');
                        return Container(
                            height: 200,
                            child: FlutterMap(
                              options: MapOptions(
                                  center: LatLng(lat, lon),
                                  zoom: 3.5,
                                  interactive: false),
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
                                      point: LatLng(lat, lon),
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
          (() {
            if (frame.match_type == "Social_2.0") {
              return Card(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
            } else {
              return Column(children: <Widget>[
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
                              color: Colors.orange.withOpacity(.5),
                              elevation: 5,
                              margin: EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
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
                              color: Colors.blue.withOpacity(.5),
                              elevation: 5,
                              margin: EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                            ),
                            width: 100,
                          ),
                        ],
                      ),
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
                                    .map<DataRow>((p) => DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text(p.name)),
                                              DataCell(Text(p.ping.toString()))
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
                                  DataColumn(label: Text('Ping')),
                                  DataColumn(label: Text('Player Name')),
                                ],
                                rows: frame.teams[1].players
                                    .map<DataRow>(
                                        (p) => DataRow(cells: <DataCell>[
                                              DataCell(Text(p.ping.toString())),
                                              DataCell(Text(p.name)),
                                            ]))
                                    .toList(),
                                columnSpacing: 10,
                                dataRowHeight: 35,
                                headingRowHeight: 40,
                                headingTextStyle: TextStyle(color: Colors.blue),
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
                          leading: Icon(
                            Icons.person,
                            color: Colors.orange,
                          ),
                          // tileColor: Colors.orange,
                          title: Text('Orange Team'),
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
                                .map<DataRow>((p) => DataRow(cells: <DataCell>[
                                      DataCell(Text(p.name)),
                                      DataCell(Text(p.stats.points.toString())),
                                      DataCell(
                                          Text(p.stats.assists.toString())),
                                      DataCell(Text(p.stats.saves.toString())),
                                      DataCell(Text(p.stats.steals.toString())),
                                      DataCell(Text(p.stats.stuns.toString())),
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
                          leading: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          title: Text('Blue Team'),
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
                                .map<DataRow>((p) => DataRow(cells: <DataCell>[
                                      DataCell(Text(p.name)),
                                      DataCell(Text(p.stats.points.toString())),
                                      DataCell(
                                          Text(p.stats.assists.toString())),
                                      DataCell(Text(p.stats.saves.toString())),
                                      DataCell(Text(p.stats.steals.toString())),
                                      DataCell(Text(p.stats.stuns.toString())),
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
      );
    } else {
      return Center(
        child: Text("Not Connected."),
      );
    }
  }

  /// <summary>
  /// This method is based on the python code that is used in the VRML Discord bot for calculating server score.
  /// </summary>
  /// <returns>The server score</returns>
  static double calculateServerScore(
      List<int> bluePings, List<int> orangePings) {
    // configurable parameters for tuning
    int min_ping = 10; // you don't lose points for being higher than this value
    int max_ping = 150; // won't compute if someone is over this number
    int ping_threshold =
        100; // you lose extra points for being higher than this

    // points_distribution dictates how many points come from each area:
    //   0 - difference in sum of pings between teams
    //   1 - within-team variance
    //   2 - overall server variance
    //   3 - overall high/low pings for server
    List<int> points_distribution = [30, 30, 30, 10];

    // determine max possible server/team variance and max possible sum diff,
    // given the min/max allowable ping
    double max_server_var = variance([
      min_ping,
      min_ping,
      min_ping,
      min_ping,
      max_ping,
      max_ping,
      max_ping,
      max_ping
    ]);
    double max_team_var = variance([min_ping, min_ping, max_ping, max_ping]);
    int max_sum_diff = (4 * max_ping) - (4 * min_ping);

    // sanity check for ping values
    if (bluePings == null ||
        bluePings.length == 0 ||
        orangePings == null ||
        orangePings.length == 0) {
      // Console.WriteLine("No player's ping can be over 150.");
      return -1;
    }
    if (bluePings.reduce(max) > max_ping ||
        orangePings.reduce(max) > max_ping) {
      // Console.WriteLine("No player's ping can be over 150.");
      return -1;
    }

    // calculate points for sum diff
    int blueSum = bluePings.reduce((a, b) => a + b);
    int orangeSum = orangePings.reduce((a, b) => a + b);
    int sum_diff = (blueSum - orangeSum).abs();

    double sum_points =
        (1 - (sum_diff / max_sum_diff)) * points_distribution[0];

    // calculate points for team variances
    double blueVariance = variance(bluePings);
    double orangeVariance = variance(orangePings);

    double mean_var = (blueVariance + orangeVariance) / 2;
    double team_points =
        (1 - (mean_var / max_team_var)) * points_distribution[1];

    // calculate points for server variance
    List<int> bothPings = new List.from(bluePings)..addAll(orangePings);

    double server_var = variance(bothPings);

    double server_points =
        (1 - (server_var / max_server_var)) * points_distribution[2];

    // calculate points for high/low ping across server
    double hilo = ((blueSum + orangeSum) - (min_ping * 8)) /
        ((ping_threshold * 8) - (min_ping * 8));

    double hilo_points = (1 - hilo) * points_distribution[3];

    // add up points
    double finalScore = sum_points + team_points + server_points + hilo_points;

    return finalScore;
  }

  static double variance(List<int> values) {
    double avg = values.reduce((a, b) => a + b) / values.length;
    return values.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b);
  }

  String getFormattedLink(
      String sessionid, int atlasLinkStyle, bool atlasLinkUseAngleBrackets) {
    if (sessionid == null) sessionid = '**********************';

    String link = "";

    if (atlasLinkUseAngleBrackets) {
      switch (atlasLinkStyle) {
        case 0:
          link = "<ignitebot://choose/$sessionid>";
          break;
        case 1:
          link = "<atlas://j/$sessionid>";
          break;
        case 2:
          link = "<atlas://s/$sessionid>";
          break;
      }
    } else {
      switch (atlasLinkStyle) {
        case 0:
          link = "ignitebot://choose/$sessionid";
          break;
        case 1:
          link = "atlas://j/$sessionid";
          break;
        case 2:
          link = "atlas://s/$sessionid";
          break;
      }
    }

    // if (atlasLinkAppendTeamNames) {
    //   if (orangeTeamName != '' && blueTeamName != '') {
    //     link = "$link ${orangeTeamName} vs ${blueTeamName}";
    //   }
    // }

    return link;
  }
}
