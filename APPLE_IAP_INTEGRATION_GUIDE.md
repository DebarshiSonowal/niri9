# Apple In-App Purchase Integration Guide

## Overview

This guide explains how to integrate Apple In-App Purchases as an alternative payment method for the
Niri9 app, alongside the existing Razorpay gateway.

## Table of Contents

1. [App Store Connect Setup](#app-store-connect-setup)
2. [Flutter App Implementation](#flutter-app-implementation)
3. [Laravel Backend Implementation](#laravel-backend-implementation)
4. [Testing](#testing)
5. [Troubleshooting](#troubleshooting)

## App Store Connect Setup

### Prerequisites

- Apple Developer Account with App Store Connect access
- Existing iOS app registered in App Store Connect
- App Bundle ID (e.g., `com.niri9.app`)

### Steps

1. **Enable In-App Purchase Capability**

    - Log in to your [Apple Developer Account](https://developer.apple.com/account)
    - Go to "Certificates, Identifiers & Profiles"
    - Select your app's identifier
    - Check the "In-App Purchase" capability
    - Save the changes

2. **Create In-App Purchase Products**

    - Log in to [App Store Connect](https://appstoreconnect.apple.com/)
    - Navigate to "My Apps" and select your app
    - Go to the "Features" tab and select "In-App Purchases"
    - Click the "+" button to add a new In-App Purchase
    - For subscriptions, choose "Auto-Renewable Subscription"
    - Create subscription groups if needed

3. **Configure Products**

   For each subscription plan (e.g., monthly, yearly), configure:

    - Reference Name (for your internal use)
    - Product ID (e.g., `com.niri9.subscription.monthly`, `com.niri9.subscription.yearly`)
    - Subscription duration
    - Price tier
    - Localization details (title, description)
    - Review information

4. **Set Up Server-to-Server Notifications**

    - In App Store Connect, go to "App Information"
    - Under "App-Specific Shared Secret", generate a shared secret for verifying receipts
    - Save this secret securely for your backend

### Detailed Instructions for Creating Subscription Products

1. **Create a Subscription Group**

    - In App Store Connect, select "In-App Purchases"
    - Click the "+" button, then select "Create a New Subscription Group"
    - Enter a Reference Name (e.g., "Niri9 Subscriptions")
    - Click "Create"

2. **Add Monthly Subscription Product**

    - Click the "+" button again
    - Choose "Auto-Renewable Subscription"
    - Choose the subscription group you created
    - Enter the following details:
        - Reference Name: "Niri9 Monthly Subscription" (internal name)
        - Product ID: `com.niri9.subscription.monthly` (must match what's in the code)
        - Subscription Period: 1 Month
        - Select the appropriate price tier
        - Click "Create"

3. **Add Yearly Subscription Product**

    - Click the "+" button again
    - Choose "Auto-Renewable Subscription"
    - Choose the subscription group you created
    - Enter the following details:
        - Reference Name: "Niri9 Yearly Subscription" (internal name)
        - Product ID: `com.niri9.subscription.yearly` (must match what's in the code)
        - Subscription Period: 1 Year
        - Select the appropriate price tier
        - Click "Create"

4. **Configure Localization for Each Product**

    - Click on your product
    - Under "Localizations", click "Add Language"
    - Fill in:
        - Name: The name users will see (e.g., "Niri9 Monthly Plan")
        - Description: A description of the benefits (e.g., "Full access to Niri9 for one month")
        - Add a promotional image if needed
    - Click "Save"

5. **Configure Review Information**

    - Under "Review Information", add details that will help Apple's review team understand your
      subscription
    - Include test account credentials and any special instructions
    - Click "Save"

6. **Submit for Review**

    - Once all details are complete, change the status to "Ready to Submit"
    - The product will be reviewed when you submit your app update

7. **Important:** Products in development can be tested with Sandbox accounts, even before they're
   approved by Apple.

### Setting Up Sandbox Testing

1. **Create Sandbox Testers**

    - In App Store Connect, go to "Users and Access"
    - Click on "Sandbox" in the sidebar
    - Click "+" to add a tester
    - Enter a unique email address that is NOT associated with an Apple ID
    - Fill in the required details
    - Click "Create"

2. **Testing on Device**

    - Sign out of your Apple ID on your device
    - When making a purchase in your test app, you'll be prompted to sign in
    - Use your sandbox tester credentials
    - Sandbox purchases will not incur real charges

### StoreKit Testing in Xcode

For faster testing, you can use StoreKit Configuration files in Xcode:

1. Open your project in Xcode
2. Go to File > New > File, select "StoreKit Configuration File"
3. Add your products with the same IDs used in App Store Connect
4. In your scheme settings, enable StoreKit Configuration
5. Run the app in debug mode to test IAP without needing App Store Connect

## Flutter App Implementation

The following files have been added/modified in the Flutter app:

1. Added `in_app_purchase` package to `pubspec.yaml`
2. Created `lib/Services/apple_iap_service.dart` for handling IAP transactions
3. Updated `lib/Models/payment_gateway.dart` to include Apple IAP
4. Updated `lib/API/api_provider.dart` with verification method
5. Modified `lib/Functions/SubscriptionPage/subscription_page.dart` to show payment options
6. Updated `ios/Runner/Info.plist` with StoreKit configuration

## Laravel Backend Implementation

Implement the following components in your Laravel backend:

### 1. Create Migration for Apple IAP Configuration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Add Apple IAP config to payment gateways table or create new table
        Schema::table('payment_gateways', function (Blueprint $table) {
            $table->boolean('apple_iap_enabled')->default(false);
            $table->string('apple_shared_secret')->nullable();
        });
        
        // Create table for IAP product mapping
        Schema::create('apple_iap_products', function (Blueprint $table) {
            $table->id();
            $table->string('product_id')->unique(); // e.g. com.niri9.subscription.monthly
            $table->unsignedBigInteger('subscription_id'); // Link to your subscription plan
            $table->string('type')->default('subscription'); // subscription or consumable
            $table->timestamps();
            
            $table->foreign('subscription_id')
                  ->references('id')
                  ->on('subscriptions')
                  ->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::table('payment_gateways', function (Blueprint $table) {
            $table->dropColumn(['apple_iap_enabled', 'apple_shared_secret']);
        });
        
        Schema::dropIfExists('apple_iap_products');
    }
};
```

### 2. Create Apple IAP Product Model

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AppleIAPProduct extends Model
{
    protected $table = 'apple_iap_products';
    
    protected $fillable = [
        'product_id',
        'subscription_id',
        'type'
    ];
    
    public function subscription()
    {
        return $this->belongsTo(Subscription::class);
    }
}
```

### 3. Create Apple Receipt Verification Service

```php
<?php

namespace App\Services;

use App\Models\AppleIAPProduct;
use App\Models\Order;
use App\Models\PaymentGateway;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;

class AppleReceiptVerificationService
{
    protected $productionUrl = 'https://buy.itunes.apple.com/verifyReceipt';
    protected $sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
    protected $sharedSecret;
    
    public function __construct()
    {
        $paymentGateway = PaymentGateway::where('name', 'apple_iap')->first();
        $this->sharedSecret = $paymentGateway ? $paymentGateway->apple_shared_secret : null;
    }
    
    public function verifyReceipt($receiptData, $orderId, $productId)
    {
        if (!$this->sharedSecret) {
            Log::error('Apple IAP shared secret not configured');
            return [
                'success' => false,
                'message' => 'Apple IAP configuration missing'
            ];
        }
        
        $client = new Client();
        
        // Prepare verification payload
        $payload = [
            'receipt-data' => $receiptData,
            'password' => $this->sharedSecret,
        ];
        
        try {
            // Try production first
            $response = $client->post($this->productionUrl, [
                'json' => $payload
            ]);
            
            $result = json_decode($response->getBody()->getContents(), true);
            
            // If status is 21007, it means this is a sandbox receipt, try sandbox environment
            if (isset($result['status']) && $result['status'] == 21007) {
                $response = $client->post($this->sandboxUrl, [
                    'json' => $payload
                ]);
                
                $result = json_decode($response->getBody()->getContents(), true);
            }
            
            // Check if the receipt is valid
            if (isset($result['status']) && $result['status'] == 0) {
                // Valid receipt - now validate the purchase details
                return $this->validatePurchaseDetails($result, $orderId, $productId);
            } else {
                Log::error('Apple IAP receipt verification failed', $result);
                return [
                    'success' => false,
                    'message' => 'Receipt verification failed: ' . $this->getStatusMessage($result['status']),
                    'data' => $result
                ];
            }
        } catch (\Exception $e) {
            Log::error('Apple IAP receipt verification exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return [
                'success' => false,
                'message' => 'Receipt verification error: ' . $e->getMessage()
            ];
        }
    }
    
    protected function validatePurchaseDetails($result, $orderId, $productId)
    {
        try {
            // For subscriptions, check in-app receipts
            if (isset($result['latest_receipt_info']) && is_array($result['latest_receipt_info'])) {
                $latestReceipt = end($result['latest_receipt_info']);
                
                // Verify this product ID exists in our database
                $product = AppleIAPProduct::where('product_id', $productId)->first();
                
                if (!$product) {
                    return [
                        'success' => false,
                        'message' => 'Unknown product ID: ' . $productId
                    ];
                }
                
                // Get the order from our database
                $order = Order::where('voucher_no', $orderId)->first();
                
                if (!$order) {
                    return [
                        'success' => false,
                        'message' => 'Order not found: ' . $orderId
                    ];
                }
                
                // Now we can mark the order as paid and activate the subscription
                // Update order status, create subscription records, etc.
                // ...
                
                return [
                    'success' => true,
                    'message' => 'Payment verified successfully',
                    'data' => [
                        'transaction_id' => $latestReceipt['transaction_id'] ?? null,
                        'product_id' => $productId,
                        'purchase_date' => $latestReceipt['purchase_date'] ?? null,
                        'subscription_id' => $product->subscription_id
                    ]
                ];
            }
            
            return [
                'success' => false,
                'message' => 'No subscription information found in receipt'
            ];
        } catch (\Exception $e) {
            Log::error('Error validating purchase details', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return [
                'success' => false,
                'message' => 'Error validating purchase: ' . $e->getMessage()
            ];
        }
    }
    
    protected function getStatusMessage($status)
    {
        $messages = [
            0 => 'Success',
            21000 => 'The request to the App Store was not made using the HTTP POST request method',
            21001 => 'This status code is no longer sent by the App Store',
            21002 => 'The data in the receipt-data property was malformed or missing',
            21003 => 'The receipt could not be authenticated',
            21004 => 'The shared secret you provided does not match the shared secret on file for your account',
            21005 => 'The receipt server is currently not available',
            21006 => 'This receipt is valid but the subscription has expired',
            21007 => 'This receipt is from the test environment, but it was sent to the production environment for verification',
            21008 => 'This receipt is from the production environment, but it was sent to the test environment for verification',
            21009 => 'Internal data access error. Try again later',
            21010 => 'The user account cannot be found or has been deleted',
        ];
        
        return $messages[$status] ?? 'Unknown error (status code: ' . $status . ')';
    }
}
```

### 4. Create Controller Endpoint for Apple IAP Verification

```php
<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\AppleReceiptVerificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ApplePaymentController extends Controller
{
    protected $verificationService;
    
    public function __construct(AppleReceiptVerificationService $verificationService)
    {
        $this->verificationService = $verificationService;
    }
    
    public function verifyPayment(Request $request)
    {
        $request->validate([
            'order_id' => 'required|string',
            'product_id' => 'required|string',
            'amount' => 'required|string',
            'receipt_data' => 'required|string',
            'transaction_date' => 'nullable|string',
        ]);
        
        Log::info('Apple IAP verification request', $request->except('receipt_data'));
        
        $result = $this->verificationService->verifyReceipt(
            $request->receipt_data,
            $request->order_id,
            $request->product_id
        );
        
        if ($result['success']) {
            // Payment verified successfully, update order status
            // Activate subscription or deliver purchased content
            // Use your existing order processing logic here
            
            return response()->json([
                'success' => true,
                'message' => 'Payment verified successfully'
            ]);
        } else {
            return response()->json([
                'success' => false,
                'message' => $result['message']
            ], 400);
        }
    }
    
    public function getAppleIAPProducts()
    {
        // Return available Apple IAP products with their mapping to subscription plans
        // This can be used by the app to understand which product ID corresponds to which subscription
        $products = AppleIAPProduct::with('subscription')->get();
        
        return response()->json([
            'success' => true,
            'products' => $products
        ]);
    }
}
```

### 5. Add Routes

In your `routes/api.php` file:

```php
<?php

use App\Http\Controllers\API\ApplePaymentController;
use Illuminate\Support\Facades\Route;

// Apple IAP routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/sales/order/verify-apple-payment', [ApplePaymentController::class, 'verifyPayment']);
    Route::get('/apple-iap/products', [ApplePaymentController::class, 'getAppleIAPProducts']);
});
```

### 6. Add Controller for Admin to Manage Apple IAP Products

Create an admin interface to manage the mapping between Apple IAP product IDs and your subscription
plans. This is important to maintain the connection between App Store products and your backend
subscription logic.

## Testing

### Sandbox Testing

1. **Create Sandbox Testers**
    - In App Store Connect, go to "Users and Access" > "Sandbox" > "Testers"
    - Add a new sandbox tester with a unique email address

2. **Testing in Development**
    - Use a development build of your app
    - Sign out of your Apple ID on the test device
    - When prompted to sign in during purchase, use your sandbox tester account
    - You'll be able to make test purchases without being charged

### Verification

1. **Test End-to-End Flow**
    - Complete a purchase with a sandbox account
    - Verify the receipt is correctly validated by your server
    - Check that subscription is activated in your database
    - Verify user can access premium content

2. **Check Subscription Management**
    - Test renewal dates are correctly calculated
    - Verify subscription expiration works as expected
    - Test subscription upgrade/downgrade flows

## Troubleshooting

### Common Issues

1. **Receipt Verification Fails**
    - Ensure your shared secret is correct
    - Check if you're using the right environment (sandbox vs. production)
    - Verify your receipt-data is properly encoded

2. **Products Not Loading**
    - Ensure products are marked as "Ready to Submit" in App Store Connect
    - Check bundle ID matches between app and App Store Connect
    - Verify In-App Purchase capability is enabled in your app

3. **Sandbox Purchase Issues**
    - Always use a dedicated sandbox tester account
    - Some sandbox accounts may have purchase restrictions
    - Try creating a fresh sandbox tester account

4. **Missing Subscriptions After Purchase**
    - Check server logs for receipt verification errors
    - Ensure your webhook endpoints for subscription notifications are working
    - Verify the correct subscription plan is mapped to the purchased product ID

---

## Additional Resources

- [Apple In-App Purchase Documentation](https://developer.apple.com/documentation/storekit/in-app_purchase)
- [Receipt Validation Programming Guide](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html)
- [Server Notifications for Subscriptions](https://developer.apple.com/documentation/appstoreservernotifications)