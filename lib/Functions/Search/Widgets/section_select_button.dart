import 'package:flutter/material.dart';
import 'package:niri9/Models/sections.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';

class SectionSelectButton extends StatelessWidget {
  const SectionSelectButton(
      {super.key,
      this.selectedSection,
      required this.onChanged,
      required this.data});

  final Sections? selectedSection;
  final Function(Sections?) onChanged;
  final Repository data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      padding: EdgeInsets.symmetric(horizontal: 1.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Sections>(
          dropdownColor: Colors.black,
          isExpanded: true,
          value: selectedSection,
          onChanged: (val) => onChanged(val),
          items:
              data.sections.map<DropdownMenuItem<Sections>>((Sections value) {
            return DropdownMenuItem<Sections>(
              value: value,
              child: Text(
                value.title ?? "",
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8.sp,
                    ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
