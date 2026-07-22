import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
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
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final allGranted = micGranted && storageGranted;

    return Scaffold(
      backgroundColor: p.canvas,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: l10n.permissionsTitle, showBackButton: true),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: p.canvasGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Text(
                  l10n.microphonePrivacy,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: p.ink,
                      ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.appNeedsMicAccess,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: p.inkMuted,
                      ),
                ),
                SizedBox(height: 24.h),
                _permissionTile(
                  icon: Icons.mic_rounded,
                  title: l10n.microphone,
                  subtitle: micGranted ? l10n.granted : l10n.notGranted,
                  granted: micGranted,
                  onTap: () async {
                    final res = await Permission.microphone.request();
                    setState(() => micGranted = res.isGranted);
                  },
                ),
                SizedBox(height: 12.h),
                _permissionTile(
                  icon: Icons.folder_rounded,
                  title: l10n.storage,
                  subtitle: storageGranted ? l10n.granted : l10n.notGranted,
                  granted: storageGranted,
                  onTap: () async {
                    final res = await Permission.storage.request();
                    setState(() => storageGranted = res.isGranted);
                  },
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  text:
                      allGranted ? l10n.startRecording : l10n.requestPermission,
                  onPressed: allGranted
                      ? () {
                          context.goNamed(RouteNames.liveRecording);
                        }
                      : _requestAll,
                ),
                SizedBox(height: 12.h),
                SecondaryButton(
                  text: l10n.skipForNow,
                  icon: Icons.skip_next,
                  onPressed: () {
                    context.goNamed(RouteNames.liveRecording);
                  },
                ),
              ],
            ),
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
    final p = context.palette;
    return ListTile(
      onTap: onTap,
      tileColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        side: BorderSide(color: p.hairline),
      ),
      leading: Icon(icon, color: p.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Icon(
        granted ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
        color: granted ? p.secondary : p.inkMuted,
      ),
    );
  }
}
