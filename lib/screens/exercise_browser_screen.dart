import 'package:flutter/material.dart';
import '../services/exercise_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class ExerciseBrowserScreen extends StatefulWidget {
  const ExerciseBrowserScreen({super.key});
  @override State<ExerciseBrowserScreen> createState() => _ExerciseBrowserScreenState();
}

class _ExerciseBrowserScreenState extends State<ExerciseBrowserScreen> {
  List<ExerciseData> _exercises = [];
  bool _loading = false;
  String _error = '';
  String _selectedBodyPart = 'chest';
  final _searchCtrl = TextEditingController();

  final _bodyParts = [
    'back', 'cardio', 'chest', 'lower arms', 'lower legs',
    'neck', 'shoulders', 'upper arms', 'upper legs', 'waist'
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final exercises = await ExerciseApiService.getExercisesByBodyPart(_selectedBodyPart);
      setState(() { _exercises = exercises; _loading = false; });
    } catch (e) {
      setState(() { 
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _searchExercises() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    
    setState(() { _loading = true; _error = ''; });
    try {
      final exercises = await ExerciseApiService.searchExercises(query);
      setState(() { _exercises = exercises; _loading = false; });
    } catch (e) {
      setState(() { 
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('EXERCISE LIBRARY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim, letterSpacing: 2)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrim), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: AppColors.textPrim),
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search, color: AppColors.textDim),
                isDense: true,
                contentPadding: EdgeInsets.all(12),
              ),
              onSubmitted: (_) => _searchExercises(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _searchExercises,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.search, color: Colors.black),
              ),
            ),
          ]),
        ),

        // Body part filter
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _bodyParts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final part = _bodyParts[i];
              final active = _selectedBodyPart == part;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedBodyPart = part);
                  _loadExercises();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.hiit : AppColors.card,
                    border: Border.all(color: active ? AppColors.hiit : AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text(
                    part.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: active ? Colors.black : AppColors.textDim, letterSpacing: 1),
                  )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Exercise list
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.hiit)))
        else if (_error.isNotEmpty)
          Expanded(child: Center(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppColors.textSub, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _loadExercises,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(10)),
                  child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black, letterSpacing: 1)),
                ),
              ),
            ]),
          )))
        else if (_exercises.isEmpty)
          const Expanded(child: Center(child: Text('No exercises found', style: TextStyle(color: AppColors.textDim))))
        else
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
            itemCount: _exercises.length,
            itemBuilder: (_, i) {
              final ex = _exercises[i];
              return _ExerciseCard(exercise: ex);
            },
          )),
      ]),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseData exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image
        if (exercise.gifUrl.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              exercise.gifUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: AppColors.card2,
                child: const Center(child: Icon(Icons.fitness_center, size: 48, color: AppColors.textDim)),
              ),
            ),
          ),
        
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              exercise.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim, letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Row(children: [
              _InfoChip('🎯 ${exercise.target}', AppColors.hiit),
              const SizedBox(width: 6),
              _InfoChip('💪 ${exercise.bodyPart}', AppColors.bodyweight),
              const SizedBox(width: 6),
              _InfoChip('🏋️ ${exercise.equipment}', AppColors.strength),
            ]),
            if (exercise.instructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('INSTRUCTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              const SizedBox(height: 6),
              ...exercise.instructions.take(3).asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.5)),
              )),
              if (exercise.instructions.length > 3)
                const Text('...', style: TextStyle(color: AppColors.textDim)),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      border: Border.all(color: color.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w700)),
  );
}
