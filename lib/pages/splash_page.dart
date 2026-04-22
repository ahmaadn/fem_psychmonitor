import 'package:fem_psychmonitor/app/config/app_colors.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // AnimationController untuk mengontrol progress bar dan navigasi otomatis
  late final AnimationController _progressController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _goToRegister();
            }
          })
          ..forward();
  }

  void _goToRegister() {
    // Pastikan hanya navigasi sekali, baik dari progress selesai atau swipe up
    if (!mounted || _hasNavigated) {
      return;
    }
    _hasNavigated = true;
    context.goNamed(RouteNames.register);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan GestureDetector untuk menangkap aksi "Swipe Up"
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          // Jika primaryVelocity bernilai negatif, artinya pengguna menggeser ke atas
          if ((details.primaryVelocity ?? 0) < 0) {
            _goToRegister();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // Latar belakang gradien soft pastel sesuai desain
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE5F1FA), // Soft Light Blue (Atas)
                Color(0xFFFDF8E4), // Soft Light Yellow (Bawah)
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 16.h),
                          Column(
                            children: [
                              Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.onSurface.withAlpha(
                                        (255 * 0.05).toInt(),
                                      ),
                                      blurRadius: 32.r,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/logo.png',
                                    width: 100.w,
                                    height: 100.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'FEM-PSYCHMONITOR',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: const Color(
                                        0xFF1E293B,
                                      ), // Dark Navy yang lebih kuat
                                    ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'YOUR EMOTIONAL SANCTUARY',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.5,
                                      color: AppColors.onSurface.withAlpha(
                                        (255 * 0.5).toInt(),
                                      ),
                                    ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 24.h),
                            child: Column(
                              children: [
                                AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) {
                                    final progress = _progressController.value;

                                    return SizedBox(
                                      width: 220.w,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.full,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6.h,
                                          backgroundColor: Colors.white
                                              .withAlpha((255 * 0.55).toInt()),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 12.h),
                                Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: const Color(0xFF8BA5C2),
                                  size: 24.sp,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'SWIPE UP TO BEGIN',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        color: const Color(
                                          0xFF8BA5C2,
                                        ), // Pale blue grey
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
