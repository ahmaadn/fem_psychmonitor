import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool micGranted = false;
  bool storageGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final mic = await Permission.microphone.status;
    final storage = await Permission.storage.status;
    setState(() {
      micGranted = mic.isGranted;
      storageGranted = storage.isGranted;
    });
  }

  Future<void> _requestAll() async {
    final mic = await Permission.microphone.request();
    final storage = await Permission.storage.request();
    setState(() {
      micGranted = mic.isGranted;
      storageGranted = storage.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = micGranted && storageGranted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Permissions', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                'Izin Mikrofon & Privasi',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 12.h),
              Text(
                'Aplikasi membutuhkan akses mikrofon untuk merekam suara Anda dan menyimpan data rekaman secara lokal. Data digunakan hanya untuk analisis emosi.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 24.h),

              _permissionTile(
                icon: Icons.mic_rounded,
                title: 'Mikrofon',
                subtitle: micGranted ? 'Diizinkan' : 'Tidak Diizinkan',
                granted: micGranted,
                onTap: () async {
                  final res = await Permission.microphone.request();
                  setState(() => micGranted = res.isGranted);
                },
              ),
              SizedBox(height: 12.h),
              _permissionTile(
                icon: Icons.folder_rounded,
                title: 'Penyimpanan',
                subtitle: storageGranted ? 'Diizinkan' : 'Tidak Diizinkan',
                granted: storageGranted,
                onTap: () async {
                  final res = await Permission.storage.request();
                  setState(() => storageGranted = res.isGranted);
                },
              ),

              SizedBox(height: 24.h),
              PrimaryButton(
                text: allGranted ? 'Mulai Rekaman' : 'Minta Izin',
                onPressed: allGranted
                    ? () {
                        context.goNamed(RouteNames.liveRecording);
                      }
                    : _requestAll,
              ),
              SizedBox(height: 12.h),
              SecondaryButton(
                text: 'Lewati Sementara',
                icon: Icons.skip_next,
                onPressed: () {
                  context.goNamed(RouteNames.liveRecording);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.outline),
      ),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Icon(
        granted ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
        color: granted ? AppColors.secondary : AppColors.textSecondary,
      ),
    );
  }
}
