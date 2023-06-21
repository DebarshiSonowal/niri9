import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Models/dynamic_list_item_model.dart';
import 'package:niri9/Models/subscription_model.dart';

import '../Models/account_item.dart';
import '../Models/appbar_option.dart';
import '../Models/available_language.dart';
import '../Models/genres.dart';
import '../Models/languages.dart';
import '../Models/ott.dart';
import '../Models/plan_pricing.dart';
import '../Models/sections.dart';
import '../Models/types.dart';

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

  List<DynamicListItemModel> premiumList = [
    DynamicListItemModel(
      title: "Top 10 in India",
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
  List<DynamicListItemModel> premiumOthersList = [
    DynamicListItemModel(
      title: "Movies that are top rated",
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
      title: "Fresh Arrival",
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
      name: "About",
      icon: Icons.info,
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

  List<PlanPricing> plans = [
    PlanPricing(true, false, false, 1, "HD 720P", "299", "Mobile"),
    PlanPricing(true, true, false, 2, "HD 1080P", "499", "Gold"),
    PlanPricing(true, true, true, 4, "HD 1080P", "599", "Premium"),
  ];

  List<Sections> _sections = [];

  List<Genres> _genres = [];

  List<Language> _languages = [];

  List<Types> _types = [];

  String? _about, _privacy, _terms, _refund;

  void updateIndex(int val) {
    _currentIndex = val;
    notifyListeners();
  }

  void updateAbout(String val) {
    _about = val;
    notifyListeners();
  }

  void updatePrivacy(String val) {
    _privacy = val;
    notifyListeners();
  }

  void updateTerms(String val) {
    _terms = val;
    notifyListeners();
  }

  void updateRefund(String val) {
    _refund = val;
    notifyListeners();
  }

  void addSections(List<Sections> list) {
    _sections = list;
    debugPrint("`addSections ${list}");
    notifyListeners();
  }

  void addLanguages(List<Language> list) {
    _languages = list;
    notifyListeners();
  }

  void addTypes(List<Types> list) {
    _types = list;
    notifyListeners();
  }

  void addGenres(List<Genres> list) {
    _genres = list;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;

  get refund => _refund;

  get terms => _terms;

  get privacy => _privacy;

  get about => _about;

  List<Types> get types => _types;

  List<Language> get languages => _languages;

  List<Genres> get genres => _genres;

  List<Sections> get sections => _sections;

// get int index
}
