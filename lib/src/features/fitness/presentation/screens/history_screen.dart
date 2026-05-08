// ─── history_screen.dart ───────────────────────────────────────────────────
// ignore_for_file: unnecessary_import

import 'package:fit_tracker/src/imports/core_imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: Text('Activity History', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: activitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: FitColors.cyan, strokeWidth: 2)),
        error: (_, __) => const Center(child: Text('Error loading history', style: TextStyle(color: FitColors.textSecondary))),
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(child: FitEmptyState(emoji: '📋', message: 'No activities yet.\nStart logging your workouts!'));
          }

          // Group by date
          final grouped = <String, List<ActivityModel>>{};
          for (final a in activities) {
            final key = DateFormat('EEEE, MMM d').format(a.date);
            grouped.putIfAbsent(key, () => []).add(a);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: grouped.length,
            itemBuilder: (_, i) {
              final dateKey = grouped.keys.elementAt(i);
              final dayActivities = grouped[dateKey]!;
              final totalCals = dayActivities.fold<double>(0, (sum, a) => sum + a.caloriesBurned);

              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h, top: i == 0 ? 0 : 8.h),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(dateKey, style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    Text('${totalCals.toStringAsFixed(0)} kcal', style: TextStyle(color: FitColors.orange, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                  ]),
                ),
                ...dayActivities.map((a) => ActivityTile(
                  activity: a,
                  showDate: false,
                  onDelete: () async {
                    await ref.read(fitnessRepoProvider).deleteActivity(a.id);
                    ref.invalidate(allActivitiesProvider);
                  },
                )),
              ]);
            },
          );
        },
      ),
    );
  }
}
