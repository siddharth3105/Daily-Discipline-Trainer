import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class CreateDietPlanScreen extends StatefulWidget {
  const CreateDietPlanScreen({super.key});
  @override State<CreateDietPlanScreen> createState() => _CreateDietPlanScreenState();
}

class _CreateDietPlanScreenState extends State<CreateDietPlanScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _goalCalCtrl = TextEditingController(text: '2500');
  final List<CustomMealItem> _meals = [];

  void _addMeal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMealModal(onAdd: (meal) {
        setState(() => _meals.add(meal));
        Navigator.pop(context);
      }),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a name and at least one meal')));
      return;
    }
    final plan = CustomDietPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descCtrl.text.trim(),
      goalCalories: int.tryParse(_goalCalCtrl.text) ?? 2500,
      meals: _meals,
    );
    context.read<AppProvider>().addCustomDietPlan(plan);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final totalCal = _meals.fold(0, (sum, m) => sum + m.calories);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('CREATE DIET PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim, letterSpacing: 2)),
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textPrim), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PLAN NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrim, fontSize: 16, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(hintText: 'e.g. Lean Bulk Plan', isDense: true, contentPadding: EdgeInsets.all(10)),
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
          const SizedBox(height: 14),
          const Text('DAILY CALORIE GOAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 8),
          TextField(
            controller: _goalCalCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrim, fontSize: 16, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(hintText: '2500', isDense: true, contentPadding: EdgeInsets.all(10)),
          ),
        ])),
        const SizedBox(height: 16),

        Row(children: [
          const Text('MEALS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrim, letterSpacing: 2)),
          const Spacer(),
          Text('$totalCal kcal total', style: const TextStyle(fontSize: 11, color: AppColors.hiit, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),

        if (_meals.isEmpty)
          DarkCard(child: Column(children: const [
            Text('🍽️', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('No meals added yet', style: TextStyle(fontSize: 14, color: AppColors.textDim)),
          ]))
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _meals.length,
            onReorder: (oldIdx, newIdx) {
              setState(() {
                if (newIdx > oldIdx) newIdx--;
                final meal = _meals.removeAt(oldIdx);
                _meals.insert(newIdx, meal);
              });
            },
            itemBuilder: (_, i) {
              final meal = _meals[i];
              return Container(
                key: ValueKey(i),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.drag_handle, color: AppColors.textDim, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(meal.time, style: const TextStyle(fontSize: 10, color: AppColors.hiit, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      const SizedBox(width: 8),
                      Text(meal.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrim)),
                    ]),
                    Text(meal.foods, style: const TextStyle(fontSize: 11, color: AppColors.textDim), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${meal.calories} kcal · P:${meal.protein.toInt()}g C:${meal.carbs.toInt()}g F:${meal.fat.toInt()}g', style: const TextStyle(fontSize: 10, color: AppColors.textSub)),
                  ])),
                  IconButton(icon: const Icon(Icons.close, size: 18, color: AppColors.textDim), onPressed: () => setState(() => _meals.removeAt(i))),
                ]),
              );
            },
          ),

        const SizedBox(height: 12),
        GestureDetector(
          onTap: _addMeal,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card2, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('+ ADD MEAL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSub, letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 20),

        GestureDetector(
          onTap: _save,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(13)),
            child: const Center(child: Text('SAVE DIET PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

class _AddMealModal extends StatefulWidget {
  final Function(CustomMealItem) onAdd;
  const _AddMealModal({required this.onAdd});
  @override State<_AddMealModal> createState() => _AddMealModalState();
}

class _AddMealModalState extends State<_AddMealModal> {
  final _nameCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '8:00 AM');
  final _foodsCtrl = TextEditingController();
  final _calCtrl = TextEditingController(text: '500');
  final _proteinCtrl = TextEditingController(text: '30');
  final _carbsCtrl = TextEditingController(text: '50');
  final _fatCtrl = TextEditingController(text: '15');

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
          const Text('ADD MEAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.hiit, letterSpacing: 2)),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('MEAL NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              const SizedBox(height: 6),
              TextField(controller: _nameCtrl, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(hintText: 'e.g. Breakfast', isDense: true, contentPadding: EdgeInsets.all(10))),
            ])),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              const SizedBox(height: 6),
              TextField(controller: _timeCtrl, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(hintText: '8:00 AM', isDense: true, contentPadding: EdgeInsets.all(10))),
            ])),
          ]),
          const SizedBox(height: 14),

          const Text('FOODS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 6),
          TextField(controller: _foodsCtrl, maxLines: 2, style: const TextStyle(color: AppColors.textPrim), decoration: const InputDecoration(hintText: 'e.g. 3 eggs + toast + banana', isDense: true, contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 14),

          const Text('CALORIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 6),
          TextField(controller: _calCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrim, fontSize: 18, fontWeight: FontWeight.w700), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(10))),
          const SizedBox(height: 14),

          const Text('MACROS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Column(children: [
              const Text('PROTEIN (g)', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
              const SizedBox(height: 4),
              TextField(controller: _proteinCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.hiit, fontWeight: FontWeight.w700), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8))),
            ])),
            const SizedBox(width: 8),
            Expanded(child: Column(children: [
              const Text('CARBS (g)', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
              const SizedBox(height: 4),
              TextField(controller: _carbsCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.strength, fontWeight: FontWeight.w700), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8))),
            ])),
            const SizedBox(width: 8),
            Expanded(child: Column(children: [
              const Text('FAT (g)', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
              const SizedBox(height: 4),
              TextField(controller: _fatCtrl, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.bodyweight, fontWeight: FontWeight.w700), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.all(8))),
            ])),
          ]),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) return;
              widget.onAdd(CustomMealItem(
                name: name,
                time: _timeCtrl.text.trim(),
                foods: _foodsCtrl.text.trim(),
                calories: int.tryParse(_calCtrl.text) ?? 500,
                protein: double.tryParse(_proteinCtrl.text) ?? 30,
                carbs: double.tryParse(_carbsCtrl.text) ?? 50,
                fat: double.tryParse(_fatCtrl.text) ?? 15,
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(13)),
              child: const Center(child: Text('ADD MEAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
            ),
          ),
        ]),
      ),
    );
  }
}
