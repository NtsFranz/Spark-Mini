import 'dart:convert';
import 'dart:developer';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'Pages/MatchRulesPage.dart';
import 'Pages/OpenSparkLinkScreen.dart';
import 'Model/APIFrame.dart';
import 'Model/ColorSchemes.dart';
import 'Pages/ShareWidget.dart';
import 'Pages/DashboardWidget.dart';
import 'Pages/DebugPage.dart';
import 'Pages/SettingsWidget.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'Services/frame_fetcher.dart';
import 'Services/other_api_fetchers.dart';
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

final ipLocationFutureProvider = FutureProvider((ref) async {
  final ip = ref.watch(frameProvider.select((value) => value.sessionip));
  if (ip != '') {
    return await getIPAPI(ip);
  } else {
    return Map<String, dynamic>();
  }
});

final ipLocationResponseProvider = StateProvider<Map<String, dynamic>>((ref) {
  AsyncValue<Map<String, dynamic>> resp = ref.watch(ipLocationFutureProvider);

  return resp.when(
    loading: () => Map<String, dynamic>(),
    error: (err, stack) => Map<String, dynamic>(),
    data: (value) {
      return value;
    },
  );
});

final versionNumberFutureProvider = FutureProvider((ref) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String packageName = packageInfo.packageName;
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  return version + "+" + buildNumber;
});

final versionNumberProvider = StateProvider((ref) {
  final f = ref.watch(versionNumberFutureProvider);

  return f.when(data: (data) => data, error: (e1, e2) => "", loading: () => "");
});

final orangeTeamVRMLInfoProvider = StateProvider((ref) {
  final f = ref.watch(orangeTeamVRMLInfoFutureProvider);

  return f.when(
      data: (data) => data,
      error: (e1, e2) => Map<String, dynamic>(),
      loading: () => Map<String, dynamic>());
});

final orangeTeamVRMLInfoFutureProvider = FutureProvider((ref) async {
  final players = ref.watch(frameProvider.select((value) =>
      jsonEncode(value?.teams[1].players.map((e) => e.name).toList())));
  if (players != null) {
    return await getTeamNameFromPlayersJson(players);
  } else {
    return Map<String, dynamic>();
  }
});

final blueTeamVRMLInfoProvider = StateProvider((ref) {
  final f = ref.watch(blueTeamVRMLInfoFutureProvider);

  return f.when(
      data: (data) => data,
      error: (e1, e2) => Map<String, dynamic>(),
      loading: () => Map<String, dynamic>());
});

final blueTeamVRMLInfoFutureProvider = FutureProvider((ref) async {
  final players = ref.watch(frameProvider.select((value) =>
      jsonEncode(value?.teams[0].players.map((e) => e.name).toList())));
  if (players != null) {
    return await getTeamNameFromPlayersJson(players);
  } else {
    return Map<String, dynamic>();
  }
});

// TODO this refreshes every frame
final inGameProvider = StateProvider((ref) {
  final APIFrame frame = ref.watch(frameProvider);
  return frame != null;
});
final sessionIPProvider = StateProvider<String>((ref) {
  return ref.watch(frameProvider)?.sessionip ?? "";
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
      blue,
    );
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
  return FrameFetcher(ref);
});

Future setMaxWindowSize() async {
  await DesktopWindow.setWindowSize(Size(560, 870));

  await DesktopWindow.setMinWindowSize(Size(350, 570));
  await DesktopWindow.setMaxWindowSize(Size(800, 1000));
}

class MyApp extends ConsumerWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(sharedPreferencesProvider);

    return MaterialApp(
      title: 'Spark Mini',
      // theme: IgniteTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: settings.getBool('darkMode') ?? true
            ? Brightness.dark
            : Brightness.light,
        colorSchemeSeed: colorSchemes[settings.getInt('colorScheme') ?? 2]
            ['color'],
      ),
      home: MyHomePage(
        title: 'Spark Mini',
        restorationId: 'root',
      ),

      // Provide a function to handle named routes.
      // Use this function to identify the named
      // route being pushed, and create the correct
      // Screen.
      onGenerateRoute: (settings) {
        print(settings.name);

        return MaterialPageRoute(
          builder: (context) {
            return OpenSparkLinkScreen(link: settings.name);
          },
        );
      },
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
    var bottomNavigationItems = <Widget>[
      NavigationDestination(
          icon: const Icon(Icons.dashboard), label: "Dashboard"),
      NavigationDestination(
          icon: const Icon(Icons.share), label: "Share Match"),
      NavigationDestination(icon: const Icon(Icons.rule), label: "Match Rules"),
      // NavigationDestination(icon: const Icon(Icons.bug_report), label: "Debug"),
      // BottomNavigationBarItem(icon: const Icon(Icons.replay), label: "Replays"),
      // BottomNavigationBarItem(icon: const Icon(Icons.web), label: "Ignite Stats"),
      NavigationDestination(
          icon: const Icon(Icons.settings), label: "Settings"),
    ];

    List<Widget> _tabViews = [
      DashboardWidget(),
      ShareWidget(),
      MatchRulesPage(),
      // DebugPage(),
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
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: _tabViews[_currentPage.value],
      bottomNavigationBar: NavigationBar(
        destinations: bottomNavigationItems,
        selectedIndex: _currentPage.value,
        onDestinationSelected: (index) {
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
