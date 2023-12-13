import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sizer/sizer.dart';

import '../../API/api_provider.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../HomeScreen/Widgets/dynamic_list_item.dart';
import '../HomeScreen/Widgets/ott_item.dart';

class LanguageSelectedPage extends StatefulWidget {
  const LanguageSelectedPage({super.key, required this.language});
  final String language;
  @override
  State<LanguageSelectedPage> createState() => _LanguageSelectedPageState();
}

class _LanguageSelectedPageState extends State<LanguageSelectedPage> {  final ScrollController _scrollController = ScrollController();
final RefreshController _refreshController =
RefreshController(initialRefresh: true);
int page=1;

@override
void initState() {
  super.initState();
  _scrollController.addListener(() {
    if (_refreshController.position?.atEdge??false) {
      bool isTop = _refreshController.position?.pixels == 0;
      if (isTop) {
        _refreshController.requestRefresh();
      } else {
        // print('At the bottom');
        _refreshController.requestLoading();
      }
    }
  });
}
void _onRefresh() async {
  setState(() {
    page = 1;
  });
  // monitor network fetch
  fetchVideos(context);
  // if failed,use refreshFailed()
}

void _onLoading() async {
  // monitor network fetch
  // await Future.delayed(Duration(milliseconds: 1000));
  // // if failed,use loadFailed(),if no data return,use LoadNodata()
  // items.add((items.length+1).toString());
  // if(mounted)
  //   setState(() {
  //
  //   });
  setState(() {
    page++;
  });
  fetchVideos(context);
}
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar:PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: CategorySpecificAppbar(searchTerm: widget.language)),
    body: Container(
      height: double.infinity,
      width: double.infinity,
      color: Constants.backgroundColor,
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = const CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = const Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("release to load more");
            } else {
              body = Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: Consumer<Repository>(builder: (context, data, _) {
          return SizedBox(
            height: 100.h,
            width: double.infinity,
            child: Consumer<Repository>(builder: (context, data, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var item = data.languageSections[index];
                  return DynamicListItem(
                    text: item.title ?? "",
                    list: item.videos ?? [],
                    onTap: () {
                      Navigation.instance.navigate(Routes.moreScreen,args: 0);
                    },
                  );
                },
                itemCount:data.languageSections.length,
              );
            }),
          );
        }),
      ),
    ),
  );
}

fetchVideos(context) async {
  Navigation.instance.navigate(Routes.loadingScreen);
  final response = await ApiProvider.instance.getSections("language","$page");
  if (response.status??false){
    Navigation.instance.goBack();
    _refreshController.refreshCompleted();
    Provider.of<Repository>(context,listen: false).addLanguageSections(response.sections??[]);
  } else {
    Navigation.instance.goBack();
    _refreshController.refreshCompleted();
    // showError(response.message ?? "Something went wrong");
  }
}
}

class CategorySpecificAppbar extends StatelessWidget {
  const CategorySpecificAppbar({
    super.key,
    required this.searchTerm,
  });

  final String searchTerm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 5.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigation.instance.goBack();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
                // SizedBox(
                //   width: 5.w,
                // ),
                Text(
                  searchTerm.capitalize(),
                  style:
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 15.sp,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                Container()
              ],
            ),
          ),
        ],
      ),
    );
  }
}


