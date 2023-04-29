import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../Models/appbar_option.dart';

class CustomAppbarItem extends StatelessWidget {
  const CustomAppbarItem({
    super.key,
    required this.item,
    required this.index, required this.onTap,
  });

  final int index;
  final AppBarOption item;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>onTap(),
      child: Container(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              (index == 0 || index == 2)
                  ? Image.asset(
                item.image!,
                scale: 16,
                color: Colors.white,
              )
                  : Image.asset(
                item.image!,
                scale: 16,
              ),
              SizedBox(
                height: 0.4.h,
              ),
              Text(
                item.name ?? "",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}