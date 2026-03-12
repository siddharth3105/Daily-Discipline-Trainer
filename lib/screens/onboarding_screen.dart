import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});
  @override State<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  String _name = '';
  int _age = 22;
  String _gender = 'male';
  double _height = 170;
  double _weight = 70;
  String _goal = 'muscle';
  String _activity = 'moderate';

  final goals = [
    ('muscle', '💪', 'Build Muscle', 'Gain strength & size with progressive overload'),
    ('lean',   '🔥', 'Lose Fat',    'Burn fat while preserving muscle mass'),
    ('height', '📏', 'Height & Growth','Decompress spine & optimize growth hormones'),
    ('endurance','🏃','Endurance',  'Boost stamina, cardio & athletic performance'),
  ];

  final activities = [
    ('sedentary',  'Sedentary',   'Desk job, little exercise'),
    ('light',      'Light',       '1-3 days/week exercise'),
    ('moderate',   'Moderate',    '3-5 days/week exercise'),
    ('active',     'Active',      '6-7 days/week exercise'),
    ('very_active','Very Active', 'Physical job + daily training'),
  ];

  void _next() {
    if (_page < 4) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  void _finish() async {
    final prov = context.read<AppProvider>();
    await prov.saveProfile(UserProfile(
      name: _name.isNotEmpty ? _name : 'Athlete',
      age: _age, gender: _gender, heightCm: _height, weightKg: _weight,
      goal: _goal, activityLevel: _activity, onboardingDone: true,
    ));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: Column(children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(children: List.generate(5, (i) => Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
              decoration: BoxDecoration(
                color: i <= _page ? AppColors.hiit : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ))),
        ),
        Expanded(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _WelcomePage(onNext: _next),
              _PersonalPage(name: _name, age: _age, gender: _gender,
                onName: (v) => setState(() => _name = v),
                onAge: (v) => setState(() => _age = v),
                onGender: (v) => setState(() => _gender = v),
                onNext: _next),
              _BodyPage(height: _height, weight: _weight,
                onHeight: (v) => setState(() => _height = v),
                onWeight: (v) => setState(() => _weight = v),
                onNext: _next),
              _GoalPage(selected: _goal, goals: goals,
                onSelect: (v) => setState(() => _goal = v), onNext: _next),
              _ActivityPage(selected: _activity, activities: activities,
                onSelect: (v) => setState(() => _activity = v), onNext: _next),
            ],
          ),
        ),
      ])),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🔥', style: TextStyle(fontSize: 80)),
      const SizedBox(height: 20),
      const Text('DAILY DISCIPLINE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36, color: AppColors.hiit, letterSpacing: 3)),
      const Text('TRAINER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textSub, letterSpacing: 8)),
      const SizedBox(height: 24),
      const Text('Your complete fitness companion for Android & iOS.\n\nWorkouts · AI Food Scanner · Smartwatch · Reminders · Progress Tracking',
        style: TextStyle(fontSize: 15, color: AppColors.textSub, height: 1.7), textAlign: TextAlign.center),
      const SizedBox(height: 40),
      _BigBtn(label: "LET'S BUILD YOUR PLAN →", onTap: onNext),
    ]),
  );
}

class _PersonalPage extends StatelessWidget {
  final String name, gender;
  final int age;
  final Function(String) onName;
  final Function(int) onAge;
  final Function(String) onGender;
  final VoidCallback onNext;
  const _PersonalPage({required this.name, required this.age, required this.gender, required this.onName, required this.onAge, required this.onGender, required this.onNext});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 20),
    const Text('WHO ARE YOU?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.textPrim, letterSpacing: 2)),
    const SizedBox(height: 6),
    const Text("Let's personalise your experience.", style: TextStyle(color: AppColors.textSub, fontSize: 14)),
    const SizedBox(height: 32),
    _Label('YOUR NAME'),
    const SizedBox(height: 8),
    TextField(
      onChanged: onName,
      style: const TextStyle(color: AppColors.textPrim, fontSize: 18, fontWeight: FontWeight.w700),
      decoration: const InputDecoration(hintText: 'e.g. Arjun', contentPadding: EdgeInsets.all(14)),
    ),
    const SizedBox(height: 24),
    _Label('YOUR AGE'),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(child: Slider(
        value: age.toDouble(), min: 13, max: 70,
        activeColor: AppColors.hiit, inactiveColor: AppColors.border,
        onChanged: (v) => onAge(v.round()),
      )),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(8)),
        child: Text('$age', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.hiit)),
      ),
    ]),
    const SizedBox(height: 24),
    _Label('GENDER'),
    const SizedBox(height: 8),
    Row(children: [
      _GenderBtn(label: '♂ Male', val: 'male', selected: gender, onTap: () => onGender('male')),
      const SizedBox(width: 8),
      _GenderBtn(label: '♀ Female', val: 'female', selected: gender, onTap: () => onGender('female')),
      const SizedBox(width: 8),
      _GenderBtn(label: '○ Other', val: 'other', selected: gender, onTap: () => onGender('other')),
    ]),
    const SizedBox(height: 40),
    _BigBtn(label: 'CONTINUE →', onTap: onNext),
  ]));
}

class _BodyPage extends StatelessWidget {
  final double height, weight;
  final Function(double) onHeight, onWeight;
  final VoidCallback onNext;
  const _BodyPage({required this.height, required this.weight, required this.onHeight, required this.onWeight, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final bmi = weight / ((height/100) * (height/100));
    final bmiLabel = bmi < 18.5 ? 'Underweight' : bmi < 25 ? 'Normal ✓' : bmi < 30 ? 'Overweight' : 'Obese';
    final bmiColor = bmi < 18.5 ? AppColors.bodyweight : bmi < 25 ? AppColors.flex : bmi < 30 ? AppColors.strength : AppColors.hiit;
    return SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      const Text('YOUR BODY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.textPrim, letterSpacing: 2)),
      const SizedBox(height: 6),
      const Text('We calculate your personalised calorie target.', style: TextStyle(color: AppColors.textSub, fontSize: 14)),
      const SizedBox(height: 32),
      _Label('HEIGHT (cm)'),
      Row(children: [
        Expanded(child: Slider(value: height, min: 140, max: 220, activeColor: AppColors.hiit, inactiveColor: AppColors.border, onChanged: onHeight)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(8)),
          child: Text('${height.toInt()}cm', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.hiit))),
      ]),
      const SizedBox(height: 16),
      _Label('WEIGHT (kg)'),
      Row(children: [
        Expanded(child: Slider(value: weight, min: 30, max: 200, activeColor: AppColors.hiit, inactiveColor: AppColors.border, onChanged: onWeight)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(8)),
          child: Text('${weight.toInt()}kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.hiit))),
      ]),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: bmiColor.withOpacity(0.4)), borderRadius: BorderRadius.circular(14)), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR BMI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          Text(bmi.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: bmiColor, height: 1)),
          Text(bmiLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: bmiColor)),
        ])),
        _BmiBar(bmi: bmi),
      ])),
      const SizedBox(height: 32),
      _BigBtn(label: 'CONTINUE →', onTap: onNext),
    ]));
  }
}

class _GoalPage extends StatelessWidget {
  final String selected;
  final List<(String, String, String, String)> goals;
  final Function(String) onSelect;
  final VoidCallback onNext;
  const _GoalPage({required this.selected, required this.goals, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 20),
    const Text('YOUR GOAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.textPrim, letterSpacing: 2)),
    const SizedBox(height: 6),
    const Text('What are you training for?', style: TextStyle(color: AppColors.textSub, fontSize: 14)),
    const SizedBox(height: 24),
    ...goals.map((g) {
      final active = selected == g.$1;
      return GestureDetector(
        onTap: () => onSelect(g.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active ? AppColors.hiit.withOpacity(0.1) : AppColors.card,
            border: Border.all(color: active ? AppColors.hiit : AppColors.border, width: active ? 2 : 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            Text(g.$2, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.$3, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: active ? AppColors.hiit : AppColors.textPrim)),
              Text(g.$4, style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.4)),
            ])),
            if (active) const Icon(Icons.check_circle, color: AppColors.hiit),
          ]),
        ),
      );
    }),
    const SizedBox(height: 16),
    _BigBtn(label: 'CONTINUE →', onTap: onNext),
  ]));
}

class _ActivityPage extends StatelessWidget {
  final String selected;
  final List<(String, String, String)> activities;
  final Function(String) onSelect;
  final VoidCallback onNext;
  const _ActivityPage({required this.selected, required this.activities, required this.onSelect, required this.onNext});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 20),
    const Text('ACTIVITY LEVEL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.textPrim, letterSpacing: 2)),
    const SizedBox(height: 6),
    const Text('How active are you outside gym?', style: TextStyle(color: AppColors.textSub, fontSize: 14)),
    const SizedBox(height: 24),
    ...activities.map((a) {
      final active = selected == a.$1;
      return GestureDetector(
        onTap: () => onSelect(a.$1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.hiit.withOpacity(0.1) : AppColors.card,
            border: Border.all(color: active ? AppColors.hiit : AppColors.border, width: active ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.$2, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: active ? AppColors.hiit : AppColors.textPrim)),
              Text(a.$3, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
            ])),
            if (active) const Icon(Icons.check_circle, color: AppColors.hiit, size: 20),
          ]),
        ),
      );
    }),
    const SizedBox(height: 24),
    _BigBtn(label: "🔥  LET'S START!", onTap: onNext),
  ]));
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3));
}

class _GenderBtn extends StatelessWidget {
  final String label, val, selected;
  final VoidCallback onTap;
  const _GenderBtn({required this.label, required this.val, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final active = selected == val;
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.hiit.withOpacity(0.1) : AppColors.card2,
          border: Border.all(color: active ? AppColors.hiit : AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: active ? AppColors.hiit : AppColors.textSub))),
      ),
    ));
  }
}

class _BigBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _BigBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black, letterSpacing: 2))),
    ),
  );
}

class _BmiBar extends StatelessWidget {
  final double bmi;
  const _BmiBar({required this.bmi});
  @override
  Widget build(BuildContext context) {
    final zones = [
      (18.5, const Color(0xFF3498DB)),
      (25.0, AppColors.flex),
      (30.0, AppColors.strength),
      (40.0, AppColors.hiit),
    ];
    final pct = ((bmi - 10) / 30).clamp(0.0, 1.0);
    return SizedBox(width: 24, height: 100, child: Stack(children: [
      Container(decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF3498DB), AppColors.flex, AppColors.strength, AppColors.hiit]),
        borderRadius: BorderRadius.circular(4),
      )),
      Positioned(top: (100 * pct).clamp(0, 90), child: Container(width: 24, height: 4, color: Colors.white, margin: EdgeInsets.zero)),
    ]));
  }
}
