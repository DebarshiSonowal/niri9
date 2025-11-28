import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:intl/intl.dart';
import 'package:niri9/main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Constants/constants.dart';
import '../../../Repository/repository.dart';
import '../../../Widgets/gradient_text.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Repository>(builder: (context, data, _) {
      // Comprehensive debug logging
      debugPrint("=== COMPREHENSIVE USER DEBUG ===");
      debugPrint("User exists: ${data.user != null}");
      if (data.user != null) {
        debugPrint("User ID: ${data.user!.id}");
        debugPrint("User Name: ${data.user!.name}");
        debugPrint("Has Subscription: ${data.user!.has_subscription}");
        debugPrint("Expiry Date: ${data.user!.expiry_date}");
        debugPrint("Last Sub: ${data.user!.last_sub}");
        debugPrint("Last Rent: ${data.user!.last_rent}");

        if (data.user!.last_rent != null) {
          debugPrint("--- LAST RENT INFO ---");
          debugPrint("Rent ID: ${data.user!.last_rent!.lastRent?.id}");
          debugPrint("Rent Title: ${data.user!.last_rent!.lastRent?.title}");
          debugPrint(
              "Rent Total Price: ${data.user!.last_rent!.lastRent?.totalPriceInr}");
          debugPrint(
              "Rent Expiry: ${data.user!.last_rent!.lastRent?.expiryDate}");
        }

        if (data.user!.last_sub != null) {
          debugPrint("--- LAST SUBSCRIPTION INFO ---");
          debugPrint("Last Sub exists: ${data.user!.last_sub != null}");
          debugPrint(
              "Last Subscription: ${data.user!.last_sub!.lastSubscription}");
          if (data.user!.last_sub!.lastSubscription != null) {
            final sub = data.user!.last_sub!.lastSubscription!;
            debugPrint("Sub ID: ${sub.id}");
            debugPrint("Sub Title: ${sub.title}");
            debugPrint("Sub Total Price INR: '${sub.totalPriceInr}'");
            debugPrint("Sub Base Price INR: '${sub.basePriceInr}'");
            debugPrint("Sub Plan Type: '${sub.planType}'");
            debugPrint("Sub Duration: '${sub.duration}'");
            debugPrint("Sub Updated At: '${sub.updatedAt}'");
          } else {
            debugPrint("lastSubscription is null!");
          }
        }
      }
      debugPrint("================================");

      return data.user?.last_sub?.lastSubscription == null
          ? _buildNoSubscriptionCard(context, data)
          : _buildActiveSubscriptionCard(context, data);
    });
  }

  Widget _buildNoSubscriptionCard(BuildContext context, Repository data) {
    // Check if user has subscription flag set but no last_sub data
    final hasSubscriptionFlag = data.user?.has_subscription ?? false;
    final hasLastSub = data.user?.last_sub != null;
    final hasRentData = data.user?.last_rent != null;
    final expiryDate = data.user?.expiry_date;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            hasSubscriptionFlag
                ? Icons.warning_amber_outlined
                : Icons.workspace_premium_outlined,
            size: 12.w,
            color: hasSubscriptionFlag
                ? Colors.orange.withOpacity(0.6)
                : Colors.white.withOpacity(0.4),
          ),
          SizedBox(height: 2.h),
          Text(
            hasSubscriptionFlag
                ? "Subscription Details Missing"
                : "No Active Subscription",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            hasSubscriptionFlag
                ? "You have an active subscription but pricing details are unavailable"
                : "Upgrade to premium to unlock all features",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13.sp,
            ),
            textAlign: TextAlign.center,
          ),

          // Show basic subscription info if available
          if (hasSubscriptionFlag &&
              expiryDate != null &&
              expiryDate != "NA") ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Active Subscription",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Status: Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Expires: ${_formatDate(expiryDate)}",
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (hasRentData) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Active Rental",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "₹${data.user!.last_rent!.lastRent?.totalPriceInr ?? 'N/A'}",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Expires: ${_formatDate(data.user!.last_rent!.lastRent?.expiryDate)}",
                    style: TextStyle(
                      color: Colors.blue.withOpacity(0.8),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(BuildContext context, Repository data) {
    final subscription = data.user?.last_sub?.lastSubscription;
    final isActive = _isSubscriptionActive(data.user?.expiry_date);

    // Debug subscription data
    debugPrint("=== Subscription Debug Info ===");
    debugPrint("Has subscription: ${subscription != null}");
    if (subscription != null) {
      debugPrint("Subscription ID: ${subscription.id}");
      debugPrint("Title: ${subscription.title}");
      debugPrint("Total Price INR: '${subscription.totalPriceInr}'");
      debugPrint("Base Price INR: '${subscription.basePriceInr}'");
      debugPrint("Plan Type: '${subscription.planType}'");
      debugPrint("Duration: '${subscription.duration}'");
    }
    debugPrint("==============================");

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription?.title ?? "Premium Plan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "Current Subscription",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF22C55E).withOpacity(0.15)
                        : const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF22C55E).withOpacity(0.3)
                          : const Color(0xFFEF4444).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isActive ? "Active" : "Expired",
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Price section
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "₹${_getSubscriptionPriceWithFallback(subscription)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  "/${_getDurationText(subscription?.planType)}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Details section
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    "Purchase Date",
                    _formatDate(subscription?.updatedAt),
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    "Expiry Date",
                    _formatDate(data.user?.expiry_date),
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    "Screens",
                    "${subscription?.noOfScreens ?? 1} device${(subscription?.noOfScreens ?? 1) > 1 ? 's' : ''}",
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    "Duration",
                    "${subscription?.duration ?? 'N/A'}",
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    "Auto Renewal",
                    "Disabled",
                  ),
                ],
              ),
            ),

            if (!isActive) ...[
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFF59E0B),
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subscription Expired",
                            style: TextStyle(
                              color: const Color(0xFFF59E0B),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Renew to continue enjoying premium features",
                            style: TextStyle(
                              color: const Color(0xFFF59E0B).withOpacity(0.8),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.08),
      height: 1,
    );
  }

  bool _isSubscriptionActive(String? expiryDate) {
    if (expiryDate == null || expiryDate.isEmpty) return false;

    try {
      final expiry = DateTime.parse(expiryDate);
      return expiry.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  String _getDurationText(String? planType) {
    if (planType == null) return "plan";

    if (planType.toLowerCase().contains("365") ||
        planType.toLowerCase().contains("year")) {
      return "year";
    } else if (planType.toLowerCase().contains("30") ||
        planType.toLowerCase().contains("month")) {
      return "month";
    } else if (planType.toLowerCase().contains("7") ||
        planType.toLowerCase().contains("week")) {
      return "week";
    }

    return "plan";
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "N/A";
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      debugPrint("Date parsing error: $e for date: $dateString");
      return "Invalid Date";
    }
  }

  String _getSubscriptionPrice(String? totalPriceInr) {
    debugPrint("_getSubscriptionPrice called with: '$totalPriceInr'");

    if (totalPriceInr == null || totalPriceInr.isEmpty) {
      debugPrint("totalPriceInr is null or empty, returning default 599");
      return "599";
    }

    try {
      // Remove any currency symbols or extra characters
      String cleanPrice = totalPriceInr.replaceAll(RegExp(r'[^\d.]'), '');
      debugPrint("Cleaned price: '$cleanPrice'");

      if (cleanPrice.isEmpty) {
        debugPrint("Cleaned price is empty, returning default 599");
        return "599";
      }

      final price = double.parse(cleanPrice);
      final result = price.toInt().toString();
      debugPrint("Parsed price successfully: $result");
      return result;
    } catch (e) {
      debugPrint("Price parsing error: $e for price: '$totalPriceInr'");
      return "599";
    }
  }

  String _getSubscriptionPriceWithFallback(dynamic subscription) {
    // Try multiple fields in order of preference
    if (subscription?.totalPriceInr != null) {
      final price = _getSubscriptionPrice(subscription.totalPriceInr);
      if (price != "599") return price; // Only use if not the default fallback
    }

    if (subscription?.basePriceInr != null) {
      final price = _getSubscriptionPrice(subscription.basePriceInr);
      if (price != "599") return price; // Only use if not the default fallback
    }

    debugPrint("No valid price found in subscription data, using default 599");
    return "599";
  }
}
