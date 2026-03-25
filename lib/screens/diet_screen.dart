import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/app_data.dart';
import '../models/models.dart';
import '../services/ai_food_service.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});
  @override State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  String _planKey = 'muscle';
  int _tabIdx = 0; // 0=tracker, 1=scan, 2=meal plan

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final plan = dietPlans[_planKey]!;
    final totalCal  = prov.totalCalToday();
    final totalP    = prov.totalProteinToday();
    final totalC    = prov.totalCarbsToday();
    final totalF    = prov.totalFatToday();

    return Column(children: [
      // ── Plan selector
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Row(children: dietPlans.entries.map((e) {
          final active = _planKey == e.key;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _planKey = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.hiit : AppColors.card,
                border: Border.all(color: active ? AppColors.hiit : AppColors.border),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(child: Text(e.value.label,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: active ? Colors.black : AppColors.textSub, letterSpacing: 1))),
            ),
          ));
        }).toList()),
      ),
      // ── Tabs
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Row(children: [
          _buildTab('📊  TRACKER', 0),
          const SizedBox(width: 5),
          _buildTab('📷  SCAN FOOD', 1),
          const SizedBox(width: 5),
          _buildTab('🍽️  MEAL PLAN', 2),
        ]),
      ),
      const SizedBox(height: 8),

      Expanded(child: IndexedStack(index: _tabIdx, children: [
        // ── TRACKER
        _TrackerTab(plan: plan, totalCal: totalCal, totalP: totalP, totalC: totalC, totalF: totalF),
        // ── SCAN
        _ScanTab(),
        // ── MEAL PLAN
        _MealPlanTab(plan: plan),
      ])),
    ]);
  }

  Widget _buildTab(String label, int idx) {
    final active = _tabIdx == idx;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tabIdx = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.hiit.withOpacity(0.1) : AppColors.card,
          border: Border.all(color: active ? AppColors.hiit : AppColors.border),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(child: Text(label,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: active ? AppColors.hiit : AppColors.textSub, letterSpacing: 1))),
      ),
    ));
  }
}

// ── TRACKER TAB ───────────────────────────────────────────────────────────────
class _TrackerTab extends StatefulWidget {
  final DietPlan plan;
  final int totalCal; final double totalP, totalC, totalF;
  const _TrackerTab({required this.plan, required this.totalCal, required this.totalP, required this.totalC, required this.totalF});
  @override State<_TrackerTab> createState() => _TrackerTabState();
}

class _TrackerTabState extends State<_TrackerTab> {
  final _nameCtrl = TextEditingController();
  final _calCtrl  = TextEditingController();
  final _pCtrl    = TextEditingController();
  final _cCtrl    = TextEditingController();
  final _fCtrl    = TextEditingController();

  void _add(AppProvider prov) {
    final name = _nameCtrl.text.trim();
    final cal  = int.tryParse(_calCtrl.text) ?? 0;
    if (name.isEmpty || cal == 0) return;
    prov.addFood(FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, calories: cal,
      protein: double.tryParse(_pCtrl.text) ?? 0,
      carbs:   double.tryParse(_cCtrl.text) ?? 0,
      fat:     double.tryParse(_fCtrl.text) ?? 0,
    ));
    _nameCtrl.clear(); _calCtrl.clear(); _pCtrl.clear(); _cCtrl.clear(); _fCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final inRange = widget.totalCal >= widget.plan.goalCalories * 0.9 && widget.totalCal <= widget.plan.goalCalories * 1.1;
    final over = widget.totalCal > widget.plan.goalCalories;
    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      // Calorie ring + macros
      DarkCard(child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          CalorieRing(consumed: widget.totalCal, goal: widget.plan.goalCalories),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.totalCal}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: AppColors.textPrim, height: 1)),
            Text('OF ${widget.plan.goalCalories} KCAL GOAL', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSub, letterSpacing: 2)),
            const SizedBox(height: 4),
            Text(inRange ? '✓ ON TARGET' : over ? '⚠ OVER GOAL' : 'KEEP EATING',
              style: TextStyle(fontSize: 11, color: inRange ? AppColors.success : over ? AppColors.danger : AppColors.flex)),
          ])),
        ]),
        const SizedBox(height: 14),
        MacroRow(label: 'PROTEIN', value: widget.totalP, goal: 160, color: AppColors.hiit),
        MacroRow(label: 'CARBS',   value: widget.totalC, goal: 220, color: AppColors.strength),
        MacroRow(label: 'FAT',     value: widget.totalF, goal: 65,  color: AppColors.bodyweight),
      ])),
      const SizedBox(height: 12),

      // Water tracker
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('💧  WATER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.water, letterSpacing: 1)),
          const Spacer(),
          Text('${prov.water * 250}ml / 2500ml', style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
        ]),
        const SizedBox(height: 10),
        WaterTracker(count: prov.water, onTap: (n) => prov.setWater(n)),
        const SizedBox(height: 8),
        AppProgressBar(value: prov.water.toDouble(), max: 10, color: AppColors.water, height: 3),
      ])),
      const SizedBox(height: 12),

      // Add food form
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('+ LOG FOOD MANUALLY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.hiit, letterSpacing: 1)),
        const SizedBox(height: 12),
        TextField(controller: _nameCtrl, style: const TextStyle(color: AppColors.textPrim),
          decoration: const InputDecoration(hintText: 'Food name (e.g. Chicken 150g)', isDense: true, contentPadding: EdgeInsets.all(10))),
        const SizedBox(height: 8),
        Row(children: [
          _numField(_calCtrl, 'KCAL'),
          const SizedBox(width: 6),
          _numField(_pCtrl, 'P(g)'),
          const SizedBox(width: 6),
          _numField(_cCtrl, 'C(g)'),
          const SizedBox(width: 6),
          _numField(_fCtrl, 'F(g)'),
        ]),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _add(prov),
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.hiit.withOpacity(0.1),
              border: Border.all(color: AppColors.hiit),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(child: Text('ADD ENTRY  +10 PTS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.hiit, letterSpacing: 2))),
          ),
        ),
      ])),
      const SizedBox(height: 12),

      // Food log
      if (prov.foodLog.isNotEmpty)
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📋  TODAY\'S LOG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.gold, letterSpacing: 2)),
          const SizedBox(height: 10),
          ...prov.foodLog.map((e) => Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(e.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrim)),
                  if (e.fromScanner) ...[const SizedBox(width: 6), Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.hiit.withOpacity(0.1), border: Border.all(color: AppColors.hiit.withOpacity(0.4)), borderRadius: BorderRadius.circular(4)),
                    child: const Text('AI', style: TextStyle(fontSize: 8, color: AppColors.hiit, fontWeight: FontWeight.w700)),
                  )],
                ]),
                Text('P:${e.protein.toInt()}g · C:${e.carbs.toInt()}g · F:${e.fat.toInt()}g',
                  style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
              ])),
              Text('${e.calories}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.hiit)),
              const Text(' KCAL', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
              const SizedBox(width: 4),
              GestureDetector(onTap: () => prov.removeFood(e.id),
                child: const Icon(Icons.close, size: 16, color: AppColors.textDim)),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSub, letterSpacing: 2)),
              const Spacer(),
              Text('${prov.totalCalToday()} kcal', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.hiit)),
            ]),
          ),
        ])),
    ]);
  }

  Widget _numField(TextEditingController c, String hint) => Expanded(
    child: TextField(controller: c, keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrim, fontSize: 12),
      textAlign: TextAlign.center,
      decoration: InputDecoration(hintText: hint, isDense: true, contentPadding: const EdgeInsets.all(8))));
}

// ── SCAN TAB ─────────────────────────────────────────────────────────────────
class _ScanTab extends StatefulWidget {
  @override State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  XFile? _image;
  bool _scanning = false;
  ScannedFood? _result;
  String _error = '';
  bool _added = false;
  String _aiProvider = 'gemini'; // 'gemini' or 'claude'

  final _picker = ImagePicker();

  static const _catColors = {
    'protein': AppColors.hiit, 'carbs': AppColors.strength,
    'fats': AppColors.bodyweight, 'dairy': AppColors.height,
    'fruits': AppColors.flex, 'vegetables': AppColors.success,
    'junk': Color(0xFFFF6B35), 'drink': AppColors.water,
    'other': AppColors.textSub,
  };

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (picked == null) return;
    setState(() { _image = picked; _result = null; _error = ''; _added = false; });
  }

  Future<void> _scanFood() async {
    if (_image == null) return;
    setState(() { _scanning = true; _error = ''; });
    try {
      AiFoodService.setProvider(_aiProvider); // Set provider before scanning
      final result = await AiFoodService.analyzeFood(_image!);
      setState(() { _result = result; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); });
    }
    setState(() { _scanning = false; });
  }

  void _addToLog(AppProvider prov) {
    if (_result == null) return;
    prov.addFood(FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _result!.name,
      calories: _result!.calories,
      protein: _result!.protein,
      carbs: _result!.carbs,
      fat: _result!.fat,
      fiber: _result!.fiber,
      sugar: _result!.sugar,
      sodium: _result!.sodium,
      fromScanner: true,
    ));
    setState(() => _added = true);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppProvider>();
    final catColor = _result != null ? (_catColors[_result!.category] ?? AppColors.textSub) : AppColors.hiit;
    final scoreColor = _result != null
        ? (_result!.healthScore >= 8 ? AppColors.flex : _result!.healthScore >= 5 ? AppColors.strength : AppColors.hiit)
        : AppColors.textSub;

    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      // Image picker area
      GestureDetector(
        onTap: () => _showPickerDialog(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _image != null ? null : 160,
          decoration: BoxDecoration(
            color: const Color(0xFF080808),
            border: Border.all(color: _image != null ? AppColors.hiit : const Color(0xFF333333), width: 2, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: kIsWeb
                      ? Image.network(_image!.path, fit: BoxFit.cover)
                      : FutureBuilder<Uint8List>(
                          future: _image!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(snapshot.data!, fit: BoxFit.cover);
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                )
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('📸', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text('TAP TO SCAN FOOD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.hiit, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  const Text('Camera · Gallery · Any food photo', style: TextStyle(color: AppColors.textSub, fontSize: 12)),
                ]),
        ),
      ),
      const SizedBox(height: 12),

      // AI Provider selector
      if (_image == null)
        DarkCard(child: Row(children: [
          const Text('🤖', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('AI PROVIDER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrim)),
            Text('Choose which AI analyzes your food', style: TextStyle(fontSize: 11, color: AppColors.textSub)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card2,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _aiProvider,
              underline: const SizedBox(),
              dropdownColor: AppColors.card2,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.hiit),
              items: const [
                DropdownMenuItem(value: 'gemini', child: Text('Gemini (Free)')),
                DropdownMenuItem(value: 'claude', child: Text('Claude (Premium)')),
              ],
              onChanged: (v) => setState(() => _aiProvider = v!),
            ),
          ),
        ])),
      if (_image == null) const SizedBox(height: 12),

      // Action buttons
      if (_image != null && _result == null)
        Row(children: [
          Expanded(child: _ActionBtn(label: '🔄  RETAKE', filled: false, onTap: _showPickerDialog)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: _scanning
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.hiit.withOpacity(0.1), border: Border.all(color: AppColors.hiit), borderRadius: BorderRadius.circular(10)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.hiit)),
                    SizedBox(width: 10),
                    Text('ANALYZING...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.hiit, letterSpacing: 2)),
                  ]),
                )
              : _ActionBtn(label: '🔍  ANALYZE FOOD', filled: true, onTap: _scanFood)),
        ]),

      // Error
      if (_error.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1A0000), border: Border.all(color: AppColors.hiit.withOpacity(0.4)), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            const Text('⚠️', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(_error, style: const TextStyle(fontSize: 13, color: Color(0xFFFF6666)), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => setState(() { _image = null; _error = ''; }),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: AppColors.hiit), borderRadius: BorderRadius.circular(8)),
                child: const Text('TRY AGAIN', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.hiit, letterSpacing: 1))),
            ),
          ]),
        ),
      ],

      // Results
      if (_result != null) ...[
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF080808),
            border: Border.all(color: catColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Top accent
            Container(height: 3, decoration: BoxDecoration(gradient: LinearGradient(colors: [catColor, catColor.withOpacity(0.2)]), borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
            Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Name + score
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_result!.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: catColor, height: 1.2)),
                  const SizedBox(height: 3),
                  Text('📏 ${_result!.serving}', style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: scoreColor.withOpacity(0.1), border: Border.all(color: scoreColor.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [
                    Text('${_result!.healthScore}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: scoreColor, height: 1)),
                    Text('/10', style: TextStyle(fontSize: 8, color: scoreColor)),
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: catColor.withOpacity(0.15), border: Border.all(color: catColor.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
                child: Text(_result!.healthLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: catColor, letterSpacing: 1)),
              ),
              const SizedBox(height: 14),

              // Calories + macros
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(12)), child: Column(children: [
                Row(children: [
                  Column(children: [
                    Text('${_result!.calories}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 44, color: AppColors.hiit, height: 1)),
                    const Text('CALORIES', style: TextStyle(fontSize: 9, color: AppColors.textDim, letterSpacing: 2)),
                  ]),
                  const SizedBox(width: 16),
                  Expanded(child: Column(children: [
                    MacroRow(label:'PROTEIN', value:_result!.protein, goal:50, color:AppColors.hiit),
                    MacroRow(label:'CARBS',   value:_result!.carbs,   goal:60, color:AppColors.strength),
                    MacroRow(label:'FAT',     value:_result!.fat,     goal:20, color:AppColors.bodyweight),
                  ])),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: NutrientCard(icon:'🌾', label:'FIBER',  value:'${_result!.fiber.toInt()}g',  color:AppColors.flex)),
                  const SizedBox(width: 6),
                  Expanded(child: NutrientCard(icon:'🍬', label:'SUGAR',  value:'${_result!.sugar.toInt()}g',  color:AppColors.strength)),
                  const SizedBox(width: 6),
                  Expanded(child: NutrientCard(icon:'🧂', label:'SODIUM', value:'${_result!.sodium.toInt()}mg',color:AppColors.bodyweight)),
                ]),
              ])),
              const SizedBox(height: 12),

              // Vitamins
              if (_result!.vitamins.isNotEmpty) ...[
                const Text('RICH IN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: _result!.vitamins.map((v) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF0A180A), border: Border.all(color: AppColors.flex.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
                  child: Text('✓ $v', style: const TextStyle(fontSize: 10, color: AppColors.flex, fontWeight: FontWeight.w600)),
                )).toList()),
                const SizedBox(height: 12),
              ],

              // Warnings
              if (_result!.warnings.isNotEmpty) ...[
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1A0800), border: Border.all(color: AppColors.hiit.withOpacity(0.3)), borderRadius: BorderRadius.circular(10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('⚠  HEADS UP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.hiit, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  ..._result!.warnings.map((w) => Padding(padding: const EdgeInsets.only(top: 2), child: Text('• $w', style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.5)))),
                ])),
                const SizedBox(height: 12),
              ],

              // Tip
              if (_result!.tip.isNotEmpty) ...[
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: catColor, width: 3))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('💡  NUTRITION TIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: catColor.withOpacity(0.7), letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(_result!.tip, style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.5)),
                ])),
                const SizedBox(height: 14),
              ],

              // Action buttons
              Row(children: [
                _ActionBtn(label: '🔄  SCAN NEW', filled: false, onTap: () => setState(() { _result = null; _image = null; _added = false; })),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: GestureDetector(
                  onTap: _added ? null : () => _addToLog(prov),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _added ? const Color(0xFF0D1A0D) : AppColors.hiit,
                      border: Border.all(color: _added ? AppColors.flex : AppColors.hiit),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text(
                      _added ? '✅  ADDED TO LOG' : '+ ADD TO LOG  +10 PTS',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: _added ? AppColors.flex : Colors.black, letterSpacing: 1),
                    )),
                  ),
                )),
              ]),
            ])),
          ]),
        ),
      ],

      // Instructions
      if (_image == null && _result == null) ...[
        const SizedBox(height: 12),
        DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('HOW TO USE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDim, letterSpacing: 3)),
          const SizedBox(height: 10),
          ...['Point camera at any food, meal, or packaged item',
              'Works with photos from gallery too',
              'AI identifies ingredients & gives full nutrition data',
              'Tap + ADD TO LOG to auto-fill your diary'].asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${e.key+1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.hiit, letterSpacing: 1)),
              const SizedBox(width: 10),
              Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.5))),
            ]),
          )),
        ])),
      ],
    ]);
  }

  void _showPickerDialog() {
    showModalBottomSheet(context: context, backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera_alt, color: AppColors.hiit),
          title: const Text('Take Photo', style: TextStyle(color: AppColors.textPrim)),
          onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
        ListTile(leading: const Icon(Icons.photo_library, color: AppColors.hiit),
          title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.textPrim)),
          onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
        const SizedBox(height: 8),
      ])),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label; final bool filled; final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.filled, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: filled ? AppColors.hiit : AppColors.card2,
        border: Border.all(color: filled ? AppColors.hiit : AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: filled ? Colors.black : AppColors.textSub, letterSpacing: 1))),
    ),
  );
}

// ── MEAL PLAN TAB ─────────────────────────────────────────────────────────────
class _MealPlanTab extends StatelessWidget {
  final DietPlan plan;
  const _MealPlanTab({required this.plan});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(14, 0, 14, 90), children: [
      DarkCard(child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(plan.label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.hiit, letterSpacing: 1)),
          Text('TARGET: ${plan.goalCalories} KCAL/DAY', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSub, letterSpacing: 2)),
        ])),
        Column(children: [
          Text('${plan.meals.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.textPrim)),
          const Text('MEALS', style: TextStyle(fontSize: 9, color: AppColors.textDim, letterSpacing: 2)),
        ]),
      ])),
      const SizedBox(height: 10),
      ...plan.meals.map((m) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.hiit, letterSpacing: 3)),
              Text(m.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.textPrim)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${m.cal}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.hiit)),
              const Text('KCAL', style: TextStyle(fontSize: 9, color: AppColors.textDim, letterSpacing: 1)),
            ]),
          ]),
          const SizedBox(height: 8),
          Text(m.foods, style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.5)),
          const SizedBox(height: 8),
          Row(children: [
            _MacroChip('P', '${m.protein}g', AppColors.hiit),
            const SizedBox(width: 6),
            _MacroChip('C', '${m.carbs}g', AppColors.strength),
            const SizedBox(width: 6),
            _MacroChip('F', '${m.fat}g', AppColors.bodyweight),
          ]),
        ]),
      )),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF0A180A), border: Border.all(color: AppColors.flex.withOpacity(0.2)), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('💡  TIPS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.flex, letterSpacing: 2)),
          const SizedBox(height: 10),
          ...plan.tips.map((t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('→  ', style: TextStyle(color: AppColors.flex, fontSize: 13)),
            Expanded(child: Text(t, style: const TextStyle(fontSize: 13, color: AppColors.textSub, height: 1.5))),
          ]))),
        ]),
      ),
    ]);
  }
}

class _MacroChip extends StatelessWidget {
  final String label, value; final Color color;
  const _MacroChip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(7)),
    child: Column(children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
      Text(label == 'P' ? 'PROTEIN' : label == 'C' ? 'CARBS' : 'FAT', style: const TextStyle(fontSize: 8, color: AppColors.textDim, letterSpacing: 1)),
    ]),
  );
}
