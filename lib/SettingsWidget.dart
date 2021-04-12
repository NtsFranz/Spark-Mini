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
      Card(
          child: Consumer<Settings>(
              builder: (context, settings, child) =>
                  Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    SettingsSection(
                      titlePadding: const EdgeInsets.all(8),
                      title: 'Connection',
                      tiles: [
                        SettingsTile(
                            title: 'Quest IP Address',
                            subtitle: widget.echoVRIP,
                            leading: Icon(Icons.wifi_rounded),
                            onPressed: (BuildContext context) {},
                            trailing: Container(
                              width: 125,
                              child: TextField(
                                maxLength: 15,
                                // controller:
                                //     new TextEditingController(text: echoVRIP),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (value) {
                                  widget.setEchoVRIP(value);
                                },
                              ),
                            )),
                      ],
                    ),
                    SettingsSection(
                      title: 'Display',
                      tiles: [
                        SettingsTile(
                            title: 'Link Type',
                            subtitle: 'Join as spectator or player',
                            trailing: DropdownButton<String>(
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
                                    })),
                        SettingsTile.switchTile(
                          title: 'Surround with <>',
                          subtitle: 'Makes links clickable in Discord',
                          switchValue: settings.atlasLinkUseAngleBrackets,
                          switchActiveColor: Theme.of(context).primaryColor,
                          onToggle: (bool value) {
                            settings.setAtlasLinkUseAngleBrackets(value);
                          },
                        ),
                        SettingsTile.switchTile(
                          title: 'Append team names',
                          subtitle:
                              'Adds auto-detected VRML team names to the end',
                          switchValue: settings.atlasLinkAppendTeamNames,
                          switchActiveColor: Theme.of(context).primaryColor,
                          onToggle: (bool value) {
                            settings.setAtlasLinkAppendTeamNames(value);
                          },
                        ),
                      ],
                    ),
                  ])))
    ]);
  }
}
