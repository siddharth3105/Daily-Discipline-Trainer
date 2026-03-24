import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../services/quotes_api_service.dart';
import '../services/weather_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'plan_manager_screen.dart';
import 'exercise_browser_screen.dart';
import 'nutrition_search_screen.dart';
import 'ai_coach_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final r = prov.reminders;
    final p = prov.profile;
    final h = prov.healthData;

    return ListView(padding: const EdgeInsets.fromLTRB(14, 8, 14, 90), children: [
      // ── Custom Plans
      _SectionTitle('📅  CUSTOM PLANS'),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanManagerScreen())),
        child: DarkCard(child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.hiit.withOpacity(0.2),
              border: Border.all(color: AppColors.hiit.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('💪', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('MY CUSTOM PLANS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
            Text('Create workout & diet plans', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textDim),
        ])),
      ),
      const SizedBox(height: 16),

      // ── API Features
      _SectionTitle('🌐  API FEATURES'),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiCoachScreen())),
        child: DarkCard(child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.hiit.withOpacity(0.2),
              border: Border.all(color: AppColors.hiit.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('AI FITNESS COACH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
            Text('Groq & Gemini AI powered', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textDim),
        ])),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseBrowserScreen())),
        child: DarkCard(child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.bodyweight.withOpacity(0.2),
              border: Border.all(color: AppColors.bodyweight.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🏋️', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('EXERCISE LIBRARY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
            Text('1300+ exercises with instructions', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textDim),
        ])),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionSearchScreen())),
        child: DarkCard(child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.flex.withOpacity(0.2),
              border: Border.all(color: AppColors.flex.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🍎', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('NUTRITION DATABASE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrim)),
            Text('Search 800k+ foods', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.textDim),
        ])),
      ),
      const SizedBox(height: 8),
      FutureBuilder<QuoteData>(
        future: QuotesApiService.getQuoteOfDay(),
        builder: (context, snapshot) {
          final quote = snapshot.data;
          return DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Text('💭', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text('QUOTE OF THE DAY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrim)),
            ]),
            if (quote != null) ...[
              const SizedBox(height: 12),
              Text('"${quote.quote}"', style: const TextStyle(fontSize: 14, color: AppColors.textSub, fontStyle: FontStyle.italic, height: 1.5)),
              const SizedBox(height: 6),
              Text('— ${quote.author}', style: const TextStyle(fontSize: 12, color: AppColors.textDim)),
            ] else if (snapshot.hasError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Failed to load quote', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.hiit))),
              ),
          ]));
        },
      ),
      const SizedBox(height: 16),

      // ── Profile section
      _SectionTitle('👤  MY PROFILE'),
      DarkCard(child: Column(children: [
        Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.hiit.withOpacity(0.2), border: Border.all(color: AppColors.hiit.withOpacity(0.5)), borderRadius: BorderRadius.circular(28)),
            child: const Center(child: Text('💪', style: TextStyle(fontSize: 26)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name.isNotEmpty ? p.name : 'Athlete', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim)),
            Text('${p.goal.toUpperCase()} GOAL  •  ${p.age}yo', style: const TextStyle(fontSize: 11, color: AppColors.textSub, letterSpacing: 2)),
          ])),
          GestureDetector(onTap: () => _editProfile(context, p), child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(border: Border.all(color: AppColors.hiit.withOpacity(0.4)), borderRadius: BorderRadius.circular(8)),
            child: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: AppColors.hiit, letterSpacing: 1)),
          )),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _MiniStat('HEIGHT', '${p.heightCm.toInt()}cm', AppColors.bodyweight)),
          Expanded(child: _MiniStat('WEIGHT', '${p.weightKg.toInt()}kg', AppColors.strength)),
          Expanded(child: _MiniStat('BMI', p.bmi.toStringAsFixed(1), p.bmi < 25 ? AppColors.flex : AppColors.hiit)),
          Expanded(child: _MiniStat('TDEE', '${p.tdee}kcal', AppColors.hiit)),
        ]),
      ])),
      const SizedBox(height: 16),

      // ── Smartwatch / Health
      _SectionTitle('⌚  SMARTWATCH & HEALTH'),
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CONNECT HEALTH PLATFORM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrim)),
            Text(
              prov.healthAuthorized
                ? h.watchConnected ? '✅ ${h.watchSource} Connected' : '✅ Apple Health / Health Connect'
                : '🔗 Sync Apple Watch or Wear OS data',
              style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
          ])),
          GestureDetector(
            onTap: () async {
              final ok = await prov.connectHealthPlatform();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: ok ? AppColors.card : AppColors.card,
                  content: Text(ok ? '✅ Health platform connected!' : '❌ Could not connect. Check permissions.'),
                ));
              }
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: prov.healthAuthorized ? AppColors.flex.withOpacity(0.1) : AppColors.hiit,
                border: Border.all(color: prov.healthAuthorized ? AppColors.flex : AppColors.hiit),
                borderRadius: BorderRadius.circular(9)),
              child: Text(prov.healthAuthorized ? 'SYNC' : 'CONNECT',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: prov.healthAuthorized ? AppColors.flex : Colors.black, letterSpacing: 1))),
          ),
        ]),
        if (prov.healthAuthorized) ...[
          const SizedBox(height: 14),
          const Divider(color: AppColors.border),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _HealthTile('👟', 'STEPS', '${h.steps}', '/10k')),
            Expanded(child: _HealthTile('❤️', 'HEART RATE', '${h.heartRate.toInt()}', 'bpm')),
            Expanded(child: _HealthTile('🔥', 'CALORIES', '${h.caloriesBurned.toInt()}', 'kcal')),
            Expanded(child: _HealthTile('😴', 'SLEEP', '${h.sleepHours.toStringAsFixed(1)}', 'hrs')),
          ]),
          const SizedBox(height: 10),
          Text('Last sync: ${_timeAgo(h.lastSync)}', style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
        ],
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('HOW IT WORKS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 8),
          ...[
            '📱 iOS: Syncs with Apple Watch via HealthKit',
            '🤖 Android: Syncs with Wear OS via Health Connect',
            '⌚ Steps, Heart Rate, Calories & Sleep auto-sync',
            '💪 Your workouts sync back to your watch too',
          ].map((t) => Padding(padding: const EdgeInsets.only(bottom: 4),
            child: Text(t, style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.5)))),
        ])),
      ])),
      const SizedBox(height: 16),

      // ── Reminders
      _SectionTitle('🔔  REMINDERS & NOTIFICATIONS'),
      DarkCard(child: Column(children: [
        _ReminderToggle(
          icon: '💪', label: 'WORKOUT REMINDER', sub: 'Daily at ${_fmt(r.workoutHour, r.workoutMinute)}',
          value: r.workoutEnabled,
          onChanged: (v) => _updateReminder(context, r.copyWith(workoutEnabled: v)),
          onTimeTap: () => _pickTime(context, r.workoutHour, r.workoutMinute,
              (h, m) => _updateReminder(context, r.copyWith(workoutHour: h, workoutMinute: m))),
        ),
        const Divider(color: AppColors.border),
        _ReminderToggle(
          icon: '💧', label: 'WATER REMINDERS', sub: 'Every ${r.waterIntervalHours}h (6am–10pm)',
          value: r.waterEnabled,
          onChanged: (v) => _updateReminder(context, r.copyWith(waterEnabled: v)),
          onTimeTap: () => _pickInterval(context, r.waterIntervalHours,
              (h) => _updateReminder(context, r.copyWith(waterIntervalHours: h))),
        ),
        const Divider(color: AppColors.border),
        _ReminderToggle(
          icon: '🍽', label: 'MEAL REMINDERS', sub: '6 meal times throughout the day',
          value: r.mealEnabled,
          onChanged: (v) => _updateReminder(context, r.copyWith(mealEnabled: v)),
          onTimeTap: null,
        ),
        const Divider(color: AppColors.border),
        _ReminderToggle(
          icon: '🌅', label: 'MORNING MOTIVATION', sub: 'Daily at ${_fmt(r.motivationHour, r.motivationMinute)}',
          value: r.motivationEnabled,
          onChanged: (v) => _updateReminder(context, r.copyWith(motivationEnabled: v)),
          onTimeTap: () => _pickTime(context, r.motivationHour, r.motivationMinute,
              (h, m) => _updateReminder(context, r.copyWith(motivationHour: h, motivationMinute: m))),
        ),
        const Divider(color: AppColors.border),
        _ReminderToggle(
          icon: '⚠️', label: 'STREAK PROTECTION', sub: 'Alert at 9 PM if not trained',
          value: r.streakEnabled,
          onChanged: (v) => _updateReminder(context, r.copyWith(streakEnabled: v)),
          onTimeTap: null,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            await NotificationService.showImmediate('🧪 Test Notification', 'Daily Discipline Trainer notifications are working!');
          },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border.all(color: AppColors.hiit.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('SEND TEST NOTIFICATION', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.hiit, letterSpacing: 2)))),
        ),
      ])),
      const SizedBox(height: 16),

      // ── App info
      _SectionTitle('ℹ️  ABOUT'),
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Daily Discipline Trainer v2.0', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrim)),
        const SizedBox(height: 4),
        const Text('Built with Flutter · AI by Anthropic Claude', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
        const SizedBox(height: 12),
        ...[
          ('🏋 14 Exercises', 'Animated form guides for every exercise'),
          ('📷 AI Food Scanner', 'Photo → instant nutrition data'),
          ('⌚ Smartwatch Sync', 'Apple Watch + Wear OS support'),
          ('🔔 Smart Reminders', 'Never miss a workout again'),
          ('📊 Progress Tracking', '35-day heatmap + body stats'),
          ('🔥 Gamification', 'Streaks, points, badges'),
          ('📱 Works Offline', 'No internet needed (except AI scanner)'),
        ].map((f) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
          Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.hiit)),
          const SizedBox(width: 8),
          Expanded(child: Text(f.$2, style: const TextStyle(fontSize: 12, color: AppColors.textSub))),
        ]))),
      ])),
    ]);
  }

  void _updateReminder(BuildContext ctx, ReminderSettings r) {
    ctx.read<AppProvider>().updateReminders(r);
    setState(() {});
  }

  Future<void> _pickTime(BuildContext ctx, int h, int m, Function(int, int) onPick) async {
    final picked = await showTimePicker(
      context: ctx,
      initialTime: TimeOfDay(hour: h, minute: m),
      builder: (ctx2, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.hiit)), child: child!),
    );
    if (picked != null && mounted) onPick(picked.hour, picked.minute);
  }

  Future<void> _pickInterval(BuildContext ctx, int current, Function(int) onPick) async {
    await showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Water reminder interval', style: TextStyle(color: AppColors.textPrim)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [1, 2, 3, 4].map((h) => ListTile(
        title: Text('Every $h hour${h > 1 ? 's' : ''}', style: const TextStyle(color: AppColors.textPrim)),
        trailing: current == h ? const Icon(Icons.check, color: AppColors.hiit) : null,
        onTap: () { onPick(h); Navigator.pop(context); },
      )).toList()),
    ));
  }

  void _editProfile(BuildContext ctx, UserProfile p) {
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ProfileEditor(profile: p));
  }

  String _fmt(int h, int m) => '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 2) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _ProfileEditor extends StatefulWidget {
  final UserProfile profile;
  const _ProfileEditor({required this.profile});
  @override State<_ProfileEditor> createState() => _ProfileEditorState();
}
class _ProfileEditorState extends State<_ProfileEditor> {
  late UserProfile _p;
  late TextEditingController _nameCtrl;
  @override void initState() { super.initState(); _p = widget.profile; _nameCtrl = TextEditingController(text: _p.name); }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim, letterSpacing: 2)),
        const SizedBox(height: 20),
        TextField(controller: _nameCtrl, onChanged: (v) => setState(() => _p = _p.copyWith(name: v)),
          style: const TextStyle(color: AppColors.textPrim),
          decoration: const InputDecoration(labelText: 'Name', contentPadding: EdgeInsets.all(12))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('HEIGHT (cm)', style: TextStyle(fontSize: 9, color: AppColors.textDim, letterSpacing: 2)),
            Slider(value: _p.heightCm, min: 140, max: 220, activeColor: AppColors.hiit, inactiveColor: AppColors.border,
              onChanged: (v) => setState(() => _p = _p.copyWith(heightCm: v))),
            Text('${_p.heightCm.toInt()}cm', style: const TextStyle(color: AppColors.hiit, fontWeight: FontWeight.w700, fontSize: 16)),
          ])),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('WEIGHT (kg)', style: TextStyle(fontSize: 9, color: AppColors.textDim, letterSpacing: 2)),
            Slider(value: _p.weightKg, min: 30, max: 200, activeColor: AppColors.hiit, inactiveColor: AppColors.border,
              onChanged: (v) => setState(() => _p = _p.copyWith(weightKg: v))),
            Text('${_p.weightKg.toInt()}kg', style: const TextStyle(color: AppColors.hiit, fontWeight: FontWeight.w700, fontSize: 16)),
          ])),
        ]),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () { context.read<AppProvider>().saveProfile(_p); Navigator.pop(context); },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black, letterSpacing: 2)))),
        ),
      ])),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
  );
}

class _MiniStat extends StatelessWidget {
  final String label, value; final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
    Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textDim, letterSpacing: 1)),
  ]);
}

class _HealthTile extends StatelessWidget {
  final String icon, label, value, unit;
  const _HealthTile(this.icon, this.label, this.value, this.unit);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 22)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrim)),
    Text(label, style: const TextStyle(fontSize: 7, color: AppColors.textDim, letterSpacing: 1)),
    Text(unit, style: const TextStyle(fontSize: 9, color: AppColors.textSub)),
  ]);
}

class _ReminderToggle extends StatelessWidget {
  final String icon, label, sub;
  final bool value;
  final Function(bool) onChanged;
  final VoidCallback? onTimeTap;
  const _ReminderToggle({required this.icon, required this.label, required this.sub, required this.value, required this.onChanged, required this.onTimeTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrim)),
        Row(children: [
          Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
          if (onTimeTap != null) ...[
            const SizedBox(width: 6),
            GestureDetector(onTap: onTimeTap,
              child: const Text('CHANGE', style: TextStyle(fontSize: 9, color: AppColors.hiit, fontWeight: FontWeight.w700, letterSpacing: 1))),
          ],
        ]),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: AppColors.hiit),
    ]),
  );
}
