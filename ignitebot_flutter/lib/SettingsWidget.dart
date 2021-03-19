import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'main.dart';

class SettingsWidget extends StatelessWidget {
  final Settings settings;

  SettingsWidget(this.settings);

  final List<String> linkTypes = <String>['Choose', 'Player', 'Spectator'];

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          titlePadding: const EdgeInsets.all(8),
          title: 'Connection',
          tiles: [
            SettingsTile(
                title: 'Quest IP Address',
                subtitle: settings.echoVRIP,
                leading: Icon(Icons.wifi_rounded),
                onPressed: (BuildContext context) {},
                trailing: Container(
                  width: 125,
                  child: TextField(
                    maxLength: 15,
                    controller:
                        new TextEditingController(text: settings.echoVRIP),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      settings.echoVRIP = value;
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
                    value: linkTypes[settings.atlasLinkStyle],
                    items: linkTypes.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        {settings.atlasLinkStyle = linkTypes.indexOf(value)})),
            SettingsTile.switchTile(
              title: 'Surround with <>',
              subtitle: 'Makes links clickable in Discord',
              switchValue: settings.atlasLinkUseAngleBrackets,
              switchActiveColor: Theme.of(context).primaryColor,
              onToggle: (bool value) {
                log('${settings.atlasLinkUseAngleBrackets}');
                settings.atlasLinkUseAngleBrackets = value;
              },
            ),
            SettingsTile.switchTile(
              title: 'Append team names',
              subtitle: 'Adds auto-detected VRML team names to the end',
              switchValue: settings.atlasLinkAppendTeamNames,
              switchActiveColor: Theme.of(context).primaryColor,
              onToggle: (bool value) {
                settings.atlasLinkAppendTeamNames = value;
              },
            ),
          ],
        ),
      ],
    );
  }
}
