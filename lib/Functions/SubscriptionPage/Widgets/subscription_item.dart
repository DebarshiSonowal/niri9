import 'dart:io';
import 'package:flutter/material.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Services/apple_iap_service.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/subscription.dart';

class SubscriptionItem extends StatelessWidget {
  const SubscriptionItem({
    super.key,
    required this.selected,
    required this.item,
    required this.index,
    required this.onTap,
    this.iapService,
  });

  final int? selected, index;
  final Subscription item;
  final Function onTap;
  final AppleIAPService? iapService;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 17.h,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: () => onTap(),
            child: Consumer<Repository>(builder: (context, data, _) {
              final isSelected = selected == index;
              final isCurrentSubscription = checkConditions(data, item.id);

              // Get StoreKit product if on iOS
              final storeKitProduct = Platform.isIOS && iapService != null
                  ? iapService!.findProductForSubscription(item.id ?? 0)
                  : null;

              // Determine price and currency to display
              final displayPrice = storeKitProduct != null
                  ? storeKitProduct.price
                  : '₹${(item.total_price_inr ?? 419).toInt()}';

              // Extract numeric value and currency symbol
              final priceInfo = _extractPriceInfo(
                storeKitProduct?.price,
                item.total_price_inr,
              );

              return Container(
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Colors.blue.shade700,
                            Colors.blue.shade900,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : isCurrentSubscription
                          ? LinearGradient(
                              colors: [
                                Colors.green.shade700,
                                Colors.green.shade900,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                  color: !isSelected && !isCurrentSubscription
                      ? Colors.grey.shade900.withOpacity(0.5)
                      : null,
                  border: Border.all(
                    color: isCurrentSubscription
                        ? Colors.green.shade400
                        : isSelected
                            ? Colors.blue.shade400
                            : Colors.white24,
                    width: isSelected || isCurrentSubscription ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected || isCurrentSubscription
                      ? [
                          BoxShadow(
                            color: isCurrentSubscription
                                ? Colors.green.shade400.withOpacity(0.3)
                                : Colors.blue.shade400.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                width: getAdaptiveWidth(context),
                padding: EdgeInsets.all(2.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status text
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: isCurrentSubscription
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data.user?.has_subscription ?? false
                            ? isCurrentSubscription
                                ? "ACTIVE"
                                : "UPGRADE TO"
                            : "GET STARTED",
                        style: TextStyle(
                          color: isCurrentSubscription
                              ? Colors.green.shade300
                              : Colors.orange.shade300,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 0.2.h),

                    // Plan title
                    Text(
                      item.title ?? "Premium",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    SizedBox(height: 0.5.h),

                    // Price - Use StoreKit price on iOS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          priceInfo['currencySymbol']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          priceInfo['amount']!,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 0.3.h),

                    // Duration
                    Text(
                      "per ${(item.plan_type ?? 'month').toLowerCase()}",
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.white60,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          selected == index
              ? Consumer<Repository>(builder: (context, data, _) {
                  final isCurrentSub = checkConditions(data, item.id);
                  return Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: isCurrentSub
                            ? Colors.green.shade600
                            : Colors.blue.shade600,
                        size: 20,
                      ),
                    ),
                  );
                })
              : Container(),
        ],
      ),
    );
  }

  // Extract price information from StoreKit or backend
  Map<String, String> _extractPriceInfo(
      String? storeKitPrice, double? backendPrice) {
    if (Platform.isIOS && storeKitPrice != null && storeKitPrice.isNotEmpty) {
      // Parse StoreKit price (e.g., "₹149.00", "$4.99", "€3.99")
      // Remove all non-digit characters except decimal point to get the number
      final numericValue = storeKitPrice.replaceAll(RegExp(r'[^\d.]'), '');

      // Extract currency symbol (first non-digit character)
      final currencyMatch = RegExp(r'[^\d.,\s]+').firstMatch(storeKitPrice);
      final currencySymbol = currencyMatch?.group(0) ?? '₹';

      // Format the amount (remove decimals if .00)
      double amount = double.tryParse(numericValue) ?? 0.0;
      String formattedAmount = amount % 1 == 0
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);

      return {
        'currencySymbol': currencySymbol,
        'amount': formattedAmount,
      };
    }

    // Fallback to backend price
    return {
      'currencySymbol': '₹',
      'amount': (backendPrice ?? 419).toInt().toString(),
    };
  }

  checkConditions(Repository data, int? id) {
    // Check if user has subscription and this plan matches their current subscription
    if (data.user?.has_subscription ?? false) {
      final currentSubId = data.user?.last_sub?.lastSubscription?.id;
      return currentSubId == id;
    }
    return false;
  }

  // Function to calculate adaptive width based on device type
  double getAdaptiveWidth(BuildContext context) {
    // Check if the device is a tablet (iPad)
    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // Return a smaller percentage width for tablets to avoid text overflow
    return isTablet ? 38.w : 42.w;
  }
}
