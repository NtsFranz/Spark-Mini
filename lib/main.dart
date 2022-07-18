import 'dart:developer';
import 'package:archive/archive_io.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:spark_mini/MatchRulesPage.dart';
import 'AtlasWidget.dart';
import 'DashboardWidget.dart';
import 'ReplayWidget.dart';
import 'DebugPage.dart';
import 'SettingsWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:isolate';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setMaxWindowSize();
  }
  runApp(
      ChangeNotifierProvider(create: (context) => Settings(), child: MyApp()));
}

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
        brightness: Brightness.dark,
        primaryColor: Colors.red,
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
  String echoVRPort = '6721';

  // int atlasLinkStyle = 0;
  // bool atlasLinkUseAngleBrackets = false;
  // bool atlasLinkAppendTeamNames = false;
  Timer timer;

  bool inGame = false;
  static APIFrame lastFrame = APIFrame();
  String replayFilename = 'newReplay.echoreplay';
  String replayFilePath = '';
  SendPort logIsolatePort;
  ReceivePort logIsolateReceivePort2 = ReceivePort();
  bool storageAuthorized = false;

  Map<String, dynamic> lastIPLocationResponse = Map<String, dynamic>();
  Map<String, dynamic> orangeVRMLTeamInfo = Map<String, dynamic>();
  Map<String, dynamic> blueVRMLTeamInfo = Map<String, dynamic>();
  List fileList = new List();

  // SharedPreferences prefs;
  // Settings settings = new Settings();

  Future<void> getReplayFilePath() async {
    String folderName = 'replays';
    if (Platform.isAndroid) {
      Directory appDir = await getExternalStorageDirectory();
      replayFilePath = p.join(appDir.path, folderName);
    } else if (Platform.isWindows) {
      Directory appDir = await getApplicationDocumentsDirectory();
      replayFilePath = p.join(appDir.path, 'Spark-Mini', folderName);
    } else {
      Directory appDir = await getApplicationDocumentsDirectory();
      replayFilePath = p.join(appDir.path, folderName);
    }
  }

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
    getFilePermissions();
    Map map = Map();
    map['echoVRIP'] = echoVRIP;
    map['echoVRPort'] = echoVRPort;
    map['replayFilePath'] = replayFilePath;
    map['replayFilename'] = replayFilename;
    map['saveReplays'] = Settings().saveReplays;

    initLogIsolate();

    //compute(computeFunction, map);
    /*var timer = Timer.periodic(Duration(milliseconds: 33), (Timer t) {
      compute(fullLogFetch, map);
    });*/
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      fetchAPI();
      setState(() {});
    });
    getEchoVRIP();
    getEchoVRPort();
  }

  initLogIsolate() async {
    await getFilePermissions();
    var ourFirstReceivePort = new ReceivePort();
    await Isolate.spawn(fullLogFetchIsolate, ourFirstReceivePort.sendPort);
    logIsolatePort = await ourFirstReceivePort.first;
    logIsolatePort.send([
      'message 1',
      logIsolateReceivePort2.sendPort,
      echoVRIP,
      echoVRPort,
      replayFilePath,
      replayFilename,
      Settings().saveReplays
    ]);
    var msg = await logIsolateReceivePort2.first;
    print('main received "$msg"');
    var port3 = ReceivePort();
    logIsolatePort.send(['message 2', port3.sendPort]);
    port3.first.then((msg) {
      print('main received "$msg"');
    });

    // use 'then' one more time
    var port4 = ReceivePort();
    logIsolatePort.send(['port 4', port4.sendPort]);
    port4.first.then((msg) {
      print('main received "$msg"');
    });

    print('end of main');
  }

  static void computeFunction(Map argsMap) async {
    // var timer = Timer.periodic(Duration(milliseconds: 33), (Timer t) {
    while (true) {
      compute(fullLogFetch, argsMap);
      sleep(const Duration(milliseconds: 33));
    }
    // });
  }

  static fullLogFetchIsolate(SendPort sendPort) async {
    // open our receive port. this is like turning on
    // our cellphone.
    var ourReceivePort = ReceivePort();

    // tell whoever created us what port they can reach us on
    // (like giving them our phone number)
    sendPort.send(ourReceivePort.sendPort);

    // while(true) {
    // listen for text messages that are sent to us,
    // and respond to them with this algorithm
    await for (var msg in ourReceivePort) {
      var data = msg[0]; // the 1st element we receive should be their message
      print('echo received "$data"');
      SendPort replyToPort = msg[1]; // the 2nd element should be their port
      String echoVRIP = msg[2];
      String echoVRPort = msg[3];
      String replayFilePath = msg[4];
      String replayFilename = msg[5];
      bool saveReplays = msg[6];
      Map map = Map();
      map['echoVRIP'] = echoVRIP;
      map['echoVRPort'] = echoVRPort;
      map['replayFilePath'] = replayFilePath;
      map['replayFilename'] = replayFilename;
      map['saveReplays'] = saveReplays;
      /*while (true) {
        try {
          await fullLogFetch(map);
        } catch (Exception) {

        }
        sleep(const Duration(milliseconds: 20));
      }*/
      Timer timer = Timer.periodic(Duration(milliseconds: 30), (Timer t) async {
        if (saveReplays) {
          await fullLogFetch(map);
        }
      });
      /*while (true) {
        */ /*try {
          await fullLogFetch(map);
        } catch (Exception) {

        }*/ /*
        sleep(const Duration(seconds: 20));
      }*/
      // }
      // add a little delay to simulate some work being done
      // Future.delayed(const Duration(milliseconds: 100), () {
      //   // send a message back to the caller on their port,
      //   // like calling them back after they left us a message
      //   // (or if you prefer, they sent us a text message, and
      //   // now we’re texting them a reply)
      //   replyToPort.send('echo said: ' + data);
      // });
      //while(ourReceivePort.)
      // you can close the ReceivePort if you want
      //if (data == "bye") ourReceivePort.close();
    }
  }

  static Future<void> fullLogFetch(Map argsMap) async {
    String echoVRIP = argsMap['echoVRIP'];
    String echoVRPort = argsMap['echoVRPort'];
    String replayFilePath = argsMap['replayFilePath'];
    String replayFilename = argsMap['replayFilename'];
    bool saveReplays = argsMap['saveReplays'];
    try {
      //log(echoVRIP);
      final response = await http
          .get(Uri.http('$echoVRIP:$echoVRPort', 'session'))
          .timeout(Duration(seconds: 2));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        // setState(() {
        try {
          String rawJSON = response.body;
          // var newFrame = APIFrame.fromJson(jsonDecode(rawJSON));

          try {
            // switched match
            // if (lastFrame.sessionid == null ||
            //     lastFrame.sessionip != newFrame.sessionip) {}

            // if (lastFrame.game_status == "post_match") {
            //   // newFilename();
            // }
            if (saveReplays) {
              if (!true) {
                //getFilePermissions();
                // code of read or write file in external storage (SD card)
              } else {
                saveReplayFrame(replayFilePath, replayFilename, rawJSON);
              }
            }
            // Do something with the file.
          } catch (e) {
            print('Failed to process API data');
          }
          // lastFrame = newFrame;
        } catch (e) {
          print('Failed to parse API response');
        }
        // });
      } else {
        if (saveReplays) {
          if (!true) {
            //getFilePermissions();
            // code of read or write file in external storage (SD card)
          } else {
            await saveReplayFrame(
                replayFilePath, replayFilename, 'NOT IN GAME');
          }
        }
        // If the server did not return a 200 OK response,
        // then throw an exception.
        // throw Exception('Failed to get game data');
      }
    } catch (SocketException) {
      if (saveReplays) {
        if (!true) {
          //getFilePermissions();
          // code of read or write file in external storage (SD card)
        } else {
          //newFilename();
          saveReplayFrame(replayFilePath, replayFilename, 'NOT IN MATCH');
        }
      }
      //print('Not in game');
    }
  }

  static Future<void> saveReplayFrame(
      String replayFilePath, String replayFilename, String data) async {
    // generate the timestamp string
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm:ss.mmm');
    final String formattedNow = formatter.format(now);

    // the file we are saving to
    File file = File(p.join(replayFilePath, replayFilename));

    // create file if it doesn't exist
    if (!(await file.exists())) {
      file.create(recursive: true);
    }

    // write the data
    file.writeAsString('$formattedNow\t$data\n', mode: FileMode.append);
  }

  Future<void> getFilePermissions() async {
    storageAuthorized = false;
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      storageAuthorized = true;
    } else {
      PermissionStatus permissionResult = await Permission.storage.status;
      storageAuthorized = permissionResult.isGranted;
    }
    if (!storageAuthorized) {
      // Either the permission was already granted before or the user just granted it.
      if (await Permission.storage.request().isGranted) {
        storageAuthorized = true;
      }
    }
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    if (storageAuthorized) {
      await getReplayFilePath();
      if (Settings().saveReplays) {
        await newFilename();
      }
      try {
        final myDir = Directory('$replayFilePath');
        if (!await myDir.exists()) {
          await myDir.create();
        }
        fileList = Directory("$replayFilePath").listSync();
      } catch (Exception) {
        fileList = new List();
      }
      // code of read or write file in external storage (SD card)
    }
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

  Future<void> getEchoVRPort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String newEchoVRPort = prefs.getString('echoVRPort') ?? '6721';
      setState(() {
        echoVRPort = newEchoVRPort;
      });
    } catch (Exception) {
      setState(() {
        echoVRPort = '6721';
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

  Future<void> setEchoVRPort(String value) async {
    setState(() {
      echoVRPort = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('echoVRPort', value);
  }

  @override
  void dispose() {
    _currentPage.dispose();
    // _echoVRIP.dispose();
    timer.cancel();
    super.dispose();
  }

  Future<void> newFilename() async {
    // lock(fileWritingLock) {
    String lastFilename = replayFilename;
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat("yyyy-MM-dd_HH-mm-ss");
    replayFilename = 'rec_${formatter.format(now)}.echoreplay';
    print(replayFilename);
    if (true) //(Settings.Default.useCompression)
    {
      if ((File(p.join(replayFilePath, lastFilename)).existsSync())) {
        final file = File(p.join(replayFilePath, lastFilename));
        var encoder = ZipFileEncoder();
        encoder.create(
            '${p.join(replayFilePath, lastFilename)}_ZIPPED.echoreplay');
        encoder.addFile(file);
        encoder.close();
        try {
          await file.delete();
        } catch (e) {}
      }
    }
    // if(!(File('$replayFilePath$replayFilename').existsSync())){
    //     new File('$replayFilePath$replayFilename').createSync(recursive: true);
    //     }
    // if(File(replayFilename).exists() )
    // }
    final myDir = Directory('$replayFilePath');
    if (!await myDir.exists()) {
      await myDir.create(recursive: true);
    }
    fileList = Directory("$replayFilePath").listSync();
  }

  void fetchAPI() async {
    try {
      final response = await http
          .get(Uri.http('$echoVRIP:$echoVRPort', 'session'))
          .timeout(Duration(seconds: 2));
      if (response.statusCode == 200 || response.statusCode == 500) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        // setState(() {
        try {
          var newFrame = APIFrame.fromJson(jsonDecode(response.body));

          try {
            if (newFrame.sessionid != null) {
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
                  getTeamNameFromPlayerList(
                      newFrame.teams[i].players
                          .map<String>((p) => p.name)
                          .toList(),
                      i);
                }
              }
              if (lastFrame.game_status == "post_match") {
                // newFilename();
              }
              /*final DateTime now = DateTime.now();
          final DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm:ss.mmm');
          final String formattedNow = formatter.format(now);
          print(formattedNow);
          if (Settings().saveReplays) {
            if (!permissionResult.isGranted) {
              getFilePermissions();
              // code of read or write file in external storage (SD card)
            } else {
              if (!(await File('$replayFilePath$replayFilename').exists())) {
                new File('$replayFilePath$replayFilename').create(
                    recursive: true);
              }
              var file = await File('$replayFilePath$replayFilename')
                  .writeAsString('$formattedNow \t ${newFrame.toString()}\n', mode: FileMode.append);
            }
          }*/
            }
            // Do something with the file.
          } catch (e) {
            print('Failed to process API data');
            inGame = false;
          }
          lastFrame = newFrame;
          inGame = true;
        } catch (e) {
          print('Failed to parse API response');
          inGame = false;
        }
        // });
      }
      // else if (response.statusCode == 500) {
      //   if (response.body.startsWith(
      //       '{"err_description":"Endpoint is restricted in this match type","err_code":-6}')) {
      //     // IN LOBBY
      //     inGame = true;
      //   }
      // }
      else {
        inGame = false;
        /*if (Settings().saveReplays) {
        if (!permissionResult.isGranted) {
          getFilePermissions();
          // code of read or write file in external storage (SD card)
        } else {
          newFilename();
        }*/
      }
      // If the server did not return a 200 OK response,
      // then throw an exception.
      // throw Exception('Failed to get game data');

    } catch (SocketException) {
      if (Settings().saveReplays) {
        if (!storageAuthorized) {
          getFilePermissions();
          // code of read or write file in external storage (SD card)
        } else {
          //newFilename();
        }
      }
      print('Not in game: $echoVRIP');
      inGame = false;
    }
  }

  void getIPAPI(String ip) async {
    print('Fetching from Ignite ip-api');
    if (ip == null || ip == "") {
      return;
    }
    final response =
        await http.get(Uri.http('api.ignitevr.gg', 'ip_geolocation/$ip'));

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

  void getTeamNameFromPlayerList(List<String> players, int teamIndex) async {
    String playersList = jsonEncode(players);
    var uri = Uri.https('api.ignitevr.gg', 'vrml/get_team_name_from_list',
        {'player_list': '$playersList'});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        if (teamIndex == 0) {
          blueVRMLTeamInfo = jsonDecode(response.body);
        } else if (teamIndex == 1) {
          orangeVRMLTeamInfo = jsonDecode(response.body);
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

    // getSharedPrefs();

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
      DashboardWidget(inGame, lastFrame, lastIPLocationResponse,
          orangeVRMLTeamInfo, blueVRMLTeamInfo, setEchoVRIP, setEchoVRPort),
      AtlasWidget(
        inGame: inGame,
        frame: lastFrame,
        ipLocation: lastIPLocationResponse,
        echoVRIP: echoVRIP,
        echoVRPort: echoVRPort,
      ),
      MatchRulesPage(
        inGame: inGame,
        frame: lastFrame,
        echoVRIP: echoVRIP,
        echoVRPort: echoVRPort,
      ),
      DebugPage(),
      // ReplayWidget(replayFilePath),
      // IgniteStatsWidget(),
      // ColorPage(Colors.yellow),
      SettingsWidget(
          echoVRIP: echoVRIP,
          setEchoVRIP: setEchoVRIP,
          echoVRPort: echoVRPort,
          setEchoVRPort: setEchoVRPort),
    ];

    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          backgroundColor: Colors.red),
      body: _tabViews[_currentPage.value],
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: bottomNavigationItems,
        currentIndex: _currentPage.value,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        // unselectedItemColor: Colors.white.withOpacity(.5),
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

      // if at least one team name exists
      if (orangeName != '?' || blueName != '?') {
        link = "$link $orangeName vs $blueName";
      }
    }

    return link;
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

class APIFrame {
  final int err_code;
  final String err_description;
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
  final String rules_changed_by;
  final int rules_changed_at;
  final Map<String, dynamic> raw;

  APIFrame({
    this.err_code,
    this.err_description,
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
    this.teams,
    this.last_throw,
    this.rules_changed_by,
    this.rules_changed_at,
    this.raw,
  });

  factory APIFrame.fromJson(Map<String, dynamic> json) {
    var teamsMap = <APITeam>[
      APITeam(team: "", players: <APIPlayer>[]),
      APITeam(team: "", players: <APIPlayer>[]),
      APITeam(team: "", players: <APIPlayer>[]),
    ];
    if (json['teams'] != null) {
      teamsMap = json['teams']
          .map<APITeam>((teamJSON) => APITeam.fromJson(teamJSON))
          .toList();
    }
    var lastThrowMap = APILastThrow(
      arm_speed: 0,
      total_speed: 0,
      off_axis_spin_deg: 0,
      wrist_throw_penalty: 0,
      rot_per_sec: 0,
      pot_speed_from_rot: 0,
      speed_from_arm: 0,
      speed_from_movement: 0,
      speed_from_wrist: 0,
      wrist_align_to_throw_deg: 0,
      throw_align_to_movement_deg: 0,
      off_axis_penalty: 0,
      throw_move_penalty: 0,
    );
    if (json['last_throw'] != null) {
      lastThrowMap = APILastThrow.fromJson(json['last_throw']);
    }
    return APIFrame(
      err_code: json['err_code'],
      err_description: json['err_description'],
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
      teams: teamsMap,
      last_throw: lastThrowMap,
      rules_changed_by: json['rules_changed_by'],
      rules_changed_at: json['rules_changed_at'],
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
