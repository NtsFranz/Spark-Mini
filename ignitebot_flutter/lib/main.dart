import 'dart:developer';
import 'dart:isolate';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:settings_ui/settings_ui.dart';
import 'AtlasWidget.dart';
import 'DashboardWidget.dart';
import 'SettingsWidget.dart';
import 'ColorPage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:desktop_window/desktop_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
      ChangeNotifierProvider(create: (context) => Settings(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IgniteBot Lite',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
        accentColor: Colors.orangeAccent,
      ),
      home: MyHomePage(
        title: 'IgniteBot Lite',
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
  static String lastIP = '';
  Map<String, dynamic> lastIPLocationResponse = Map<String, dynamic>();
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
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchAPI());
    getEchoVRIP();
  }

  Future<void> getEchoVRIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newEchoVRIP = prefs.getString('echoVRIP') ?? '127.0.0.1';
    setState(() {
      echoVRIP = newEchoVRIP;
    });
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
          lastFrame = APIFrame.fromJson(jsonDecode(response.body));
          if (lastIP != lastFrame.sessionip) {
            getIPAPI(lastFrame.sessionip);
            lastIP = lastFrame.sessionip;
          }
        } catch (Exception) {
          print('Failed to parse API data');
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
      // BottomNavigationBarItem(icon: const Icon(Icons.link), label: "Atlas"),
      BottomNavigationBarItem(icon: const Icon(Icons.replay), label: "Replays"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.settings), label: "Settings"),
    ];

    List<Widget> _tabViews = [
      DashboardWidget(lastFrame, lastIPLocationResponse),
      // AtlasWidget(
      //   frame: lastFrame,
      //   setAtlasLinkStyle: setAtlasLinkStyle,
      // ),
      ColorPage(Colors.yellow),
      SettingsWidget(echoVRIP, setEchoVRIP),
    ];

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _tabViews[_currentPage.value],
      floatingActionButton: Consumer<Settings>(
        builder: (context, settings, child) => FloatingActionButton(
          onPressed: () {
            fetchAPI();
          },
          child: const Icon(Icons.refresh),
          tooltip: "Refresh Data",
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: bottomNavigationItems,
        currentIndex: _currentPage.value,
        type: BottomNavigationBarType.fixed,
        // selectedItemColor: colorScheme.onPrimary,
        // unselectedItemColor: colorScheme.onPrimary.withOpacity(.5),
        // backgroundColor: colorScheme.primary,
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

  Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('atlasLinkStyle', atlasLinkStyle);
    prefs.setBool('atlasLinkUseAngleBrackets', atlasLinkUseAngleBrackets);
    prefs.setBool('echoVRIP', atlasLinkAppendTeamNames);
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
  final String sessionip;
  final String sessionid;
  final String match_type;
  final String client_name;
  final String game_clock_display;
  final int blue_points;
  final int orange_points;
  final List<APITeam> teams;
  final Map<String, dynamic> raw;

  APIFrame({
    this.sessionip,
    this.sessionid,
    this.match_type,
    this.client_name,
    this.game_clock_display,
    this.blue_points,
    this.orange_points,
    this.teams,
    this.raw,
  });

  factory APIFrame.fromJson(Map<String, dynamic> json) {
    return APIFrame(
      sessionid: json['sessionid'],
      sessionip: json['sessionip'],
      match_type: json['match_type'],
      client_name: json['client_name'],
      game_clock_display: json['game_clock_display'],
      blue_points: json['blue_points'],
      orange_points: json['orange_points'],
      teams: json['teams']
          .map<APITeam>((teamJSON) => APITeam.fromJson(teamJSON))
          .toList(),
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