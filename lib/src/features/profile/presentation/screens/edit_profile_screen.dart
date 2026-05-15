import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: FitColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Profile', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: FitColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    ref.read(authStateProvider.notifier).updateUserName(_nameController.text);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated!'), backgroundColor: FitColors.neonGreen),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.neonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
