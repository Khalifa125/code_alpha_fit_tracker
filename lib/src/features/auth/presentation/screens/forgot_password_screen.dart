import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: FitColors.background,
      appBar: AppBar(
        backgroundColor: FitColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FitColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Forgot Password', style: TextStyle(color: FitColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.lock_reset_rounded, color: FitColors.neonGreen, size: 64),
            const SizedBox(height: 24),
            const Text(
              'Reset Password',
              style: TextStyle(
                color: FitColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email to receive reset instructions',
              style: TextStyle(color: FitColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: FitColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: const TextStyle(color: FitColors.textMuted),
                prefixIcon: const Icon(Icons.email_outlined, color: FitColors.textMuted),
                filled: true,
                fillColor: FitColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: FitColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: FitColors.border),
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
                  foregroundColor: FitColors.background,
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
