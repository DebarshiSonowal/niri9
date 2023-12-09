import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Helper/storage.dart';
import 'package:niri9/Models/banner.dart';
import 'package:niri9/Models/category.dart';
import 'package:niri9/Models/dynamic_list_item_model.dart';
import 'package:niri9/Models/order_history.dart';
import 'package:niri9/Models/subscription.dart';
import 'package:niri9/Models/subscription_model.dart';
import 'package:niri9/Models/video.dart';
import 'package:niri9/Models/video_details.dart';

import '../Models/account_item.dart';
import '../Models/appbar_option.dart';
import '../Models/available_language.dart';
import '../Models/genres.dart';
import '../Models/languages.dart';
import '../Models/ott.dart';
import '../Models/plan_pricing.dart';
import '../Models/sections.dart';
import '../Models/series_episode_details.dart';
import '../Models/types.dart';
import '../Models/user.dart';

class Repository extends ChangeNotifier {
  int _currentIndex = 0;
  List<Category> _categories = [];
  List<Video> _specificVideos = [], _rental = [];
  List<AppBarOption> _appbarOptions = [];
  List<BannerResult> homeBanner = [], trendingBanner = [];
  List<OrderHistoryItem> orders = [];
  User? _user;
  List<List<Video>> _videos = [];
  int? currentVideoId;
  String _faq = "",
      _refundPolicy = "",
      _privacyPolicy = "",
      _help_center = "",
      _termsConditions = "";

  List<AppBarOption> get appbarOptions => _appbarOptions;

  List<List<VideoDetails>> currentSeasons = [];
  Video? videoDetails;
  List<Subscription> subscriptions = [];
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

  // List<SubscriptionModel> subscriptions = [
  //   SubscriptionModel(
  //     "Status",
  //     "Active",
  //   ),
  //   SubscriptionModel(
  //     "Pack Country",
  //     "India",
  //   ),
  //   SubscriptionModel(
  //     "Payment Mode",
  //     "crm",
  //   ),
  //   SubscriptionModel(
  //     "Expiry Date",
  //     "04 Jun 2023",
  //   ),
  // ];

  List<AccountItem> items = [
    AccountItem(
      name: "My Account",
      icon: Icons.person,
    ),
    AccountItem(
      name: "Subscription",
      icon: Icons.subscriptions,
    ),
    AccountItem(
      name: "Orders",
      icon: FontAwesomeIcons.boxArchive,
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
      name: "Refund Policy",
      icon: Icons.help,
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
      name: Storage.instance.isLoggedIn ? "Sign Out" : "Sign In",
      icon: FontAwesomeIcons.signOut,
    ),
  ];

  List<PlanPricing> plans = [
    PlanPricing(true, false, false, 1, "HD 720P", "299", "Mobile"),
    PlanPricing(true, true, false, 2, "HD 1080P", "499", "Gold"),
    PlanPricing(true, true, true, 4, "HD 1080P", "599", "Premium"),
  ];

  List<Sections> _homeSections = [], _trendingSections = [];

  List<Genres> _genres = [];

  List<Language> _languages = [];

  List<Types> _types = [];

  String? _about, _privacy, _terms, _refund;

  void setFaq(String val) {
    _faq = val;
    notifyListeners();
  }

  void setUser(User val) {
    _user = val;
    notifyListeners();
  }

  void setHelp(String s) {
    _help_center = s;
    notifyListeners();
  }

  void setTermsConditions(String val) {
    _termsConditions = val;
    notifyListeners();
  }

  void setRefund(String val) {
    _refundPolicy = val;
    notifyListeners();
  }
void setVideo(int val) {
  currentVideoId = val;
    notifyListeners();
  }

  void setPrivacy(String val) {
    _privacyPolicy = val;
    notifyListeners();
  }

  void setVideoDetails(Video? details) {
    videoDetails = details;
    notifyListeners();
  }

  void setSeasons(List<List<VideoDetails>> list) {
    currentSeasons = list;
    notifyListeners();
  }
  void addSeasons(List<VideoDetails> list) {
    currentSeasons.add(list);
    debugPrint("List added ${list.length}");
    notifyListeners();
  }

  void setCategories(List<Category> list) {
    _appbarOptions = list
        .map((e) =>
            AppBarOption(name: e.name ?? "", image: e.profile_icon ?? ""))
        .toList();
    _categories = list;
    notifyListeners();
  }

  void setVideos(List<Video> list) {
    _videos.add(list);
    notifyListeners();
  }

  void setSearchVideos(List<Video> list) {
    _specificVideos = list;
    notifyListeners();
  }

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

  void addHomeSections(List<Sections> list) {
    _homeSections = list;
    debugPrint("`addHomeSections ${list}");
    notifyListeners();
  }

  void addTrendingSections(List<Sections> list) {
    _trendingSections = list;
    debugPrint("`addTrendingSections ${list}");
    notifyListeners();
  }

  void addLanguages(List<Language> list) {
    _languages = list;
    notifyListeners();
  }

  void addHomeBanner(List<BannerResult> list) {
    homeBanner = list;
    notifyListeners();
  }

  void addTrendingBanner(List<BannerResult> list) {
    trendingBanner = list;
    notifyListeners();
  }

  void setOrders(List<OrderHistoryItem> list) {
    orders = list;
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

  void addRental(List<Video> videos) {
    _rental = videos;
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

  List<Sections> get homeSections => _homeSections;

  List<Sections> get trendingSections => _trendingSections;

  List<List<Video>> get videos => _videos;

  List<Category> get categories => _categories;

  List<Video> get specificVideos => _specificVideos;

  String get refundPolicy => _refundPolicy;

  String get faq => _faq;

  String get termsConditions => _termsConditions;

  String get privacyPolicy => _privacyPolicy;

  get help_center => _help_center;

  User? get user => _user;

  get rental => _rental;

  void addSubscriptions(SubscriptionResponse response) {
    subscriptions = response.subscriptions;
    notifyListeners();
  }

// get int index
}
