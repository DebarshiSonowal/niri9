// {
// "id": 1,
// "name": "Assamese",
// "slug": "assamese",
// "short_code": "as",
// "local_name": "অসমীয়া",
// "profile_pic": "http://test.niri9.com/public/assets/languages/assamese-pic.jpg",
// "status": 1
// },

class Language {
  int? id, status;
  String? name, slug,local_name,profile_pic;

  Language.fromJson(json) {
    id = json['id'] ?? 0;
    status = json['status'] ?? 0;
    name = json['name'] ?? "";
    slug = json['slug'] ?? "";
    local_name = json['local_name'] ?? "";
    profile_pic = json['profile_pic'] ?? "";
  }
}

class LanguageResponse {
  bool? status;
  String? message;
  List<Language> languages = [];

  LanguageResponse.fromJson(json) {
    status = json['status'] ?? true;
    message = json['message'] ?? "";
    languages = json['result'] == null
        ? []
        : (json['result'] as List).map((e) => Language.fromJson(e)).toList();
  }
  LanguageResponse.withError(msg){
    status = false;
    message = msg;
  }
}
