String getFormattedLink(
    String sessionid,
    bool angleBrackets,
    int linkType,
    bool appendTeamNames,
    Map<String, dynamic> orangeVRMLTeamInfo,
    Map<String, dynamic> blueVRMLTeamInfo) {
  if (sessionid == null) sessionid = '**********************';

  String link = "";

  if (angleBrackets) {
    switch (linkType) {
      case 0:
        link = "<spark://c/$sessionid>";
        break;
      case 1:
        link = "<spark://j/$sessionid>";
        break;
      case 2:
        link = "<spark://s/$sessionid>";
        break;
    }
  } else {
    switch (linkType) {
      case 0:
        link = "spark://c/$sessionid";
        break;
      case 1:
        link = "spark://j/$sessionid";
        break;
      case 2:
        link = "spark://s/$sessionid";
        break;
    }
  }

  if (appendTeamNames) {
    String orangeName = '?';
    String blueName = '?';
    if (orangeVRMLTeamInfo != null &&
        orangeVRMLTeamInfo.containsKey('team_name') &&
        orangeVRMLTeamInfo['team_name'] != '') {
      orangeName = orangeVRMLTeamInfo['team_name'];
    }
    if (blueVRMLTeamInfo != null &&
        blueVRMLTeamInfo.containsKey('team_name') &&
        blueVRMLTeamInfo['team_name'] != '') {
      blueName = blueVRMLTeamInfo['team_name'];
    }

    // if at least one team name exists
    if (orangeName != '?' || blueName != '?') {
      link = "$link $orangeName vs $blueName";
    }
  }

  return link;
}
