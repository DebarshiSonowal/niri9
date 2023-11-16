import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:niri9/Constants/constants.dart';
import 'package:niri9/Models/ott.dart';
import 'package:niri9/Repository/repository.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'Widgets/ottitem.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key, required this.section}) : super(key: key);
  final String section;

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section.replaceAll("-", " ").capitalize(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      backgroundColor: Constants.backgroundColor,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 2.w,
          vertical: 1.h,
        ),
        child: Consumer<Repository>(builder: (context, data, _) {
          return GridView.builder(
            itemCount: data.selectedCategory.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 0.5.h,
              childAspectRatio: 9 / 12,
            ),
            itemBuilder: (BuildContext context, int index) {
              var item = data.selectedCategory[index];
              return OttItem(item: item, onTap: () {});
            },
          );
        }),
      ),
    );
  }
}
