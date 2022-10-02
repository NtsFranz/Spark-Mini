import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../Model/APIFrame.dart';

class FrameFetcher extends StateNotifier<APIFrame> {
  // 1. initialize with current time
  FrameFetcher() : super(APIFrame()) {
    // 2. create a timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      // 3. update the state with the current time
      state = await fetchAPI();
    });
  }

  Timer _timer;

  // 4. cancel the timer when finished
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<APIFrame> fetchAPI() async {
    try {
      final response = await http
          .get(Uri.http('127.0.0.1:6721', 'session'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200 || response.statusCode == 500) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        try {
          var newFrame = APIFrame.fromJson(jsonDecode(response.body));

          if (newFrame.sessionid != null) {
            return newFrame;
          }
        } catch (e) {
          print(e);
          return null;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
    print('fail');
    return null;
  }
}
