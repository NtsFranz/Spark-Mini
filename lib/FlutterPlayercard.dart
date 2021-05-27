import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'SizeConfig.dart';

class FlutterPlayercard extends StatelessWidget {
  FlutterPlayercard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3000),
                    border: Border.all(
                      color: Colors.white70,
                      width: SizeConfig.blockSizeHorizontal * 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                      radius: SizeConfig.blockSizeHorizontal * 15,
                      backgroundImage: NetworkImage(
                          'https://vrmasterleague.com/images/logos/users/efa4648c-dc7d-4f7c-aaf5-74bb224b5c26.png')),
                ),
                // Team Stats
                Column(
                  children: [
                    SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                    Container(
                      child: Image.network(
                          'https://vrmasterleague.com/images/logos/teams/09093858-5626-404d-97a3-10b8353fcc47.png'),
                      width: SizeConfig.blockSizeHorizontal * 20,
                    ),
                    SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                    DefaultTextStyle(
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 4),
                      child: Row(
                        children: [
                          DefaultTextStyle(
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: SizeConfig.blockSizeHorizontal * 4),
                            child: Column(
                              children: [
                                Container(
                                  width: SizeConfig.blockSizeHorizontal * 26,
                                  child: Text(
                                    "Division",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Container(
                                  width: SizeConfig.blockSizeHorizontal * 26,
                                  child: Text(
                                    "Ranking",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Container(
                                  width: SizeConfig.blockSizeHorizontal * 26,
                                  child: Text(
                                    "W/L",
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Container(
                                  width: SizeConfig.blockSizeHorizontal * 26,
                                  child: Text(
                                    "Games Played",
                                    textAlign: TextAlign.right,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                          Column(
                            children: [
                              Container(
                                  width: SizeConfig.blockSizeHorizontal * 25,
                                  child: Text("Diamond")),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal * 25,
                                  child: Text("#22")),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal * 25,
                                  child: Text("18 - 12")),
                              Container(
                                  width: SizeConfig.blockSizeHorizontal * 25,
                                  child: Text("30")),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),

            SizedBox(height: SizeConfig.blockSizeHorizontal * 4),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.black, Colors.black12],
              )),
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 1),
                child: ListTile(
                  title: Text('NtsFranz',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 6)),
                  subtitle: Text('Ignite',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 5)),
                ),
              ),
            ),

            // Stats Area
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white30, Colors.white54],
              )),
              child: Column(children: [
                DefaultTextStyle(
                  style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'monospace',
                      fontSize: SizeConfig.blockSizeHorizontal * 4),
                  child: Padding(
                    padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("Games......"),
                            new LinearPercentIndicator(
                              width: SizeConfig.blockSizeHorizontal * 48,
                              lineHeight: SizeConfig.blockSizeHorizontal * 5,
                              percent: 0.5,
                              linearStrokeCap: LinearStrokeCap.butt,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                        Row(
                          children: [
                            Text("Points....."),
                            new LinearPercentIndicator(
                              width: SizeConfig.blockSizeHorizontal * 48,
                              lineHeight: SizeConfig.blockSizeHorizontal * 5,
                              percent: 0.5,
                              linearStrokeCap: LinearStrokeCap.butt,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                        Row(
                          children: [
                            Text("Assists...."),
                            new LinearPercentIndicator(
                              width: SizeConfig.blockSizeHorizontal * 48,
                              lineHeight: SizeConfig.blockSizeHorizontal * 5,
                              percent: 0.5,
                              linearStrokeCap: LinearStrokeCap.butt,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                        Row(
                          children: [
                            Text("Stuns......"),
                            new LinearPercentIndicator(
                              width: SizeConfig.blockSizeHorizontal * 48,
                              lineHeight: SizeConfig.blockSizeHorizontal * 5,
                              percent: 0.5,
                              linearStrokeCap: LinearStrokeCap.butt,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                        Row(
                          children: [
                            Text("Possession."),
                            new LinearPercentIndicator(
                              width: SizeConfig.blockSizeHorizontal * 48,
                              lineHeight: SizeConfig.blockSizeHorizontal * 5,
                              percent: 0.5,
                              linearStrokeCap: LinearStrokeCap.butt,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                        Row(
                          children: [
                            Text("Saves......"),
                            new LinearPercentIndicator(
                              width: SizeConfig.blockSizeHorizontal * 48,
                              lineHeight: SizeConfig.blockSizeHorizontal * 5,
                              percent: 0.5,
                              linearStrokeCap: LinearStrokeCap.butt,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
                        Row(
                          children: [
                            Text("Steals....."),
                            new LinearPercentIndicator(
                              width: SizeConfig.blockSizeHorizontal * 48,
                              lineHeight: SizeConfig.blockSizeHorizontal * 5,
                              percent: 0.5,
                              linearStrokeCap: LinearStrokeCap.butt,
                              backgroundColor: Colors.grey,
                              progressColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Powered by Ignite Metrics',
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 4,
                      color: Colors.black54),
                ),
                SizedBox(height: SizeConfig.blockSizeHorizontal * 2),
              ]),
            )
          ],
        ),
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2),
      ),
      color: Colors.black12,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.white70, width: SizeConfig.blockSizeHorizontal * 2),
          borderRadius:
              BorderRadius.circular(SizeConfig.blockSizeHorizontal * 6)),
      elevation: 10,
    );
  }
}
