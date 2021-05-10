// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'igniteStatsPlayer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IgniteStatsPlayer _$IgniteStatsPlayerFromJson(Map<String, dynamic> json) {
  return IgniteStatsPlayer(
    game_count: json['game_count'] as int,
    inverted_time: (json['inverted_time'] as num)?.toDouble(),
    level: json['level'] as int,
    opt_in: json['opt_in'] as int,
    opt_out: json['opt_out'] as int,
    play_time: (json['play_time'] as num)?.toDouble(),
    player_id: json['player_id'] as int,
    player_name: json['player_name'] as String,
    player_number: json['player_number'] as int,
    possession_time: (json['possession_time'] as num)?.toDouble(),
    profile_image: json['profile_image'] as String,
    profile_page: json['profile_page'] as String,
    total_2_pointers: json['total_2_pointers'] as int,
    total_3_pointers: json['total_3_pointers'] as int,
    total_assists: json['total_assists'] as int,
    total_blocks: json['total_blocks'] as int,
    total_catches: json['total_catches'] as int,
    total_goals: json['total_goals'] as int,
    total_interceptions: json['total_interceptions'] as int,
    total_passes: json['total_passes'] as int,
    total_points: json['total_points'] as int,
    total_saves: json['total_saves'] as int,
    total_shots_taken: json['total_shots_taken'] as int,
    total_steals: json['total_steals'] as int,
    total_stuns: json['total_stuns'] as int,
    total_wins: json['total_wins'] as int,
  );
}

Map<String, dynamic> _$IgniteStatsPlayerToJson(IgniteStatsPlayer instance) =>
    <String, dynamic>{
      'game_count': instance.game_count,
      'inverted_time': instance.inverted_time,
      'level': instance.level,
      'opt_in': instance.opt_in,
      'opt_out': instance.opt_out,
      'play_time': instance.play_time,
      'player_id': instance.player_id,
      'player_name': instance.player_name,
      'player_number': instance.player_number,
      'possession_time': instance.possession_time,
      'profile_image': instance.profile_image,
      'profile_page': instance.profile_page,
      'total_2_pointers': instance.total_2_pointers,
      'total_3_pointers': instance.total_3_pointers,
      'total_assists': instance.total_assists,
      'total_blocks': instance.total_blocks,
      'total_catches': instance.total_catches,
      'total_goals': instance.total_goals,
      'total_interceptions': instance.total_interceptions,
      'total_passes': instance.total_passes,
      'total_points': instance.total_points,
      'total_saves': instance.total_saves,
      'total_shots_taken': instance.total_shots_taken,
      'total_steals': instance.total_steals,
      'total_stuns': instance.total_stuns,
      'total_wins': instance.total_wins,
    };
