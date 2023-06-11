class GenericResponse {
  bool? success;
  String? message, result;

  GenericResponse.fromJson(json) {
    success = json['success'] ?? true;
    message = json['message'];
    result = json['result'] ?? "";
  }

  GenericResponse.withError(msg){
    success = false;
    message = msg;
  }
}
