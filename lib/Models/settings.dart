// "site_name": "Niri9",
// "site_url": "http://test.niri9.com/",
// "owner": "Niri9",
import 'package:niri9/Models/os_info.dart';

class Settings {
  String? name, email, contact, logo;
  OsInfo? android, ios;

  Settings.fromJson(json) {
    name = json["name"] ?? "";
    email = json["email"] ?? "";
    contact = json["contact"] ?? "";
    logo = json["logo"] ?? "";
    android = json["android"] == null ? null : OsInfo.fromJson(json["android"]);
    ios = json["ios"] == null ? null : OsInfo.fromJson(json["ios"]);
  }
}

class SettingsResponse {
  bool? success;
  String? message, site_name, site_url, owner;
  Settings? settings;

  SettingsResponse.fromJson(json) {
    success = json["success"] ?? false;
    message = json["message"] ?? "";
    site_name = json["site_name"] ?? "";
    site_url = json["site_url"] ?? "";
    owner = json["owner"] ?? "";
    settings =
        json["settings"] == null ? null : Settings.fromJson(json["settings"]);
  }

  SettingsResponse.withError(msg) {
    success = false;
    message = msg;
  }
}
