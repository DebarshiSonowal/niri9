import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.name,
    required this.onTap,
    required this.icon,
  });

  final String name;
  final Function onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>onTap(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22.sp,
          ),
          SizedBox(
            height: 1.2.h,
          ),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}