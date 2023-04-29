import 'package:flutter/material.dart';

import '../../../Models/ott.dart';

class OttItem extends StatelessWidget {
  const OttItem({
    super.key,
    required this.item, required this.onTap,
  });

  final OTT item;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>onTap(),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            item.image!,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}