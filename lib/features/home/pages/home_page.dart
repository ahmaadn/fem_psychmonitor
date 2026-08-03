import 'dart:math' as math;

import 'package:fem_psychmonitor/app/config/app_palette.dart';
import 'package:fem_psychmonitor/app/config/app_constants.dart';
import 'package:fem_psychmonitor/app/config/app_spacing.dart';
import 'package:fem_psychmonitor/app/config/app_typography.dart';
import 'package:fem_psychmonitor/app/providers/locale_provider.dart';
import 'package:fem_psychmonitor/app/utils/emotion_config.dart';
import 'package:fem_psychmonitor/app/utils/mental_health_score.dart';
import 'package:fem_psychmonitor/app/utils/recommendation_engine.dart';
import 'package:fem_psychmonitor/app/widgets/emotion_emoji.dart';
import 'package:fem_psychmonitor/data/models/emotion_summary_model.dart';
import 'package:fem_psychmonitor/data/repositories/recommendation_repository.dart';
import 'package:fem_psychmonitor/data/viewmodels/auth_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/home_viewmodel.dart';
import 'package:fem_psychmonitor/data/viewmodels/profile_viewmodel.dart';
import 'package:fem_psychmonitor/features/home/widgets/today_mood_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  EmotionLabelType? _todayMood;
  RecommendationResult? _saran;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HomeViewModel>().loadStats();
      context.read<ProfileViewModel>().loadProfile();
      await _loadMoodAndSaran();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMoodAndSaran() async {
    final auth = context.read<AuthViewModel>();
    final user = auth.currentUser;
    if (user == null) return;
    final homeVm = context.read<HomeViewModel>();
    final isEn = context.read<LocaleProvider>().isEnglish;
    final repo = context.read<RecommendationRepository>();
    final mood = await loadDailyMood(user.id);
    if (!mounted) return;
    final homeStats = homeVm.stats;
    final emotion = mood ?? homeStats?.currentMood ?? EmotionLabelType.neutral;
    final saran = await repo.getRecommendations(
      ocean: user.oceanScores,
      emotion: emotion,
      psychScore: user.psychScore,
      isEnglish: isEn,
    );
    if (!mounted) return;
    setState(() {
      _todayMood = mood;
      _saran = saran;
    });
  }

  Future<void> _pickMood() async {
    final selected = await showTodayMoodSheet(context, initial: _todayMood);
    if (selected == null || !mounted) return;
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) return;
    await persistDailyMood(userId: user.id, emotion: selected);
    await _loadMoodAndSaran();
  }

  // icon berdasarkan waktu hari
  IconData _greetingIcon() {
    final h = DateTime.now().hour;
    if (h < 11) return Icons.wb_sunny_rounded; // pagi - matahari
    if (h < 15) return Icons.light_mode_rounded; // siang - terang
    if (h < 18) return Icons.wb_twilight_rounded; // sore - senja
    return Icons.nights_stay_rounded; // malam - bulan
  }

  String _greetingTime(bool isEn) {
    final h = DateTime.now().hour;
    if (isEn) {
      if (h < 12) return 'Good morning';
      if (h < 15) return 'Good afternoon';
      if (h < 18) return 'Good evening';
      return 'Good night';
    }
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _scoreLabel(int score, bool isEn) {
    final key = psychClassKeyForScore(score);
    if (isEn) {
      return switch (key) {
        'butuh_perhatian' => 'Needs attention',
        'rentan' => 'Vulnerable',
        'cukup_sehat' => 'Fairly healthy',
        _ => 'Healthy',
      };
    }
    return switch (key) {
      'butuh_perhatian' => 'Butuh Perhatian',
      'rentan' => 'Rentan',
      'cukup_sehat' => 'Cukup Sehat',
      _ => 'Sehat',
    };
  }

  Color _scoreColor(int score, AppPalette p) {
    if (score <= 25) return p.errorText;
    if (score <= 50) return p.warningText;
    if (score <= 75) return p.infoText;
    return p.successText;
  }

  EmotionLabelType? _scoreEmoji(int score) {
    if (score <= 50) return EmotionLabelType.sad;
    return EmotionLabelType.happy;
  }

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _needsSupport(int score) {
    final key = psychClassKeyForScore(score);
    return key == 'rentan' || key == 'butuh_perhatian';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final homeVm = context.watch<HomeViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final auth = context.watch<AuthViewModel>();
    final isEn = context.watch<LocaleProvider>().isEnglish;
    final stats = homeVm.stats;
    final user = profileVm.user ?? auth.currentUser;
    final score = user?.psychScore ?? 0;
    final name = (user?.fullName ?? '').trim();
    final mood = _todayMood ?? stats?.currentMood;
    final streakDays = stats?.streakDays ?? 0;
    final todayCount =
        stats?.weeklyCheckins
            .where((d) => d.isCheckedIn && _isToday(d.date))
            .length ??
        0;
    final scoreColor = _scoreColor(score, p);
    final showSupportBanner = _needsSupport(score);

    return Scaffold(
      // Scaffold transparan — gradient dihandle oleh DecoratedBox di bawah
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(color: p.canvas),
        child: RefreshIndicator(
          color: p.primaryFill,
          backgroundColor: p.surface1,
          onRefresh: () async {
            await homeVm.loadStats();
            await _loadMoodAndSaran();
          },
          child: CustomScrollView(
            slivers: [
              // ── Hero header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroHeader(
                  greetingTime: _greetingTime(isEn),
                  greetingIcon: _greetingIcon(),
                  name: name,
                  score: score,
                  scoreLabel: _scoreLabel(score, isEn),
                  scoreEmoji: _scoreEmoji(score),
                  scoreColor: scoreColor,
                  mood: mood,
                  isEn: isEn,
                  pulseAnim: _pulseAnim,
                  onMoodTap: _pickMood,
                ),
              ),

              // ── Body content ─────────────────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageX.w,
                  AppSpacing.md.h,
                  AppSpacing.pageX.w,
                  80.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // [6] Support banner jika skor rentan/butuh perhatian
                    if (showSupportBanner) ...[
                      _SupportBanner(isEn: isEn, score: score),
                      SizedBox(height: AppSpacing.md.h),
                    ],

                    // [3] Stat row — hanya 2 card: checkin + streak
                    _StatRow(
                      todayCount: todayCount,
                      streakDays: streakDays,
                      isEn: isEn,
                    ),
                    SizedBox(height: AppSpacing.md.h),

                    // Week strip
                    _WeekStrip(
                      checkins: stats?.weeklyCheckins ?? const [],
                      isEn: isEn,
                    ),
                    SizedBox(height: AppSpacing.lg.h),

                    // [4] Hanya Voice CTA, tidak ada aksi cepat lagi
                    _VoiceCheckinCTA(
                      isEn: isEn,
                      mood: mood,
                      onTap: () => context.goNamed(RouteNames.liveRecording),
                      onMoodTap: _pickMood,
                    ),
                    SizedBox(height: AppSpacing.lg.h),

                    // [5] Section: For you — diperbagus
                    _ForYouHeader(isEn: isEn),
                    SizedBox(height: AppSpacing.sm.h),
                    _RecommendationSection(saran: _saran, isEn: isEn),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greetingTime,
    required this.greetingIcon,
    required this.name,
    required this.score,
    required this.scoreLabel,
    required this.scoreEmoji,
    required this.scoreColor,
    required this.mood,
    required this.isEn,
    required this.pulseAnim,
    required this.onMoodTap,
  });

  final String greetingTime;
  final IconData greetingIcon;
  final String name;
  final int score;
  final String scoreLabel;
  final EmotionLabelType? scoreEmoji;
  final Color scoreColor;
  final EmotionLabelType? mood;
  final bool isEn;
  final Animation<double> pulseAnim;
  final VoidCallback onMoodTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // [2] bg hero sekarang solid canvas + surface, bukan gradient beraneka warna
    // score ring container juga pakai warna yang serasi
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + AppSpacing.md.h,
            left: AppSpacing.pageX.w,
            right: AppSpacing.pageX.w,
            bottom: AppSpacing.xl.h,
          ),
          // Transparan — gradient sudah dihandle Scaffold satu level atas
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [1] Greeting dengan icon waktu
              Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: p.surface2,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      greetingIcon,
                      color: p.textSecondary,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs.w),
                  Text(
                    greetingTime,
                    style: AppTypography.label.copyWith(
                      color: p.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),

              // Name
              Text(
                name.isEmpty
                    ? (isEn ? 'Welcome back' : 'Selamat datang')
                    : name,
                style: AppTypography.display.copyWith(
                  color: p.textPrimary,
                  height: 1.1,
                ),
              ),
              SizedBox(height: AppSpacing.xxs.h),
              Text(
                isEn
                    ? 'How is your heart today?'
                    : 'Bagaimana hatimu hari ini?',
                style: AppTypography.body.copyWith(color: p.textSecondary),
              ),
              SizedBox(height: AppSpacing.lg.h),

              // [2] Score panel — sekarang card putih di atas bg strawberry,
              // tidak ada warna kontras yang membentur gradient hero
              Container(
                padding: EdgeInsets.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: p.surface1,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: p.divider, width: AppBorder.thin),
                  boxShadow: [
                    BoxShadow(
                      color: p.shadowRaised,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Score ring
                    _ScoreRing(
                      score: score,
                      emotion: scoreEmoji,
                      color: scoreColor,
                      pulseAnim: pulseAnim,
                    ),
                    SizedBox(width: AppSpacing.md.w),

                    // Score details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Mental health' : 'Kesehatan mental',
                            style: AppTypography.caption.copyWith(
                              color: p.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$score',
                                style: AppTypography.metric.copyWith(
                                  color: p.textPrimary,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '/ 100',
                                style: AppTypography.caption.copyWith(
                                  color: p.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xxs.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: scoreColor.withValues(alpha: 0.15),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Text(
                              scoreLabel,
                              style: AppTypography.caption.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm.h),
                          ClipRRect(
                            borderRadius: AppRadius.chip,
                            child: LinearProgressIndicator(
                              value: score / 100,
                              minHeight: 5.h,
                              backgroundColor: p.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                scoreColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.md.h),

              // Mood chip
              GestureDetector(
                onTap: onMoodTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: AppSpacing.xs.h,
                  ),
                  decoration: BoxDecoration(
                    color: mood != null
                        ? p.emotionBase(mood!).withValues(alpha: 0.12)
                        : p.surface1,
                    borderRadius: AppRadius.chip,
                    border: Border.all(
                      color: mood != null
                          ? p.emotionBase(mood!).withValues(alpha: 0.35)
                          : p.divider,
                      width: AppBorder.thin,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EmotionEmoji(
                        asset: mood?.emojiAsset ?? 'assets/emoji/netral.png',
                        size: 22,
                      ),
                      SizedBox(width: AppSpacing.xs.w),
                      Text(
                        mood != null
                            ? (isEn
                                  ? 'Feeling ${mood!.displayName.toLowerCase()}'
                                  : 'Merasa ${mood!.displayName.toLowerCase()}')
                            : (isEn ? 'Set your mood' : 'Atur moodmu'),
                        style: AppTypography.label.copyWith(
                          color: mood != null
                              ? p.emotionText(mood!)
                              : p.textPrimary,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14.sp,
                        color: p.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Score Ring ───────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.score,
    required this.emotion,
    required this.color,
    required this.pulseAnim,
  });

  final int score;
  final EmotionLabelType? emotion;
  final Color color;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = 88.w;

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, _) {
        return Transform.scale(
          scale: pulseAnim.value,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(
                progress: score / 100,
                trackColor: p.divider,
                progressColor: color,
              ),
              child: Center(
                child: EmotionEmoji(
                  asset: emotion?.emojiAsset ?? 'assets/emoji/netral.png',
                  size: 36,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 6;
    const strokeW = 5.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );

    final sweepAngle = 2 * math.pi * progress;
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + sweepAngle,
      colors: [progressColor.withValues(alpha: 0.55), progressColor],
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}

// ── Support Banner ────────────────────────────────────────────────────────────

class _SupportBanner extends StatelessWidget {
  const _SupportBanner({required this.isEn, required this.score});
  final bool isEn;
  final int score;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isAttention = psychClassKeyForScore(score) == 'butuh_perhatian';

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse('tel:119');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          color: isAttention
              ? p.error.withValues(alpha: 0.1)
              : p.warning.withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isAttention
                ? p.error.withValues(alpha: 0.35)
                : p.warning.withValues(alpha: 0.35),
            width: AppBorder.thin,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isAttention
                    ? p.error.withValues(alpha: 0.15)
                    : p.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAttention
                    ? Icons.favorite_rounded
                    : Icons.support_agent_rounded,
                color: isAttention ? p.errorText : p.warning,
                size: 22.sp,
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn
                        ? (isAttention
                              ? 'You are not alone'
                              : 'Support is available')
                        : (isAttention
                              ? 'Kamu tidak sendirian'
                              : 'Bantuan tersedia'),
                    style: AppTypography.bodyStrong.copyWith(
                      color: isAttention ? p.errorText : p.warningText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isEn
                        ? 'Tap to call free helpline 119'
                        : 'Ketuk untuk hubungi hotline 119',
                    style: AppTypography.caption.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.phone_rounded,
              color: isAttention ? p.errorText : p.warning,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Row — hanya 2 card ──────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.todayCount,
    required this.streakDays,
    required this.isEn,
  });

  final int todayCount;
  final int streakDays;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: _BigStatCard(
            value: '$todayCount',
            label: isEn ? 'Today' : 'Hari ini',
            sub: isEn ? 'check-in' : 'cek-in',
            icon: Icons.mic_rounded,
            accent: p.textPrimary,
            iconBg: p.surface2,
          ),
        ),
        SizedBox(width: AppSpacing.sm.w),
        Expanded(
          child: _BigStatCard(
            value: '$streakDays',
            label: 'Streak',
            sub: isEn ? 'days' : 'hari',
            icon: Icons.local_fire_department_rounded,
            accent: p.warning,
            iconBg: p.warning.withValues(alpha: 0.12),
            suffix: streakDays > 0 ? '🔥' : null,
          ),
        ),
      ],
    );
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.value,
    required this.label,
    required this.sub,
    required this.icon,
    required this.accent,
    required this.iconBg,
    this.suffix,
  });

  final String value;
  final String label;
  final String sub;
  final IconData icon;
  final Color accent;
  final Color iconBg;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: p.surface1,
        borderRadius: AppRadius.card,
        border: Border.all(color: p.divider, width: AppBorder.thin),
        boxShadow: [
          BoxShadow(
            color: p.shadowRaised,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: accent, size: 17.sp),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.title.copyWith(
                  color: p.textPrimary,
                  height: 1.0,
                ),
              ),
              if (suffix != null) ...[
                SizedBox(width: AppSpacing.xxs.w),
                Text(suffix!, style: AppTypography.emojiSm),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.xxs.h),
          Text(
            label,
            style: AppTypography.label.copyWith(color: p.textSecondary),
          ),
          Text(sub, style: AppTypography.label.copyWith(color: p.textTertiary)),
        ],
      ),
    );
  }
}

// ── Week Strip ───────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.checkins, required this.isEn});

  final List<DailyCheckIn> checkins;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final days = isEn
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final now = DateTime.now();
    final checked = checkins.where((c) => c.isCheckedIn).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isEn ? 'This week' : 'Minggu ini',
              style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: p.secondarySoft,
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                '$checked/7',
                style: AppTypography.label.copyWith(
                  color: p.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final checkin = i < checkins.length ? checkins[i] : null;
            final isChecked = checkin?.isCheckedIn == true;
            final date = checkin?.date;
            final isToday =
                date != null &&
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final emotion = checkin?.dominantEmotion;
            final bubbleSize = isToday ? 42.w : 36.w;
            final emotionColor = emotion != null
                ? p.emotionBase(emotion)
                : null;

            return Column(
              children: [
                Text(
                  days[i],
                  style: AppTypography.label.copyWith(
                    color: isToday ? p.textPrimary : p.textTertiary,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs.h + 2),
                Container(
                  width: bubbleSize,
                  height: bubbleSize,
                  decoration: BoxDecoration(
                    color: isChecked && emotionColor != null
                        ? emotionColor.withValues(alpha: 0.15)
                        : p.surface3,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isToday
                          ? p.primaryText
                          : (isChecked && emotionColor != null
                                ? emotionColor.withValues(alpha: 0.45)
                                : p.divider),
                      width: isToday ? AppBorder.thick : AppBorder.thin,
                    ),
                    boxShadow: isChecked && emotionColor != null
                        ? [
                            BoxShadow(
                              color: emotionColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: isChecked
                      ? Text(
                          emotion?.emoji ?? '✓',
                          style: isToday
                              ? AppTypography.emojiLg
                              : AppTypography.emojiSm,
                        )
                      : Icon(
                          isToday
                              ? Icons.radio_button_unchecked_rounded
                              : Icons.circle_outlined,
                          size: isToday ? 13.sp : 10.sp,
                          color: isToday ? p.textPrimary : p.textTertiary,
                        ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// ── Voice Check-in CTA — mencakup tombol + mood shortcut ─────────────────────

class _VoiceCheckinCTA extends StatelessWidget {
  const _VoiceCheckinCTA({
    required this.isEn,
    required this.mood,
    required this.onTap,
    required this.onMoodTap,
  });
  final bool isEn;
  final EmotionLabelType? mood;
  final VoidCallback onTap;
  final VoidCallback onMoodTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        // Tombol utama voice check-in
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w,
              vertical: AppSpacing.md.h + 2,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  p.primaryFill,
                  Color.lerp(p.primaryFill, p.primaryPressed, 0.4)!,
                ],
              ),
              borderRadius: AppRadius.card,
              boxShadow: [
                BoxShadow(
                  color: p.primaryFill.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: p.onPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: p.onPrimary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Start voice check-in' : 'Mulai cek-in suara',
                        style: AppTypography.bodyStrong.copyWith(
                          color: p.onPrimary,
                        ),
                      ),
                      Text(
                        isEn ? 'Speak your feelings' : 'Ungkapkan perasaanmu',
                        style: AppTypography.caption.copyWith(
                          color: p.onPrimary.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: p.onPrimary.withValues(alpha: 0.7),
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),

        // Mood shortcut di bawah tombol utama
        SizedBox(height: AppSpacing.xs.h),
        GestureDetector(
          onTap: onMoodTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.xs.h + 1,
            ),
            decoration: BoxDecoration(
              color: p.surface1,
              borderRadius: AppRadius.card,
              border: Border.all(color: p.divider, width: AppBorder.thin),
            ),
            child: Row(
              children: [
                Text(mood?.emoji ?? '💭', style: AppTypography.emojiMd),
                SizedBox(width: AppSpacing.xs.w),
                Expanded(
                  child: Text(
                    mood != null
                        ? (isEn
                              ? 'Feeling ${mood!.displayName.toLowerCase()} today'
                              : 'Hari ini merasa ${mood!.displayName.toLowerCase()}')
                        : (isEn ? 'How do you feel?' : 'Bagaimana perasaanmu?'),
                    style: AppTypography.caption.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ),
                Text(
                  isEn ? 'Change' : 'Ubah',
                  style: AppTypography.label.copyWith(color: p.primaryText),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── For You Header ────────────────────────────────────────────────────────────

class _ForYouHeader extends StatelessWidget {
  const _ForYouHeader({required this.isEn});
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: p.secondarySoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: p.secondaryText,
            size: 13.sp,
          ),
        ),
        SizedBox(width: AppSpacing.xs.w),
        Text(
          isEn ? 'For you' : 'Untukmu',
          style: AppTypography.bodyStrong.copyWith(color: p.textPrimary),
        ),
        SizedBox(width: AppSpacing.xxs.w),
        Text('✨', style: AppTypography.emojiSm),
      ],
    );
  }
}

// ── Recommendation Section ────────────────────────────────────────────────────

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({required this.saran, required this.isEn});
  final RecommendationResult? saran;
  final bool isEn;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // Loading state
    if (saran == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.lg.h,
        ),
        decoration: BoxDecoration(
          color: p.surface1,
          borderRadius: AppRadius.card,
          border: Border.all(color: p.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: p.primaryText,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Text(
              isEn ? 'Loading suggestions…' : 'Memuat saran…',
              style: AppTypography.caption.copyWith(color: p.textSecondary),
            ),
          ],
        ),
      );
    }

    if (saran!.safetyTriggered) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.warning.withValues(alpha: 0.12), p.surface1],
          ),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: p.warning.withValues(alpha: 0.4),
            width: AppBorder.thin,
          ),
          boxShadow: [
            BoxShadow(
              color: p.shadowRaised,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: p.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.favorite_rounded, color: p.warning),
                ),
                SizedBox(width: AppSpacing.sm.w),
                Expanded(
                  child: Text(
                    isEn
                        ? 'You matter — support is here'
                        : 'Kamu berharga — dukungan ada',
                    style: AppTypography.bodyStrong.copyWith(
                      color: p.warningText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm.h),
            ...saran!.items.map(
              (i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: AppTypography.caption.copyWith(
                        color: p.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        i.text,
                        style: AppTypography.caption.copyWith(
                          color: p.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal recommendations — [5] tampilan diperbagus
    // Pakai horizontal scroll card untuk kesan "feed personal"
    final tipEmojis = ['🌱', '💧', '🌸', '☀️', '💝'];
    // warna accent bergantian: strawberry dan matcha
    final accentPairs = [
      (bg: p.secondarySoft, icon: p.secondaryText),
      (bg: p.primarySoft, icon: p.primaryText),
      (bg: p.secondaryWash, icon: p.secondaryText),
      (bg: p.surface2, icon: p.textPrimary),
      (
        bg: Color.lerp(p.primarySoft, p.secondarySoft, 0.5)!,
        icon: p.secondaryText,
      ),
    ];

    return Column(
      children: saran!.items.asMap().entries.map((entry) {
        final i = entry.value;
        final idx = entry.key % tipEmojis.length;
        final emoji = tipEmojis[idx];
        final accent = accentPairs[idx];

        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
          decoration: BoxDecoration(
            color: p.surface1,
            borderRadius: AppRadius.card,
            border: Border.all(color: p.divider, width: AppBorder.thin),
            boxShadow: [
              BoxShadow(
                color: p.shadowRaised,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // [5] accent strip di sisi kiri + emoji
                Container(
                  width: 52.w,
                  decoration: BoxDecoration(
                    color: accent.bg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: AppTypography.emojiLg),
                ),
                // Teks rekomendasi
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md.w,
                      vertical: AppSpacing.sm.h + 2,
                    ),
                    child: Text(
                      i.text,
                      style: AppTypography.caption.copyWith(
                        color: p.textPrimary,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
