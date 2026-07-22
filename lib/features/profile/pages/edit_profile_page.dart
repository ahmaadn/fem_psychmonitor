import 'dart:io';

import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_util;
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;
  // US-04: avatar path. May be an asset path (default) or a copied file path.
  String? _avatarUrl;
  bool _isInitialized = false;
  bool _isPickingAvatar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.read<ProfileViewModel>().user;
      if (user != null) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
        _dateOfBirth = user.dateOfBirth;
        _avatarUrl = user.avatarUrl;
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// US-04: pick an avatar image from gallery or camera, copy it into the app
  /// documents directory, and stage the resulting path for saving.
  Future<void> _pickAvatar(ImageSource source) async {
    final p = context.palette;
    if (_isPickingAvatar) return;
    setState(() => _isPickingAvatar = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/avatars');
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }
      final ext = path_util.extension(picked.path);
      final destPath =
          '${avatarsDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
      final destFile = await File(picked.path).copy(destPath);

      if (mounted) {
        setState(() => _avatarUrl = destFile.path);
      }
    } catch (_) {
      // Best-effort: silently ignore so the user can retry.
    } finally {
      if (mounted) setState(() => _isPickingAvatar = false);
    }
  }

  /// US-04: bottom sheet offering gallery / camera source selection.
  Future<void> _showAvatarSourceSheet() async {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.relaxed.w,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.tapToChangePhoto,
                      style: AppTypography.h2.copyWith(fontSize: 15.sp),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: Text(l10n.gallery),
                  onTap: () => Navigator.of(sheetContext)
                      .pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(l10n.camera),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source != null) {
      await _pickAvatar(source);
    }
  }

  /// US-04: present the system date picker and stage the picked DOB.
  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ??
        DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _dateOfBirth = picked);
    }
  }

  /// US-04: render the staged avatar — either a copied image file, an asset
  /// (default), or a placeholder icon.
  Widget _avatarAvatarContent() {
    final p = context.palette;
    final url = _avatarUrl;
    if (url == null || url.isEmpty) {
      return Icon(
        Icons.person_rounded,
        color: p.hairline,
        size: 52.sp,
      );
    }
    // Asset paths (default avatar) start with 'assets/'.
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    return Image.file(File(url), fit: BoxFit.cover);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileVm = context.read<ProfileViewModel>();
    final currentUser = profileVm.user;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth,
      avatarUrl: _avatarUrl,
    );

    final l10n = AppLocalizations.of(context)!;
    final success = await profileVm.updateProfile(updatedUser, l10n);

    if (mounted && success) {
      final palette = context.palette;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: palette.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                l10n.profileSaved,
                style: AppTypography.bodyMd.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final profileVm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: p.canvas,
      appBar: CustomAppBar(title: l10n.editProfileTitle, showBackButton: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSpacing.lg.h),
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 96.w,
                              height: 96.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.strawberry,
                                border: Border.all(
                                  color: p.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: _avatarAvatarContent(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isPickingAvatar
                                    ? null
                                    : _showAvatarSourceSheet,
                                child: Container(
                                  width: 30.w,
                                  height: 30.w,
                                  decoration: BoxDecoration(
                                    color: p.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: p.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: _isPickingAvatar
                                      ? Padding(
                                          padding: EdgeInsets.all(7.w),
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Icon(
                                          Icons.camera_alt_rounded,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Center(
                        child: Text(
                          l10n.tapToChangePhoto,
                          style: AppTypography.bodySm.copyWith(
                            color: p.inkMuted.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      _SectionLabel(label: l10n.personalInfo),
                      SizedBox(height: AppSpacing.md.h),
                      CustomTextField(
                        label: l10n.fullName,
                        hintText: l10n.enterFullName,
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _fullNameController,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      CustomTextField(
                        label: l10n.email,
                        hintText: l10n.enterEmail,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      CustomTextField(
                        label: l10n.phoneNumber,
                        hintText: l10n.enterPhoneNumber,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        controller: _phoneController,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      _DateField(
                        label: l10n.dateOfBirth,
                        value: _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : l10n.dateOfBirthValue,
                        onTap: _pickDateOfBirth,
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                      PrimaryButton(
                        text: l10n.saveProfile,
                        onPressed: _saveProfile,
                        isLoading: profileVm.isSaving,
                      ),
                      SizedBox(height: AppSpacing.xl.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: p.primary,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Text(label, style: AppTypography.h2.copyWith(fontSize: 14.sp)),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: p.inkMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.md.h,
            ),
            decoration: BoxDecoration(
              color: p.inputFill,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: p.hairline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18.sp,
                  color: p.inkMuted.withValues(alpha: 0.6),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(child: Text(value, style: AppTypography.bodyMd)),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: p.hairline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
