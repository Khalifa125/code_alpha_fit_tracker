// ignore_for_file: use_if_null_to_convert_nulls_to_bools, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/home/presentation/screens/home_page.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authStateProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: FitColors.background,
      appBar: AppBar(
        backgroundColor: FitColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: FitColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sign Up', style: TextStyle(color: FitColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (v) => v?.isEmpty == true ? 'Name required' : null,
                style: TextStyle(color: FitColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Full name',
                  hintStyle: TextStyle(color: FitColors.textMuted),
                  filled: true,
                  fillColor: FitColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FitColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                validator: (v) => v?.isEmpty == true ? 'Email required' : null,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: FitColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: FitColors.textMuted),
                  filled: true,
                  fillColor: FitColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FitColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                validator: (v) => v?.isEmpty == true ? 'Password required' : null,
                obscureText: _obscurePassword,
                style: TextStyle(color: FitColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: FitColors.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: FitColors.textMuted),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: FitColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: FitColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    foregroundColor: FitColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}