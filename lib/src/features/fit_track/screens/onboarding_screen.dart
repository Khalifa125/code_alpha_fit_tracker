import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/fit_track/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/fit_track/providers/workout_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String? _selectedGoal;
  String? _selectedFitness;
  int _selectedMinutes = 20;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: i <= _currentPage 
                          ? FitColors.neonGreen 
                          : FitColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                )),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildGoalPage(),
                  _buildFitnessPage(),
                  _buildTimePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPage() => Padding(
    padding: EdgeInsets.all(24.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is your\nfitness goal?',
          style: TextStyle(
            color: FitColors.textPrimary,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        SizedBox(height: 8.h),
        Text(
          'We\'ll personalize your workouts\nto help you achieve it',
          style: TextStyle(
            color: FitColors.textSecondary,
            fontSize: 14.sp,
          ),
        ).animate().fadeIn(delay: 100.ms),
        SizedBox(height: 32.h),
        
        _buildOptionCard(
          title: 'Lose Weight',
          subtitle: 'Burn fat and get leaner',
          icon: Icons.local_fire_department,
          color: FitColors.orange,
          isSelected: _selectedGoal == 'loseWeight',
          onTap: () => setState(() => _selectedGoal = 'loseWeight'),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        SizedBox(height: 16.h),
        
        _buildOptionCard(
          title: 'Build Muscle',
          subtitle: 'Gain strength and size',
          icon: Icons.fitness_center,
          color: FitColors.neonGreen,
          isSelected: _selectedGoal == 'buildMuscle',
          onTap: () => setState(() => _selectedGoal = 'buildMuscle'),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
        SizedBox(height: 16.h),
        
        _buildOptionCard(
          title: 'Stay Active',
          subtitle: 'Maintain your fitness',
          icon: Icons.directions_run,
          color: FitColors.blue,
          isSelected: _selectedGoal == 'stayActive',
          onTap: () => setState(() => _selectedGoal = 'stayActive'),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        
        const Spacer(),
        _buildNextButton(),
      ],
    ),
  );

  Widget _buildFitnessPage() => Padding(
    padding: EdgeInsets.all(24.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your\nfitness level?',
          style: TextStyle(
            color: FitColors.textPrimary,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        SizedBox(height: 8.h),
        Text(
          'This helps us choose the right exercises',
          style: TextStyle(
            color: FitColors.textSecondary,
            fontSize: 14.sp,
          ),
        ).animate().fadeIn(delay: 100.ms),
        SizedBox(height: 32.h),
        
        _buildOptionCard(
          title: 'Beginner',
          subtitle: 'New to fitness',
          icon: Icons.sentiment_satisfied,
          color: FitColors.neonGreen,
          isSelected: _selectedFitness == 'beginner',
          onTap: () => setState(() => _selectedFitness = 'beginner'),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        SizedBox(height: 16.h),
        
        _buildOptionCard(
          title: 'Intermediate',
          subtitle: 'Regular exerciser',
          icon: Icons.sentiment_very_satisfied,
          color: FitColors.amber,
          isSelected: _selectedFitness == 'intermediate',
          onTap: () => setState(() => _selectedFitness = 'intermediate'),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
        SizedBox(height: 16.h),
        
        _buildOptionCard(
          title: 'Advanced',
          subtitle: 'Experienced athlete',
          icon: Icons.emoji_events,
          color: FitColors.purple,
          isSelected: _selectedFitness == 'advanced',
          onTap: () => setState(() => _selectedFitness = 'advanced'),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
        
        const Spacer(),
        _buildNextButton(),
      ],
    ),
  );

  Widget _buildTimePage() => Padding(
    padding: EdgeInsets.all(24.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How much time\ndo you have?',
          style: TextStyle(
            color: FitColors.textPrimary,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        SizedBox(height: 8.h),
        Text(
          'We\'ll create a workout that fits your schedule',
          style: TextStyle(
            color: FitColors.textSecondary,
            fontSize: 14.sp,
          ),
        ).animate().fadeIn(delay: 100.ms),
        SizedBox(height: 32.h),
        
        Row(
          children: [10, 20, 30].map((minutes) => Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: GestureDetector(
                onTap: () => setState(() => _selectedMinutes = minutes),
                child: AnimatedContainer(
                  duration: 300.ms,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: _selectedMinutes == minutes
                        ? FitColors.neonGreen.withValues(alpha: 0.15)
                        : FitColors.card,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: _selectedMinutes == minutes
                          ? FitColors.neonGreen
                          : FitColors.border,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$minutes',
                        style: TextStyle(
                          color: _selectedMinutes == minutes
                              ? FitColors.neonGreen
                              : FitColors.textPrimary,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'min',
                        style: TextStyle(
                          color: FitColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: (minutes * 100).ms).scale(begin: const Offset(0.9, 0.9)),
              ),
            ),
          )).toList(),
        ),
        
        const Spacer(),
        _buildCompleteButton(),
      ],
    ),
  );

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : FitColors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? color : FitColors.border,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: -4,
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: FitColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _canProceed() ? () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: FitColors.neonGreen,
        disabledBackgroundColor: FitColors.border,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: Text(
        'Continue',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ).animate().fadeIn(delay: 500.ms),
  );

  Widget _buildCompleteButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _canComplete() ? _completeOnboarding : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: FitColors.neonGreen,
        disabledBackgroundColor: FitColors.border,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
      child: Text(
        'Start My Journey',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ).animate().fadeIn(delay: 500.ms),
  );

  bool _canProceed() {
    if (_currentPage == 0) return _selectedGoal != null;
    if (_currentPage == 1) return _selectedFitness != null;
    return false;
  }

  bool _canComplete() {
    return _selectedGoal != null && _selectedFitness != null;
  }

  void _completeOnboarding() async {
    await ref.read(authProvider.notifier).completeOnboarding(
      goal: _selectedGoal!,
      fitnessLevel: _selectedFitness!,
      availableMinutes: _selectedMinutes,
    );
    
    ref.read(workoutProvider.notifier).generateWorkout(
      goal: _selectedGoal!,
      fitnessLevel: _selectedFitness!,
      availableMinutes: _selectedMinutes,
    );
  }
}