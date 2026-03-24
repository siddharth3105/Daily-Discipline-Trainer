import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({super.key});
  @override State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  final _nameCtrl = TextEditingController();
  final Map<int, String> _workoutSchedule = {};
  String _dietPlanId = 'muscle';

  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  void _selectWorkout(int dayIdx) {
    final prov = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('SELECT WORKOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim, letterSpacing: 2)),
        ),
        // Rest day
        ListTile(
          leading: const Icon(Icons.hotel, color: AppColors.flex),
          title: const Text('Rest Day', style: TextStyle(color: AppColors.textPrim)),
          onTap: () {
            setState(() => _workoutSchedule[dayIdx] = 'rest');
            Navigator.pop(context);
          },
        ),
        const Divider(color: AppColors.border),
        // Default categories
        ...exerciseCategories.map((cat) => ListTile(
          leading: Text(cat.icon, style: const TextStyle(fontSize: 20)),
          title: Text(cat.label, style: const TextStyle(color: AppColors.textPrim)),
          onTap: () {
            setState(() => _workoutSchedule[dayIdx] = cat.key);
            Navigator.pop(context);
          },
        )),
        const Divider(color: AppColors.border),
        // Custom workouts
        if (prov.customWorkouts.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('CUSTOM WORKOUTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          ),
          ...prov.customWorkouts.map((workout) => ListTile(
            leading: const Icon(Icons.fitness_center, color: AppColors.hiit),
            title: Text(workout.name, style: const TextStyle(color: AppColors.textPrim)),
            subtitle: Text('${workout.exercises.length} exercises', style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
            onTap: () {
              setState(() => _workoutSchedule[dayIdx] = 'custom:${workout.id}');
              Navigator.pop(context);
            },
          )),
        ],
        const SizedBox(height: 16),
      ])),
    );
  }

  void _selectDietPlan() {
    final prov = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('SELECT DIET PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim, letterSpacing: 2)),
        ),
        // Default plans
        ...dietPlans.entries.map((e) => ListTile(
          leading: const Icon(Icons.restaurant, color: AppColors.hiit),
          title: Text(e.value.label, style: const TextStyle(color: AppColors.textPrim)),
          subtitle: Text('${e.value.goalCalories} kcal/day', style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          onTap: () {
            setState(() => _dietPlanId = e.key);
            Navigator.pop(context);
          },
        )),
        const Divider(color: AppColors.border),
        // Custom plans
        if (prov.customDietPlans.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('CUSTOM DIET PLANS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          ),
          ...prov.customDietPlans.map((plan) => ListTile(
            leading: const Icon(Icons.restaurant_menu, color: AppColors.hiit),
            title: Text(plan.name, style: const TextStyle(color: AppColors.textPrim)),
            subtitle: Text('${plan.goalCalories} kcal/day · ${plan.meals.length} meals', style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
            onTap: () {
              setState(() => _dietPlanId = 'custom:${plan.id}');
              Navigator.pop(context);
            },
          )),
        ],
        const SizedBox(height: 16),
      ])),
    );
  }

  String _getWorkoutLabel(String id) {
    if (id == 'rest') return '😴 Rest Day';
    if (id.startsWith('custom:')) {
      final workoutId = id.substring(7);
      final workout = context.read<AppProvider>().customWorkouts.firstWhere((w) => w.id == workoutId, orElse: () => CustomWorkout(id: '', name: 'Unknown', description: '', exercises: []));
      return '💪 ${workout.name}';
    }
    final cat = exerciseCategories.firstWhere((c) => c.key == id, orElse: () => const ExerciseCategory(key: '', label: 'Unknown', emoji: '❓', exercises: [], color: 0xFF666666, icon: '❓'));
    return '${cat.icon} ${cat.label}';
  }

  String _getDietLabel() {
    if (_dietPlanId.startsWith('custom:')) {
      final planId = _dietPlanId.substring(7);
      final plan = context.read<AppProvider>().customDietPlans.firstWhere((p) => p.id == planId, orElse: () => CustomDietPlan(id: '', name: 'Unknown', description: '', goalCalories: 0, meals: []));
      return plan.name;
    }
    return dietPlans[_dietPlanId]?.label ?? 'Unknown';
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a schedule name')));
      return;
    }
    final schedule = WeeklySchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      workoutSchedule: _workoutSchedule,
      dietPlanId: _dietPlanId,
    );
    context.read<AppProvider>().addWeeklySchedule(schedule);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('CREATE SCHEDULE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim, letterSpacing: 2)),
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textPrim), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SCHEDULE NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrim, fontSize: 16, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(hintText: 'e.g. My Custom Plan', isDense: true, contentPadding: EdgeInsets.all(10)),
          ),
        ])),
        const SizedBox(height: 16),

        const Text('WEEKLY WORKOUT SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrim, letterSpacing: 2)),
        const SizedBox(height: 8),
        ...List.generate(7, (i) {
          final hasWorkout = _workoutSchedule.containsKey(i);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: hasWorkout ? AppColors.card : AppColors.card2,
              border: Border.all(color: hasWorkout ? AppColors.hiit.withOpacity(0.3) : AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Text(_days[i].substring(0, 3).toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSub, letterSpacing: 1)),
              title: Text(hasWorkout ? _getWorkoutLabel(_workoutSchedule[i]!) : 'Tap to assign', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: hasWorkout ? AppColors.textPrim : AppColors.textDim)),
              trailing: hasWorkout
                  ? IconButton(icon: const Icon(Icons.close, size: 18, color: AppColors.textDim), onPressed: () => setState(() => _workoutSchedule.remove(i)))
                  : const Icon(Icons.add, color: AppColors.textDim),
              onTap: () => _selectWorkout(i),
            ),
          );
        }),
        const SizedBox(height: 16),

        const Text('DIET PLAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrim, letterSpacing: 2)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDietPlan,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.hiit.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.restaurant, color: AppColors.hiit, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(_getDietLabel(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrim))),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textDim),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        GestureDetector(
          onTap: _save,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(13)),
            child: const Center(child: Text('SAVE SCHEDULE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}
