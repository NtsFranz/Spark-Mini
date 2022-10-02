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
    final APIFrame frame = ref.watch(frameProvider);
    final bool inGame = ref.watch(inGameProvider);
    final echoVRIP = ref.watch(echoVRIPProvider);
    final echoVRPort = ref.watch(echoVRPortProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Container(
            child: Center(
                child: Text(
              (() {
                if (inGame &&
                    frame.private_match != null &&
                    frame.private_match) {
                  return "Rules last changed by: ${frame.rules_changed_by}";
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
                              primary: Colors.red,
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
        backgroundColor: Colors.red,
      ),
    );
  }

  void fetchMatchRulesPresets() async {
    setState(() {
      fetchingPresets = true;
    });
    final response =
        await http.get(Uri.https('api.ignitevr.gg', 'private_match_rules'));

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