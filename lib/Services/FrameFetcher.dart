import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../Model/APIFrame.dart';

class FrameFetcher extends StateNotifier<APIFrame> {
  // 1. initialize with current time
  FrameFetcher() : super(APIFrame()) {
    // 2. create a timer that fires every second
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      // 3. update the state with the current time
      state = await fetchAPI();
    });
  }

  var Timer _timer;

  // 4. cancel the timer when finished
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<APIFrame> fetchAPI() async {
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
}
