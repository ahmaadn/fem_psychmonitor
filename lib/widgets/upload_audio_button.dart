import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UploadAudioButton extends StatelessWidget {
  const UploadAudioButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Aksi upload audio dari storage
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file_rounded,
            size: 16.sp,
            color: const Color(0xFF6c5a00), // Olive tone sesuai desain
          ),
          SizedBox(width: 8.w),
          Text(
            'Upload Audio',
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
