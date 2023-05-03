import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Models/dynamic_list_item_model.dart';
import 'package:niri9/Models/subscription_model.dart';

import '../Models/account_item.dart';
import '../Models/appbar_option.dart';
import '../Models/available_language.dart';
import '../Models/ott.dart';

class Repository extends ChangeNotifier {
  int _currentIndex = 0;
  List<AppBarOption> appbarOptions = [
    AppBarOption(
      name: "All",
      image: Assets.allImage,
    ),
    AppBarOption(
      name: "Movies",
      image: Assets.movieImage,
    ),
    AppBarOption(
      name: "Web Series",
      image: Assets.webSeriesImage,
    ),
    AppBarOption(
      name: "Film Festival",
      image: Assets.filmImage,
    ),
    AppBarOption(
      name: "Videos",
      image: Assets.videoImage,
    ),
    AppBarOption(
      name: "More",
      image: Assets.moreImage,
    ),
  ];
  List<AppBarOption> appbarOptions2 = [
    AppBarOption(
      name: "All",
      image: Assets.allImage,
    ),
    AppBarOption(
      name: "Movies",
      image: Assets.movieImage,
    ),
    AppBarOption(
      name: "Web Series",
      image: Assets.webSeriesImage,
    ),
    AppBarOption(
      name: "Film Festival",
      image: Assets.filmImage,
    ),
    AppBarOption(
      name: "Videos",
      image: Assets.videoImage,
    ),
    AppBarOption(
      name: "Less",
      image: Assets.uploadImage,
    ),
  ];
  List<AppBarOption> appbarOptions3 = [
    AppBarOption(
      name: "Web Series",
      image: Assets.webSeriesImage,
    ),
    AppBarOption(
      name: "Movies",
      image: Assets.movieImage,
    ),
    AppBarOption(
      name: "Film Festival",
      image: Assets.filmImage,
    ),
  ];

  List<String> bannerList = [
    Assets.bannerImage,
    Assets.bannerImage,
    Assets.bannerImage,
    Assets.bannerImage,
  ];
  List<AvailableLanguage> languageList = [
    AvailableLanguage(
      name: "অসমীয়া",
      inEnglish: "Assamese",
      id: 0,
      assets: Assets.assameseImage,
    ),
    AvailableLanguage(
      name: "हिंदी",
      inEnglish: "Hindi",
      id: 1,
      assets: Assets.hindiImage,
    ),
    AvailableLanguage(
      name: "भोजपुरी",
      inEnglish: "Bhojpuri",
      id: 2,
      assets: Assets.bhojpuriImage,
    ),
  ];
  List<DynamicListItemModel> dynamicList = [
    DynamicListItemModel(
      title: "Recently Added | Rent Now",
      list: [
        OTT(id: 0, image: Assets.itemImage),
        OTT(id: 1, image: Assets.item2Image),
        OTT(id: 2, image: Assets.item3Image),
        OTT(id: 3, image: Assets.itemImage),
        OTT(id: 4, image: Assets.item2Image),
        OTT(id: 5, image: Assets.item3Image),
      ],
    ),
    DynamicListItemModel(
      title: "TOP 10 WEB SERIES",
      list: [
        OTT(id: 0, image: Assets.itemImage),
        OTT(id: 1, image: Assets.item2Image),
        OTT(id: 2, image: Assets.item3Image),
        OTT(id: 3, image: Assets.itemImage),
        OTT(id: 4, image: Assets.item2Image),
        OTT(id: 5, image: Assets.item3Image),
      ],
    ),
  ];

  List<OTT> selectedCategory = [
    OTT(id: 0, image: Assets.itemImage),
    OTT(id: 1, image: Assets.item2Image),
    OTT(id: 2, image: Assets.item3Image),
    OTT(id: 3, image: Assets.itemImage),
    OTT(id: 4, image: Assets.item2Image),
    OTT(id: 5, image: Assets.item3Image),
    OTT(id: 6, image: Assets.itemImage),
    OTT(id: 7, image: Assets.item2Image),
    OTT(id: 8, image: Assets.item3Image),
    OTT(id: 9, image: Assets.itemImage),
    OTT(id: 9, image: Assets.item2Image),
    OTT(id: 9, image: Assets.itemImage),
    OTT(id: 9, image: Assets.item3Image),
    OTT(id: 9, image: Assets.itemImage),
    OTT(id: 9, image: Assets.item2Image),
  ];

  List<SubscriptionModel> subscriptions = [
    SubscriptionModel(
      "Status",
      "Active",
    ),
    SubscriptionModel(
      "Pack Country",
      "India",
    ),
    SubscriptionModel(
      "Payment Mode",
      "crm",
    ),
    SubscriptionModel(
      "Expiry Date",
      "04 Jun 2023",
    ),
  ];

  List<AccountItem> items = [
    AccountItem(
      name: "My Account",
      icon: Icons.person,
    ),
    AccountItem(
      name: "Notification Inbox",
      icon: Icons.notifications,
    ),
    AccountItem(
      name: "Upgrade",
      icon: FontAwesomeIcons.crown,
    ),
    AccountItem(
      name: "Activate TV",
      icon: Icons.tv,
    ),
    AccountItem(
      name: "Terms of Use",
      icon: FontAwesomeIcons.fileContract,
    ),
    AccountItem(
      name: "Privacy Policy",
      icon: Icons.privacy_tip_rounded,
    ),
    AccountItem(
      name: "Help & FAQ's",
      icon: Icons.help,
    ),
    AccountItem(
      name: "Chat With Us",
      icon: FontAwesomeIcons.whatsapp,
    ),
    AccountItem(
      name: "Sign Out",
      icon: FontAwesomeIcons.signOut,
    ),
  ];

  void updateIndex(int val) {
    _currentIndex = val;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;

// get int index
}
