import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'main.dart';
// import 'package:esys_flutter_share/esys_flutter_share.dart';

class SettingsWidget extends StatefulWidget {
  final setEchoVRIP;
  final String echoVRIP;
  SettingsWidget({Key key, this.echoVRIP, this.setEchoVRIP}) : super(key: key);

  final List<String> linkTypes = <String>['Choose', 'Player', 'Spectator'];

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(12), children: <Widget>[
      Container(child: Consumer<Settings>(builder: (context, settings, child) {
        var inputDecoration = InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        );
        return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
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
                        subtitle: Text(widget.echoVRIP),
                      ),
                    ),
                    Container(
                      width: 125,
                      child: TextField(
                        maxLength: 15,
                        // controller:
                        //     new TextEditingController(text: echoVRIP),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: inputDecoration,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          widget.setEchoVRIP(value);
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
                    "Display",
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
                        value: widget.linkTypes[settings.atlasLinkStyle],
                        items: widget.linkTypes.map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) => {
                              settings.setAtlasLinkStyle(
                                  widget.linkTypes.indexOf(value))
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
                        value: settings.atlasLinkUseAngleBrackets,
                        onChanged: (bool value) {
                          settings.setAtlasLinkUseAngleBrackets(value);
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
                        value: settings.atlasLinkAppendTeamNames,
                        onChanged: (bool value) {
                          settings.setAtlasLinkAppendTeamNames(value);
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
          Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Replays",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Row(children: [
                Expanded(
                  child: ListTile(
                    title: Text("Save Replays"),
                    subtitle: Text(
                        "Replays are recorded in the .echoreplay file format, which contains all API data from the game. Echoreplay files to not contain any video or audio data. The most common use of .echoreplay files is in the Echo Replay Viewer"),
                  ),
                ),
                Switch(
                  value: settings.saveReplays,
                  onChanged: (bool value) {
                    settings.setSaveReplays(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                SizedBox(
                  width: 20,
                ),
              ]),
              SizedBox(
                height: 10,
              ),
            ]),
          ]))
        ]);
      }))
    ]);
  }
}
