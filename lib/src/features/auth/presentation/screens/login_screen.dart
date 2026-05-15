// ignore_for_file: deprecated_member_use, use_if_null_to_convert_nulls_to_bools, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authStateProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _emailController.text.split('@').first,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: FitColors.neonGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.fitness_center_rounded,
                      color: FitColors.neonGreen,
                      size: 40,
                    ),
                  ),
                ).animate().fadeIn().scale(),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Sign in to continue',
                    style: TextStyle(
                      color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Text('Email', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  validator: (v) => v?.isEmpty == true ? 'Email required' : null,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    hintStyle: TextStyle(color: isDark ? FitColors.textSecondaryDark.withValues(alpha: 0.6) : FitColors.textSecondaryLight.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.email_outlined, color: isDark ? FitColors.textSecondaryDark.withValues(alpha: 0.6) : FitColors.textSecondaryLight.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: isDark ? FitColors.cardDark : FitColors.cardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: FitColors.neonGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Password', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  validator: (v) => v?.isEmpty == true ? 'Password required' : null,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TextStyle(color: isDark ? FitColors.textSecondaryDark.withValues(alpha: 0.6) : FitColors.textSecondaryLight.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.lock_outline, color: isDark ? FitColors.textSecondaryDark.withValues(alpha: 0.6) : FitColors.textSecondaryLight.withValues(alpha: 0.6)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: isDark ? FitColors.textSecondaryDark.withValues(alpha: 0.6) : FitColors.textSecondaryLight.withValues(alpha: 0.6)),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: isDark ? FitColors.cardDark : FitColors.cardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: FitColors.neonGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FitColors.neonGreen,
                      foregroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
