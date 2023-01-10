import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark_mini/Model/ColorSchemes.dart';
import '../Model/LinkTypes.dart';
import '../main.dart';

class SettingsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(sharedPreferencesProvider);
    final echoVRIP = ref.watch(echoVRIPProvider);
    final echoVRPort = ref.watch(echoVRPortProvider);
    final versionNumber = ref.watch(versionNumberProvider);

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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                      // decoration: inputDecoration,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        settings.setString('echoVRIP', value);
                        ref.refresh(sharedPreferencesProvider);
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
                      // decoration: inputDecoration,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        settings.setString('echoVRPort', value);
                        ref.refresh(sharedPreferencesProvider);
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: ListTile(
                      title: Text("Link Type"),
                      subtitle: Text(
                          "Join as spectator or player. It is always recommended to use Choose links."),
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
                      onChanged: (value) {
                        settings.setInt('linkType', linkTypes.indexOf(value));
                        ref.refresh(sharedPreferencesProvider);
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
                        ref.refresh(sharedPreferencesProvider);
                      },
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
                        ref.refresh(sharedPreferencesProvider);
                      },
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
        Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Spark Mini Settings",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(children: <Widget>[
                  Expanded(
                    child: ListTile(
                      title: Text("Accent Color"),
                    ),
                  ),
                  DropdownButton<String>(
                      value: colorSchemes[settings.getInt('colorScheme') ?? 2]
                          ['name'],
                      items: colorSchemes.map((value) {
                        return DropdownMenuItem<String>(
                          value: value['name'],
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.color_lens,
                                  color: colorSchemes.singleWhere(
                                      (element) => element == value)['color'],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(colorSchemes.singleWhere(
                                    (element) => element == value)['name']),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        settings.setInt(
                            'colorScheme',
                            colorSchemes.indexWhere(
                                (element) => element['name'] == value));
                        ref.refresh(sharedPreferencesProvider);
                      }),
                  SizedBox(
                    width: 20,
                  ),
                ]),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text("Dark Mode"),
                      ),
                    ),
                    Switch(
                      value: settings.getBool('darkMode') ?? true,
                      onChanged: (bool value) {
                        settings.setBool('darkMode', value);
                        ref.refresh(sharedPreferencesProvider);
                      },
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
        //           ref.refresh(sharedPreferencesProvider);
        //         },
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

        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text("v$versionNumber"),
            SizedBox(width: 10),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ]))
    ]);
  }
}
