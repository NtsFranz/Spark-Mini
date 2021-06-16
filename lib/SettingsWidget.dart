import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'main.dart';

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
      Card(child: Consumer<Settings>(builder: (context, settings, child) {
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
                ],
              )
            ]),
          ),
        ]);
      }))
    ]);
  }
}
