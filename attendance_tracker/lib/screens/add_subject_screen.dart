import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/subject.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _attendanceController = TextEditingController();
  double? _requiredAttendance;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Predefined subject suggestions
  final List<String> _subjectSuggestions = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'English Literature',
    'History',
    'Geography',
    'Economics',
    'Psychology',
    'Philosophy',
    'Statistics',
    'Data Structures',
    'Algorithms',
    'Database Management',
    'Software Engineering',
    'Web Development',
    'Machine Learning',
    'Artificial Intelligence',
    'Operating Systems',
  ];

  List<String> _filteredSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();

    // Set default attendance requirement
    _attendanceController.text = '75';
    _requiredAttendance = 75.0;

    // Add listener for subject name field
    _nameController.addListener(_onSubjectNameChanged);
  }

  void _onSubjectNameChanged() {
    final query = _nameController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _filteredSuggestions = [];
      });
      return;
    }

    setState(() {
      _filteredSuggestions = _subjectSuggestions
          .where((subject) => subject.toLowerCase().contains(query))
          .take(5)
          .toList();
      _showSuggestions = _filteredSuggestions.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _attendanceController.dispose();
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
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
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
          'Add Subject',
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

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildFormCard(),
          const SizedBox(height: 24),
          if (_showSuggestions) _buildSuggestionsCard(),
          const SizedBox(height: 100), // Space for floating action button
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                      ),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Subject',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add a subject to start tracking your attendance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
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
    );
  }

  Widget _buildFormCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Subject Details'),
                    const SizedBox(height: 20),
                    _buildSubjectNameField(),
                    const SizedBox(height: 20),
                    _buildAttendanceField(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildSubjectNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _nameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter subject name',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.book_rounded,
                color: const Color(0xFF6C63FF).withOpacity(0.8),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a subject name';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Attendance %',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _attendanceController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '75',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.percent_rounded,
                color: const Color(0xFF4ECDC4).withOpacity(0.8),
                size: 20,
              ),
              suffixText: '%',
              suffixStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= 0 && parsed <= 100) {
                  _requiredAttendance = parsed;
                }
              } else {
                _requiredAttendance = 75.0;
              }
            },
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final parsed = double.tryParse(value);
                if (parsed == null || parsed < 0 || parsed > 100) {
                  return 'Please enter a valid percentage (0-100)';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Default is 75%. Most institutions require 75% attendance.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isLoading ? null : _saveSubject,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add Subject',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: const Color(0xFFFFB74D),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Suggestions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFB74D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._filteredSuggestions.map((suggestion) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _nameController.text = suggestion;
                          setState(() {
                            _showSuggestions = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveSubject() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final subject = Subject(
          name: _nameController.text.trim(),
          requiredAttendance: _requiredAttendance ?? 75.0,
        );

        await Hive.box<Subject>('subjects').add(subject);

        // Scale animation for success
        _scaleController.forward();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4ECDC4),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Subject "${_nameController.text}" added successfully!',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF1A1A2E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate back after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF6B6B),
                      ),
                      child: const Icon(
                        Icons.error_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Failed to add subject. Please try again.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF1A1A2E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          );
        }
      }
    }
  }
}
