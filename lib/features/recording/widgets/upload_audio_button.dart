import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadAudioButton extends StatelessWidget {
  final VoidCallback onTap;

  const UploadAudioButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file_rounded,
            size: 16.sp,
            color: const Color(0xFF6c5a00),
          ),
          SizedBox(width: 8.w),
          Text(
            AppLocalizations.of(context)!.uploadAudio,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6c5a00),
            ),
          ),
        ],
      ),
    );
  }
}
