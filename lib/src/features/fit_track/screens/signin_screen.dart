// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/fit_track/providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              
              // Logo
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FitColors.neonGreen,
                        FitColors.neonGreen.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: FitColors.neonGreen.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Icon(Icons.fitness_center, color: Colors.white, size: 40.sp),
                ),
              ).animate().fadeIn().scale(),
              
              SizedBox(height: 32.h),
              
              // Title
              Center(
                child: Text(
                  'Fit Track',
                  style: TextStyle(
                    color: FitColors.textPrimary,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms),
              
              Center(
                child: Text(
                  'Your personal fitness journey',
                  style: TextStyle(
                    color: FitColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ).animate().fadeIn(delay: 150.ms),
              
              SizedBox(height: 48.h),
              
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: FitColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: FitColors.textMuted),
                        prefixIcon: Icon(Icons.email_outlined, color: FitColors.textMuted),
                        filled: true,
                        fillColor: FitColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: FitColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: FitColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: FitColors.neonGreen, width: 2),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    
                    SizedBox(height: 16.h),
                    
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: FitColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: FitColors.textMuted),
                        prefixIcon: Icon(Icons.lock_outline, color: FitColors.textMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: FitColors.textMuted,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: FitColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: FitColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: FitColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          borderSide: BorderSide(color: FitColors.neonGreen, width: 2),
                        ),
                      ),
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),
                    
                    SizedBox(height: 8.h),
                    
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: FitColors.neonGreen,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    
                    SizedBox(height: 24.h),
                    
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FitColors.neonGreen,
                          disabledBackgroundColor: FitColors.border,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                    
                    SizedBox(height: 16.h),
                    
                    // Sign Up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: FitColors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: FitColors.neonGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: FitColors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final success = await ref.read(authProvider.notifier).signIn(
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password'),
          backgroundColor: FitColors.orange,
        ),
      );
    }
  }
}