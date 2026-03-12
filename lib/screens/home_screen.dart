import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/app_data.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final s = prov.stats;
    final h = prov.healthData;
    final p = prov.profile;
    final today = prov.todayCat;
    final todayCatObj = exerciseCategories.firstWhere((c) => c.key == today);
    final done = prov.dayDone;

    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      // ── Greeting banner
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.hiit.withOpacity(0.18), Colors.transparent]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.hiit.withOpacity(0.2)),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_greeting(p.name), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.textPrim, height: 1.2)),
            const SizedBox(height: 4),
            Text(_motiveLine(s.streak), style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.4)),
          ])),
          _StreakBadge(s.streak),
        ]),
      ),
      const SizedBox(height: 12),

      // ── 4-stat row
      Row(children: [
        Expanded(child: _QuickStat('🔥', '${s.streak}d', 'STREAK', AppColors.hiit)),
        const SizedBox(width: 6),
        Expanded(child: _QuickStat('⭐', '${s.totalPoints}', 'POINTS', AppColors.gold)),
        const SizedBox(width: 6),
        Expanded(child: _QuickStat('${(s.multiplier).toStringAsFixed(1)}×', '${(s.multiplier).toStringAsFixed(1)}', 'BOOST', AppColors.flex)),
        const SizedBox(width: 6),
        Expanded(child: _QuickStat('💪', '${s.completedSessions}', 'SESSIONS', AppColors.bodyweight)),
      ]),
      const SizedBox(height: 12),

      // ── Smartwatch / Health snapshot
      if (prov.healthAuthorized) ...[
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('⌚', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(h.watchConnected ? h.watchSource : 'Health Platform', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrim)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.flex.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: const Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.flex, letterSpacing: 2))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _WatchStat('👟', '${h.steps}', 'STEPS', h.stepGoalReached ? AppColors.flex : AppColors.textPrim)),
            Expanded(child: _WatchStat('❤️', '${h.heartRate.toInt()}', 'BPM', h.heartRate > 100 ? AppColors.hiit : AppColors.textPrim)),
            Expanded(child: _WatchStat('🔥', '${h.caloriesBurned.toInt()}', 'KCAL', AppColors.strength)),
            Expanded(child: _WatchStat('😴', '${h.sleepHours.toStringAsFixed(1)}h', 'SLEEP', AppColors.bodyweight)),
          ]),
          const SizedBox(height: 8),
          AppProgressBar(value: h.steps.toDouble(), max: 10000,
            color: h.stepGoalReached ? AppColors.flex : AppColors.hiit, height: 5),
          const SizedBox(height: 4),
          Text(h.stepGoalReached ? '🎯 Step goal done!' : '${10000 - h.steps.clamp(0, 10000)} steps to go',
            style: TextStyle(fontSize: 10, color: h.stepGoalReached ? AppColors.flex : AppColors.textDim)),
        ])),
        const SizedBox(height: 12),
      ],

      // ── Today's workout card
      DarkCard(
        bgColor: done ? const Color(0xFF0A1F0A) : null,
        borderColor: done ? AppColors.flex.withOpacity(0.4) : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(todayCatObj.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TODAY\'S FOCUS', style: const TextStyle(fontSize: 9, color: AppColors.textDim, letterSpacing: 3, fontWeight: FontWeight.w700)),
              Text(todayCatObj.label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim, letterSpacing: 1)),
            ])),
            if (done) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.flex.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Text('✓ DONE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.flex, letterSpacing: 1))),
          ]),
          const SizedBox(height: 12),
          // Exercise list preview
          ...todayCatObj.exercises.take(3).map((name) {
            final ex = exercisesByName[name];
            final k = '${today}|$name';
            final checked = prov.checked[k] ?? false;
            return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
              Container(width: 20, height: 20, decoration: BoxDecoration(
                color: checked ? AppColors.flex.withOpacity(0.15) : Colors.transparent,
                border: Border.all(color: checked ? AppColors.flex : AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ), child: checked ? const Icon(Icons.check, size: 13, color: AppColors.flex) : null),
              const SizedBox(width: 10),
              Expanded(child: Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: checked ? AppColors.textSub : AppColors.textPrim,
                decoration: checked ? TextDecoration.lineThrough : null))),
              if (ex != null) Text('${ex.calories} kcal', style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
            ]));
          }),
          if (todayCatObj.exercises.length > 3) Text('+ ${todayCatObj.exercises.length - 3} more exercises in Train tab',
            style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
          const SizedBox(height: 12),
          if (!done) _BigActionBtn(
            label: 'START WORKOUT →',
            color: AppColors.hiit,
            onTap: () => DefaultTabController.of(context).animateTo(1),
          ),
          if (done) const Center(child: Text('🎉 Incredible work today! Rest up and recover!',
            style: TextStyle(fontSize: 13, color: AppColors.flex, fontWeight: FontWeight.w700))),
        ])),
      const SizedBox(height: 12),

      // ── Calorie tracker mini
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('🍽', style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Text('TODAY\'S NUTRITION', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrim)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${prov.totalCalToday()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 30, color: AppColors.textPrim, height: 1)),
              Text(' / ${p.targetCalories} kcal', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
            ]),
            const SizedBox(height: 6),
            AppProgressBar(value: prov.totalCalToday().toDouble(), max: p.targetCalories.toDouble(), color: AppColors.strength, height: 5),
          ])),
          const SizedBox(width: 16),
          Column(children: [
            _MacroMini('P', '${prov.totalProteinToday().toInt()}g', AppColors.hiit),
            const SizedBox(height: 4),
            _MacroMini('C', '${prov.totalCarbsToday().toInt()}g', AppColors.bodyweight),
            const SizedBox(height: 4),
            _MacroMini('F', '${prov.totalFatToday().toInt()}g', AppColors.strength),
          ]),
        ]),
        const SizedBox(height: 10),
        // Water tracker
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('💧', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text('${prov.water}/8 glasses', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrim)),
            const Spacer(),
            ...List.generate(8, (i) => GestureDetector(
              onTap: () => prov.setWater(i + 1),
              child: Padding(padding: const EdgeInsets.only(left: 2), child: Icon(
                i < prov.water ? Icons.water_drop : Icons.water_drop_outlined,
                size: 18, color: i < prov.water ? AppColors.bodyweight : AppColors.border,
              )),
            )),
          ]),
        ]),
      ])),
      const SizedBox(height: 12),

      // ── 7-day strip
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('THIS WEEK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        const SizedBox(height: 10),
        Row(children: List.generate(7, (i) {
          final dayNames = ['M','T','W','T','F','S','S'];
          final dayKey = prov.weekDates[i];
          final done2 = prov.weekHistory[dayKey] ?? false;
          final isToday = i == prov.todayDayIndex;
          return Expanded(child: Column(children: [
            Text(dayNames[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: isToday ? AppColors.hiit : AppColors.textDim)),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: done2 ? AppColors.flex : isToday ? AppColors.hiit.withOpacity(0.2) : AppColors.border,
                border: Border.all(color: isToday ? AppColors.hiit : Colors.transparent, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: done2 ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ]));
        })),
      ])),
      const SizedBox(height: 12),

      // ── Daily quote
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('💬  TODAY\'S QUOTE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
        const SizedBox(height: 8),
        Text('"${motivationalQuotes[DateTime.now().day % motivationalQuotes.length]}"',
          style: const TextStyle(fontSize: 14, color: AppColors.textSub, fontStyle: FontStyle.italic, height: 1.6)),
      ])),
    ]);
  }

  String _greeting(String name) {
    final h = DateTime.now().hour;
    final greet = h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
    return '$greet${name.isNotEmpty ? ", $name!" : "!"}';
  }

  String _motiveLine(int streak) {
    if (streak == 0) return 'Start your journey today. Every legend has a day 1.';
    if (streak < 3) return 'Day $streak! The habit is forming. Keep it alive!';
    if (streak < 7) return '$streak days strong! You\'re building real discipline.';
    if (streak < 30) return '🔥 $streak-day streak! Elite mindset activated!';
    return '🏆 $streak DAYS! You\'re in the top 1% of athletes!';
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge(this.streak);
  @override
  Widget build(BuildContext context) {
    final color = streak >= 30 ? AppColors.gold : streak >= 7 ? AppColors.hiit : AppColors.textSub;
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(streak >= 30 ? '🏆' : streak >= 7 ? '🔥' : '💪', style: const TextStyle(fontSize: 20)),
        Text('$streak', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color, height: 1)),
      ]),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String icon, value, label; final Color color;
  const _QuickStat(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color, height: 1)),
      Text(label, style: const TextStyle(fontSize: 7, color: AppColors.textDim, letterSpacing: 1)),
    ]),
  );
}

class _WatchStat extends StatelessWidget {
  final String icon, value, label; final Color color;
  const _WatchStat(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 20)),
    const SizedBox(height: 2),
    Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color, height: 1)),
    Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textDim, letterSpacing: 1)),
  ]);
}

class _MacroMini extends StatelessWidget {
  final String label, value; final Color color;
  const _MacroMini(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 16, height: 16, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
      child: Center(child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color)))),
    const SizedBox(width: 4),
    Text(value, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
  ]);
}

class _BigActionBtn extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _BigActionBtn({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
      child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black, letterSpacing: 2)))),
  );
}
