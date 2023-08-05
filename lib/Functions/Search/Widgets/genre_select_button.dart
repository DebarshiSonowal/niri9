import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../Models/genres.dart';
import '../../../Repository/repository.dart';

class GenreSelectButton extends StatelessWidget {
  const GenreSelectButton({super.key, required this.selectedGenre, required this.onChanged, required this.data});
  final Genres? selectedGenre;
  final Function(Genres?) onChanged;
  final Repository data;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      padding: EdgeInsets.symmetric(horizontal: 1.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Genres>(
          dropdownColor: Colors.black,
          isExpanded: true,
          value: selectedGenre,
          onChanged: (val)=>onChanged(val),
          items: data.genres
              .map<DropdownMenuItem<Genres>>((Genres value) {
            return DropdownMenuItem<Genres>(
              value: value,
              child: Text(
                value.name ?? "",
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(
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
