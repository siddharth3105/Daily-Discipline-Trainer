import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'create_workout_plan_screen.dart';
import 'create_diet_plan_screen.dart';
import 'create_schedule_screen.dart';

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});
  @override State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  int _tabIdx = 0; // 0=schedules, 1=workouts, 2=diet plans

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('MY PLANS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim, letterSpacing: 2)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrim), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        // Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(children: [
            _buildTab('📅 SCHEDULES', 0),
            const SizedBox(width: 5),
            _buildTab('💪 WORKOUTS', 1),
            const SizedBox(width: 5),
            _buildTab('🍽️ DIET', 2),
          ]),
        ),
        Expanded(child: IndexedStack(index: _tabIdx, children: const [
          _SchedulesTab(),
          _WorkoutsTab(),
          _DietPlansTab(),
        ])),
      ]),
    );
  }

  Widget _buildTab(String label, int idx) {
    final active = _tabIdx == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tabIdx = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.hiit.withOpacity(0.1) : AppColors.card,
          border: Border.all(color: active ? AppColors.hiit : AppColors.border),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: active ? AppColors.hiit : AppColors.textSub, letterSpacing: 1))),
      ),
    ));
  }
}

// ── SCHEDULES TAB ─────────────────────────────────────────────────────────────
class _SchedulesTab extends StatelessWidget {
  const _SchedulesTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      // Info card
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('📅  WEEKLY SCHEDULES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.hiit, letterSpacing: 1)),
        SizedBox(height: 8),
        Text('Create custom weekly schedules combining your workout and diet plans. Switch between auto-generated and custom plans anytime.', style: TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.5)),
      ])),
      const SizedBox(height: 12),

      // Auto-generated schedule
      _ScheduleCard(
        name: 'Auto-Generated Plan',
        description: 'Default weekly workout rotation with recommended diet plans',
        isActive: prov.activeScheduleId == null,
        isCustom: false,
        onTap: () => prov.setActiveSchedule(null),
      ),
      const SizedBox(height: 8),

      // Custom schedules
      ...prov.weeklySchedules.map((schedule) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _ScheduleCard(
          name: schedule.name,
          description: '${schedule.workoutSchedule.length} days planned',
          isActive: prov.activeScheduleId == schedule.id,
          isCustom: true,
          onTap: () => prov.setActiveSchedule(schedule.id),
          onDelete: () => _confirmDelete(context, () => prov.removeWeeklySchedule(schedule.id)),
        ),
      )),

      const SizedBox(height: 12),
      // Create new button
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateScheduleScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.hiit.withOpacity(0.1),
            border: Border.all(color: AppColors.hiit),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Center(child: Text('+ CREATE NEW SCHEDULE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.hiit, letterSpacing: 2))),
        ),
      ),
    ]);
  }
}

class _ScheduleCard extends StatelessWidget {
  final String name, description;
  final bool isActive, isCustom;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  const _ScheduleCard({required this.name, required this.description, required this.isActive, required this.isCustom, required this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? AppColors.hiit.withOpacity(0.1) : AppColors.card,
          border: Border.all(color: isActive ? AppColors.hiit : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: isActive ? AppColors.hiit : AppColors.card2,
              border: Border.all(color: isActive ? AppColors.hiit : AppColors.border2, width: 2),
              shape: BoxShape.circle,
            ),
            child: isActive ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isActive ? AppColors.hiit : AppColors.textPrim)),
            Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
          ])),
          if (isCustom && onDelete != null)
            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textDim), onPressed: onDelete),
        ]),
      ),
    );
  }
}

// ── WORKOUTS TAB ──────────────────────────────────────────────────────────────
class _WorkoutsTab extends StatelessWidget {
  const _WorkoutsTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('💪  CUSTOM WORKOUTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.hiit, letterSpacing: 1)),
        SizedBox(height: 8),
        Text('Build your own workout routines with custom exercises, sets, reps, and rest times.', style: TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.5)),
      ])),
      const SizedBox(height: 12),

      if (prov.customWorkouts.isEmpty)
        DarkCard(child: Column(children: const [
          Text('📝', style: TextStyle(fontSize: 48)),
          SizedBox(height: 8),
          Text('No custom workouts yet', style: TextStyle(fontSize: 14, color: AppColors.textDim)),
          SizedBox(height: 4),
          Text('Create your first workout plan', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
        ]))
      else
        ...prov.customWorkouts.map((workout) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(workout.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
                Text(workout.description, style: const TextStyle(fontSize: 12, color: AppColors.textDim)),
              ])),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textDim), onPressed: () => _confirmDelete(context, () => prov.removeCustomWorkout(workout.id))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _InfoChip('${workout.exercises.length} exercises', AppColors.bodyweight),
              const SizedBox(width: 6),
              _InfoChip('~${workout.totalCalories} kcal', AppColors.hiit),
            ]),
          ]),
        )),

      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateWorkoutPlanScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.hiit.withOpacity(0.1), border: Border.all(color: AppColors.hiit), borderRadius: BorderRadius.circular(13)),
          child: const Center(child: Text('+ CREATE NEW WORKOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.hiit, letterSpacing: 2))),
        ),
      ),
    ]);
  }
}

// ── DIET PLANS TAB ────────────────────────────────────────────────────────────
class _DietPlansTab extends StatelessWidget {
  const _DietPlansTab();

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('🍽️  CUSTOM DIET PLANS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.hiit, letterSpacing: 1)),
        SizedBox(height: 8),
        Text('Design personalized meal plans with your own meals, timing, and macro targets.', style: TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.5)),
      ])),
      const SizedBox(height: 12),

      if (prov.customDietPlans.isEmpty)
        DarkCard(child: Column(children: const [
          Text('🍴', style: TextStyle(fontSize: 48)),
          SizedBox(height: 8),
          Text('No custom diet plans yet', style: TextStyle(fontSize: 14, color: AppColors.textDim)),
          SizedBox(height: 4),
          Text('Create your first meal plan', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
        ]))
      else
        ...prov.customDietPlans.map((plan) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
                Text(plan.description, style: const TextStyle(fontSize: 12, color: AppColors.textDim)),
              ])),
              IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textDim), onPressed: () => _confirmDelete(context, () => prov.removeCustomDietPlan(plan.id))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              _InfoChip('${plan.meals.length} meals', AppColors.strength),
              const SizedBox(width: 6),
              _InfoChip('${plan.goalCalories} kcal goal', AppColors.hiit),
            ]),
          ]),
        )),

      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDietPlanScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.hiit.withOpacity(0.1), border: Border.all(color: AppColors.hiit), borderRadius: BorderRadius.circular(13)),
          child: const Center(child: Text('+ CREATE NEW DIET PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.hiit, letterSpacing: 2))),
        ),
      ),
    ]);
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
  );
}

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Delete?', style: TextStyle(color: AppColors.textPrim)),
      content: const Text('This action cannot be undone.', style: TextStyle(color: AppColors.textSub)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppColors.textDim))),
        TextButton(onPressed: () { Navigator.pop(context); onConfirm(); }, child: const Text('DELETE', style: TextStyle(color: AppColors.hiit))),
      ],
    ),
  );
}
