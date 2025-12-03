import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Models/account_item.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constants/assets.dart';
import '../../Helper/storage.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 8.h,
        title: Row(
          children: [
            Image.asset(
              Assets.logoTransparent,
              height: 5.h,
              width: 10.w,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 3.w),
            Text(
              "Account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (Storage.instance.isLoggedIn) {
                Navigation.instance.navigate(Routes.profileUpdateScreen);
              } else {
                Navigation.instance.navigate(Routes.loginScreen, args: "");
              }
            },
            icon: Icon(
              FontAwesomeIcons.userEdit,
              color: Colors.white,
              size: 5.w,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          // User Profile Section
          Container(
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 15.w,
                  width: 15.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade600,
                        Colors.red.shade800,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Storage.instance.isLoggedIn
                            ? "Welcome back!"
                            : "Guest User",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        Storage.instance.isLoggedIn
                            ? "Manage your account settings"
                            : "Sign in to access all features",
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!Storage.instance.isLoggedIn)
                  GestureDetector(
                    onTap: () {
                      Navigation.instance
                          .navigate(Routes.loginScreen, args: "");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade600,
                            Colors.red.shade800,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Consumer<Repository>(builder: (context, data, _) {
                return ListView.builder(
                  itemCount: data.items.length,
                  itemBuilder: (context, index) {
                    var item = data.items[index];
                    if (item.name == "Activate TV") {
                      return const SizedBox.shrink();
                    }
                    if (item.name == "Delete Account" &&
                        !Storage.instance.isLoggedIn) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () => onTap(index, item),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        leading: Container(
                          height: 12.w,
                          width: 12.w,
                          decoration: BoxDecoration(
                            color:
                                _getIconColor(item.name ?? "").withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: _getIconColor(item.name ?? ""),
                            size: 6.w,
                          ),
                        ),
                        title: Text(
                          ((item.name ?? "") == "Sign In" ||
                                  (item.name ?? "") == "Sign Out")
                              ? (Storage.instance.isLoggedIn
                                  ? "Sign Out"
                                  : "Sign In")
                              : (item.name ?? ""),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        trailing: item.name == "Delete Account" && _isDeleting
                            ? SizedBox(
                                height: 3.h,
                                width: 3.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade400,
                                size: 4.w,
                              ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Color _getIconColor(String itemName) {
    switch (itemName) {
      case "My Account":
        return Colors.red.shade400;
      case "My List":
        return Colors.red.shade400;
      case "Subscription":
        return Colors.red.shade400;
      case "Orders":
        return Colors.red.shade400;
      case "Upgrade":
        return Colors.red.shade400;
      case "Terms of Use":
        return Colors.red.shade400;
      case "Privacy Policy":
        return Colors.red.shade400;
      case "Refund Policy":
        return Colors.red.shade400;
      case "Help & FAQ's":
        return Colors.red.shade400;
      case "About":
        return Colors.red.shade400;
      case "Chat With Us":
        return Colors.red.shade400;
      case "Sign Out":
      case "Sign In":
        return Colors.red.shade400;
      default:
        return Colors.white;
    }
  }

  Future<void> onTap(int index, AccountItem item) async {
    switch (index) {
      case 0:
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.profile);
        } else {
          Navigation.instance.navigate(Routes.loginScreen, args: "");
        }
        break;
      case 1:
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.watchlistScreen);
        } else {
          Navigation.instance.navigate(Routes.loginScreen, args: "");
        }
        break;
      case 2:
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.subscriptionScreen);
        } else {
          Navigation.instance.navigate(Routes.loginScreen, args: "");
        }
        break;
      case 3:
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.orderHistory);
        } else {
          Navigation.instance.navigate(Routes.loginScreen, args: "");
        }
        break;
      case 4:
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.subscriptionScreen);
        } else {
          Navigation.instance.navigate(Routes.loginScreen, args: "sub");
        }
        break;
      case 5:
        // Navigation.instance.navigate(Routes.activateTV);
        break;
      case 6:
        // _launchUrl(Uri.parse("https://niri9.com/terms-condition.php"));
        Navigation.instance.navigate(Routes.termsConditionsScreen);
        break;
      case 7:
        // _launchUrl(Uri.parse("https://niri9.com/privacy_policy.php"));
        Navigation.instance.navigate(Routes.privacyPolicyScreen);
        break;
      case 8:
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.refundScreen);
        } else {
          Navigation.instance.navigate(Routes.loginScreen, args: "");
        }
        break;
      case 9:
        Navigation.instance.navigate(Routes.helpFaqScreen);
        break;
      case 10:
        Navigation.instance.navigate(Routes.aboutScreen);
        break;
      case 11:
        _launchUrl(Uri.parse("whatsapp://send?phone=+919864000253"));
        break;
      case 12:
        if (_isDeleting) return;
        _showDeleteAccountDialog();
        break;
      case 13:
        if (Storage.instance.isLoggedIn) {
          await Storage.instance.logout();
          setState(() {});
          final response =
              await Navigation.instance.navigate(Routes.homeScreen);
          Provider.of<Repository>(context, listen: false).updateIndex(0);
          if (response == null) {
            setState(() {});
          }
          break;
        } else {
          Navigation.instance.navigate(Routes.loginScreen, args: "");
        }
        break;
      default:
        break;
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            "Delete Account",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: const Text(
            "Are you sure you want to delete your Niri9 account? This action cannot be undone.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                _deleteAccount();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await ApiProvider.instance.deleteAccount();
      if (!mounted) return;
      if (response.success ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Account deleted successfully"),
          ),
        );
        await Storage.instance.logout();
        Provider.of<Repository>(context, listen: false).updateIndex(0);
        setState(() {});
        Navigation.instance.navigateAndRemoveUntil(Routes.homeScreen);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response.message ?? "Unable to delete account right now"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Please try again later."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(
      _url,
    )) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // fetchData(context);
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.accountScreen);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure correct navigation index when coming back to account screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomBottomNavBar.ensureCorrectIndex(context, Routes.accountScreen);
    });
  }
}
