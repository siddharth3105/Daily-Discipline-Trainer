import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DarkCard extends StatelessWidget {
  final Widget child;
  final Color? bgColor, borderColor;
  const DarkCard({super.key, required this.child, this.bgColor, this.borderColor});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: bgColor ?? AppColors.card, border: Border.all(color: borderColor ?? AppColors.border), borderRadius: BorderRadius.circular(14)),
    child: child,
  );
}

class StatCard extends StatelessWidget {
  final String label, value; final Color color;
  const StatCard({super.key, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: color, height: 1)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textDim, letterSpacing: 1.5), textAlign: TextAlign.center),
    ]),
  );
}

class AppProgressBar extends StatelessWidget {
  final double value, max; final Color color; final double height;
  const AppProgressBar({super.key, required this.value, required this.max, required this.color, this.height = 6});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (_, box) {
    final frac = (value / max).clamp(0.0, 1.0);
    return Container(height: height, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(height)),
      child: FractionallySizedBox(widthFactor: frac, alignment: Alignment.centerLeft,
        child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)))));
  });
}

class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrim, letterSpacing: 0.5));
}

class MacroRow extends StatelessWidget {
  final String label; final double value, goal; final Color color;
  const MacroRow({super.key, required this.label, required this.value, required this.goal, required this.color});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
    SizedBox(width: 30, child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: color))),
    Expanded(child: AppProgressBar(value: value, max: goal.clamp(1, double.infinity), color: color, height: 5)),
    const SizedBox(width: 8),
    Text('${value.toInt()}g', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
  ]));
}

class WaterTracker extends StatelessWidget {
  final int count; final Function(int) onTap;
  const WaterTracker({super.key, required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) => Row(children: List.generate(8, (i) => Expanded(
    child: GestureDetector(
      onTap: () => onTap(i + 1),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Icon(
        i < count ? Icons.water_drop : Icons.water_drop_outlined,
        size: 28, color: i < count ? AppColors.bodyweight : AppColors.border,
      )),
    ),
  )));
}

class CalorieRing extends StatelessWidget {
  final int consumed, goal;
  const CalorieRing({super.key, required this.consumed, required this.goal});
  @override
  Widget build(BuildContext context) {
    final frac = (consumed / goal.clamp(1, 9999)).clamp(0.0, 1.0);
    final over = consumed > goal;
    return SizedBox(width: 100, height: 100, child: Stack(alignment: Alignment.center, children: [
      CircularProgressIndicator(value: frac, strokeWidth: 9, strokeCap: StrokeCap.round,
        backgroundColor: AppColors.border, color: over ? AppColors.hiit : AppColors.flex),
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text('$consumed', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim, height: 1)),
        const Text('kcal', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
      ]),
    ]));
  }
}

class NutrientCard extends StatelessWidget {
  final String icon, label, value; final Color color;
  const NutrientCard({super.key, required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color, height: 1.1)),
      Text(label, style: const TextStyle(fontSize: 8, color: AppColors.textDim)),
    ]),
  );
}
