import 'package:flutter/material.dart';
import 'package:niri9/API/api_provider.dart';
import 'package:niri9/Constants/assets.dart';
import 'package:niri9/Models/film_festival.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Constants/constants.dart';
import '../../Navigation/Navigate.dart';
import '../../Repository/repository.dart';
import '../../Router/routes.dart';
import '../More/Widgets/ottitem.dart';
import 'Widgets/film_festival_appbar.dart';

class FilmFestivalPage extends StatefulWidget {
  const FilmFestivalPage({super.key});

  @override
  State<FilmFestivalPage> createState() => _FilmFestivalPageState();
}

class _FilmFestivalPageState extends State<FilmFestivalPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(17.h),
        child: const FilmFestivalAppbar(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Constants.backgroundColor,
        child: FutureBuilder<List<FilmFestival>?>(
          future: fetchFilmFestival(context),
          builder: (context, _) {
            if (_.hasData && _.data != null) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 5.5.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      // vertical: 1.h,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var item = _.data![index];
                        bool isCurrent = selected == index;
                        return FestivalItem(isCurrent: isCurrent, item: item);
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: 2.w,
                        );
                      },
                      itemCount: _.data!.length,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                    // child: Text("${_.data![selected].videos?.length??0}"),
                  ),
                  SizedBox(
                    width: double.infinity,
                    // height: 20.h,
                    child: GridView.builder(
                      itemCount: _.data![selected].videos!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 0.5.h,
                        childAspectRatio: 9 / 12,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var item = _.data![selected].videos![index];
                        debugPrint("Item: ${item.title ?? ""}");
                        return GestureDetector(
                          onTap: () {
                            Navigation.instance
                                .navigate(Routes.watchScreen, args: item.id);
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // child: Text("${item.title}",),
                            child: Image.network(
                              item.profile_pic!,
                              fit: BoxFit.fill,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            if (_.hasError || _.data == null) {
              return const Center(
                child: Text("Something Went wrong"),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<FilmFestival>?> fetchFilmFestival(context) async {
    final response = await ApiProvider.instance.getFestival(1);
    if (response.success ?? false) {
      return response.result;
    } else {
      return List<FilmFestival>.empty();
    }
  }
}

class FestivalItem extends StatelessWidget {
  const FestivalItem({
    super.key,
    required this.isCurrent,
    required this.item,
  });

  final bool isCurrent;
  final FilmFestival item;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: 27.w,
        decoration: BoxDecoration(
          // color: Color(0xff868686),
          color: isCurrent ? const Color(0xfffdfefe) : const Color(0xff868686),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        child: Center(
          child: Text(
            "${item.name}",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isCurrent ? Colors.black : Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}
