import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Forgot Password', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.lock_reset_rounded, color: FitColors.neonGreen, size: 64),
            const SizedBox(height: 24),
            Text(
              'Reset Password',
              style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your email to receive reset instructions',
              style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
              decoration: InputDecoration(
                hintText: 'Enter your email',
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
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent!'),
                      backgroundColor: FitColors.neonGreen,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.neonGreen,
                  foregroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
