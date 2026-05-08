// ignore_for_file: unnecessary_import, unused_import

import 'package:fit_tracker/src/imports/core_imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';

class AddActivityScreen extends ConsumerStatefulWidget {
  const AddActivityScreen({super.key});

  @override
  ConsumerState<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends ConsumerState<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Running';
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  static const _types = [
    ('Running', Icons.directions_run_rounded, Color(0xFFFF6B35)),
    ('Walking', Icons.directions_walk_rounded, Color(0xFF00E5FF)),
    ('Cycling', Icons.directions_bike_rounded, Color(0xFF7C4DFF)),
    ('Swimming', Icons.pool_rounded, Color(0xFF00B0FF)),
    ('Gym', Icons.fitness_center_rounded, Color(0xFFFF4081)),
    ('Yoga', Icons.self_improvement_rounded, Color(0xFF00E676)),
    ('HIIT', Icons.flash_on_rounded, Color(0xFFFFD740)),
    ('Other', Icons.sports_rounded, Color(0xFF8899AA)),
  ];

  static const _metsPerMin = {
    'Running': 11.5, 'Walking': 3.5, 'Cycling': 8.0,
    'Swimming': 9.0, 'Gym': 5.5, 'Yoga': 2.5, 'HIIT': 12.0, 'Other': 5.0,
  };

  void _autoCalc() {
    final dur = int.tryParse(_durationCtrl.text) ?? 0;
    if (dur > 0 && _caloriesCtrl.text.isEmpty) {
      final cal = ((_metsPerMin[_selectedType] ?? 5.0) * dur * 70 / 200).round();
      _caloriesCtrl.text = cal.toString();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repo = ref.read(fitnessRepoProvider);
    await repo.saveActivity(ActivityModel(
      id: repo.generateId(),
      type: _selectedType,
      durationMinutes: int.parse(_durationCtrl.text),
      caloriesBurned: double.parse(_caloriesCtrl.text),
      steps: int.tryParse(_stepsCtrl.text) ?? 0,
      date: DateTime.now(),
      notes: _notesCtrl.text.trim(),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    _stepsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: Text('Log Activity',
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // Activity Type Selector
            Text('Activity Type',
                style: TextStyle(color: FitColors.textSecondary, fontSize: 13.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 10.h),
            SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _types.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (_, i) {
                  final (name, icon, color) = _types[i];
                  final selected = name == _selectedType;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedType = name;
                      _caloriesCtrl.clear();
                    }),
                    child: AnimatedContainer(
                      duration: NumExtension(200).ms,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: selected ? color.withOpacity(0.12) : FitColors.card,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: selected ? color : FitColors.border, width: 1.5),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(icon, color: selected ? color : FitColors.textSecondary, size: 26.sp),
                        SizedBox(height: 6.h),
                        Text(name,
                            style: TextStyle(
                                color: selected ? color : FitColors.textSecondary,
                                fontSize: 11.sp,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),

            // Duration
            _FitInput(
              controller: _durationCtrl,
              label: 'Duration (minutes)',
              hint: 'e.g. 30',
              icon: Icons.timer_rounded,
              keyboardType: TextInputType.number,
              onChanged: (_) => _autoCalc(),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter duration' : null,
            ),
            SizedBox(height: 14.h),

            // Calories
            _FitInput(
              controller: _caloriesCtrl,
              label: 'Calories Burned',
              hint: 'Auto-calculated or enter manually',
              icon: Icons.local_fire_department_rounded,
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter calories' : null,
            ),
            SizedBox(height: 14.h),

            // Steps
            _FitInput(
              controller: _stepsCtrl,
              label: 'Steps (optional)',
              hint: 'e.g. 5000',
              icon: Icons.directions_walk_rounded,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 14.h),

            // Notes
            _FitInput(
              controller: _notesCtrl,
              label: 'Notes (optional)',
              hint: 'How did it feel?',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            SizedBox(height: 32.h),

            // Save Button
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.cyan,
                  foregroundColor: const Color(0xFF0A0E1A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Color(0xFF0A0E1A), strokeWidth: 2)
                    : Text('Save Activity',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FitInput extends StatelessWidget {
  const _FitInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 13.sp, fontWeight: FontWeight.w500)),
      SizedBox(height: 8.h),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: FitColors.textSecondary.withOpacity(0.5), fontSize: 13.sp),
          prefixIcon: Icon(icon, color: FitColors.cyan, size: 18.sp),
          filled: true,
          fillColor: FitColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: FitColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: FitColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: FitColors.cyan, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.redAccent)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.redAccent)),
        ),
      ),
    ]);
  }
}
