import 'dart:math';

/// <summary>
/// This method is based on the python code that is used in the VRML Discord bot for calculating server score.
/// </summary>
/// <returns>
/// The server score
/// -1: Ping over 150
/// -2: Too few players
/// -3: Too many players
/// -4: Teams have different number of players
/// </returns>
num calculateServerScore(List<int> bluePings, List<int> orangePings) {
  if (bluePings == null || orangePings == null) {
    return -100;
  }

  // configurable parameters for tuning
  int ppt = bluePings.length; // players per team - can be set to 5 for NEPA
  int min_ping = 10; // you don't lose points for being higher than this value
  int max_ping = 150; // won't compute if someone is over this number
  int ping_threshold = 100; // you lose extra points for being higher than this

  // points_distribution dictates how many points come from each area:
  //   0 - difference in sum of pings between teams
  //   1 - within-team variance
  //   2 - overall server variance
  //   3 - overall high/low pings for server
  final points_distribution = [30, 30, 30, 10];

  // sanity check for ping values
  if (bluePings.length < 4) {
    return -2;
  } else if (bluePings.length > 5) {
    return -4;
  }

  if (bluePings.length != orangePings.length) {
    return -4;
  }

  if (bluePings.reduce(max) > max_ping || orangePings.reduce(max) > max_ping) {
    return -1;
  }

  // determine max possible server/team variance and max possible sum diff,
  // given the min/max allowable ping
  num max_server_var = variance(
      new List<int>.generate(ppt * 2, (i) => i % 2 == 0 ? min_ping : max_ping));
  var l1 =
      new List<int>.generate(((ppt as num) / 2.0).floor(), (i) => min_ping);
  l1.addAll(
      new List<int>.generate(((ppt as num) / 2.0).ceil(), (i) => max_ping));
  num max_team_var = variance(l1);
  num max_sum_diff = ((ppt as num) * max_ping) - ((ppt as num) * min_ping);

  // calculate points for sum diff
  num blueSum = bluePings.reduce((a, b) => a + b) as num;
  num orangeSum = orangePings.reduce((a, b) => a + b) as num;
  num sum_diff = (blueSum - orangeSum).abs();
  num sum_points = (1 - (sum_diff / max_sum_diff)) * points_distribution[0];

  // calculate points for team variances
  num blueVariance = variance(bluePings);
  num orangeVariance = variance(orangePings);

  num mean_var = (blueVariance + orangeVariance) / 2.0;
  num team_points = (1 - (mean_var / max_team_var)) * points_distribution[1];

  List<int> bothPings = new List.from(bluePings)..addAll(orangePings);

  // calculate points for server variance
  num server_var = variance(bothPings);
  num server_points =
      (1 - (server_var / max_server_var)) * points_distribution[2];

  // calculate points for high/low ping across server
  num hilo = ((blueSum + orangeSum) - (min_ping * ppt * 2)) /
      ((ping_threshold * ppt * 2) - (min_ping * ppt * 2));
  num hilo_points = (1 - hilo) * points_distribution[3];

  // add up points
  num result = sum_points + team_points + server_points + hilo_points;

  return result;
}

num variance(List<int> values) {
  num avg = values.reduce((a, b) => a + b) / values.length;
  return values.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b);
}
