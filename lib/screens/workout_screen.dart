import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/exercise_gif_widget.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late String _activeTab;

  @override
  void initState() {
    super.initState();
    final prov = context.read<AppProvider>();
    _activeTab = prov.todayCat == 'rest' ? 'hiit' : prov.todayCat;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final todayCat = prov.todayCat;
    final todayCatData = todayCat != 'rest'
        ? exerciseCategories.firstWhere((c) => c.key == todayCat)
        : null;
    final activeCat = exerciseCategories.firstWhere((c) => c.key == _activeTab);
    final todayProgress = todayCatData == null ? null : (
      done: todayCatData.exercises.where((n) => prov.checked['$todayCat|$n'] == true).length,
      total: todayCatData.exercises.length,
    );

    return Column(children: [
      // ── Category tabs
      Container(
        height: 44,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: exerciseCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final cat = exerciseCategories[i];
            final done = cat.exercises.where((n) => prov.checked['${cat.key}|$n'] == true).length;
            final isActive = _activeTab == cat.key;
            return GestureDetector(
              onTap: () => setState(() => _activeTab = cat.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? Color(cat.color) : AppColors.card,
                  border: Border.all(color: isActive ? Color(cat.color) : AppColors.border),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${cat.icon}  ${cat.label}${done > 0 ? "  ($done/${cat.exercises.length})" : ""}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: isActive ? Colors.black : AppColors.textDim,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // ── Today's focus bar
      if (todayCatData != null && todayProgress != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Color(todayCatData.color).withOpacity(0.1),
              border: Border.all(color: Color(todayCatData.color).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Expanded(child: Text('TODAY → ${todayCatData.icon}  ${todayCatData.label}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(todayCatData.color), letterSpacing: 1))),
              Text('${todayProgress.done}/${todayProgress.total}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim)),
            ]),
          ),
        ),

      const SizedBox(height: 8),

      // ── Exercise List
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: [
            Text('${activeCat.icon}  ${activeCat.label}',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(activeCat.color), letterSpacing: 2)),
            const SizedBox(height: 10),
            ...activeCat.exercises.map((name) {
              final ex = exercisesByName[name];
              if (ex == null) return const SizedBox();
              final k = '${_activeTab}|$name';
              final checked = prov.checked[k] == true;
              return _ExerciseCard(
                name: name, ex: ex, catColor: Color(activeCat.color),
                checked: checked,
                onToggle: () => prov.toggleExercise(_activeTab, name),
                onInfo: () => _showExerciseModal(context, name, ex, Color(activeCat.color)),
              );
            }),
            const SizedBox(height: 16),

            // ── Complete Day button
            if (prov.dayDone)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1A0A),
                  border: Border.all(color: AppColors.flex.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Center(
                  child: Text('✅  TODAY LOCKED IN — COME BACK TOMORROW 💪',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.flex, letterSpacing: 1)),
                ),
              )
            else
              Builder(builder: (ctx) {
                final canComplete = (todayCat == 'rest' ||
                    (todayProgress != null && todayProgress.done == todayProgress.total));
                return GestureDetector(
                  onTap: canComplete ? () => prov.completeDay() : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: canComplete ? AppColors.hiit : AppColors.card,
                      border: Border.all(color: canComplete ? AppColors.hiit : AppColors.border),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        canComplete
                            ? '🔥  MARK TODAY COMPLETE  +50 PTS'
                            : 'COMPLETE TODAY (${todayProgress?.done ?? 0}/${todayProgress?.total ?? 0} DONE)',
                        style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16,
                          color: canComplete ? Colors.black : AppColors.textDim,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    ]);
  }

  void _showExerciseModal(BuildContext context, String name, Exercise ex, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseModal(name: name, ex: ex, catColor: color,
        isDone: context.read<AppProvider>().checked['${_activeTab}|$name'] == true,
        onDone: () => context.read<AppProvider>().toggleExercise(_activeTab, name)),
    );
  }
}

// ── Exercise Card ─────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final String name;
  final Exercise ex;
  final Color catColor;
  final bool checked;
  final VoidCallback onToggle;
  final VoidCallback onInfo;

  const _ExerciseCard({required this.name, required this.ex, required this.catColor,
    required this.checked, required this.onToggle, required this.onInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: checked ? catColor.withOpacity(0.07) : AppColors.card,
        border: Border.all(color: checked ? catColor.withOpacity(0.4) : AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        // Checkbox
        GestureDetector(
          onTap: onToggle,
          child: Container(
            margin: const EdgeInsets.all(12),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: checked ? catColor : AppColors.card2,
              border: Border.all(color: checked ? catColor : AppColors.border2, width: 2),
              borderRadius: BorderRadius.circular(7),
            ),
            child: checked ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
          ),
        ),
        // Info
        Expanded(
          child: GestureDetector(
            onTap: onInfo,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5,
                  color: checked ? catColor : AppColors.textPrim,
                  decoration: checked ? TextDecoration.lineThrough : null,
                )),
                const SizedBox(height: 2),
                Text('${ex.sets}×${ex.reps}', style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                Text('🎯 ${ex.muscle}', style: TextStyle(fontSize: 10, color: catColor.withOpacity(0.7))),
              ]),
            ),
          ),
        ),
        // Calories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: [
            Text('${ex.calories}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textSub)),
            const Text('KCAL', style: TextStyle(fontSize: 8, color: AppColors.textDim, letterSpacing: 1)),
          ]),
        ),
        // How button
        GestureDetector(
          onTap: onInfo,
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: catColor.withOpacity(0.15),
              border: Border.all(color: catColor.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('▶ HOW', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: catColor, letterSpacing: 1)),
          ),
        ),
      ]),
    );
  }
}

// ── Exercise Detail Modal ─────────────────────────────────────────────────────
class _ExerciseModal extends StatefulWidget {
  final String name;
  final Exercise ex;
  final Color catColor;
  final bool isDone;
  final VoidCallback onDone;
  const _ExerciseModal({required this.name, required this.ex, required this.catColor, required this.isDone, required this.onDone});

  @override State<_ExerciseModal> createState() => _ExerciseModalState();
}

class _ExerciseModalState extends State<_ExerciseModal> {
  int _timer = 0;
  bool _running = false;
  String _tab = 'form';
  late bool _isDone;

  @override
  void initState() { super.initState(); _isDone = widget.isDone; }

  void _startTimer(int s) {
    setState(() { _timer = s; _running = true; });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { _timer--; if (_timer <= 0) { _running = false; _timer = 0; } });
      return _running && _timer > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9, minChildSize: 0.5, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF080808),
          border: Border.all(color: widget.catColor.withOpacity(0.2)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(18, 0, 18, 40), children: [
          // Handle
          Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2)))),
          // Top accent
          Container(height: 3, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [widget.catColor, widget.catColor.withOpacity(0.3)]))),
          // Header
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EXERCISE GUIDE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.catColor, letterSpacing: 4)),
              Text(widget.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.textPrim, letterSpacing: 1)),
              Text('${widget.ex.sets} SETS · ${widget.ex.reps} · ~${widget.ex.calories} kcal/set',
                style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
              Text('🎯 ${widget.ex.muscle}', style: TextStyle(fontSize: 11, color: widget.catColor.withOpacity(0.7))),
            ])),
            IconButton(icon: const Icon(Icons.close, color: AppColors.textDim), onPressed: () => Navigator.pop(context)),
          ]),
          const SizedBox(height: 16),

          // ── Animation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF040404),
              border: Border.all(color: widget.catColor.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Text('PROPER FORM — REAL HUMAN DEMONSTRATION',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 4)),
              const SizedBox(height: 14),
              // Use real human GIF from ExerciseDB
              ExerciseGifWidget(
                gifUrl: ExerciseGifMapping.getGifUrl(widget.name),
                borderColor: widget.catColor,
                height: 280,
                fallbackText: widget.name,
              ),
              const SizedBox(height: 12),
              const Text(
                'Professional exercise demonstration',
                style: TextStyle(fontSize: 10, color: AppColors.textDim, fontStyle: FontStyle.italic),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Timer
          Text('REST / SET TIMER', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 8),
          Row(children: [
            ...[30, 45, 60, 90].map((s) => Expanded(
              child: GestureDetector(
                onTap: () => _startTimer(s),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card2,
                    border: Border.all(color: widget.catColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(child: Text(
                    _running && _timer > 0 ? '${_timer}s' : '${s}s',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: widget.catColor, letterSpacing: 1),
                  )),
                ),
              ),
            )),
            if (_running)
              GestureDetector(
                onTap: () => setState(() { _running = false; _timer = 0; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.card2, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9)),
                  child: const Text('■', style: TextStyle(color: AppColors.textDim, fontSize: 14)),
                ),
              ),
          ]),
          if (_running) ...[
            const SizedBox(height: 8),
            AppProgressBar(value: _timer.toDouble(), max: 90, color: widget.catColor, height: 3),
          ],
          const SizedBox(height: 14),

          // ── Tabs
          Row(children: [
            _TabBtn(label: '📋  FORM', active: _tab == 'form', color: widget.catColor, onTap: () => setState(() => _tab = 'form')),
            const SizedBox(width: 6),
            _TabBtn(label: '💡  TIPS', active: _tab == 'tips', color: widget.catColor, onTap: () => setState(() => _tab = 'tips')),
          ]),
          const SizedBox(height: 14),

          if (_tab == 'form') ...[
            Text('✅  HOW TO DO IT RIGHT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: widget.catColor, letterSpacing: 1)),
            const SizedBox(height: 10),
            ...widget.ex.steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 26, height: 26, margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: widget.catColor.withOpacity(0.1),
                    border: Border.all(color: widget.catColor.withOpacity(0.3)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('${e.key + 1}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: widget.catColor))),
                ),
                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14, color: Color(0xFFC0C0C0), height: 1.6))),
              ]),
            )),
          ],

          if (_tab == 'tips') ...[
            const Text('⚠️  COMMON MISTAKES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.hiit, letterSpacing: 1)),
            const SizedBox(height: 10),
            ...widget.ex.mistakes.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('✗  ', style: TextStyle(color: AppColors.hiit, fontSize: 13)),
                Expanded(child: Text(m, style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.5))),
              ]),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card2,
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: widget.catColor, width: 3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('💡  PRO TIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.catColor.withOpacity(0.7), letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(widget.ex.tip, style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.5)),
              ]),
            ),
          ],
          const SizedBox(height: 16),

          // ── Mark Done
          GestureDetector(
            onTap: () {
              widget.onDone();
              setState(() => _isDone = !_isDone);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDone ? const Color(0xFF0D1A0D) : AppColors.hiit.withOpacity(0.1),
                border: Border.all(color: _isDone ? AppColors.flex : AppColors.hiit),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(child: Text(
                _isDone ? '✅  MARKED AS DONE  +${widget.ex.calories} KCAL' : 'MARK AS DONE  +${widget.ex.calories} KCAL',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _isDone ? AppColors.flex : AppColors.hiit, letterSpacing: 2),
              )),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label; final bool active; final Color color; final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.1) : AppColors.card2,
          border: Border.all(color: active ? color : AppColors.border),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: active ? color : AppColors.textDim, letterSpacing: 1))),
      ),
    ),
  );
}
