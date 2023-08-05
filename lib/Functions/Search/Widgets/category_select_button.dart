import 'package:flutter/material.dart';
import 'package:niri9/Models/category.dart';
import 'package:sizer/sizer.dart';

import '../../../Repository/repository.dart';

class CategorySelectButton extends StatelessWidget {
  const CategorySelectButton(
      {super.key,
      this.selectedCategory,
      required this.onChanged,
      required this.data});

  final Category? selectedCategory;
  final Function(Category?) onChanged;
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
        child: DropdownButton<Category>(
          dropdownColor: Colors.black,
          isExpanded: true,
          value: selectedCategory,
          onChanged: (val) => onChanged(val),
          items:
              data.categories.map<DropdownMenuItem<Category>>((Category value) {
            return DropdownMenuItem<Category>(
              value: value,
              child: Text(
                value.name ?? "",
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
