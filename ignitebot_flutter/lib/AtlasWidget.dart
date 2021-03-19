import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

class AtlasWidget extends StatefulWidget {
  final APIFrame frame;
  final ValueChanged<int> setAtlasLinkStyle;

  const AtlasWidget(
      {Key key, this.frame, this.setAtlasLinkStyle})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AtlasState();
}

class AtlasState extends State<AtlasWidget> {
  // AtlasState(this.frame, this.orangeTeamName, this.blueTeamName, this.echoVRIP);

  final List<String> linkTypes = <String>['Choose', 'Player', 'Spectator'];

  String linkType = 'Choose';
  bool atlasLinkUseAngleBrackets = false;
  bool atlasLinkAppendTeamNames = false;
  String echoVRIP = '127.0.0.1';

  Future<Null> getSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      linkType = linkTypes[prefs.getInt('atlasLinkStyle') ?? 0];
      atlasLinkUseAngleBrackets =
          prefs.getBool('atlasLinkUseAngleBrackets') ?? true;
      atlasLinkAppendTeamNames =
          prefs.getBool('atlasLinkAppendTeamNames') ?? false;
      echoVRIP = prefs.getString('echoVRIP') ?? '127.0.0.1';
    });
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Center(
          child: Container(
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 16),
              ),
              margin: const EdgeInsets.only(top: 20)),
        ),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SettingsSection(
                titlePadding: const EdgeInsets.all(8),
                title: 'Connection',
                tiles: [
                  SettingsTile(
                      title: 'Quest IP Address',
                      subtitle: echoVRIP,
                      leading: Icon(Icons.wifi_rounded),
                      onPressed: (BuildContext context) {},
                      trailing: Container(
                        width: 125,
                        child: TextField(
                          maxLength: 15,
                          controller: new TextEditingController(text: echoVRIP),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
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
                          onSubmitted: (value) async {
                            setState(() {
                              echoVRIP = value;
                            });
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('echoVRIP', value);
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
                      value: linkType,
                      items: linkTypes.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) => widget.setAtlasLinkStyle(linkTypes.indexOf(value))
                    ),
                  ),
                  SettingsTile.switchTile(
                    title: 'Surround with <>',
                    subtitle: 'Makes links clickable in Discord',
                    switchValue: atlasLinkUseAngleBrackets,
                    switchActiveColor: Theme.of(context).primaryColor,
                    onToggle: (bool value) async {
                      setState(() {
                        atlasLinkUseAngleBrackets = value;
                      });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('atlasLinkUseAngleBrackets', value);
                    },
                  ),
                  SettingsTile.switchTile(
                    title: 'Append team names',
                    subtitle: 'Adds auto-detected VRML team names to the end',
                    switchValue: atlasLinkAppendTeamNames,
                    switchActiveColor: Theme.of(context).primaryColor,
                    onToggle: (bool value) async {
                      setState(() {
                        atlasLinkAppendTeamNames = value;
                      });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('atlasLinkAppendTeamNames', value);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
