import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/custom_app_bar.dart';
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
    'INTJ',
    'INTP',
    'ENTJ',
    'ENTP',
    'INFJ',
    'INFP',
    'ENFJ',
    'ENFP',
    'ISTJ',
    'ISFJ',
    'ESTJ',
    'ESFJ',
    'ISTP',
    'ISFP',
    'ESTP',
    'ESFP',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: l10n.personalityType,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              Text(
                l10n.knowMbtiQuestion,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _knowMbti = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _knowMbti
                              ? AppColors.primary
                              : AppColors.outline,
                          width: _knowMbti ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(
                        l10n.yesIKnow,
                        style: TextStyle(
                          color: _knowMbti
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _knowMbti = false;
                          _selectedMbti = null;
                        });
                        context.pushNamed(RouteNames.mbtiTest);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(
                        l10n.notSure,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_knowMbti) ...[
                SizedBox(height: 32.h),
                Text(
                  l10n.selectYourMbti,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 2,
                    ),
                    itemCount: mbtiTypes.length,
                    itemBuilder: (context, index) {
                      final type = mbtiTypes[index];
                      final isSelected = _selectedMbti == type;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMbti = type;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                        context.read<QuestionnaireViewModel>().setKnownMbti(
                          _selectedMbti!,
                        );
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
}
