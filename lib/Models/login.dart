// {data: {id: 18, unique_no: ID-230805115232,
// name: User , email: null, status: 0,
// profile_pic: http://test.niri9.com/doc/default/blank-image.svg,
// f_name: User, l_name: , mobile: 8638372157, has_subscription: false,
// expiry_date: null, last_subscription: false, last_rent: false},
// access_token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vdGVzdC5uaXJpOS5jb20vYXBpL3VzZXJzL2xvZ2luIiwiaWF0IjoxNjkxMjEzMTI3LCJleHAiOjE2OTEyMTY3MjcsIm5iZiI6MTY5MTIxMzEyNywianRpIjoiMlFaTUsxdUMybTZkbUpBNSIsInN1YiI6IjE4IiwicHJ2IjoiODFkY2IzMDQ2MjY3NmE0MzFhZTQzZjFmZjM3OTlmYjEyZjkwNDU5MiJ9.4y0L2h1iksY69Vt2h-aTRSD4GyPAzFGn3yDckzx-orE,
// token_type: bearer, expires_in: 3600}

import 'package:niri9/Models/user.dart';

class LoginResponse {
  bool? success;
  String? message, token;
  User? user;

  LoginResponse.fromJson(json) {
    success = json["success"] ?? false;
    message = json["message"] ?? "";
    token = json["token"] ?? "";
    user = User.fromJson(json["data"]);
  }

  LoginResponse.withError(msg) {
    success = false;
    message = msg;
  }
}
