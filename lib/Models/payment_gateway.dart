// "name": "Razorpay",
//             "active_mode": "live",
//             "api_key": "rzp_live_iQ7sh3ZRzuy1u9",
//             "secret_key": "jMpgLbygk3LidMcKkrq0zGJ6",
//             "is_active": "1"
class PaymentGateway {
  String? name, active_mode, secret_key, api_key;
  int? is_active;
  Map<String, dynamic>? productMappings;

  PaymentGateway.fromJson(json) {
    name = json['name'] ?? "";
    active_mode = json['active_mode'] ?? "";
    secret_key = json['secret_key'] ?? "";
    api_key = json['api_key'] ?? "";
    is_active = int.parse("${json['is_active'] ?? "0"}");
    // For Apple IAP - product mappings between subscription IDs and product identifiers
    if (json['product_mappings'] != null) {
      productMappings = json['product_mappings'];
    }
  }
}

class PaymentGatewayResponse {
  bool? success;
  String? message;
  PaymentGateway? razorpay, easebuzz, apple_iap;

  PaymentGatewayResponse.fromJson(json) {
    success = json['success'] ?? false;
    message = json['message'] ?? "Something went wrong";
    razorpay = json['rz'] == null ? null : PaymentGateway.fromJson(json['rz']);
    easebuzz =
        json['ebuzz'] == null ? null : PaymentGateway.fromJson(json['ebuzz']);
    apple_iap = json['apple_iap'] == null
        ? null
        : PaymentGateway.fromJson(json['apple_iap']);
  }

  PaymentGatewayResponse.withError(msg) {
    success = false;
    message = msg ?? "Something went wrong";
  }
}
