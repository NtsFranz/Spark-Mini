
import 'package:json_annotation/json_annotation.dart';

part 'igniteStatsPlayer.g.dart';

@JsonSerializable()
class IgniteStatsPlayer {
  int game_count;
  double inverted_time;
  int level;
  int opt_in;
  int opt_out;
  double play_time;
  int player_id;
  String player_name;
  int player_number;
  double possession_time;
  String profile_image;
  String profile_page;
  int total_2_pointers;
  int total_3_pointers;
  int total_assists;
  int total_blocks;
  int total_catches;
  int total_goals;
  int total_interceptions;
  int total_passes;
  int total_points;
  int total_saves;
  int total_shots_taken;
  int total_steals;
  int total_stuns;
  int total_wins;

  IgniteStatsPlayer(
      {this.game_count,
      this.inverted_time,
      this.level,
      this.opt_in,
      this.opt_out,
      this.play_time,
      this.player_id,
      this.player_name,
      this.player_number,
      this.possession_time,
      this.profile_image,
      this.profile_page,
      this.total_2_pointers,
      this.total_3_pointers,
      this.total_assists,
      this.total_blocks,
      this.total_catches,
      this.total_goals,
      this.total_interceptions,
      this.total_passes,
      this.total_points,
      this.total_saves,
      this.total_shots_taken,
      this.total_steals,
      this.total_stuns,
      this.total_wins});

      factory IgniteStatsPlayer.fromJson(Map<String,dynamic> json)=> _$IgniteStatsPlayerFromJson(json);
      Map<String,dynamic>toJson() => _$IgniteStatsPlayerToJson(this);
}

// class IgniteStatsVRMLPlayer {
//   String game;
//   String nationality;
//   String nationality_logo;
//   String player_id;
//   String player_logo;
//   String player_name;
//   String player_page;
//   String rank;
//   String region;
//   String team_banner;
//   String team_id;
//   String team_logo;
//   String team_name;
//   String team_page;

//   IgniteStatsVRMLPlayer(
//       {this.game,
//       this.nationality,
//       this.nationality_logo,
//       this.player_id,
//       this.player_logo,
//       this.player_name,
//       this.player_page,
//       this.rank,
//       this.region,
//       this.team_banner,
//       this.team_id,
//       this.team_logo,
//       this.team_name,
//       this.team_page});
// }
