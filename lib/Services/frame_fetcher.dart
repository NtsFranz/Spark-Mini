import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:spark_mini/main.dart';

import '../Model/APIFrame.dart';

class FrameFetcher extends StateNotifier<APIFrame> {
  FrameFetcher(ref) : super(APIFrame()) {
    // 2. create a timer that fires every second
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) async {
      final echoVRIP = ref.read(echoVRIPProvider);
      final echoVRPort = ref.read(echoVRPortProvider);

      // 3. update the state with the current time
      state = await fetchAPI(echoVRIP, echoVRPort);
    });
  }

  Timer _timer;

  // 4. cancel the timer when finished
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<APIFrame> fetchAPI(echoVRIP, echoVRPort) async {
    try {
      final response = await http
          .get(Uri.http('$echoVRIP:$echoVRPort', 'session'))
          .timeout(const Duration(seconds: 1))
          .onError((error, stackTrace) => null);
      if (response != null) {
        if (response.statusCode == 200 || response.statusCode == 500) {
          // If the server did return a 200 OK response,
          // then parse the JSON.
          try {
            var newFrame = APIFrame.fromJson(jsonDecode(response.body));

            return newFrame;
          } catch (e) {
            print(e);
            return null;
          }
        } else if (response.statusCode == 404) {
          // var newFrame = APIFrame();
          // newFrame.err_code = -7;
          // return newFrame;
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }
}
