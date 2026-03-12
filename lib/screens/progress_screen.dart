import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _tab = 0; // 0=Overview, 1=Body Stats, 2=Health

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    return Column(children: [
      // Tabs
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Row(children: [
          _buildTab('📊 OVERVIEW', 0),
          const SizedBox(width: 6),
          _buildTab('📏 BODY STATS', 1),
          const SizedBox(width: 6),
          _buildTab('⌚ HEALTH', 2),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(child: IndexedStack(index: _tab, children: [
        _OverviewTab(),
        _BodyStatsTab(),
        _HealthTab(),
      ])),
    ]);
  }

  Widget _buildTab(String label, int idx) {
    final active = _tab == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = idx),
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

// ── OVERVIEW TAB ──────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final s = prov.stats;

    const levels = [
      (name: 'Rookie',    min: 0,    max: 100,  c: Color(0xFF888888)),
      (name: 'Trainee',   min: 100,  max: 500,  c: AppColors.bodyweight),
      (name: 'Athlete',   min: 500,  max: 1000, c: AppColors.flex),
      (name: 'Champion',  min: 1000, max: 5000, c: AppColors.strength),
      (name: 'Legend',    min: 5000, max: 99999,c: AppColors.hiit),
    ];

    final currentLevel = levels.lastWhere((l) => s.totalPoints >= l.min, orElse: () => levels[0]);

    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      // Stats
      GridView.count(crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.1,
        children: [
          StatCard(label:'STREAK',     value:'${s.streak}d',       color:AppColors.hiit),
          StatCard(label:'TOTAL PTS',  value:'${s.totalPoints}',   color:AppColors.gold),
          StatCard(label:'MULTIPLIER', value:'${s.multiplier}×',   color:AppColors.flex),
          StatCard(label:'EXERCISES',  value:'${s.totalExercises}',color:AppColors.textPrim),
          StatCard(label:'SESSIONS',   value:'${s.completedSessions}',color:AppColors.bodyweight),
          StatCard(label:'LEVEL',      value:currentLevel.name.toUpperCase(), color:currentLevel.c),
        ]),
      const SizedBox(height: 14),

      // Level progress
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const SectionHeader('⭐  LEVEL LADDER'),
          const Spacer(),
          Text('${s.totalPoints} PTS', style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
        ]),
        const SizedBox(height: 12),
        ...levels.map((l) {
          final done = s.totalPoints >= l.max;
          final active = s.totalPoints >= l.min && s.totalPoints < l.max;
          final frac = done ? 1.0 : active ? ((s.totalPoints - l.min) / (l.max - l.min)).clamp(0.0, 1.0) : 0.0;
          return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            SizedBox(width: 72, child: Text(l.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11,
              color: active ? l.c : done ? const Color(0xFF444444) : AppColors.textDim))),
            Expanded(child: AppProgressBar(value: frac, max: 1.0, color: l.c.withOpacity(done ? 0.3 : 1.0), height: 5)),
            const SizedBox(width: 8),
            SizedBox(width: 40, child: Text('${l.min}', style: const TextStyle(fontSize: 8, color: AppColors.textDim), textAlign: TextAlign.right)),
          ]));
        }),
      ])),
      const SizedBox(height: 14),

      // 35-day heatmap
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader('📅  ACTIVITY HEATMAP (35 DAYS)'),
        const SizedBox(height: 10),
        Row(children: ['M','T','W','T','F','S','S'].map((d) => Expanded(
          child: Center(child: Text(d, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 1))),
        )).toList()),
        const SizedBox(height: 4),
        Builder(builder: (_) {
          final today = DateTime.now();
          final data = List.generate(35, (i) {
            final d = today.subtract(Duration(days: 34 - i));
            final k = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
            return prov.weekHistory[k] ?? false;
          });
          return GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemCount: 35,
            itemBuilder: (_, i) => AnimatedContainer(
              duration: Duration(milliseconds: 200 + i * 5),
              decoration: BoxDecoration(
                color: data[i] ? AppColors.hiit : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          const Text('Rest', style: TextStyle(fontSize: 10, color: AppColors.textDim)),
          const SizedBox(width: 16),
          Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          const Text('Trained', style: TextStyle(fontSize: 10, color: AppColors.textDim)),
        ]),
      ])),
      const SizedBox(height: 14),

      // Badges
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const SectionHeader('🏅  BADGES'),
          const Spacer(),
          Text('${prov.unlockedBadges.length}/${allBadges.length}', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
        ]),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
          itemCount: allBadges.length,
          itemBuilder: (_, i) {
            final b = allBadges[i];
            final unlocked = prov.unlockedBadges.contains(b.id);
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + i * 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: unlocked ? AppColors.card2 : const Color(0xFF080808),
                border: Border.all(color: unlocked ? AppColors.gold.withOpacity(0.4) : AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(b.icon, style: TextStyle(fontSize: 26, color: unlocked ? null : const Color(0xFF444444))),
                const SizedBox(height: 4),
                Text(b.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: unlocked ? AppColors.gold : AppColors.textDim), textAlign: TextAlign.center),
                Text(b.desc, style: const TextStyle(fontSize: 7, color: AppColors.textDim), textAlign: TextAlign.center, maxLines: 2),
                if (unlocked) const SizedBox(height: 3),
                if (unlocked) const Text('✓', style: TextStyle(fontSize: 11, color: AppColors.flex)),
              ]),
            );
          },
        ),
      ])),
    ]);
  }
}

// ── BODY STATS TAB ────────────────────────────────────────────────────────────
class _BodyStatsTab extends StatefulWidget {
  @override State<_BodyStatsTab> createState() => _BodyStatsTabState();
}

class _BodyStatsTabState extends State<_BodyStatsTab> {
  final _wCtrl = TextEditingController();
  final _bfCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final stats = prov.bodyStats;
    final todayKey = prov.todayKey;

    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      // Log today
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📝  LOG TODAY\'S STATS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.hiit, letterSpacing: 1)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _numField(_wCtrl, 'Weight (kg)')),
          const SizedBox(width: 8),
          Expanded(child: _numField(_bfCtrl, 'Body Fat (%)')),
        ]),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _numField(_chestCtrl, 'Chest (cm)')),
            const SizedBox(width: 8),
            Expanded(child: _numField(_waistCtrl, 'Waist (cm)')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _numField(_hipsCtrl, 'Hips (cm)')),
            const SizedBox(width: 8),
            Expanded(child: _numField(_armsCtrl, 'Arms (cm)')),
          ]),
        ],
        const SizedBox(height: 8),
        GestureDetector(onTap: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? '▲ Less fields' : '▼ Add measurements', style: const TextStyle(fontSize: 11, color: AppColors.hiit))),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            final w = double.tryParse(_wCtrl.text);
            if (w == null) return;
            prov.addBodyStat(BodyStatEntry(
              date: todayKey, weight: w,
              bodyFat: double.tryParse(_bfCtrl.text),
              chest: double.tryParse(_chestCtrl.text),
              waist: double.tryParse(_waistCtrl.text),
              hips: double.tryParse(_hipsCtrl.text),
              arms: double.tryParse(_armsCtrl.text),
            ));
            for (final c in [_wCtrl,_bfCtrl,_chestCtrl,_waistCtrl,_hipsCtrl,_armsCtrl]) c.clear();
          },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: AppColors.hiit.withOpacity(0.1), border: Border.all(color: AppColors.hiit), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('LOG STATS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.hiit, letterSpacing: 2)))),
        ),
      ])),
      const SizedBox(height: 14),

      // Weight chart
      if (stats.length >= 2)
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('⚖️  WEIGHT TREND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
          const SizedBox(height: 16),
          SizedBox(height: 140, child: LineChart(LineChartData(
            gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1)),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9, color: AppColors.textDim)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(
              spots: stats.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
              isCurved: true, color: AppColors.hiit, barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.hiit.withOpacity(0.08)),
            )],
          ))),
          const SizedBox(height: 8),
          if (stats.length >= 2) () {
            final diff = stats.last.weight - stats.first.weight;
            final isLoss = diff < 0;
            return Text('${isLoss ? "📉" : "📈"} ${diff.abs().toStringAsFixed(1)}kg ${isLoss ? "lost" : "gained"} over ${stats.length} entries',
              style: TextStyle(fontSize: 12, color: isLoss ? AppColors.flex : AppColors.hiit));
          }(),
        ])),
      const SizedBox(height: 14),

      // Stats table
      if (stats.isNotEmpty)
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📋  HISTORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
          const SizedBox(height: 10),
          ...stats.reversed.take(10).map((e) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.date, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrim)),
                Text([
                  if (e.bodyFat != null) 'Fat: ${e.bodyFat}%',
                  if (e.waist != null) 'Waist: ${e.waist}cm',
                  if (e.arms != null) 'Arms: ${e.arms}cm',
                ].join('  '), style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
              ])),
              Text('${e.weight} kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.hiit)),
            ]),
          )),
        ])),
    ]);
  }

  Widget _numField(TextEditingController c, String hint) => TextField(
    controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: const TextStyle(color: AppColors.textPrim, fontSize: 14),
    decoration: InputDecoration(hintText: hint, isDense: true, contentPadding: const EdgeInsets.all(10)));
}

// ── HEALTH TAB ────────────────────────────────────────────────────────────────
class _HealthTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final h = prov.healthData;

    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      if (!prov.healthAuthorized)
        DarkCard(child: Column(children: [
          const Text('⌚', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 12),
          const Text('CONNECT YOUR SMARTWATCH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim, letterSpacing: 1), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Sync Apple Watch, Wear OS, Fitbit and more\nvia Apple Health or Google Health Connect.',
            style: TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => prov.connectHealthPlatform(),
            child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(13)),
              child: const Center(child: Text('⌚  CONNECT NOW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2)))),
          ),
          const SizedBox(height: 14),
          ...[
            ('Apple Watch', '🍎', 'Syncs via HealthKit on iPhone'),
            ('Wear OS Watch', '🤖', 'Syncs via Health Connect on Android'),
            ('Fitbit / Garmin', '⌚', 'Connect via platform health apps'),
            ('Samsung Galaxy Watch', '💎', 'Syncs via Samsung Health → Health Connect'),
          ].map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
            Text(item.$2, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrim)),
              Text(item.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
            ])),
          ]))),
        ])),

      if (prov.healthAuthorized) ...[
        // Watch connection status
        DarkCard(bgColor: h.watchConnected ? const Color(0xFF0A1A0A) : null,
          borderColor: h.watchConnected ? AppColors.flex.withOpacity(0.4) : null,
          child: Row(children: [
            Text(h.watchConnected ? '✅' : '📱', style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.watchConnected ? '${h.watchSource} Active' : 'Health Platform Connected', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
              Text('Last sync: ${_timeAgo(h.lastSync)}', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
            ])),
            GestureDetector(onTap: () => prov.refreshHealthData(), child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: AppColors.hiit.withOpacity(0.4)), borderRadius: BorderRadius.circular(8)),
              child: const Text('SYNC', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.hiit, letterSpacing: 1)),
            )),
          ])),
        const SizedBox(height: 12),

        // Steps ring + stats
        DarkCard(child: Column(children: [
          Row(children: [
            // Steps ring
            SizedBox(width: 110, height: 110, child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: h.stepPercent / 100,
                strokeWidth: 10, strokeCap: StrokeCap.round,
                backgroundColor: AppColors.border,
                color: h.stepGoalReached ? AppColors.flex : AppColors.hiit,
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${h.steps}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim, height: 1)),
                const Text('STEPS', style: TextStyle(fontSize: 9, color: AppColors.textDim, letterSpacing: 1)),
              ]),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(children: [
              _HealthRow('❤️', 'HEART RATE', '${h.heartRate.toInt()} bpm', AppColors.hiit),
              const SizedBox(height: 8),
              _HealthRow('🔥', 'CALORIES', '${h.caloriesBurned.toInt()} kcal', AppColors.strength),
              const SizedBox(height: 8),
              _HealthRow('😴', 'SLEEP', '${h.sleepHours.toStringAsFixed(1)} hrs', AppColors.bodyweight),
              const SizedBox(height: 8),
              _HealthRow('⚡', 'ACTIVE MIN', '${h.activeMinutes.toInt()} min', AppColors.flex),
            ])),
          ]),
          const SizedBox(height: 12),
          AppProgressBar(value: h.steps.toDouble(), max: 10000, color: h.stepGoalReached ? AppColors.flex : AppColors.hiit, height: 4),
          const SizedBox(height: 4),
          Text(h.stepGoalReached ? '🎉 Step goal reached! Great work!' : '${10000 - h.steps} steps to daily goal',
            style: TextStyle(fontSize: 11, color: h.stepGoalReached ? AppColors.flex : AppColors.textSub)),
        ])),
        const SizedBox(height: 12),

        // BMI from profile
        Builder(builder: (_) {
          final p = prov.profile;
          final bmiColor = p.bmi < 18.5 ? AppColors.bodyweight : p.bmi < 25 ? AppColors.flex : p.bmi < 30 ? AppColors.strength : AppColors.hiit;
          return DarkCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('YOUR BMI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              Text(p.bmi.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 44, color: bmiColor, height: 1)),
              Text(p.bmiLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: bmiColor)),
              const SizedBox(height: 4),
              Text('${p.heightCm.toInt()}cm · ${p.weightKg.toInt()}kg', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('CALORIES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
              Text('${p.tdee}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.textPrim, height: 1)),
              const Text('TDEE / DAY', style: TextStyle(fontSize: 10, color: AppColors.textDim, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text('Target: ${p.targetCalories} kcal', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
              Text('Goal: ${p.goal.toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppColors.hiit, fontWeight: FontWeight.w700)),
            ])),
          ]));
        }),
      ],
    ]);
  }

  Widget _HealthRow(String icon, String label, String value, Color color) => Row(children: [
    Text(icon, style: const TextStyle(fontSize: 18)),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDim, letterSpacing: 1))),
    Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
  ]);

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 2) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
  }
}
