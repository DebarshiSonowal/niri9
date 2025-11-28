class OrderHistoryResponse {
  bool? success;
  List<Result>? result;
  String? message;
  int? code;

  OrderHistoryResponse({this.success, this.result, this.message, this.code});

  OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['code'] = code;
    return data;
  }

  OrderHistoryResponse.withError(msg) {
    success = false;
    message = msg;
  }
}

class Result {
  int? id;
  String? voucherNo;
  String? sellingTotal;
  String? baseTotal;
  String? discount;
  String? total;
  String? taxAmt;
  String? grandTotal;
  int? isPaid;
  int? status;
  String? currency;
  TaxData? taxData;
  int? customerId;
  String? orderDate;
  String? customerName;
  String? orderFor;
  ProductData? productData;
  String? invoiceNo;
  String? invoiceDate;
  String? invoiceAmount;
  String? customerEmail;
  String? customerMobile;
  String? downloadUrl;

  Result(
      {this.id,
      this.voucherNo,
      this.sellingTotal,
      this.baseTotal,
      this.discount,
      this.total,
      this.taxAmt,
      this.grandTotal,
      this.isPaid,
      this.status,
      this.currency,
      this.taxData,
      this.customerId,
      this.orderDate,
      this.customerName,
      this.orderFor,
      this.productData,
      this.invoiceNo,
      this.invoiceDate,
      this.invoiceAmount,
      this.customerEmail,
      this.customerMobile,
      this.downloadUrl});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    voucherNo = json['voucher_no'];
    sellingTotal = json['selling_total'];
    baseTotal = json['base_total'];
    discount = json['discount'];
    total = json['total'];
    taxAmt = json['tax_amt'];
    grandTotal = json['grand_total'];
    isPaid = json['is_paid'];
    status = json['status'];
    currency = json['currency'];
    taxData =
        (json['tax_data'] != null && json['tax_data'] is Map<String, dynamic>)
            ? TaxData.fromJson(json['tax_data'])
            : null;
    customerId = json['customer_id'];
    orderDate = json['order_date'];
    customerName = json['customer_name'];
    orderFor = json['order_for'];
    productData = (json['product_data'] != null &&
            json['product_data'] is Map<String, dynamic>)
        ? ProductData.fromJson(json['product_data'])
        : null;
    invoiceNo = json['invoice_no'];
    invoiceDate = json['invoice_date'];
    invoiceAmount = json['invoice_amount'];
    customerEmail = json['customer_email'];
    customerMobile = json['customer_mobile'];
    downloadUrl = json['download_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['voucher_no'] = voucherNo;
    data['selling_total'] = sellingTotal;
    data['base_total'] = baseTotal;
    data['discount'] = discount;
    data['total'] = total;
    data['tax_amt'] = taxAmt;
    data['grand_total'] = grandTotal;
    data['is_paid'] = isPaid;
    data['status'] = status;
    data['currency'] = currency;
    if (taxData != null) {
      data['tax_data'] = taxData!.toJson();
    }
    data['customer_id'] = customerId;
    data['order_date'] = orderDate;
    data['customer_name'] = customerName;
    data['order_for'] = orderFor;
    if (productData != null) {
      data['product_data'] = productData!.toJson();
    }
    data['invoice_no'] = invoiceNo;
    data['invoice_date'] = invoiceDate;
    data['invoice_amount'] = invoiceAmount;
    data['customer_email'] = customerEmail;
    data['customer_mobile'] = customerMobile;
    data['download_url'] = downloadUrl;
    return data;
  }
}

class TaxData {
  String? gst;
  String? cgst;
  String? sgst;
  String? igst;
  String? cTds;
  double? gstAmt;
  double? cgstAmt;
  double? sgstAmt;
  double? igstAmt;

  TaxData(
      {this.gst,
      this.cgst,
      this.sgst,
      this.igst,
      this.cTds,
      this.gstAmt,
      this.cgstAmt,
      this.sgstAmt,
      this.igstAmt});

  TaxData.fromJson(Map<String, dynamic> json) {
    gst = json['gst']?.toString();
    cgst = json['cgst']?.toString();
    sgst = json['sgst']?.toString();
    igst = json['igst']?.toString();
    cTds = json['c_tds']?.toString();
    gstAmt = json['gst_amt']?.toDouble();
    cgstAmt = json['cgst_amt']?.toDouble();
    sgstAmt = json['sgst_amt']?.toDouble();
    igstAmt = json['igst_amt']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gst'] = gst;
    data['cgst'] = cgst;
    data['sgst'] = sgst;
    data['igst'] = igst;
    data['c_tds'] = cTds;
    data['gst_amt'] = gstAmt;
    data['cgst_amt'] = cgstAmt;
    data['sgst_amt'] = sgstAmt;
    data['igst_amt'] = igstAmt;
    return data;
  }
}

class ProductData {
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
  int? qty;
  String? productType;
  String? totalPrice;
  String? activeDate;
  String? expiryDate;

  ProductData(
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
      this.updatedAt,
      this.qty,
      this.productType,
      this.totalPrice,
      this.activeDate,
      this.expiryDate});

  ProductData.fromJson(Map<String, dynamic> json) {
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
    qty = json['qty'];
    productType = json['product_type'];
    totalPrice = json['total_price'];
    activeDate = json['active_date'];
    expiryDate = json['expiry_date'];
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
    data['qty'] = qty;
    data['product_type'] = productType;
    data['total_price'] = totalPrice;
    data['active_date'] = activeDate;
    data['expiry_date'] = expiryDate;
    return data;
  }
}
