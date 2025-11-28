import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';
import '../../../Services/apple_iap_service.dart';
import 'dart:io' show Platform;

class PaymentWidget extends StatelessWidget {
  const PaymentWidget({
    super.key,
    required this.selected,
    required this.upgrade,
    this.iapService,
  });

  final int? selected;
  final Function upgrade;
  final AppleIAPService? iapService;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.black
            .withOpacity(0.8), // Increased opacity for better contrast
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Consumer<Repository>(builder: (context, data, _) {
                  if (data.subscriptions.isEmpty ||
                      selected == null ||
                      selected! >= data.subscriptions.length) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "₹",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "0",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    );
                  }

                  final selectedSubscription = data.subscriptions[selected!];

                  // Get StoreKit product if on iOS
                  final storeKitProduct = Platform.isIOS &&
                          iapService != null &&
                          iapService!.productsLoaded
                      ? iapService!.findProductForSubscription(
                          selectedSubscription.id ?? 0)
                      : null;

                  // Debug logging
                  if (Platform.isIOS && iapService != null) {
                    debugPrint(
                        '💳 PaymentWidget - Subscription ID: ${selectedSubscription.id}');
                    debugPrint(
                        '💳 Products loaded: ${iapService!.productsLoaded}');
                    debugPrint(
                        '💳 Available products: ${iapService!.products.length}');
                    if (storeKitProduct != null) {
                      debugPrint(
                          '✅ Found StoreKit product: ${storeKitProduct.id}');
                      debugPrint('✅ StoreKit price: ${storeKitProduct.price}');
                    } else {
                      debugPrint(
                          '❌ No StoreKit product found for subscription ${selectedSubscription.id}');
                    }
                  }

                  // Get price info
                  final priceInfo = _getPriceInfo(
                    storeKitProduct,
                    selectedSubscription.total_price_inr,
                  );

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        priceInfo['symbol']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Use AnimatedDigitWidget for smooth transitions
                      AnimatedDigitWidget(
                        duration: const Duration(milliseconds: 500),
                        value: priceInfo['value']!,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: 0.3.h),
                if (selected != null)
                  Consumer<Repository>(
                    builder: (context, data, _) {
                      if (data.subscriptions.isEmpty ||
                          selected! >= data.subscriptions.length) {
                        return SizedBox.shrink();
                      }

                      final planType = data.subscriptions[selected!].plan_type
                              ?.toLowerCase() ??
                          'monthly';

                      return Text(
                        Platform.isIOS
                            ? "Auto-renews $planType"
                            : "Renews $planType",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            flex: 3,
            child: Container(
              height: 5.h,
              child: ElevatedButton(
                onPressed: selected != null ? () => upgrade() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected != null
                      ? Colors.blue.shade600
                      : Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  elevation: selected != null ? 8 : 0,
                  shadowColor: Colors.blue.shade400.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    selected != null
                        ? (Platform.isIOS
                            ? "Subscribe with Apple"
                            : "Subscribe Now")
                        : "Select a Plan",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Extract price information from StoreKit or backend
  Map<String, dynamic> _getPriceInfo(
      dynamic storeKitProduct, double? backendPrice) {
    // Use StoreKit price if available on iOS
    if (Platform.isIOS && storeKitProduct != null) {
      final rawPrice = storeKitProduct.price; // e.g., "₹149.00" or "$4.99"

      debugPrint('💰 Parsing StoreKit price: $rawPrice');

      // Extract currency symbol - everything before the first digit
      String symbol = '₹';
      String amountStr = rawPrice;

      // Find where the first digit is
      final firstDigitIndex = rawPrice.indexOf(RegExp(r'\d'));
      if (firstDigitIndex > 0) {
        symbol = rawPrice.substring(0, firstDigitIndex).trim();
        amountStr = rawPrice.substring(firstDigitIndex).trim();
      } else if (firstDigitIndex == 0) {
        // Price starts with digit, symbol is at the end (like "4.99$")
        final lastDigitIndex = rawPrice.lastIndexOf(RegExp(r'\d'));
        if (lastDigitIndex < rawPrice.length - 1) {
          symbol = rawPrice.substring(lastDigitIndex + 1).trim();
          amountStr = rawPrice.substring(0, lastDigitIndex + 1).trim();
        }
      }

      // Clean up the amount string - remove any remaining non-numeric chars except decimal point
      amountStr = amountStr.replaceAll(RegExp(r'[^\d.]'), '');

      // Parse to double for AnimatedDigitWidget
      final amount = double.tryParse(amountStr) ?? 0.0;

      debugPrint('💰 Extracted - Symbol: $symbol, Amount: $amount');

      return {
        'symbol': symbol,
        'value': amount,
        'formatted': amount % 1 == 0
            ? amount.toInt().toString()
            : amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), ''),
      };
    }

    // Fallback to backend price for Android or when StoreKit unavailable
    final fallbackPrice = backendPrice ?? 0.0;
    debugPrint('💰 Using backend price: ₹${fallbackPrice.toInt()}');

    return {
      'symbol': '₹',
      'value': fallbackPrice,
      'formatted': fallbackPrice.toInt().toString(),
    };
  }
}
