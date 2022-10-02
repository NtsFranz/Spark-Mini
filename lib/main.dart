import 'dart:developer';
import 'package:archive/archive_io.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:spark_mini/Pages/MatchRulesPage.dart';
import 'Model/APIFrame.dart';
import 'Pages/AtlasWidget.dart';
import 'Pages/DashboardWidget.dart';
import 'Pages/DebugPage.dart';
import 'Pages/SettingsWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:isolate';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'Services/FrameFetcher.dart';
import 'Services/spark_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setMaxWindowSize();
  }

  runApp(ProviderScope(
    overrides: [
      // override the previous value with the new object
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: MyApp(),
  ));
}

final ipLocationResponseProvider =
    StateProvider((ref) => Map<String, dynamic>());
final orangeTeamVRMLInfoProvider =
    StateProvider((ref) => Map<String, dynamic>());
final blueTeamVRMLInfoProvider = StateProvider((ref) => Map<String, dynamic>());
final inGameProvider = StateProvider((ref) {
  final APIFrame frame = ref.watch(frameProvider);
  return frame != null;
});
final sparkLinkProvider = StateProvider<String>((ref) {
  final APIFrame frame = ref.watch(frameProvider);
  final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
  final orange = ref.watch(orangeTeamVRMLInfoProvider);
  final blue = ref.watch(blueTeamVRMLInfoProvider);
  if (frame != null) {
    return getFormattedLink(
        frame.sessionid,
        prefs.getBool('linkAngleBrackets') ?? true,
        prefs.getInt('linkType') ?? 0,
        prefs.getBool('linkAppendTeamNames') ?? false,
        orange,
        blue);
  } else {
    return "";
  }
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final echoVRIPProvider = StateProvider<String>((ref) {
  final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
  final ip = prefs.getString('echoVRIP');
  if (ip == null) {
    return '127.0.0.1';
  } else {
    return ip;
  }
});
final echoVRPortProvider = StateProvider<String>((ref) {
  final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
  final ip = prefs.getString('echoVRPort');
  if (ip == null) {
    return '6721';
  } else {
    return ip;
  }
});

final frameProvider = StateNotifierProvider<FrameFetcher, APIFrame>((ref) {
  return FrameFetcher();
});

// final lastFrameProvider = StateProvider((ref) {
//   final APIFrame frame = ref.watch(frameProvider);
//   if (frame != null) {
//     return frame;
//   }
//   return null;
// });

// final sharedPrefs = FutureProvider<SharedPreferences>(
//     (_) async => await SharedPreferences.getInstance());

// class EchoVRIP extends StateNotifier<String> {
//   EchoVRIP(this.pref) : super(pref?.getString("echoVRIP") ?? []);

//   static final provider = StateNotifierProvider<EchoVRIP, String>((ref) {
//     final pref = ref.watch(sharedPrefs).maybeWhen(
//           data: (value) => value,
//           orElse: () => '127.0.0.1',
//         );
//     return EchoVRIP(pref);
//   });

//   final SharedPreferences pref;

//   void set(String ip) {
//     state = ip;
//     pref.setString("echoVRIP", state);
//   }
// }

// class EchoVRPort extends StateNotifier<String> {
//   EchoVRPort(this.pref) : super(pref?.getString("echoVRPort") ?? []);

//   static final provider = StateNotifierProvider<EchoVRPort, String>((ref) {
//     final pref = ref.watch(sharedPrefs).maybeWhen(
//           data: (value) => value,
//           orElse: () => '127.0.0.1',
//         );
//     return EchoVRPort(pref);
//   });

//   final SharedPreferences pref;

//   void set(String ip) {
//     state = ip;
//     pref.setString("echoVRPort", state);
//   }
// }

Future setMaxWindowSize() async {
  await DesktopWindow.setWindowSize(Size(560, 870));

  await DesktopWindow.setMinWindowSize(Size(350, 570));
  await DesktopWindow.setMaxWindowSize(Size(800, 1000));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spark Mini',
      // theme: IgniteTheme.darkTheme,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
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

  final String restorationId;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RestorationMixin {
  final RestorableInt _currentPage = RestorableInt(0);

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    registerForRestoration(_currentPage, 'bottom_navigation_tab_index');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bottomNavigationItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.share), label: "Share Match"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.rule), label: "Match Rules"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.bug_report), label: "Debug"),
      // BottomNavigationBarItem(icon: const Icon(Icons.replay), label: "Replays"),
      // BottomNavigationBarItem(icon: const Icon(Icons.web), label: "Ignite Stats"),
      BottomNavigationBarItem(
          icon: const Icon(Icons.settings), label: "Settings"),
    ];

    List<Widget> _tabViews = [
      DashboardWidget(),
      AtlasWidget(),
      MatchRulesPage(),
      DebugPage(),
      // ReplayWidget(replayFilePath),
      // IgniteStatsWidget(),
      // ColorPage(Colors.yellow),
      SettingsWidget(),
    ];

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        // backgroundColor: Colors.red,
      ),
      body: _tabViews[_currentPage.value],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: bottomNavigationItems,
        currentIndex: _currentPage.value,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white.withOpacity(.5),
        // backgroundColor: Colors.black12,
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
  bool saveReplays = false;
  String clientName = ''; // doesn't need to notify others usually

  Settings() {
    log('recreate');
    load();
  }

  // void setEchoVRIP(String value) {
  //   echoVRIP = value;
  //   notifyListeners();
  // }

  void setSaveReplays(bool value) {
    saveReplays = value;
    notifyListeners();
    save();
  }

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
    prefs.setBool('atlasLinkAppendTeamNames', atlasLinkAppendTeamNames);
    prefs.setBool('saveReplays', saveReplays);
  }

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('atlasLinkStyle') != null)
      atlasLinkStyle = prefs.getInt('atlasLinkStyle');
    if (prefs.getBool('atlasLinkUseAngleBrackets') != null)
      atlasLinkUseAngleBrackets = prefs.getBool('atlasLinkUseAngleBrackets');
    if (prefs.getBool('atlasLinkAppendTeamNames') != null)
      atlasLinkAppendTeamNames = prefs.getBool('atlasLinkAppendTeamNames');
    if (prefs.getBool('saveReplays') != null)
      saveReplays = prefs.getBool('saveReplays');
  }
}
