import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:fem_psychmonitor/widgets/page_header.dart';
import 'package:flutter/material.dart';
import 'package:fem_psychmonitor/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InitialQuestionnairePage extends StatefulWidget {
  const InitialQuestionnairePage({super.key});

  @override
  State<InitialQuestionnairePage> createState() =>
      _InitialQuestionnairePageState();
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

    final List<Map<String, String>> moods = [
      {'id': 'happy', 'label': l10n.happy},
      {'id': 'sad', 'label': l10n.sad},
      {'id': 'neutral', 'label': l10n.neutral},
      {'id': 'angry', 'label': l10n.angry},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: l10n.welcome, showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              PageHeader(
                title: l10n.quickQuestions,
                subtitle: l10n.selectMoodToHelp,
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.selectDominantEmotion,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: moods.map((m) {
                  final selected = selectedMood == m['id'];
                  return ChoiceChip(
                    label: Text(m['label']!),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selectedMood = m['id'];
                      });
                    },
                    selectedColor: AppColors.secondary,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(color: AppColors.outline),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? Colors.black : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
              Text(
                l10n.briefNote,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  hintText: l10n.writeWhatYouWant,
                ),
              ),
              SizedBox(height: 24.h),
              PrimaryButton(
                text: l10n.startDemoRecording,
                onPressed: () {
                  if (selectedMood == null) return;
                  // pass initial answers via extra or state management later
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
