import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:spark_mini/IgniteStatsWidget.dart';
import 'AtlasWidget.dart';
import 'DashboardWidget.dart';
import 'SettingsWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:window_size/window_size.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Spark Mini");
    setWindowMinSize(Size(375, 750));
    setWindowMaxSize(Size(600, 1000));
  }
  runApp(
      ChangeNotifierProvider(create: (context) => Settings(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spark Mini',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        accentColor: Colors.orangeAccent,
      ),
      home: MyHomePage(
        title: 'Spark Mini',
        restorationId: 'root',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, @required this.restorationId})
      : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String restorationId;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RestorationMixin {
  final RestorableInt _currentPage = RestorableInt(0);
  // final RestorableString _echoVRIP = RestorableString('127.0.0.1');
  String echoVRIP = '127.0.0.1';
  // int atlasLinkStyle = 0;
  // bool atlasLinkUseAngleBrackets = false;
  // bool atlasLinkAppendTeamNames = false;
  Timer timer;

  static APIFrame lastFrame = APIFrame();
  Map<String, dynamic> lastIPLocationResponse = Map<String, dynamic>();
  Map<String, dynamic> orangeVRMLTeamInfo = Map<String, dynamic>();
  Map<String, dynamic> blueVRMLTeamInfo = Map<String, dynamic>();
  // SharedPreferences prefs;
  // Settings settings = new Settings();

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    registerForRestoration(_currentPage, 'bottom_navigation_tab_index');
    // registerForRestoration(_echoVRIP, 'echovr_ip');
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      fetchAPI();
      setState(() {});
    });
    getEchoVRIP();
  }

  Future<void> getEchoVRIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String newEchoVRIP = prefs.getString('echoVRIP') ?? '127.0.0.1';
      setState(() {
        echoVRIP = newEchoVRIP;
      });
    } catch (Exception) {
      setState(() {
        echoVRIP = '127.0.0.1';
      });
    }
  }

  Future<void> setEchoVRIP(String value) async {
    setState(() {
      echoVRIP = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('echoVRIP', value);
  }

  @override
  void dispose() {
    _currentPage.dispose();
    // _echoVRIP.dispose();
    timer.cancel();
    super.dispose();
  }

  void fetchAPI() async {
    // return;
    try {
      log(echoVRIP);
      final response = await http.get(Uri.http('$echoVRIP:6721', 'session'));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        // setState(() {
        try {
          var newFrame = APIFrame.fromJson(jsonDecode(response.body));

          try {
            // switched match
            if (lastFrame.sessionid == null ||
                lastFrame.sessionip != newFrame.sessionip) {
              getIPAPI(newFrame.sessionip);
            }

            // player joined or left (or switched match)
            for (int i = 0; i < 2; i++) {
              if (lastFrame.sessionid == null ||
                  lastFrame.sessionip != newFrame.sessionip ||
                  lastFrame.teams[i].players.length !=
                      newFrame.teams[i].players.length) {
                getTeamnameFromPlayerList(
                    newFrame.teams[i].players
                        .map<String>((p) => p.name)
                        .toList(),
                    i);
              }
            }
          } catch (Exception) {
            print('Failed to process API data');
          }
          lastFrame = newFrame;
        } catch (Exception) {
          print('Failed to parse API response');
        }
        // });
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        // throw Exception('Failed to get game data');
      }
    } catch (SocketException) {
      print('Not in game');
    }
  }

  void getIPAPI(String ip) async {
    print('Fetching from ip-api');
    final response = await http.get(Uri.http('ip-api.com', 'json/$ip'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        lastIPLocationResponse = jsonDecode(response.body);
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get game data');
    }
  }

  void getTeamnameFromPlayerList(List<String> players, int teamIndex) async {
    final response = await http.get(Uri.https(
        'ignitevr.gg',
        'cgi-bin/EchoStats.cgi/get_team_name_from_list',
        {'player_list': '${jsonEncode(players)}'}));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        if (teamIndex == 0) {
          orangeVRMLTeamInfo = jsonDecode(response.body);
        } else if (teamIndex == 1) {
          blueVRMLTeamInfo = jsonDecode(response.body);
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get player team info');
    }
  }

  // void getSharedPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     atlasLinkStyle = prefs.getInt('atlasLinkStyle');
  //     atlasLinkUseAngleBrackets =
  //         prefs.getBool('atlasLinkUseAngleBrackets') ?? true;
  //     atlasLinkAppendTeamNames =
  //         prefs.getBool('atlasLinkAppendTeamNames') ?? false;
  //     echoVRIP = prefs.getString('echoVRIP') ?? '127.0.0.1';
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final colorScheme = Theme.of(context).colorScheme;

    // getSharedPrefs();

    var bottomNavigationItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(icon: const Icon(Icons.link), label: "Atlas"),
      // BottomNavigationBarItem(icon: const Icon(Icons.replay), label: "Replays"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.web), label: "Ignite Stats"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.settings), label: "Settings"),
    ];

    List<Widget> _tabViews = [
      DashboardWidget(lastFrame, lastIPLocationResponse, orangeVRMLTeamInfo,
          blueVRMLTeamInfo),
      AtlasWidget(
        frame: lastFrame,
        ipLocation: lastIPLocationResponse,
      ),
      IgniteStatsWidget(),
      // ColorPage(Colors.yellow),
      SettingsWidget(echoVRIP: echoVRIP, setEchoVRIP: setEchoVRIP),
    ];

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _tabViews[_currentPage.value],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: bottomNavigationItems,
        currentIndex: _currentPage.value,
        type: BottomNavigationBarType.fixed,
        // selectedItemColor: colorScheme.onPrimary,
        // unselectedItemColor: colorScheme.onPrimary.withOpacity(.5),
        // backgroundColor: Colors.white10,
        onTap: (index) {
          setState(() {
            _currentPage.value = index;
          });
        },
      ),
    );
  }
}

class Settings with ChangeNotifier {
  // String echoVRIP = '127.0.0.1';
  int atlasLinkStyle = 0;
  bool atlasLinkUseAngleBrackets = true;
  bool atlasLinkAppendTeamNames = false;
  String clientName = ''; // doesn't need to notify others usually

  Settings() {
    log('recreate');
    load();
  }

  // void setEchoVRIP(String value) {
  //   echoVRIP = value;
  //   notifyListeners();
  // }

  void setAtlasLinkUseAngleBrackets(bool value) {
    atlasLinkUseAngleBrackets = value;
    notifyListeners();
    save();
  }

  void setAtlasLinkStyle(int value) {
    atlasLinkStyle = value;
    notifyListeners();
    save();
  }

  void setAtlasLinkAppendTeamNames(bool value) {
    atlasLinkAppendTeamNames = value;
    notifyListeners();
    save();
  }

  String getFormattedLink(
      String sessionid,
      Map<String, dynamic> orangeVRMLTeamInfo,
      Map<String, dynamic> blueVRMLTeamInfo) {
    if (sessionid == null) sessionid = '**********************';

    String link = "";

    if (atlasLinkUseAngleBrackets) {
      switch (atlasLinkStyle) {
        case 0:
          link = "<spark://c/$sessionid>";
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
          link = "spark://c/$sessionid";
          break;
        case 1:
          link = "atlas://j/$sessionid";
          break;
        case 2:
          link = "atlas://s/$sessionid";
          break;
      }
    }

    if (atlasLinkAppendTeamNames) {
      String orangeName = '?';
      String blueName = '?';
      if (orangeVRMLTeamInfo != null &&
          orangeVRMLTeamInfo.containsKey('team_name') &&
          orangeVRMLTeamInfo['team_name'] != '') {
        orangeName = orangeVRMLTeamInfo['team_name'];
      }
      if (blueVRMLTeamInfo != null &&
          blueVRMLTeamInfo.containsKey('team_name') &&
          blueVRMLTeamInfo['team_name'] != '') {
        blueName = blueVRMLTeamInfo['team_name'];
      }

      link = "$link $orangeName vs $blueName";
    }

    return link;
  }

  Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('atlasLinkStyle', atlasLinkStyle);
    prefs.setBool('atlasLinkUseAngleBrackets', atlasLinkUseAngleBrackets);
    prefs.setBool('atlasLinkAppendTeamNames', atlasLinkAppendTeamNames);
  }

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('atlasLinkStyle') != null)
      atlasLinkStyle = prefs.getInt('atlasLinkStyle');
    if (prefs.getBool('atlasLinkUseAngleBrackets') != null)
      atlasLinkUseAngleBrackets = prefs.getBool('atlasLinkUseAngleBrackets');
    if (prefs.getBool('atlasLinkAppendTeamNames') != null)
      atlasLinkAppendTeamNames = prefs.getBool('atlasLinkAppendTeamNames');
  }
}

class APIFrame {
  final String sessionid;
  final String sessionip;
  final String game_status;
  final double game_clock;
  final String match_type;
  final bool private_match;
  final String client_name;
  final String game_clock_display;
  final int blue_points;
  final int orange_points;
  final List<APITeam> teams;
  final APILastThrow last_throw;
  final Map<String, dynamic> raw;

  APIFrame({
    this.sessionid,
    this.sessionip,
    this.game_status,
    this.game_clock,
    this.match_type,
    this.private_match,
    this.client_name,
    this.game_clock_display,
    this.blue_points,
    this.orange_points,
    this.last_throw,
    this.teams,
    this.raw,
  });

  factory APIFrame.fromJson(Map<String, dynamic> json) {
    return APIFrame(
      sessionid: json['sessionid'],
      sessionip: json['sessionip'],
      match_type: json['match_type'],
      game_status: json['game_status'],
      game_clock: json['game_clock'],
      private_match: json['private_match'],
      client_name: json['client_name'],
      game_clock_display: json['game_clock_display'],
      blue_points: json['blue_points'],
      orange_points: json['orange_points'],
      teams: json['teams']
          .map<APITeam>((teamJSON) => APITeam.fromJson(teamJSON))
          .toList(),
      last_throw: APILastThrow.fromJson(json['last_throw']),
      raw: json,
    );
  }
}

class APITeam {
  final String team;
  final List<APIPlayer> players;

  APITeam({this.team, this.players});

  factory APITeam.fromJson(Map<String, dynamic> json) {
    return APITeam(
      team: json['team'],
      players: json.containsKey('players')
          ? json['players']
              .map<APIPlayer>((playerJSON) => APIPlayer.fromJson(playerJSON))
              .toList()
          : <APIPlayer>[],
    );
  }
}

class APIPlayer {
  final String name;
  final int ping;
  final APIStats stats;

  APIPlayer({this.name, this.ping, this.stats});

  factory APIPlayer.fromJson(Map<String, dynamic> json) {
    return APIPlayer(
      name: json['name'],
      ping: json['ping'],
      stats: APIStats.fromJson(json['stats']),
    );
  }
}

class APIStats {
  final double possession_time;
  final int points;
  final int saves;
  final int goals;
  final int stuns;
  final int steals;
  final int blocks;
  final int assists;
  final int shots_taken;

  APIStats(
      {this.possession_time,
      this.points,
      this.saves,
      this.goals,
      this.stuns,
      this.steals,
      this.blocks,
      this.assists,
      this.shots_taken});

  factory APIStats.fromJson(Map<String, dynamic> json) {
    return APIStats(
      possession_time: json['possession_time'],
      points: json['points'],
      saves: json['saves'],
      goals: json['goals'],
      stuns: json['stuns'],
      steals: json['steals'],
      blocks: json['blocks'],
      assists: json['assists'],
      shots_taken: json['shots_taken'],
    );
  }
}

class APILastThrow {
  final double arm_speed;
  final double total_speed;
  final double off_axis_spin_deg;
  final double wrist_throw_penalty;
  final double rot_per_sec;
  final double pot_speed_from_rot;
  final double speed_from_arm;
  final double speed_from_movement;
  final double speed_from_wrist;
  final double wrist_align_to_throw_deg;
  final double throw_align_to_movement_deg;
  final double off_axis_penalty;
  final double throw_move_penalty;

  APILastThrow(
      {this.arm_speed,
      this.total_speed,
      this.off_axis_spin_deg,
      this.wrist_throw_penalty,
      this.rot_per_sec,
      this.pot_speed_from_rot,
      this.speed_from_arm,
      this.speed_from_movement,
      this.speed_from_wrist,
      this.wrist_align_to_throw_deg,
      this.throw_align_to_movement_deg,
      this.off_axis_penalty,
      this.throw_move_penalty});

  factory APILastThrow.fromJson(Map<String, dynamic> json) {
    return APILastThrow(
      arm_speed: json['arm_speed'],
      total_speed: json['total_speed'],
      off_axis_spin_deg: json['off_axis_spin_deg'],
      wrist_throw_penalty: json['wrist_throw_penalty'],
      rot_per_sec: json['rot_per_sec'],
      pot_speed_from_rot: json['pot_speed_from_rot'],
      speed_from_arm: json['speed_from_arm'],
      speed_from_movement: json['speed_from_movement'],
      speed_from_wrist: json['speed_from_wrist'],
      wrist_align_to_throw_deg: json['wrist_align_to_throw_deg'],
      throw_align_to_movement_deg: json['throw_align_to_movement_deg'],
      off_axis_penalty: json['off_axis_penalty'],
      throw_move_penalty: json['throw_move_penal'],
    );
  }
}
