import 'dart:convert';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getIPAPI(String ip) async {
  print('Fetching from Ignite ip-api');
  if (ip == null || ip == "") {
    return null;
  }
  final response =
      await http.get(Uri.http('api.ignitevr.gg', 'ip_geolocation/$ip'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return jsonDecode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to get game data');
  }
}

Future<Map<String, dynamic>> getTeamNameFromPlayerList(
    List<String> players) async {
  return getTeamNameFromPlayersJson(jsonEncode(players));
}

Future<Map<String, dynamic>> getTeamNameFromPlayersJson(
    String playersJson) async {
  var uri = Uri.https('api.ignitevr.gg', 'vrml/get_team_name_from_list',
      {'player_list': '$playersJson'});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return jsonDecode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to get player team info');
  }
}
