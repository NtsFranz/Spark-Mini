import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'DashboardWidget.dart';
import 'ColorPage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:desktop_window/desktop_window.dart';

void main() {
  runApp(MyApp());
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
  final RestorableString _echoVRIP = RestorableString('127.0.0.1');

  APIFrame lastFrame = APIFrame();
  String lastIP = '';
  Map<String, dynamic> lastIPLocationResponse = Map<String, dynamic>();

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    registerForRestoration(_currentPage, 'bottom_navigation_tab_index');
    registerForRestoration(_echoVRIP, 'echovr_ip');
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _echoVRIP.dispose();
    super.dispose();
  }

  void fetchAPI() async {
    final response =
        await http.get(Uri.http('${_echoVRIP.value}:6721', 'session'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        lastFrame = APIFrame.fromJson(jsonDecode(response.body));
        if (lastIP != lastFrame.sessionip) {
          getIPAPI(lastFrame.sessionip);
          lastIP = lastFrame.sessionip;
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get game data');
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

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final colorScheme = Theme.of(context).colorScheme;

    var bottomNavigationItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(icon: const Icon(Icons.link), label: "Atlas"),
      BottomNavigationBarItem(icon: const Icon(Icons.replay), label: "Replays"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.settings), label: "Settings"),
    ];

    List<Widget> _tabViews = [
      DashboardWidget(lastFrame, lastIPLocationResponse),
      ColorPage(Colors.blue),
      ColorPage(Colors.yellow),
      ColorPage(Colors.purple),
    ];

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: _tabViews[_currentPage.value],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchAPI();
        },
        child: const Icon(Icons.refresh),
        tooltip: "Refresh Data",
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

class APIFrame {
  final String sessionip;
  final String sessionid;
  final String client_name;
  final String game_clock_display;
  final int blue_points;
  final int orange_points;
  // final List<APITeam> teams;
  final Map<String, dynamic> raw;

  APIFrame({
    this.sessionip,
    this.sessionid,
    this.client_name,
    this.game_clock_display,
    this.blue_points,
    this.orange_points,
    // this.teams,
    this.raw,
  });

  factory APIFrame.fromJson(Map<String, dynamic> json) {
    return APIFrame(
      sessionid: json['sessionid'],
      sessionip: json['sessionip'],
      client_name: json['client_name'],
      game_clock_display: json['game_clock_display'],
      blue_points: json['blue_points'],
      orange_points: json['orange_points'],
      // teams: json['teams'].map((teamJSON) => APITeam.fromJson(teamJSON)).toList(),
      raw: json,
    );
  }
}

class APITeam {
  final String team;
  // final List<APIPlayer> teams;

  APITeam({
    this.team,
  });

  factory APITeam.fromJson(Map<String, dynamic> json) {
    return APITeam(
      team: json['team'],
    );
  }
}
