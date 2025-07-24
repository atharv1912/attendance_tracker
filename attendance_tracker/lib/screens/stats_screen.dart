import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/subject.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    // Delay progress animation for dramatic effect
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subjects =
        Hive.box<Subject>('subjects').values.toList().cast<Subject>();

    int totalAttended =
        subjects.fold(0, (sum, subject) => sum + subject.attended);
    int totalMissed = subjects.fold(0, (sum, subject) => sum + subject.missed);
    double overallPercentage = totalAttended + totalMissed == 0
        ? 0
        : (totalAttended / (totalAttended + totalMissed)) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0B),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: subjects.isEmpty
                ? _buildEmptyState()
                : _buildStatsContent(
                    subjects,
                    totalAttended,
                    totalMissed,
                    overallPercentage,
                  ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
        ).createShader(bounds),
        child: const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.3),
                    const Color(0xFF00D4FF).withOpacity(0.3),
                  ],
                ),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                size: 60,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No data yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add subjects to see your statistics',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent(
    List<Subject> subjects,
    int totalAttended,
    int totalMissed,
    double overallPercentage,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildOverallStatsCard(
              totalAttended,
              totalMissed,
              overallPercentage,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickStatsRow(subjects, totalAttended, totalMissed),
          const SizedBox(height: 32),
          _buildSectionHeader('Subject Performance'),
          const SizedBox(height: 16),
          _buildSubjectsList(subjects),
          const SizedBox(height: 32),
          _buildInsightsCard(subjects, overallPercentage),
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard(
    int totalAttended,
    int totalMissed,
    double overallPercentage,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Overall Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                animation: false,
                percent: (overallPercentage / 100) * _progressAnimation.value,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(overallPercentage * _progressAnimation.value).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _getPercentageColor(overallPercentage),
                      ),
                    ),
                    Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                progressColor: _getPercentageColor(overallPercentage),
                backgroundColor: Colors.white.withOpacity(0.1),
                circularStrokeCap: CircularStrokeCap.round,
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Present',
                totalAttended.toString(),
                const Color(0xFF4ECDC4),
                Icons.check_circle_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildStatItem(
                'Absent',
                totalMissed.toString(),
                const Color(0xFFFF6B6B),
                Icons.cancel_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              _buildStatItem(
                'Total',
                (totalAttended + totalMissed).toString(),
                const Color(0xFF6C63FF),
                Icons.school_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(
      List<Subject> subjects, int totalAttended, int totalMissed) {
    final bestSubject = subjects.isEmpty
        ? null
        : subjects.reduce(
            (a, b) => a.percentage > b.percentage ? a : b,
          );
    final worstSubject = subjects.isEmpty
        ? null
        : subjects.reduce(
            (a, b) => a.percentage < b.percentage ? a : b,
          );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                if (bestSubject != null) ...[
                  Expanded(
                    child: _buildQuickStatCard(
                      'Best Performance',
                      bestSubject.name,
                      '${bestSubject.percentage.toStringAsFixed(1)}%',
                      const Color(0xFF4ECDC4),
                      Icons.trending_up_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (worstSubject != null)
                  Expanded(
                    child: _buildQuickStatCard(
                      'Needs Attention',
                      worstSubject.name,
                      '${worstSubject.percentage.toStringAsFixed(1)}%',
                      const Color(0xFFFFB74D),
                      Icons.trending_down_rounded,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String subtitle,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSubjectsList(List<Subject> subjects) {
    return Column(
      children: subjects.asMap().entries.map((entry) {
        final index = entry.key;
        final subject = entry.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 100)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildSubjectCard(subject),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    final totalClasses = subject.attended + subject.missed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:
                      _getPercentageColor(subject.percentage).withOpacity(0.1),
                  border: Border.all(
                    color: _getPercentageColor(subject.percentage)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${subject.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _getPercentageColor(subject.percentage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            animation: true,
            lineHeight: 8,
            animationDuration: 1000,
            percent: subject.percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            progressColor: _getPercentageColor(subject.percentage),
            barRadius: const Radius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStatChip(
                'Present',
                subject.attended.toString(),
                const Color(0xFF4ECDC4),
              ),
              const SizedBox(width: 8),
              _buildMiniStatChip(
                'Absent',
                subject.missed.toString(),
                const Color(0xFFFF6B6B),
              ),
              const SizedBox(width: 8),
              _buildMiniStatChip(
                'Total',
                totalClasses.toString(),
                const Color(0xFF6C63FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(List<Subject> subjects, double overallPercentage) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.1),
                    const Color(0xFF00D4FF).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                          ),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInsightText(
                      _getInsightMessage(subjects, overallPercentage)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightText(String message) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white.withOpacity(0.9),
        height: 1.5,
      ),
    );
  }

  String _getInsightMessage(List<Subject> subjects, double overallPercentage) {
    if (subjects.isEmpty) {
      return 'Start adding subjects to get personalized insights about your attendance patterns.';
    }

    final subjectsBelow75 = subjects.where((s) => s.percentage < 75).length;
    final subjectsAbove90 = subjects.where((s) => s.percentage >= 90).length;

    if (overallPercentage >= 90) {
      return '🎉 Excellent work! Your attendance is outstanding. You\'re maintaining great discipline across all subjects.';
    } else if (overallPercentage >= 75) {
      if (subjectsBelow75 > 0) {
        return '✨ Good overall attendance! Focus on improving $subjectsBelow75 subject(s) that are below 75% to maintain your academic standing.';
      }
      return '👍 Solid attendance record! Keep up the good work to maintain your academic requirements.';
    } else if (overallPercentage >= 50) {
      return '⚠️ Your attendance needs attention. Consider attending more classes regularly to meet the minimum requirements and avoid academic issues.';
    } else {
      return '🚨 Critical attendance level! Immediate action required. Attend all upcoming classes to avoid serious academic consequences.';
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF4ECDC4);
    if (percentage >= 50) return const Color(0xFFFFB74D);
    return const Color(0xFFFF6B6B);
  }
}
