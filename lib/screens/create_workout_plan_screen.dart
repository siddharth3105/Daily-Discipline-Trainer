import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class CreateWorkoutPlanScreen extends StatefulWidget {
  const CreateWorkoutPlanScreen({super.key});
  @override State<CreateWorkoutPlanScreen> createState() => _CreateWorkoutPlanScreenState();
}

class _CreateWorkoutPlanScreenState extends State<CreateWorkoutPlanScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final List<CustomExercise> _exercises = [];

  void _addExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExerciseModal(onAdd: (ex) {
        setState(() => _exercises.add(ex));
        Navigator.pop(context);
      }),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a name and at least one exercise')));
      return;
    }
    final workout = CustomWorkout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descCtrl.text.trim(),
      exercises: _exercises,
    );
    context.read<AppProvider>().addCustomWorkout(workout);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('CREATE WORKOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim, letterSpacing: 2)),
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textPrim), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('WORKOUT NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrim, fontSize: 16, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(hintText: 'e.g. Upper Body Blast', isDense: true, contentPadding: EdgeInsets.all(10)),
          ),
          const SizedBox(height: 14),
          const Text('DESCRIPTION (OPTIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: AppColors.textPrim, fontSize: 14),
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Brief description...', isDense: true, contentPadding: EdgeInsets.all(10)),
          ),
        ])),
        const SizedBox(height: 16),

        Row(children: const [
          Text('EXERCISES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrim, letterSpacing: 2)),
          Spacer(),
          Text('Tap to reorder', style: TextStyle(fontSize: 10, color: AppColors.textDim)),
        ]),
        const SizedBox(height: 8),

        if (_exercises.isEmpty)
          DarkCard(child: Column(children: const [
            Text('💪', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('No exercises added yet', style: TextStyle(fontSize: 14, color: AppColors.textDim)),
          ]))
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            onReorder: (oldIdx, newIdx) {
              setState(() {
                if (newIdx > oldIdx) newIdx--;
                final ex = _exercises.removeAt(oldIdx);
                _exercises.insert(newIdx, ex);
              });
            },
            itemBuilder: (_, i) {
              final ex = _exercises[i];
              return Container(
                key: ValueKey(i),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.drag_handle, color: AppColors.textDim, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrim)),
                    Text('${ex.sets}×${ex.reps} · ${ex.restSeconds}s rest · ${ex.calPerSet} kcal/set', style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                    Text('🎯 ${ex.muscleGroup}', style: const TextStyle(fontSize: 10, color: AppColors.textSub)),
                  ])),
                  IconButton(icon: const Icon(Icons.close, size: 18, color: AppColors.textDim), onPressed: () => setState(() => _exercises.removeAt(i))),
                ]),
              );
            },
          ),

        const SizedBox(height: 12),
        GestureDetector(
          onTap: _addExercise,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card2, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('+ ADD EXERCISE', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSub, letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 20),

        GestureDetector(
          onTap: _save,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(13)),
            child: const Center(child: Text('SAVE WORKOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

class _AddExerciseModal extends StatefulWidget {
  final Function(CustomExercise) onAdd;
  const _AddExerciseModal({required this.onAdd});
  @override State<_AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<_AddExerciseModal> {
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController(text: '3');
  final _repsCtrl = TextEditingController(text: '12');
  final _restCtrl = TextEditingController(text: '60');
  final _calCtrl = TextEditingController(text: '8');
  final _notesCtrl = TextEditingController();
  String _muscleGroup = 'Chest';

  final _muscleGroups = ['Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Core', 'Full Body', 'Cardio'];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF080808),
          border: Border.all(color: AppColors.hiit.withOpacity(0.2)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(controller: ctrl, padding: const EdgeInsets.all(18), children: [
          Center(child: Container(margin: const EdgeInsets.only(bottom: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2)))),
          const Text('ADD EXERCISE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.hiit, letterSpacing: 2)),
          const SizedBox(height: 16),

          const Text('EXERCISE NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 6),
          TextField(controller: _nameCtrl, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(hintText: 'e.g. Bench Press', isDense: true, contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 14),

          const Text('MUSCLE GROUP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: _muscleGroups.map((m) {
            final active = _muscleGroup == m;
            return GestureDetector(
              onTap: () => setState(() => _muscleGroup = m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? AppColors.hiit.withOpacity(0.2) : AppColors.card2,
                  border: Border.all(color: active ? AppColors.hiit : AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(m, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.hiit : AppColors.textDim)),
              ),
            );
          }).toList()),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('SETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              const SizedBox(height: 6),
              TextField(controller: _setsCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(10))),
            ])),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('REPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              const SizedBox(height: 6),
              TextField(controller: _repsCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(10))),
            ])),
          ]),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('REST (SEC)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              const SizedBox(height: 6),
              TextField(controller: _restCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(10))),
            ])),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('KCAL/SET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              const SizedBox(height: 6),
              TextField(controller: _calCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(10))),
            ])),
          ]),
          const SizedBox(height: 14),

          const Text('NOTES (OPTIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 6),
          TextField(controller: _notesCtrl, maxLines: 2, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(hintText: 'Form cues, tips...', isDense: true, contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) return;
              widget.onAdd(CustomExercise(
                name: name,
                muscleGroup: _muscleGroup,
                sets: int.tryParse(_setsCtrl.text) ?? 3,
                reps: int.tryParse(_repsCtrl.text) ?? 12,
                restSeconds: int.tryParse(_restCtrl.text) ?? 60,
                calPerSet: int.tryParse(_calCtrl.text) ?? 8,
                notes: _notesCtrl.text.trim(),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(13)),
              child: const Center(child: Text('ADD EXERCISE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
            ),
          ),
        ]),
      ),
    );
  }
}
