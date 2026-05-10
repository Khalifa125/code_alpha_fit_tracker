// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/routing/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String? _selectedGoal;
  String? _selectedFitness;
  int _selectedTime = 30;

  final List<Map<String, dynamic>> _goals = [
    {'id': 'lose_weight', 'name': 'Lose Weight', 'icon': Icons.monitor_weight_outlined, 'desc': 'Burn fat & get lean'},
    {'id': 'build_muscle', 'name': 'Build Muscle', 'icon': Icons.fitness_center, 'desc': 'Gain strength & size'},
    {'id': 'stay_active', 'name': 'Stay Active', 'icon': Icons.directions_run, 'desc': 'Maintain fitness'},
    {'id': 'endurance', 'name': 'Endurance', 'icon': Icons.timer, 'desc': 'Boost stamina'},
  ];

  final List<Map<String, dynamic>> _fitnessLevels = [
    {'id': 'beginner', 'name': 'Beginner', 'desc': 'New to fitness', 'icon': Icons.sentiment_satisfied_outlined},
    {'id': 'intermediate', 'name': 'Intermediate', 'desc': 'Active lifestyle', 'icon': Icons.trending_up},
    {'id': 'advanced', 'name': 'Advanced', 'desc': 'Experienced', 'icon': Icons.whatshot},
  ];

  final List<int> _timeOptions = [15, 30, 45, 60];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (_selectedGoal != null) await prefs.setString('user_goal', _selectedGoal!);
    if (_selectedFitness != null) await prefs.setString('fitness_level', _selectedFitness!);
    await prefs.setInt('available_time', _selectedTime);
    if (mounted) context.go(AppRoutes.home);
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0: return _selectedGoal != null;
      case 1: return _selectedFitness != null;
      case 2: return _selectedTime > 0;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [FitColors.neonGreen, FitColors.neonGreen.withOpacity(0.6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
                      ),
                      SizedBox(width: 10.w),
                      Text('FitTracker', style: TextStyle(
                        color: FitColors.textPrimaryDark,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      )),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text('Skip', style: TextStyle(color: FitColors.textSecondaryDark)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            _buildProgressDots(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildGoalPage(),
                  _buildFitnessPage(),
                  _buildTimePage(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _canProceed ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    disabledBackgroundColor: FitColors.surfaceDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == 2 ? 'Start Journey' : 'Continue',
                    style: TextStyle(
                      color: _canProceed ? Colors.black : FitColors.textSecondaryDark,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: List.generate(3, (index) => Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            height: 3.h,
            decoration: BoxDecoration(
              color: index <= _currentPage ? FitColors.neonGreen : FitColors.surfaceDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What\'s your goal?', style: TextStyle(
            color: FitColors.textPrimaryDark,
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          )).animate().fadeIn().slideX(begin: -0.1),
          SizedBox(height: 8.h),
          Text('Choose the goal that matches what you want to achieve', style: TextStyle(
            color: FitColors.textSecondaryDark.withOpacity(0.7),
            fontSize: 14.sp,
          )).animate().fadeIn(delay: 50.ms),
          SizedBox(height: 24.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1.1,
              ),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final isSelected = _selectedGoal == goal['id'];
                return GestureDetector(
                  key: ValueKey('goal_${goal['id']}'),
                  onTap: () => setState(() => _selectedGoal = goal['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: isSelected ? FitColors.neonGreen.withOpacity(0.12) : FitColors.cardDark,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected ? FitColors.neonGreen : FitColors.borderDark,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: isSelected ? FitColors.neonGreen.withOpacity(0.2) : FitColors.surfaceDark,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(goal['icon'], color: isSelected ? FitColors.neonGreen : FitColors.textSecondaryDark, size: 22),
                        ),
                        SizedBox(height: 10.h),
                        Text(goal['name'], style: TextStyle(
                          color: isSelected ? FitColors.neonGreen : FitColors.textPrimaryDark,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ), textAlign: TextAlign.center),
                        SizedBox(height: 2.h),
                        Text(goal['desc'], style: TextStyle(
                          color: FitColors.textSecondaryDark.withOpacity(0.6),
                          fontSize: 10.sp,
                        ), textAlign: TextAlign.center),
                      ],
                    ),
                  ).animate().fadeIn(delay: (100 + index * 50).ms).scale(begin: const Offset(0.95, 0.95)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessPage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your fitness level', style: TextStyle(
            color: FitColors.textPrimaryDark,
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          )).animate().fadeIn().slideX(begin: -0.1),
          SizedBox(height: 8.h),
          Text('This helps us personalize your training plan', style: TextStyle(
            color: FitColors.textSecondaryDark.withOpacity(0.7),
            fontSize: 14.sp,
          )).animate().fadeIn(delay: 50.ms),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView.builder(
              itemCount: _fitnessLevels.length,
              itemBuilder: (context, index) {
                final level = _fitnessLevels[index];
                final isSelected = _selectedFitness == level['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedFitness = level['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: isSelected ? FitColors.neonGreen.withOpacity(0.12) : FitColors.cardDark,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected ? FitColors.neonGreen : FitColors.borderDark,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: isSelected ? FitColors.neonGreen.withOpacity(0.2) : FitColors.surfaceDark,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(level['icon'], color: isSelected ? FitColors.neonGreen : FitColors.textSecondaryDark, size: 22),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(level['name'], style: TextStyle(
                                color: isSelected ? FitColors.neonGreen : FitColors.textPrimaryDark,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              )),
                              SizedBox(height: 2.h),
                              Text(level['desc'], style: TextStyle(
                                color: FitColors.textSecondaryDark.withOpacity(0.6),
                                fontSize: 12.sp,
                              )),
                            ],
                          ),
                        ),
                        if (isSelected) Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: const BoxDecoration(
                            color: FitColors.neonGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.black, size: 14),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(begin: 0.05),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available time', style: TextStyle(
            color: FitColors.textPrimaryDark,
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          )).animate().fadeIn().slideX(begin: -0.1),
          SizedBox(height: 8.h),
          Text('How much time can you dedicate to each workout?', style: TextStyle(
            color: FitColors.textSecondaryDark.withOpacity(0.7),
            fontSize: 14.sp,
          )).animate().fadeIn(delay: 50.ms),
          SizedBox(height: 32.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _timeOptions.map((time) {
              final isSelected = _selectedTime == time;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (MediaQuery.of(context).size.width - 60) / 2,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  decoration: BoxDecoration(
                    color: isSelected ? FitColors.neonGreen.withOpacity(0.12) : FitColors.cardDark,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected ? FitColors.neonGreen : FitColors.borderDark,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('$time', style: TextStyle(
                        color: isSelected ? FitColors.neonGreen : FitColors.textPrimaryDark,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      )),
                      SizedBox(height: 2.h),
                      Text('min', style: TextStyle(
                        color: FitColors.textSecondaryDark.withOpacity(0.6),
                        fontSize: 12.sp,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: FitColors.surfaceDark,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: FitColors.borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: FitColors.textSecondaryDark, size: 18),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'You can adjust this anytime in Profile > Settings',
                    style: TextStyle(color: FitColors.textSecondaryDark.withOpacity(0.7), fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}