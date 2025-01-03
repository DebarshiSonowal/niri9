import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Models/account_item.dart';
import 'package:niri9/Navigation/Navigate.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:niri9/Router/routes.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Constants/assets.dart';
import '../../Constants/constants.dart';
import '../../Helper/storage.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(12.h),
        child: Container(
          color: Constants.backgroundColor,
          child: Column(
            children: [
              SizedBox(
                height: 3.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 4.w,
                  ),
                  Image.asset(
                    Assets.logoTransparent,
                    height: 7.5.h,
                    width: 14.w,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              SizedBox(
                height: 0.1.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 4.w,
                  ),
                  Text(
                    "Account Settings",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    FontAwesomeIcons.pen,
                    color: Colors.white70,
                    size: 13.sp,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Storage.instance.isLoggedIn) {
                        Navigation.instance
                            .navigate(Routes.profileUpdateScreen);
                      } else {
                        Navigation.instance.navigate(Routes.loginScreen);
                      }
                    },
                    child: Text(
                      "Manage Profiles",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 15.sp,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        child: Consumer<Repository>(builder: (context, data, _) {
          return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var item = data.items[index];
              if (item.name == "Activate TV") {
                return Container();
              }
              return ListTile(
                onTap: () {
                  onTap(index, item);
                  // debugPrint("Item");
                },
                leading: Icon(
                  item.icon,
                  color: Colors.white,
                ),
                title: Text(
                  ((item.name ?? "") == "Sign In" ||
                          (item.name ?? "") == "Sign Out")
                      ? (Storage.instance.isLoggedIn ? "Sign Out" : "Sign In")
                      : (item.name ?? ""),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              var item = data.items[index];
              if (item.name == "Activate TV") {
                return Container();
              }
              return Divider(
                thickness: 0.05.h,
                color: Colors.white,
              );
            },
            itemCount: data.items.length,
          );
        }),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Future<void> onTap(int index, AccountItem item) async {
    switch (index) {
      case 0:
        if (Storage.instance.isLoggedIn) {
          Navigation.instance.navigate(Routes.profile);
        } else {
          Navigation.instance.navigate(Routes.loginScreen);
        }
        break;
      case 1:
        Navigation.instance.navigate(Routes.watchlistScreen);
        break;
      case 2:
        Navigation.instance.navigate(Routes.subscriptionScreen);
        break;
      case 3:
        Navigation.instance.navigate(Routes.orderHistory);
        break;
      case 4:
        Navigation.instance.navigate(Routes.notificationInbox);
        break;
      case 5:
        Navigation.instance.navigate(Routes.subscriptionScreen);
        break;
      case 6:
        // Navigation.instance.navigate(Routes.activateTV);
        break;
      case 7:
        // _launchUrl(Uri.parse("https://niri9.com/terms-condition.php"));
        Navigation.instance.navigate(Routes.termsConditionsScreen);
        break;
      case 8:
        // _launchUrl(Uri.parse("https://niri9.com/privacy_policy.php"));
        Navigation.instance.navigate(Routes.privacyPolicyScreen);
        break;
      case 9:
        Navigation.instance.navigate(Routes.refundScreen);
        break;
      case 10:
        Navigation.instance.navigate(Routes.helpFaqScreen);
        break;
      case 11:
        Navigation.instance.navigate(Routes.aboutScreen);
        break;
      case 12:
        _launchUrl(Uri.parse("whatsapp://send?phone=+917002413212"));
        break;
      default:
        await Storage.instance.logout();
        setState(() {});
        final response = await Navigation.instance.navigate(Routes.loginScreen);
        if (response == null) {
          setState(() {});
        }
        break;
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
      Provider.of<Repository>(context, listen: false).updateIndex(4);
    });
  }
}
