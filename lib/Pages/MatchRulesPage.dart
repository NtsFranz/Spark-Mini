import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/APIFrame.dart';
import '../main.dart';

class MatchRulesPage extends ConsumerStatefulWidget {
  const MatchRulesPage({Key key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MatchRulesPageState();
}

class MatchRulesPageState extends ConsumerState<MatchRulesPage> {
  Map<String, dynamic> matchRulesPresets;
  bool fetchingPresets = false;

  @override
  void initState() {
    super.initState();
    fetchMatchRulesPresets();
  }

  @override
  Widget build(BuildContext context) {
    final bool private_match = ref
        .watch(frameProvider.select((value) => value?.private_match ?? false));
    final String rules_changed_by = ref
        .watch(frameProvider.select((value) => value?.rules_changed_by ?? ""));
    final int client_team = ref.watch(frameProvider.select((frame) {
      if (frame == null) return -1;
      final client_name = frame.client_name;
      for (int t = 0; t < 3; t++) {
        for (int p = 0; p < frame.teams[t].players.length; p++) {
          if (frame.teams[t].players[p].name == client_name) {
            return t;
          }
        }
      }
      return -1;
    }));
    final bool inGame = ref.watch(inGameProvider.select((value) => value));
    final echoVRIP = ref.watch(echoVRIPProvider);
    final echoVRPort = ref.watch(echoVRPortProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          SizedBox(height: 10),
          (() {
            if (private_match && client_team >= 0 && client_team < 2) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await http.post(
                          Uri.http('$echoVRIP:$echoVRPort', 'set_ready'),
                          body: json.encode({'team_idx': client_team}));
                    },
                    child: Row(children: [
                      Text('Ready Up'),
                      Icon(Icons.arrow_upward),
                    ]),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.primaryContainer,
                      onPrimary:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      padding: EdgeInsets.all(14),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await http.post(
                          Uri.http('$echoVRIP:$echoVRPort', 'set_pause'),
                          body: json.encode({'team_idx': client_team}));
                    },
                    child: Row(children: [
                      Text('Pause'),
                      Icon(Icons.pause),
                    ]),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.primaryContainer,
                      onPrimary:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      padding: EdgeInsets.all(14),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await http.post(
                          Uri.http('$echoVRIP:$echoVRPort', 'restart_request'),
                          body: json.encode({'team_idx': client_team}));
                    },
                    child: Row(children: [
                      Text('Reset'),
                      Icon(Icons.restart_alt),
                    ]),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.primaryContainer,
                      onPrimary:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      padding: EdgeInsets.all(14),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          }()),
          Container(
            child: Center(
                child: Text(
              (() {
                if (inGame && private_match != null && private_match) {
                  return "Rules last changed by: ${rules_changed_by}";
                } else {
                  return "Not in private match.";
                }
              }()),
              textScaleFactor: 1.3,
              textAlign: TextAlign.center,
            )),
            margin: EdgeInsets.all(20),
          ),
          (() {
            if (matchRulesPresets != null) {
              var presets = <MapEntry<String, Map<String, dynamic>>>[];
              for (var i = 0; i < matchRulesPresets.values.length; i++) {
                var map = new MapEntry<String, Map<String, dynamic>>(
                    matchRulesPresets.keys.toList()[i],
                    matchRulesPresets.values.toList()[i]);
                presets.add(map);
                print(matchRulesPresets.keys.toList()[i]);
              }
              return Column(
                children: presets
                    .map<Container>((p) => Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              onPrimary: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              // primary: Colors.red,
                              padding: EdgeInsets.all(26),
                              minimumSize: Size.fromHeight(40),
                            ),
                            onPressed: () => {
                                  setRules(
                                      p.value["rules"], echoVRIP, echoVRPort)
                                },
                            child:
                                Text(p.key, style: TextStyle(fontSize: 20)))))
                    .toList(),
              );
            } else {
              return Container(
                child: Center(
                    child: Text(
                  "Can't get match presets from Ignite server.\nCheck your internet connection or notify NtsFranz.",
                  textScaleFactor: 1.3,
                  textAlign: TextAlign.center,
                )),
                margin: EdgeInsets.all(20),
              );
            }
          }()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchMatchRulesPresets();
        },
        child: const Icon(Icons.refresh),
        tooltip: "Fetch Presets",
      ),
    );
  }

  void fetchMatchRulesPresets() async {
    setState(() {
      fetchingPresets = true;
    });
    final response =
        await http.get(Uri.https('api.ignitevr.gg', 'v2/private_match_rules'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      if (!mounted) return;
      setState(() {
        matchRulesPresets = jsonDecode(response.body);
        fetchingPresets = false;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to get private matche presets');
    }
  }

  void setRules(
      Map<String, dynamic> rules, String echoVRIP, String echoVRPort) async {
    print(json.encode(rules));

    // set all rules
    // final response = await http.post(
    //     Uri.http('$echoVRIP:$echoVRPort', 'set_rules'),
    //     headers: headers,
    //     body: json.encode(rules));

    final response =
        await http.get(Uri.http('$echoVRIP:$echoVRPort', 'get_rules'));

    print(response.body);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      for (var entry in rules.entries) {
        final val = new Map();
        val[entry.key] = entry.value;
        print(json.encode(val));
        await http.post(Uri.http('$echoVRIP:$echoVRPort', 'set_rules'),
            // body: '"${entry.key}":"${entry.value}"'
            body: json.encode(val));
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to set match rules');
    }
  }
}
