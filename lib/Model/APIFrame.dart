class APIFrame {
  final int err_code;
  final String err_description;
  final String sessionid;
  final String sessionip;
  final String game_status;
  final double game_clock;
  final String match_type;
  final bool private_match;
  final String client_name;
  final String game_clock_display;
  final int blue_points;
  final int orange_points;
  final List<APITeam> teams;
  final APILastThrow last_throw;
  final String rules_changed_by;
  final int rules_changed_at;
  final Map<String, dynamic> raw;

  APIFrame({
    this.err_code,
    this.err_description,
    this.sessionid,
    this.sessionip,
    this.game_status,
    this.game_clock,
    this.match_type,
    this.private_match,
    this.client_name,
    this.game_clock_display,
    this.blue_points,
    this.orange_points,
    this.teams,
    this.last_throw,
    this.rules_changed_by,
    this.rules_changed_at,
    this.raw,
  });

  factory APIFrame.fromJson(Map<String, dynamic> json) {
    var teamsMap = <APITeam>[
      APITeam(team: "", players: <APIPlayer>[]),
      APITeam(team: "", players: <APIPlayer>[]),
      APITeam(team: "", players: <APIPlayer>[]),
    ];
    if (json['teams'] != null) {
      teamsMap = json['teams']
          .map<APITeam>((teamJSON) => APITeam.fromJson(teamJSON))
          .toList();
    }
    var lastThrowMap = APILastThrow(
      arm_speed: 0,
      total_speed: 0,
      off_axis_spin_deg: 0,
      wrist_throw_penalty: 0,
      rot_per_sec: 0,
      pot_speed_from_rot: 0,
      speed_from_arm: 0,
      speed_from_movement: 0,
      speed_from_wrist: 0,
      wrist_align_to_throw_deg: 0,
      throw_align_to_movement_deg: 0,
      off_axis_penalty: 0,
      throw_move_penalty: 0,
    );
    if (json['last_throw'] != null) {
      lastThrowMap = APILastThrow.fromJson(json['last_throw']);
    }
    return APIFrame(
      err_code: json['err_code'],
      err_description: json['err_description'],
      sessionid: json['sessionid'],
      sessionip: json['sessionip'],
      match_type: json['match_type'],
      game_status: json['game_status'],
      game_clock: json['game_clock'],
      private_match: json['private_match'],
      client_name: json['client_name'],
      game_clock_display: json['game_clock_display'],
      blue_points: json['blue_points'],
      orange_points: json['orange_points'],
      teams: teamsMap,
      last_throw: lastThrowMap,
      rules_changed_by: json['rules_changed_by'],
      rules_changed_at: json['rules_changed_at'],
      raw: json,
    );
  }
}

class APITeam {
  final String team;
  final List<APIPlayer> players;

  APITeam({this.team, this.players});

  factory APITeam.fromJson(Map<String, dynamic> json) {
    return APITeam(
      team: json['team'],
      players: json.containsKey('players')
          ? json['players']
              .map<APIPlayer>((playerJSON) => APIPlayer.fromJson(playerJSON))
              .toList()
          : <APIPlayer>[],
    );
  }
}

class APIPlayer {
  final String name;
  final int ping;
  final APIStats stats;

  APIPlayer({this.name, this.ping, this.stats});

  factory APIPlayer.fromJson(Map<String, dynamic> json) {
    return APIPlayer(
      name: json['name'],
      ping: json['ping'],
      stats: APIStats.fromJson(json['stats']),
    );
  }
}

class APIStats {
  final double possession_time;
  final int points;
  final int saves;
  final int goals;
  final int stuns;
  final int steals;
  final int blocks;
  final int assists;
  final int shots_taken;

  APIStats(
      {this.possession_time,
      this.points,
      this.saves,
      this.goals,
      this.stuns,
      this.steals,
      this.blocks,
      this.assists,
      this.shots_taken});

  factory APIStats.fromJson(Map<String, dynamic> json) {
    return APIStats(
      possession_time: json['possession_time'],
      points: json['points'],
      saves: json['saves'],
      goals: json['goals'],
      stuns: json['stuns'],
      steals: json['steals'],
      blocks: json['blocks'],
      assists: json['assists'],
      shots_taken: json['shots_taken'],
    );
  }
}

class APILastThrow {
  final double arm_speed;
  final double total_speed;
  final double off_axis_spin_deg;
  final double wrist_throw_penalty;
  final double rot_per_sec;
  final double pot_speed_from_rot;
  final double speed_from_arm;
  final double speed_from_movement;
  final double speed_from_wrist;
  final double wrist_align_to_throw_deg;
  final double throw_align_to_movement_deg;
  final double off_axis_penalty;
  final double throw_move_penalty;

  APILastThrow(
      {this.arm_speed,
      this.total_speed,
      this.off_axis_spin_deg,
      this.wrist_throw_penalty,
      this.rot_per_sec,
      this.pot_speed_from_rot,
      this.speed_from_arm,
      this.speed_from_movement,
      this.speed_from_wrist,
      this.wrist_align_to_throw_deg,
      this.throw_align_to_movement_deg,
      this.off_axis_penalty,
      this.throw_move_penalty});

  factory APILastThrow.fromJson(Map<String, dynamic> json) {
    return APILastThrow(
      arm_speed: json['arm_speed'],
      total_speed: json['total_speed'],
      off_axis_spin_deg: json['off_axis_spin_deg'],
      wrist_throw_penalty: json['wrist_throw_penalty'],
      rot_per_sec: json['rot_per_sec'],
      pot_speed_from_rot: json['pot_speed_from_rot'],
      speed_from_arm: json['speed_from_arm'],
      speed_from_movement: json['speed_from_movement'],
      speed_from_wrist: json['speed_from_wrist'],
      wrist_align_to_throw_deg: json['wrist_align_to_throw_deg'],
      throw_align_to_movement_deg: json['throw_align_to_movement_deg'],
      off_axis_penalty: json['off_axis_penalty'],
      throw_move_penalty: json['throw_move_penal'],
    );
  }
}
