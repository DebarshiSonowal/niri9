class User {
  int? id, mobile;
  String? unique_no, name, email, profile_pic, f_name, l_name, expiry_date;
  bool? has_subscription, last_subscription, last_rent;

  User.fromJson(json) {
    id = json["id"] ?? 0;
    mobile = int.parse("${json["mobile"]??"0"}");
    unique_no = json["unique_no"];
    name = json["name"] ?? "NA";
    email = json["email"] ?? "NA";
    profile_pic = json["profile_pic"] ?? "NA";
    f_name = json["f_name"] ?? "NA";
    l_name = json["l_name"] ?? "NA";
    expiry_date = json["expiry_date"] ?? "NA";
    has_subscription = json["has_subscription"] ?? false;
    last_subscription = json["last_subscription"] ?? false;
    last_rent = json["last_rent"] ?? false;
  }
}
