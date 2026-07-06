import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/features/onboarding/viewmodels/questionnaire_viewmodel.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MbtiSelectionPage extends StatefulWidget {
  const MbtiSelectionPage({super.key});

  @override
  State<MbtiSelectionPage> createState() => _MbtiSelectionPageState();
}

class _MbtiSelectionPageState extends State<MbtiSelectionPage> {
  bool _knowMbti = false;
  String? _selectedMbti;

  final List<String> mbtiTypes = [
    'INTJ','INTP','ENTJ','ENTP','INFJ','INFP','ENFJ','ENFP',
    'ISTJ','ISFJ','ESTJ','ESFJ','ISTP','ISFP','ESTP','ESFP',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary, size: 22.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.personalityType, style: AppTypography.fraunces(size: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(l10n.knowMbtiQuestion, style: AppTypography.fraunces(size: 22)),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _choiceButton(
                      label: l10n.yesIKnow,
                      selected: _knowMbti,
                      onTap: () => setState(() => _knowMbti = true),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _choiceButton(
                      label: l10n.notSure,
                      selected: !_knowMbti && _selectedMbti == null,
                      onTap: () {
                        setState(() {
                          _knowMbti = false;
                          _selectedMbti = null;
                        });
                        context.pushNamed(RouteNames.mbtiTest);
                      },
                    ),
                  ),
                ],
              ),
              if (_knowMbti) ...[
                SizedBox(height: 28.h),
                Text(l10n.selectYourMbti,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                SizedBox(height: 14.h),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: mbtiTypes.length,
                    itemBuilder: (context, index) {
                      final type = mbtiTypes[index];
                      final isSelected = _selectedMbti == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedMbti = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.outline,
                            ),
                          ),
                          child: Text(type,
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.textPrimary)),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const Spacer(),
              ],
              if (_knowMbti)
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: PrimaryButton(
                    text: l10n.continueButton,
                    isDisabled: _selectedMbti == null,
                    onPressed: () {
                      if (_selectedMbti != null) {
                        context.read<QuestionnaireViewModel>().setKnownMbti(_selectedMbti!);
                        context.pushNamed(RouteNames.mbtiResult);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }
}
