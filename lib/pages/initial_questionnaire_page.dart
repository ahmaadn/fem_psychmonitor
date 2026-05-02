import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/widgets/custom_app_bar.dart';
import 'package:fem_psychmonitor/widgets/button_widget.dart';
import 'package:fem_psychmonitor/widgets/page_header.dart';
import 'package:flutter/material.dart';
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

  final List<Map<String, String>> moods = [
    {'id': 'happy', 'label': 'Senang'},
    {'id': 'sad', 'label': 'Sedih'},
    {'id': 'neutral', 'label': 'Netral'},
    {'id': 'angry', 'label': 'Marah'},
  ];

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Welcome', showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              PageHeader(
                title: 'Pertanyaan Singkat',
                subtitle:
                    'Pilih suasana hati Anda saat ini untuk membantu analisis',
              ),
              SizedBox(height: 24.h),
              Text(
                'Pilih Emosi Dominan',
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
                'Catatan Singkat',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  // border: InputBorder.none,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.outline),
                  ),
                  hintText: 'Tuliskan apa yang ingin Anda catat...',
                ),
              ),
              SizedBox(height: 24.h),
              PrimaryButton(
                text: 'Mulai Demo Rekaman',
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
