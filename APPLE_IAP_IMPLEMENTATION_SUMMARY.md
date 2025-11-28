# Apple In-App Purchase Implementation Summary

## Overview

This document summarizes the implementation of Apple In-App Purchases as an alternative payment
method alongside the existing Razorpay gateway in the Niri9 app.

## Files Modified/Added

1. **lib/Services/apple_iap_service.dart**
    - Created a service class to handle Apple IAP initialization, product loading, and purchase flow
    - Added mapping between backend subscription IDs and Apple product IDs
    - Implemented purchase verification with the backend

2. **lib/Functions/SubscriptionPage/subscription_page.dart**
    - Added UI to select between Razorpay and Apple payment methods on iOS
    - Implemented loading states for payment options
    - Integrated AppleIAPService for handling purchases

3. **lib/Models/payment_gateway.dart**
    - Added support for product mappings in the PaymentGateway model
    - Added new fields to support Apple IAP configuration

4. **lib/Helper/storage.dart**
    - Added userId getter for tracking IAP purchases
    - Added methods to store and retrieve user ID

5. **lib/main.dart**
    - Added initialization of AppleIAPService at app startup on iOS devices

6. **ios/Runner/Info.plist**
    - Added StoreKit configuration for IAP support
    - Added SKAdNetworkItems for attribution

7. **APPLE_IAP_INTEGRATION_GUIDE.md**
    - Enhanced with detailed step-by-step instructions for App Store Connect setup
    - Added sandbox testing guide
    - Added StoreKit testing instructions

## How It Works

### User Flow

1. User opens the subscription page
2. On iOS, user taps the "Upgrade" button
3. User is shown payment method options (Razorpay or Apple Pay)
4. If user selects Apple Pay:
    - App initiates order with the backend to get a voucher number
    - App starts the StoreKit purchase flow
    - User completes purchase with their Apple ID
    - App verifies purchase receipt with the backend
    - Backend validates receipt with Apple servers
    - On successful validation, user's subscription is activated

### Technical Flow

1. **Initialization:**
    - `main.dart` initializes AppleIAPService on iOS devices
    - Products are pre-loaded when possible

2. **Product Configuration:**
    - Products are configured in App Store Connect with specific IDs
    - Backend maintains mapping between subscription IDs and product IDs

3. **Purchase Process:**
    - App calls `initiateOrder()` to get a voucher number from backend
    - App calls `AppleIAPService.buySubscription()` with the product details
    - In-App Purchase API shows the Apple payment sheet
    - After purchase, receipt data is sent to backend via `verifyApplePayment()`
    - Backend validates receipt with Apple's verification endpoints
    - Backend activates subscription and returns success to app

## Backend Configuration

The backend API now supports:

- Receipt verification with Apple servers
- Mapping between subscription plans and Apple product IDs
- Processing subscription activations from Apple purchases

## Testing

For testing Apple IAP:

1. Create sandbox tester accounts in App Store Connect
2. Use sandbox accounts to make purchases in development builds
3. For faster testing, use StoreKit Configuration files in Xcode

## Troubleshooting

Common issues:

1. Products not appearing: Ensure products are properly configured in App Store Connect and ready to
   submit
2. Payment failing: Check sandbox account status and receipt verification
3. Verification errors: Check that shared secret is correctly configured in backend

## Next Steps

1. Monitor subscription renewals and expirations via Apple server notifications
2. Implement subscription management UI for users to view and manage their Apple subscriptions
3. Add support for subscription upgrades/downgrades via Apple IAP
4. Consider adding family sharing support for subscriptions