class Language {
  int? id, status;
  String? name, slug;

  Language.fromJson(json) {
    id = json['id'] ?? 0;
    status = json['status'] ?? 0;
    name = json['name'] ?? "";
    slug = json['slug'] ?? "";
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
