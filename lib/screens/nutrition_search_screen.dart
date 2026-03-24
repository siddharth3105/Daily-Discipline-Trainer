import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/nutrition_api_service.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class NutritionSearchScreen extends StatefulWidget {
  const NutritionSearchScreen({super.key});
  @override State<NutritionSearchScreen> createState() => _NutritionSearchScreenState();
}

class _NutritionSearchScreenState extends State<NutritionSearchScreen> {
  final _searchCtrl = TextEditingController();
  List<FoodSearchResult> _results = [];
  NutritionData? _selectedFood;
  bool _loading = false;
  bool _loadingDetails = false;
  String _error = '';

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() { _loading = true; _error = ''; _results = []; _selectedFood = null; });
    try {
      final results = await NutritionApiService.searchFood(query);
      setState(() { _results = results; _loading = false; });
    } catch (e) {
      setState(() { 
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _loadDetails(FoodSearchResult result) async {
    setState(() { _loadingDetails = true; _error = ''; });
    try {
      final nutrition = await NutritionApiService.getFoodDetails(result.id);
      setState(() { _selectedFood = nutrition; _loadingDetails = false; });
    } catch (e) {
      setState(() { 
        _error = e.toString().replaceAll('Exception: ', '');
        _loadingDetails = false;
      });
    }
  }

  void _addToLog(BuildContext context) {
    if (_selectedFood == null) return;
    final food = _selectedFood!;
    context.read<AppProvider>().addFood(FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${food.name} (${food.servingQty} ${food.servingUnit})',
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      fiber: food.fiber,
      sugar: food.sugar,
      sodium: food.sodium,
      fromScanner: false,
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Added to food log'), backgroundColor: AppColors.flex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('NUTRITION SEARCH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrim, letterSpacing: 2)),
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
                hintText: 'Search food (e.g., "chicken breast 100g")...',
                prefixIcon: Icon(Icons.search, color: AppColors.textDim),
                isDense: true,
                contentPadding: EdgeInsets.all(12),
              ),
              onSubmitted: (_) => _search(),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _search,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.search, color: Colors.black),
              ),
            ),
          ]),
        ),

        // Content
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.hiit)))
        else if (_error.isNotEmpty)
          Expanded(child: Center(child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(_error, style: const TextStyle(color: AppColors.textSub, fontSize: 14), textAlign: TextAlign.center),
            ]),
          )))
        else if (_selectedFood != null)
          Expanded(child: _NutritionDetails(nutrition: _selectedFood!, onAdd: () => _addToLog(context)))
        else if (_results.isNotEmpty)
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final result = _results[i];
              return GestureDetector(
                onTap: () => _loadDetails(result),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Container(
                      width: 50, 
                      height: 50, 
                      decoration: BoxDecoration(
                        color: result.type == 'Brand' ? AppColors.hiit.withOpacity(0.1) : AppColors.flex.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: result.type == 'Brand' ? AppColors.hiit : AppColors.flex),
                      ), 
                      child: Icon(
                        result.type == 'Brand' ? Icons.shopping_bag : Icons.restaurant, 
                        color: result.type == 'Brand' ? AppColors.hiit : AppColors.flex,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(result.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrim)),
                      if (result.brand.isNotEmpty)
                        Text(result.brand, style: const TextStyle(fontSize: 11, color: AppColors.hiit))
                      else
                        Text(result.type, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                      if (result.description.isNotEmpty)
                        Text(result.description, style: const TextStyle(fontSize: 10, color: AppColors.textDim), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ])),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textDim),
                  ]),
                ),
              );
            },
          ))
        else
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text('🔍', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('Search for any food', style: TextStyle(fontSize: 16, color: AppColors.textDim)),
            SizedBox(height: 8),
            Text('Try: "apple", "chicken 100g", "pizza slice"', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
          ]))),

        if (_loadingDetails)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.card,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.hiit)),
              SizedBox(width: 12),
              Text('Loading nutrition data...', style: TextStyle(color: AppColors.textSub)),
            ]),
          ),
      ]),
    );
  }
}

class _NutritionDetails extends StatelessWidget {
  final NutritionData nutrition;
  final VoidCallback onAdd;
  const _NutritionDetails({required this.nutrition, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(14), children: [
      DarkCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(nutrition.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textPrim)),
        if (nutrition.brand.isNotEmpty)
          Text(nutrition.brand, style: const TextStyle(fontSize: 14, color: AppColors.hiit)),
        Text(nutrition.servingUnit, style: const TextStyle(fontSize: 12, color: AppColors.textSub)),
        const SizedBox(height: 16),

        // Calories
        Center(child: Column(children: [
          Text('${nutrition.calories}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 48, color: AppColors.hiit, height: 1)),
          const Text('CALORIES', style: TextStyle(fontSize: 10, color: AppColors.textDim, letterSpacing: 2)),
        ])),
        const SizedBox(height: 16),

        // Macros
        MacroRow(label: 'PROTEIN', value: nutrition.protein, goal: 50, color: AppColors.hiit),
        MacroRow(label: 'CARBS', value: nutrition.carbs, goal: 60, color: AppColors.strength),
        MacroRow(label: 'FAT', value: nutrition.fat, goal: 20, color: AppColors.bodyweight),
        const SizedBox(height: 12),

        // Additional nutrients
        Row(children: [
          Expanded(child: _NutrientTile('Fiber', '${nutrition.fiber.toInt()}g')),
          Expanded(child: _NutrientTile('Sugar', '${nutrition.sugar.toInt()}g')),
          Expanded(child: _NutrientTile('Sodium', '${nutrition.sodium.toInt()}mg')),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _NutrientTile('Cholesterol', '${nutrition.cholesterol.toInt()}mg')),
          Expanded(child: _NutrientTile('Sat. Fat', '${nutrition.saturatedFat.toInt()}g')),
          const Expanded(child: SizedBox()),
        ]),
      ])),
      const SizedBox(height: 16),

      GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.hiit, borderRadius: BorderRadius.circular(13)),
          child: const Center(child: Text('ADD TO FOOD LOG  +10 PTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, letterSpacing: 2))),
        ),
      ),
    ]);
  }
}

class _NutrientTile extends StatelessWidget {
  final String label, value;
  const _NutrientTile(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(4),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrim)),
      Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textDim)),
    ]),
  );
}
