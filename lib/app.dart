import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'providers/app_provider.dart';
import 'data/app_data.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';

class DDTApp extends StatelessWidget {
  const DDTApp({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AppProvider()..loadAll(),
    child: MaterialApp(
      title: 'Daily Discipline Trainer',
      theme: AppColors.theme,
      debugShowCheckedModeBanner: false,
      home: const _AppShell(),
    ),
  );
}

class _AppShell extends StatefulWidget {
  const _AppShell();
  @override State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> with TickerProviderStateMixin {
  int _tab = 0;
  late ConfettiController _confetti;
  late TabController _tabCtrl;
  bool _showingCelebration = false;

  final _tabs = const [
    HomeScreen(),
    WorkoutScreen(),
    DietScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  final _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded),     label: 'HOME'),
    BottomNavigationBarItem(icon: Icon(Icons.fitness_center),   label: 'TRAIN'),
    BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu),  label: 'DIET'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded),label: 'PROGRESS'),
    BottomNavigationBarItem(icon: Icon(Icons.settings),         label: 'SETTINGS'),
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _onTabTap(int i) => setState(() => _tab = i);

  void _celebrate(BuildContext ctx) {
    if (_showingCelebration) return;
    _showingCelebration = true;
    _confetti.play();
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => _CelebrationOverlay(onDismiss: () {
        Navigator.pop(ctx);
        _showingCelebration = false;
      }),
    ).then((_) => _showingCelebration = false);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    if (!prov.loaded) return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🔥', style: TextStyle(fontSize: 60)),
        SizedBox(height: 16),
        Text('DAILY DISCIPLINE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.hiit, letterSpacing: 3)),
        SizedBox(height: 8),
        CircularProgressIndicator(color: AppColors.hiit, strokeWidth: 2),
      ])),
    );

    // Onboarding check
    if (!prov.profile.onboardingDone) {
      return OnboardingScreen(onComplete: () => setState(() {}));
    }

    // Badge toast
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (prov.newBadgeId != null) {
        final badge = allBadges.firstWhere((b) => b.id == prov.newBadgeId, orElse: () => allBadges[0]);
        prov.clearNewBadge();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 4),
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          behavior: SnackBarBehavior.floating,
          content: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.gold.withOpacity(0.4))),
              child: Center(child: Text(badge.icon, style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              const Text('🏅 BADGE UNLOCKED!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.gold, letterSpacing: 2)),
              Text(badge.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrim)),
              Text(badge.desc, style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
            ])),
          ]),
        ));
      }
    });

    // Day complete celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (prov.dayDone && !_showingCelebration) {
        // Only show once per session
      }
    });

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Row(children: [
            const Text('🔥 ', style: TextStyle(fontSize: 20)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_tabTitles[_tab], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim, letterSpacing: 1)),
              if (prov.stats.streak > 0) Text('${prov.stats.streak} day streak 🔥', style: const TextStyle(fontSize: 10, color: AppColors.hiit, fontWeight: FontWeight.w700)),
            ]),
          ]),
          actions: [
            if (prov.healthAuthorized)
              Padding(padding: const EdgeInsets.only(right: 4), child: IconButton(
                icon: const Text('⌚', style: TextStyle(fontSize: 20)),
                onPressed: () => prov.refreshHealthData(),
                tooltip: 'Sync Watch',
              )),
            Padding(padding: const EdgeInsets.only(right: 12), child: GestureDetector(
              onTap: () => setState(() => _tab = 4),
              child: CircleAvatar(radius: 18, backgroundColor: AppColors.hiit.withOpacity(0.15),
                child: Text(prov.profile.name.isNotEmpty ? prov.profile.name[0].toUpperCase() : '💪',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.hiit))),
            )),
          ],
        ),
        body: Stack(children: [
          IndexedStack(index: _tab, children: _tabs),
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [AppColors.hiit, AppColors.gold, AppColors.flex, AppColors.bodyweight, Colors.white],
            emissionFrequency: 0.08, numberOfParticles: 25, gravity: 0.3,
          )),
        ]),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
          child: BottomNavigationBar(
            currentIndex: _tab, onTap: _onTabTap,
            type: BottomNavigationBarType.fixed,
            items: _navItems,
          ),
        ),
        floatingActionButton: _tab == 1 && prov.dayDone ? FloatingActionButton.extended(
          onPressed: () => _celebrate(context),
          backgroundColor: AppColors.flex,
          icon: const Text('🎉', style: TextStyle(fontSize: 20)),
          label: const Text('CELEBRATE!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black)),
        ) : null,
      ),
    );
  }

  static const _tabTitles = ['HOME', 'TRAIN', 'DIET', 'PROGRESS', 'SETTINGS'];
}

class _CelebrationOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  const _CelebrationOverlay({required this.onDismiss});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onDismiss,
    child: Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🏆', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 16),
        const Text('DAY COMPLETE!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36, color: AppColors.gold, letterSpacing: 4)),
        const SizedBox(height: 8),
        const Text('Another step towards greatness.', style: TextStyle(fontSize: 16, color: AppColors.textSub)),
        const SizedBox(height: 32),
        Container(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(color: AppColors.flex, borderRadius: BorderRadius.circular(12)),
          child: const Text('KEEP GOING →', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
      ])),
    ),
  );
}
