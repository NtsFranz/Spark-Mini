import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';

class AtlasWidget extends StatelessWidget {
  final APIFrame frame;
  final String orangeTeamName;
  final String blueTeamName;
  AtlasWidget(this.frame, this.orangeTeamName, this.blueTeamName);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Center(child: Text((() {
          if (frame.sessionid != null) {
            return 'Connected: ${frame.sessionid}';
          } else {
            return 'Not Connected';
          }
        })())),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SettingsSection(
                titlePadding: const EdgeInsets.all(8),
                title: 'Connection',
                tiles: [
                  SettingsTile(
                    title: 'There are no settings yet',
                    subtitle: 'no rly',
                    leading: Icon(Icons.wifi_rounded),
                    onPressed: (BuildContext context) {},
                  ),
                ],
              ),
              SettingsSection(
                title: 'Display',
                tiles: [
                  SettingsTile.switchTile(
                    title: 'Surround with <>',
                    subtitle: 'Makes links clickable in Discord',
                    switchValue: false,
                    onToggle: (bool value) {},
                  ),
                  SettingsTile.switchTile(
                    title: 'Append team names',
                    subtitle: 'Adds auto-detected VRML team names to the end',
                    switchValue: false,
                    onToggle: (bool value) {},
                  ),
                ],
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(title: Text('Link'), subtitle: Text('')),
            ],
          ),
        ),
      ],
    );
  }

  Future<String> getFormattedLink(String sessionid) async {
    String link = "";

    // Get settings
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool atlasLinkUseAngleBrackets =
        prefs.getBool('atlasLinkUseAngleBrackets') ?? true;
    int atlasLinkStyle = prefs.getInt('atlasLinkStyle') ?? 0;
    bool atlasLinkAppendTeamNames =
        prefs.getBool('atlasLinkAppendTeamNames') ?? true;

    if (atlasLinkUseAngleBrackets) {
      switch (atlasLinkStyle) {
        case 0:
          link = "<ignitebot://choose/$sessionid>";
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
          link = "ignitebot://choose/$sessionid";
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
      if (orangeTeamName != '' && blueTeamName != '') {
        link = "$link $orangeTeamName vs $blueTeamName";
      }
    }

    return link;
  }
}
