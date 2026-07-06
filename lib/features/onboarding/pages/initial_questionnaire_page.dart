import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/widgets/button_widget.dart';
import 'package:fem_psychmonitor/app/widgets/voiceprint_orb.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InitialQuestionnairePage extends StatefulWidget {
  const InitialQuestionnairePage({super.key});

  @override
  State<InitialQuestionnairePage> createState() => _InitialQuestionnairePageState();
}

class _InitialQuestionnairePageState extends State<InitialQuestionnairePage> {
  String? selectedMood;
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final moods = [
      {'id': 'happy', 'label': l10n.happy, 'emoji': '😄'},
      {'id': 'sad', 'label': l10n.sad, 'emoji': '😢'},
      {'id': 'neutral', 'label': l10n.neutral, 'emoji': '😐'},
      {'id': 'angry', 'label': l10n.angry, 'emoji': '😠'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary, size: 22.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.quickQuestions, style: AppTypography.fraunces(size: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              const VoiceprintOrb(mode: VoiceprintMode.idle, size: 160),
              SizedBox(height: 24.h),
              Text(l10n.selectDominantEmotion, style: AppTypography.fraunces(size: 20)),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: moods.map((m) {
                  final selected = selectedMood == m['id'];
                  return GestureDetector(
                    onTap: () => setState(() => selectedMood = m['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.outline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(m['emoji']!, style: TextStyle(fontSize: 18.sp)),
                          SizedBox(width: 6.w),
                          Text(m['label']!,
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 28.h),
              Text(l10n.briefNote, style: AppTypography.fraunces(size: 16)),
              SizedBox(height: 10.h),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(color: AppColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                  ),
                  hintText: l10n.writeWhatYouWant,
                  hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                ),
              ),
              SizedBox(height: 24.h),
              PrimaryButton(
                text: l10n.startDemoRecording,
                onPressed: () {
                  if (selectedMood == null) return;
                  context.goNamed(RouteNames.liveRecording);
                },
                isDisabled: selectedMood == null,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
