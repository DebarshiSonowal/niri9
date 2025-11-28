class LastSubscriptionsDetails {
  LastSubscription? lastSubscription;

  LastSubscriptionsDetails({this.lastSubscription});

  LastSubscriptionsDetails.fromJson(Map<String, dynamic> json) {
    lastSubscription = json['last_subscription'] != null
        ? LastSubscription.fromJson(json['last_subscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lastSubscription != null) {
      data['last_subscription'] = lastSubscription!.toJson();
    }
    return data;
  }
}

class LastSubscription {
  int? id;
  String? title;
  String? planType;
  String? duration;
  String? devicePermissions;
  int? videoQuality;
  int? noOfScreens;
  int? isAdFree;
  String? basePriceInr;
  String? basePriceUsd;
  String? discount;
  String? totalPriceInr;
  String? totalPriceUsd;
  Null? note;
  String? planSection;
  int? isDefault;
  int? status;
  String? createdAt;
  String? updatedAt;

  LastSubscription(
      {this.id,
      this.title,
      this.planType,
      this.duration,
      this.devicePermissions,
      this.videoQuality,
      this.noOfScreens,
      this.isAdFree,
      this.basePriceInr,
      this.basePriceUsd,
      this.discount,
      this.totalPriceInr,
      this.totalPriceUsd,
      this.note,
      this.planSection,
      this.isDefault,
      this.status,
      this.createdAt,
      this.updatedAt});

  LastSubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    planType = json['plan_type'];
    duration = json['duration'];
    devicePermissions = json['device_permissions'];
    videoQuality = json['video_quality'];
    noOfScreens = json['no_of_screens'];
    isAdFree = json['is_ad_free'];
    basePriceInr = json['base_price_inr'];
    basePriceUsd = json['base_price_usd'];
    discount = json['discount'];
    totalPriceInr = json['total_price_inr'];
    totalPriceUsd = json['total_price_usd'];
    note = json['note'];
    planSection = json['plan_section'];
    isDefault = json['is_default'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['plan_type'] = planType;
    data['duration'] = duration;
    data['device_permissions'] = devicePermissions;
    data['video_quality'] = videoQuality;
    data['no_of_screens'] = noOfScreens;
    data['is_ad_free'] = isAdFree;
    data['base_price_inr'] = basePriceInr;
    data['base_price_usd'] = basePriceUsd;
    data['discount'] = discount;
    data['total_price_inr'] = totalPriceInr;
    data['total_price_usd'] = totalPriceUsd;
    data['note'] = note;
    data['plan_section'] = planSection;
    data['is_default'] = isDefault;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
