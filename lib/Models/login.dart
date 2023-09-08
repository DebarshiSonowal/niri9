import 'package:niri9/Models/user.dart';

class LoginResponse {
  bool? success;
  String? message, token;
  User? user;

  LoginResponse.fromJson(json) {
    success = json["success"] ?? false;
    message = json["message"] ?? "";
    token = json["access_token"] ?? "";
    user = User.fromJson(json["result"]);
  }

  LoginResponse.withError(msg) {
    success = false;
    message = msg;
  }
}
