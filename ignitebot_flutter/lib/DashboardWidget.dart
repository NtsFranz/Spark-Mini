import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart';

class DashboardWidget extends StatelessWidget {
  final APIFrame frame;
  final Map<String, dynamic> ipLocation;
  DashboardWidget(this.frame, this.ipLocation);

  @override
  Widget build(BuildContext context) {
    if (frame != null && frame.sessionid != null) {
      return ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          Text((() {
            if (frame != null) {
              return 'Connected: ${frame.sessionid}';
            } else {
              return 'Not Connected';
            }
          })()),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    title: Text('Server Location'),
                    subtitle: Text((() {
                      if (frame != null) {
                        if (ipLocation != null && ipLocation['success']) {
                          return '${ipLocation['city']}, ${ipLocation['region']}';
                        } else {
                          return 'IP: ${frame.sessionip}';
                        }
                      } else {
                        return '---';
                      }
                    })())),
              ],
            ),
          ),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const ListTile(
                  title: Text('Server Score'),
                  subtitle: Text("0"),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(frame.game_clock_display),
                  subtitle:
                      Text("${frame.orange_points} - ${frame.blue_points}"),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.person),
                  tileColor: Colors.orange,
                  title: Text('Orange Team'),
                  subtitle: Text(
                      '${frame.raw['teams'][0]['players'].map((p) => p['name']).join('\n')}'),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.person),
                  tileColor: Colors.blue,
                  title: Text('Blue Team'),
                  subtitle: Text(
                      '${frame.raw['teams'][1]['players'].map((p) => p['name']).join('\n')}'),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera),
                  tileColor: Colors.grey,
                  title: Text('Spectators'),
                  subtitle: Text(
                      '${frame.raw['teams'][2]['players'].map((p) => p['name']).join('\n')}'),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Text("Not Connected."),
      );
    }
  }
}
