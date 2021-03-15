import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:settings_ui/settings_ui.dart';
import 'main.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatelessWidget {
  SettingsWidget();

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          titlePadding: const EdgeInsets.all(8),
          title: 'Connection',
          tiles: [
            SettingsTile(
              title: 'There are no settings yet',
              subtitle: 'no rly',
              leading: Icon(Icons.language),
              onPressed: (BuildContext context) {},
            ),
          ],
        ),
      ],
    );
  }
}
