import "dart:convert";

import "package:http/http.dart" as http;

class Api {
  factory Api() {
    return I;
  }

  Api._();

  static final Api I = Api._();

  static const String videosdkApiEndpoint = "https://api.videosdk.live/v2";

  Future<String> createMeeting(String token) async {
    final Uri getMeetingIdUrl = Uri.parse("$videosdkApiEndpoint/rooms");

    final http.Response meetingIdResponse = await http.post(
      getMeetingIdUrl,
      headers: {
        "Authorization": token,
      },
    );

    final body = (json.decode(meetingIdResponse.body) as Map<String, dynamic>);

    if (meetingIdResponse.statusCode != 200) {
      throw Exception(body["error"]);
    }
    return body["roomId"];
  }

  Future<bool> validateMeeting(String token, String meetingId) async {
    final Uri validateMeetingUrl =
        Uri.parse("$videosdkApiEndpoint/rooms/validate/$meetingId");

    final http.Response validateMeetingResponse = await http.get(
      validateMeetingUrl,
      headers: {
        "Authorization": token,
      },
    );

    final body =
        json.decode(validateMeetingResponse.body) as Map<String, dynamic>;

    if (validateMeetingResponse.statusCode != 200) {
      throw Exception(body["error"]);
    }

    return validateMeetingResponse.statusCode == 200;
  }

  Future<Map<String, dynamic>> fetchSession(
    String token,
    String meetingId,
  ) async {
    final Uri getMeetingIdUrl =
        Uri.parse("$videosdkApiEndpoint/sessions?roomId=$meetingId");

    final http.Response meetingIdResponse = await http.get(
      getMeetingIdUrl,
      headers: {
        "Authorization": token,
      },
    );

    final List<dynamic> sessions =
        (jsonDecode(meetingIdResponse.body) as Map<String, dynamic>)["data"];

    return sessions.first;
  }
}
