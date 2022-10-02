import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/LinkTypes.dart';
import '../main.dart';

class SettingsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(sharedPreferencesProvider);
    final echoVRIP = ref.watch(echoVRIPProvider);
    final echoVRPort = ref.watch(echoVRPortProvider);
    return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
      Container(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Connection",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.wifi_rounded),
                      title: Text("Quest IP Address"),
                      subtitle: Text(echoVRIP),
                    ),
                  ),
                  Container(
                    width: 125,
                    child: TextField(
                      maxLength: 15,
                      // controller:
                      //     new TextEditingController(text: echoVRIP),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      cursorColor: Theme.of(context).primaryColor,
                      // decoration: inputDecoration,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        settings.setString('echoVRIP', value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ]),
                SizedBox(
                  height: 10,
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: ListTile(
                      leading: Icon(Icons.wifi_rounded),
                      title: Text("Port (for PCVR)"),
                      subtitle: Text(echoVRPort),
                    ),
                  ),
                  Container(
                    width: 125,
                    child: TextField(
                      maxLength: 15,
                      // controller:
                      //     new TextEditingController(text: echoVRIP),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      cursorColor: Theme.of(context).primaryColor,
                      // decoration: inputDecoration,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        settings.setString('echoVRPort', value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ]),
                SizedBox(
                  height: 10,
                ),
              ],
            )
          ]),
        ),
        Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Links",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: ListTile(
                      title: Text("Link Type"),
                      subtitle: Text("Join as spectator or player"),
                    ),
                  ),
                  DropdownButton<String>(
                      value: linkTypes[settings.getInt('linkType') ?? 0],
                      items: linkTypes.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) => {
                            settings.setInt(
                                'linkType', linkTypes.indexOf(value))
                          }),
                  SizedBox(
                    width: 20,
                  ),
                ]),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text("Surround with <>"),
                        subtitle: Text("Makes links clickable in Discord"),
                      ),
                    ),
                    Switch(
                      value: settings.getBool('linkAngleBrackets'),
                      onChanged: (bool value) {
                        settings.setBool('linkAngleBrackets', value);
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text("Append team names"),
                        subtitle: Text(
                            "Adds auto-detected VRML team names to the end"),
                      ),
                    ),
                    Switch(
                      value: settings.getBool('linkAppendTeamNames'),
                      onChanged: (bool value) {
                        settings.setBool('linkAppendTeamNames', value);
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            )
          ]),
        ),
        // Card(
        //     child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        //   Column(mainAxisSize: MainAxisSize.min, children: [
        //     SizedBox(
        //       height: 10,
        //     ),
        //     Text(
        //       "Replays",
        //       style: TextStyle(
        //         color: Theme.of(context).primaryColor,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //     SizedBox(
        //       width: 20,
        //     ),
        //     Row(children: [
        //       Expanded(
        //         child: ListTile(
        //           title: Text("Save Replays"),
        //           subtitle: Text(
        //               "Replays are recorded in the .echoreplay file format, which contains all API data from the game. Echoreplay files to not contain any video or audio data. The most common use of .echoreplay files is in the Echo VR Replay Viewer"),
        //         ),
        //       ),
        //       Switch(
        //         value: settings.saveReplays,
        //         onChanged: (bool value) {
        //           settings.setSaveReplays(value);
        //         },
        //         activeColor: Theme.of(context).primaryColor,
        //       ),
        //       SizedBox(
        //         width: 20,
        //       ),
        //     ]),
        //     SizedBox(
        //       height: 10,
        //     ),
        //   ]),
        // ]))
      ]))
    ]);
  }
}
