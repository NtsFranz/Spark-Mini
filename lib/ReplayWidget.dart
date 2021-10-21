import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

// import 'package:share/share.dart';
// import 'package:esys_flutter_share/esys_flutter_share.dart';

class ReplayWidget extends StatefulWidget {
  ReplayWidget(this.replayFilesPath);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String restorationId;
  final String replayFilesPath;

  @override
  _ReplayWidget createState() => _ReplayWidget(replayFilesPath);
}

class _ReplayWidget extends State<ReplayWidget> {
  // String directory;
  List filesList = [];
  final String replayFilesPath;
  Future<String> _future;

  // final int atlasLinkStyle;
  // final bool atlasLinkUseAngleBrackets;
  // final bool atlasLinkShowTeamNames;
  // final SharedPreferences prefs;
  // final Settings settings;
  _ReplayWidget(this.replayFilesPath);

  void initState() {
    _future = getFileList();
    super.initState();
    setState(() {});
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      await file.delete();
      _future = getFileList();
      setState(() {});
    } catch (e) {}
  }

  Future<String> getFileList() async {
    final myDir = Directory('$replayFilesPath');
    if (!await myDir.exists()) {
      await myDir.create();
    }
    filesList = await Directory("$replayFilesPath").list().toList();
    return Future.value("Hello World");
  }

  Future<void> _onDeleteButtonPressed(
      String filePath, String fileName, BuildContext context) async {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Delete"),
      onPressed: () {
        deleteFile(filePath);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete Replay File?"),
      content: Text("Are you sure you would like to delete " + fileName + "?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _onShareButtonPressed(String filePath, String fileName) async {
    print("search button clicked");
    final Uint8List bytes = await new File(filePath).readAsBytes();
    if (!Platform.isWindows && !Platform.isLinux) {
      Share.shareFiles(['$filePath'], text: fileName);
    }
    // TODO replace
    //final ByteData bytes = await rootBundle.load('assets/rec_2020-07-31_23-30-41.echoreplay');
    // await Share.file('Share Replay', '$fileName.echoreplay',
    //     bytes, 'application/zip',
    //     text: 'Shared EchoReplay file from Spark Mini.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: const CircularProgressIndicator());

          if (snapshot.hasData) {
            if (filesList != null && filesList.length > 0) {
              return ListView.builder(
                //if file/folder list is grabbed, then show here
                padding: const EdgeInsets.all(8),
                itemCount: filesList.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    title: Text(
                        filesList[index].path.split('/').last.split('\\').last),
                    leading: (() {
                      if (!Platform.isWindows && !Platform.isLinux) {
                        return new IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () async {
                            _onShareButtonPressed(
                                filesList[index].path,
                                filesList[index]
                                    .path
                                    .split('/')
                                    .last
                                    .split('\\')
                                    .last);
                            //Share.text('my text title', 'This is my text to share with other applications.', 'text/plain');
                          },
                          // icon: Icon(Icons.open_in_full),
                          // onPressed: () async {
                          //   OpenFile.open(filesList[index].path);
                          //   //Share.text('my text title', 'This is my text to share with other applications.', 'text/plain');
                          // },
                        );
                      }
                    }()),
                    trailing: new IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        _onDeleteButtonPressed(
                            filesList[index].path,
                            filesList[index]
                                .path
                                .split('/')
                                .last
                                .split('\\')
                                .last,
                            context);
                        //Share.text('my text title', 'This is my text to share with other applications.', 'text/plain');
                      },
                    ),
                  ));
                },
              );
            } else {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "No Replay Files Found.\n\nTo record .echoreplay files, enable replay file saving in the Settings tab, then join a match.",
                    textScaleFactor: 1.3,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          }
          // return Text('${snapshot.data}');
          else
            return const Text('Some error happened');
        },
      ),
      // body:
      // ListView(
      //     padding: const EdgeInsets.all(8),
      //     children: <Widget>[
      // Card(
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: <Widget>[
      //       ListTile(
      //         leading: Icon(Icons.camera),
      //         // tileColor: Colors.grey.withOpacity(.2),
      //         title: Text('Spectators'),
      //         subtitle: Text(() {
      //           if (frame.teams[2].players != null) {
      //             return '${frame.teams[2].players.map((p) => p.name)
      //                 .join('\n')}';
      //           } else {
      //             return '';
      //           }
      //         }()),
      //       ),
      //     ],
      //   ),
      // ),
      // Files
      // Card(child:
      /*ListView.builder( //if file/folder list is grabbed, then show here
          padding: const EdgeInsets.all(8),
                    itemCount: filesList.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                            title: Text(filesList[index].path
                                .split('/')
                                .last),
                            leading: new IconButton(
                              icon: Icon(Icons.share),
                                onPressed: () async {
                                  _onShareButtonPressed(filesList[index].path,filesList[index].path.split('/').last);
                                  //Share.text('my text title', 'This is my text to share with other applications.', 'text/plain');
                                },
                            ),
                            trailing: new IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                _onDeleteButtonPressed(filesList[index].path, filesList[index].path.split('/').last, context);
                                //Share.text('my text title', 'This is my text to share with other applications.', 'text/plain');
                              },
                            ),
                          )
                      );
                    },
                  )*/
      // child: ListView.builder(Icon(Icons.file_present)
      //     itemCount: file.length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return Text(file[index].toString());
      //     }),
      // ),
      // ]),
      // floatingActionButton: Consumer<Settings>(
      //   builder: (context, settings, child) => FloatingActionButton(
      //     onPressed: () {},
      //     child: const Icon(Icons.refresh),
      //     tooltip: "Refresh Data",
      //   ),
      // ),
    );

/*// Make New Function
  void _listofFiles() async {
    // setState(() {
    //   file = Directory("$directory/resume/").listSync();  //use your folder name insted of resume.
    // });
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
  }*/
  }
}
