import 'package:flutter/material.dart';
import 'package:spark_mini/Model/IgniteStatsPlayer.dart';

import '../SizeConfig.dart';

class IgniteStatsPage extends StatelessWidget {
  final Map<String, dynamic> data;
  IgniteStatsPage(this.data);

  @override
  Widget build(BuildContext context) {
    return (() {
      if (data != null) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(children: <Widget>[
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3000),
                    border: Border.all(
                      color: Colors.white70,
                      width: SizeConfig.blockSizeHorizontal * .4,
                    ),
                  ),
                  child: CircleAvatar(
                      radius: SizeConfig.blockSizeHorizontal * 15,
                      backgroundImage:
                          NetworkImage(data['vrml_player']['player_logo'])),
                ),
                // Center(
                //   child: DefaultTextStyle(
                //       style: TextStyle(
                //           fontSize: SizeConfig.blockSizeHorizontal * 4),
                //       child: Text(data['player'][0]['player_name'])),
                // )
              ],
            ),
            Card(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                ListTile(
                  title: Center(
                      heightFactor: 2,
                      child: Text(
                        data['player'][0]['player_name'],
                        textScaleFactor: 2,
                      )),
                )
              ]),
            ),
          ]),
        );
      } else {
        return Container(child: Text('No Player'));
      }
    }());
  }
}
