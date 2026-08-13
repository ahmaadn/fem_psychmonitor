import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileMenuGroup extends StatelessWidget {
  final List<Widget> items;

  const ProfileMenuGroup({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
      clipBehavior: Clip.hardEdge,
      decoration: p.card(),
      child: Column(children: items),
    );
  }
}
