import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

class DashboardWidget extends StatelessWidget {
  final APIFrame frame;
  final Map<String, dynamic> ipLocation;
  // final int atlasLinkStyle;
  // final bool atlasLinkUseAngleBrackets;
  // final bool atlasLinkShowTeamNames;
  // final SharedPreferences prefs;
  final Settings settings;
  DashboardWidget(this.frame, this.ipLocation, this.settings);

  @override
  Widget build(BuildContext context) {
    if (frame != null && frame.sessionid != null) {
      return ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(getFormattedLink(frame.sessionid)),
                  subtitle: Text('Click to copy to clipboard'),
                  onTap: () {
                    Clipboard.setData(new ClipboardData(
                        text: getFormattedLink(frame.sessionid)));
                  },
                  onLongPress: () {
                    Share.share(getFormattedLink(frame.sessionid));
                  },
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
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
                    })())),
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
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text('Server Score'),
                        subtitle: Text((() {
                          if (frame.teams[0].players != null &&
                              frame.teams[1].players != null) {
                            return '${calculateServerScore(frame.teams[0].players.map<int>((p) => p.ping).toList(), frame.teams[1].players.map<int>((p) => p.ping).toList())}';
                          } else {
                            return 'Not enough players';
                          }
                        })()),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            child: Text(
                              '${frame.orange_points}',
                              textScaleFactor: 2,
                              textAlign: TextAlign.center,
                            ),
                            padding: const EdgeInsets.all(16),
                            width: 80,
                            color: Colors.orange,
                          ),
                          Expanded(
                              child: Text(
                            '${frame.game_clock_display}',
                            textAlign: TextAlign.center,
                            textScaleFactor: 2,
                          )),
                          Container(
                            child: Text(
                              '${frame.blue_points}',
                              textScaleFactor: 2,
                              textAlign: TextAlign.center,
                            ),
                            padding: const EdgeInsets.all(16),
                            width: 80,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person),
                        tileColor: Colors.orange,
                        title: Text('Orange Team'),
                        subtitle: Text(() {
                          if (frame.teams[0].players != null) {
                            return '${frame.teams[0].players.map((p) => p.name).join('\n')}';
                          } else {
                            return '';
                          }
                        }()),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person),
                        tileColor: Colors.blue,
                        title: Text('Blue Team'),
                        subtitle: Text(() {
                          if (frame.teams[1].players != null) {
                            return '${frame.teams[1].players.map((p) => p.name).join('\n')}';
                          } else {
                            return '';
                          }
                        }()),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.camera),
                        tileColor: Colors.grey,
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

  String getFormattedLink(String sessionid) {
    if (sessionid == null) sessionid = '**********************';

    String link = "";

    // Get settings

    if (settings.atlasLinkUseAngleBrackets) {
      switch (settings.atlasLinkStyle) {
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
      switch (settings.atlasLinkStyle) {
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
