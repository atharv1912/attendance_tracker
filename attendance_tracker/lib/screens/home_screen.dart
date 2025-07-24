import 'package:attendance_tracker/screens/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/subject.dart';
import 'add_subject_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Box<Subject> subjectsBox;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Map<int, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    subjectsBox = Hive.box<Subject>('subjects');

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ValueListenableBuilder<Box<Subject>>(
                valueListenable: subjectsBox.listenable(),
                builder: (context, box, _) {
                  final subjects = box.values.toList().cast<Subject>();

                  if (subjects.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildSubjectsList(subjects);
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
        ).createShader(bounds),
        child: const Text(
          'Attendance',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        _buildGlassMorphicButton(
          icon: Icons.analytics_rounded,
          onPressed: () => Navigator.push(
            context,
            _createSlideRoute(const StatsScreen()),
          ),
        ),
        const SizedBox(width: 8),
        _buildGlassMorphicButton(
          icon: Icons.add_rounded,
          onPressed: () => Navigator.push(
            context,
            _createSlideRoute(const AddSubjectScreen()),
          ),
        ),
        // In the _buildAppBar method, add this button between the analytics and add buttons:
        _buildGlassMorphicButton(
          icon: Icons.calendar_today_rounded,
          onPressed: () => _showAddDayDialog(context),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildGlassMorphicButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
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
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
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
                    Icons.school_rounded,
                    size: 60,
                    color: Colors.white70,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'No subjects yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first subject',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(List<Subject> subjects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildSubjectCard(context, subjects[index], index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject, int index) {
    final percentage = subject.percentage;
    final isSafe = subject.isSafeToBunk;
    final totalClasses = subject.attended + subject.missed;

    // Initialize expanded state if not present
    _expandedStates.putIfAbsent(index, () => false);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedStates[index] = !_expandedStates[index]!;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(subject, index),
                  const SizedBox(height: 16),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _expandedStates[index]!
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: _buildPercentageView(percentage),
                    secondChild: _buildDetailsView(subject, totalClasses),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButtons(index),
                  const SizedBox(height: 12),
                  _buildSafetyIndicator(isSafe),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageView(double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getPercentageColor(percentage),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            animation: true,
            lineHeight: 8,
            animationDuration: 1500,
            percent: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            progressColor: _getPercentageColor(percentage),
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView(Subject subject, int totalClasses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Lectures',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$totalClasses',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attended',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${subject.attended}',
                style: const TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Missed',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${subject.missed}',
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(Subject subject, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            subject.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Row(
          children: [
            _buildActionIcon(
              icon: Icons.edit_rounded,
              onPressed: () => _editLectureCounts(context, index, subject),
              color: const Color(0xFF6C63FF),
            ),
            const SizedBox(width: 8),
            _buildActionIcon(
              icon: Icons.delete_rounded,
              onPressed: () => _deleteSubject(index),
              color: const Color(0xFFFF6B6B),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageIndicator(double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _getPercentageColor(percentage),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            animation: true,
            lineHeight: 8,
            animationDuration: 1500,
            percent: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            progressColor: _getPercentageColor(percentage),
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Subject subject, int totalClasses) {
    return Row(
      children: [
        _buildStatChip(
          label: 'Present',
          value: '${subject.attended}',
          color: const Color(0xFF4ECDC4),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          label: 'Absent',
          value: '${subject.missed}',
          color: const Color(0xFFFF6B6B),
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          label: 'Total',
          value: '$totalClasses',
          color: const Color(0xFF6C63FF),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(int index) {
    return Container(
      width: double.infinity,
      child: _buildActionButton(
        label: 'Mark Attendance',
        icon: Icons.how_to_reg_rounded,
        color: const Color(0xFF6C63FF),
        onPressed: () => _showAttendanceDialog(index),
      ),
    );
  }

// Add this new method for the attendance dialog:
  void _showAttendanceDialog(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        final subject = subjectsBox.getAt(index);
        if (subject == null) return const SizedBox();

        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          title: Text(
            subject.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Mark your attendance for today:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                ),
              ),
              child: TextButton(
                onPressed: () {
                  _updateAttendance(index, false);
                  Navigator.pop(context);
                  _showAttendanceSnackbar(subject.name, false);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.cancel_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Absent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF26A69A)],
                ),
              ),
              child: TextButton(
                onPressed: () {
                  _updateAttendance(index, true);
                  Navigator.pop(context);
                  _showAttendanceSnackbar(subject.name, true);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Present',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Add this method for better feedback:
  void _showAttendanceSnackbar(String subjectName, bool attended) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: attended
            ? const Color(0xFF4ECDC4).withOpacity(0.9)
            : const Color(0xFFFF6B6B).withOpacity(0.9),
        content: Row(
          children: [
            Icon(
              attended ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Marked ${attended ? 'Present' : 'Absent'} for $subjectName',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyIndicator(bool isSafe) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSafe
            ? const Color(0xFF4ECDC4).withOpacity(0.1)
            : const Color(0xFFFFB74D).withOpacity(0.1),
        border: Border.all(
          color: isSafe
              ? const Color(0xFF4ECDC4).withOpacity(0.3)
              : const Color(0xFFFFB74D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSafe ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isSafe ? const Color(0xFF4ECDC4) : const Color(0xFFFFB74D),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            isSafe ? 'Safe to skip next class' : 'Attend upcoming classes',
            style: TextStyle(
              color: isSafe ? const Color(0xFF4ECDC4) : const Color(0xFFFFB74D),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF00D4FF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Navigator.push(
          context,
          _createSlideRoute(const AddSubjectScreen()),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF4ECDC4);
    if (percentage >= 50) return const Color(0xFFFFB74D);
    return const Color(0xFFFF6B6B);
  }

  void _updateAttendance(int index, bool attended) {
    final subject = subjectsBox.getAt(index);
    if (subject != null) {
      subjectsBox.putAt(
        index,
        Subject(
          name: subject.name,
          attended: attended ? subject.attended + 1 : subject.attended,
          missed: attended ? subject.missed : subject.missed + 1,
          requiredAttendance: subject.requiredAttendance,
        ),
      );
    }
  }

  void _deleteSubject(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _buildDeleteDialog(index),
    );
  }

  Widget _buildDeleteDialog(int index) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      title: const Text(
        'Delete Subject',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this subject? This action cannot be undone.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
            ),
          ),
          child: TextButton(
            onPressed: () {
              subjectsBox.deleteAt(index);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editLectureCounts(BuildContext context, int index, Subject subject) {
    final attendedController =
        TextEditingController(text: subject.attended.toString());
    final missedController =
        TextEditingController(text: subject.missed.toString());

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _buildEditDialog(
        index,
        subject,
        attendedController,
        missedController,
      ),
    );
  }

  void _showAddDayDialog(BuildContext context) {
    final Map<int, int> attendanceMap =
        {}; // 0: No lecture, 1: Attended, 2: Skipped

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final subjects = subjectsBox.values.toList().cast<Subject>();

            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              title: const Text(
                'Mark Today\'s Attendance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height:
                    MediaQuery.of(context).size.height * 0.6, // Limit height
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select attendance status for each subject:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          final selectedOption = attendanceMap[index] ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildAttendanceOption(
                                      icon: Icons.event_busy_rounded,
                                      label: 'No Lecture',
                                      isSelected: selectedOption == 0,
                                      color: Colors.white.withOpacity(0.6),
                                      onTap: () {
                                        setState(() {
                                          attendanceMap[index] = 0;
                                        });
                                      },
                                    ),
                                    _buildAttendanceOption(
                                      icon: Icons.check_circle_rounded,
                                      label: 'Attended',
                                      isSelected: selectedOption == 1,
                                      color: const Color(0xFF4ECDC4),
                                      onTap: () {
                                        setState(() {
                                          attendanceMap[index] = 1;
                                        });
                                      },
                                    ),
                                    _buildAttendanceOption(
                                      icon: Icons.cancel_rounded,
                                      label: 'Skipped',
                                      isSelected: selectedOption == 2,
                                      color: const Color(0xFFFF6B6B),
                                      onTap: () {
                                        setState(() {
                                          attendanceMap[index] = 2;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _processDayAttendance(attendanceMap);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.white.withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processDayAttendance(Map<int, int> attendanceMap) {
    int attendedCount = 0;
    int skippedCount = 0;

    attendanceMap.forEach((index, status) {
      final subject = subjectsBox.getAt(index);
      if (subject != null) {
        switch (status) {
          case 1: // Attended
            subjectsBox.putAt(
              index,
              Subject(
                name: subject.name,
                attended: subject.attended + 1,
                missed: subject.missed,
                requiredAttendance: subject.requiredAttendance,
              ),
            );
            attendedCount++;
            break;
          case 2: // Skipped
            subjectsBox.putAt(
              index,
              Subject(
                name: subject.name,
                attended: subject.attended,
                missed: subject.missed + 1,
                requiredAttendance: subject.requiredAttendance,
              ),
            );
            skippedCount++;
            break;
          // case 0: No lecture - no changes needed
        }
      }
    });

    // Show success message with summary
    String message = 'Attendance updated';
    if (attendedCount > 0 || skippedCount > 0) {
      List<String> parts = [];
      if (attendedCount > 0) parts.add('$attendedCount attended');
      if (skippedCount > 0) parts.add('$skippedCount skipped');
      message = '${parts.join(', ')} - ${message.toLowerCase()}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF4ECDC4).withOpacity(0.9),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDayTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Day (e.g., Monday)',
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.calendar_today_rounded,
            color: Colors.white70,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a day';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubjectAttendanceField({
    required Subject subject,
    required ValueChanged<String> onChanged,
  }) {
    final controller = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: Text(
            subject.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withOpacity(0.2),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              onChanged: onChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '';
                }
                if (int.tryParse(value) == null) {
                  return 'Invalid';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditDialog(
    int index,
    Subject subject,
    TextEditingController attendedController,
    TextEditingController missedController,
  ) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      title: const Text(
        'Edit Attendance',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEditTextField(
            controller: attendedController,
            label: 'Classes Attended',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF4ECDC4),
          ),
          const SizedBox(height: 16),
          _buildEditTextField(
            controller: missedController,
            label: 'Classes Missed',
            icon: Icons.cancel_rounded,
            color: const Color(0xFFFF6B6B),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
            ),
          ),
          child: TextButton(
            onPressed: () {
              final attended =
                  int.tryParse(attendedController.text) ?? subject.attended;
              final missed =
                  int.tryParse(missedController.text) ?? subject.missed;

              subjectsBox.putAt(
                index,
                Subject(
                  name: subject.name,
                  attended: attended,
                  missed: missed,
                  requiredAttendance: subject.requiredAttendance,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: color,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
