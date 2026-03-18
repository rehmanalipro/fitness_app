import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:fitness_app/features/home/services/app_api_service.dart';
import 'package:fitness_app/layout/main_layout.dart';

// ── Model ─────────────────────────────────────────────────────────────────
class FoodItem {
  final String id; // backend food_log_id (empty if not yet synced)
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String meal; // Breakfast / Lunch / Dinner

  FoodItem({
    String? id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.meal,
  }) : id = id ?? '';
}

// ── Saved Recipe Model ────────────────────────────────────────────────────
class SavedRecipe {
  final String name;
  final String ingredients;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  SavedRecipe({
    required this.name,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

// ── Controller ────────────────────────────────────────────────────────────
class FoodLogController extends GetxController {
  final _api = AppApiService();

  final RxList<FoodItem> loggedItems = <FoodItem>[].obs;
  final RxList<SavedRecipe> savedRecipes = <SavedRecipe>[].obs;
  final RxString selectedMeal = 'Breakfast'.obs;

  int get totalCalories => loggedItems.fold(0, (s, e) => s + e.calories);
  double get totalProtein => loggedItems.fold(0.0, (s, e) => s + e.protein);
  double get totalCarbs => loggedItems.fold(0.0, (s, e) => s + e.carbs);
  double get totalFat => loggedItems.fold(0.0, (s, e) => s + e.fat);

  List<FoodItem> get breakfastItems =>
      loggedItems.where((e) => e.meal == 'Breakfast').toList();
  List<FoodItem> get lunchItems =>
      loggedItems.where((e) => e.meal == 'Lunch').toList();
  List<FoodItem> get dinnerItems =>
      loggedItems.where((e) => e.meal == 'Dinner').toList();

  void addItem(FoodItem item) {
    loggedItems.add(item);
    // Persist to Laravel backend — capture returned id for future delete
    _api
        .createFoodLog({
          'title': item.name,
          'description': item.name,
          'message': item.name,
          'type': item.meal.toLowerCase(),
          'calories': item.calories,
          'protein': item.protein,
          'carbs': item.carbs,
          'fats': item.fat,
        })
        .then((result) {
          if (result['ok'] == true) {
            final data = result['data'];
            final inner = data is Map ? (data['data'] ?? data) : null;
            final serverId = inner is Map ? inner['id']?.toString() : null;
            if (serverId != null && serverId.isNotEmpty) {
              final idx = loggedItems.indexWhere(
                (e) => e.name == item.name && e.id.isEmpty,
              );
              if (idx != -1) {
                loggedItems[idx] = FoodItem(
                  id: serverId,
                  name: item.name,
                  calories: item.calories,
                  protein: item.protein,
                  carbs: item.carbs,
                  fat: item.fat,
                  meal: item.meal,
                );
              }
            }
          }
        })
        .catchError((_) {});
  }

  void removeItem(FoodItem item) {
    loggedItems.remove(item);
    if (item.id.isNotEmpty) {
      _api.deleteFoodLog(item.id).catchError((_) {});
    }
  }

  void saveRecipe(SavedRecipe recipe) {
    savedRecipes.add(recipe);
    // Persist to Laravel backend via add_recipe
    _api.addRecipe({
      'name': recipe.name,
      'title': recipe.name,
      'ingredients': recipe.ingredients,
      'calories': recipe.calories,
      'protein': recipe.protein,
      'carbs': recipe.carbs,
      'fats': recipe.fat,
    });
  }

  List<String> get previousMealNames =>
      loggedItems.map((e) => e.name).toSet().take(5).toList();
}

// ── Screen ────────────────────────────────────────────────────────────────
class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  late final FoodLogController _ctrl;
  final _searchCtrl = TextEditingController();
  String _portionSize = 'Medium (1 serving)';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  final List<String> _portionSizes = [
    'Small (0.5 serving)',
    'Medium (1 serving)',
    'Large (2 servings)',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<FoodLogController>()
        ? Get.find<FoodLogController>()
        : Get.put(FoodLogController(), permanent: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Open barcode scanner
  Future<void> _openBarcodeScanner() async {
    final result = await Get.to<String>(() => const _BarcodeScannerScreen());
    if (result == null || result.isEmpty) return;
    await _lookupBarcode(result);
  }

  // Open Food Facts API barcode lookup
  Future<void> _lookupBarcode(String barcode) async {
    _showLoading();
    try {
      final url =
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      Get.back(); // close loading
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 1) {
          final product = data['product'] as Map<String, dynamic>;
          _showFoodDetail(_productToFood(product, barcode));
        } else {
          Get.snackbar(
            'Not Found',
            'Product not found for barcode: $barcode',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (_) {
      Get.back();
      Get.snackbar(
        'Error',
        'Could not fetch product info',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Search food by name using Open Food Facts
  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final url =
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=8';
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final products = (data['products'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
        setState(() {
          _searchResults = products;
          _isSearching = false;
        });
      }
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  FoodItem _productToFood(Map<String, dynamic> p, [String? barcode]) {
    final nutriments = p['nutriments'] as Map<String, dynamic>? ?? {};
    return FoodItem(
      name: (p['product_name'] ?? p['product_name_en'] ?? barcode ?? 'Unknown')
          .toString(),
      calories: _toInt(
        nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'],
      ),
      protein: _toDouble(nutriments['proteins_100g'] ?? nutriments['proteins']),
      carbs: _toDouble(
        nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates'],
      ),
      fat: _toDouble(nutriments['fat_100g'] ?? nutriments['fat']),
      meal: _ctrl.selectedMeal.value,
    );
  }

  int _toInt(dynamic v) =>
      v == null ? 0 : (v is num ? v.round() : int.tryParse(v.toString()) ?? 0);
  double _toDouble(dynamic v) => v == null
      ? 0.0
      : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

  void _showLoading() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _showFoodDetail(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FoodDetailSheet(
        food: food,
        portionSize: _portionSize,
        portionSizes: _portionSizes,
        onPortionChanged: (v) => setState(() => _portionSize = v!),
        onAdd: () {
          _ctrl.addItem(food);
          Get.back();
          Get.snackbar(
            'Added',
            '${food.name} added to ${food.meal}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  // ── Manual Add Food ───────────────────────────────────────────────────
  void _openAddFood() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddFoodSheet(
        selectedMeal: _ctrl.selectedMeal.value,
        onAdd: (item) {
          _ctrl.addItem(item);
          Get.back();
          Get.snackbar(
            'Added',
            '${item.name} added to ${item.meal}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.black87,
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  // ── Save Recipe ───────────────────────────────────────────────────────
  void _openAddRecipe() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddRecipeSheet(
        onSave: (recipe) {
          _ctrl.saveRecipe(recipe);
          Get.back();
          Get.snackbar(
            'Saved',
            '${recipe.name} saved to recipes',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Food Logging',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 1,
      body: Obx(() {
        final ctrl = _ctrl;
        return RefreshIndicator(
          onRefresh: () async {
            ctrl.loggedItems.clear();
            ctrl.savedRecipes.clear();
          },
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Meal tabs ──────────────────────────────────────────
              _MealTabs(
                selected: ctrl.selectedMeal.value,
                onTap: (m) => ctrl.selectedMeal.value = m,
              ),
              const SizedBox(height: 16),

              // ── Previous Meals ─────────────────────────────────────
              if (ctrl.previousMealNames.isNotEmpty) ...[
                const Text(
                  'Previous Meal',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ctrl.previousMealNames
                      .map(
                        (name) => _PreviousMealChip(
                          label: name,
                          onTap: () {
                            final existing = ctrl.loggedItems.firstWhereOrNull(
                              (e) => e.name == name,
                            );
                            if (existing != null) {
                              _showFoodDetail(
                                FoodItem(
                                  name: existing.name,
                                  calories: existing.calories,
                                  protein: existing.protein,
                                  carbs: existing.carbs,
                                  fat: existing.fat,
                                  meal: ctrl.selectedMeal.value,
                                ),
                              );
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // ── Search ─────────────────────────────────────────────
              TextField(
                controller: _searchCtrl,
                onChanged: _searchFood,
                decoration: InputDecoration(
                  hintText: 'Search for a food...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFBBBBBB),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFBBBBBB),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),

              // Search results
              if (_isSearching)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_searchResults.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = _searchResults[i];
                      final food = _productToFood(p);
                      return ListTile(
                        dense: true,
                        title: Text(
                          food.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${food.calories} kcal | P:${food.protein.toStringAsFixed(1)}g C:${food.carbs.toStringAsFixed(1)}g F:${food.fat.toStringAsFixed(1)}g',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.black,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchResults = [];
                              _searchCtrl.clear();
                            });
                            _showFoodDetail(food);
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 10),

              // ── Portion size dropdown ──────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _portionSize,
                    items: _portionSizes
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _portionSize = v!),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Scan Barcode button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _openBarcodeScanner,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Scan Barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Daily Summary card ─────────────────────────────────
              _DailySummaryCard(
                ctrl: ctrl,
                onAddFood: _openAddFood,
                onAddRecipe: _openAddRecipe,
              ),
              const SizedBox(height: 20),

              // ── Logged meals by category ───────────────────────────
              if (ctrl.breakfastItems.isNotEmpty)
                _MealSection(
                  title: 'Breakfast',
                  items: ctrl.breakfastItems,
                  onDelete: _ctrl.removeItem,
                ),
              if (ctrl.lunchItems.isNotEmpty)
                _MealSection(
                  title: 'Lunch',
                  items: ctrl.lunchItems,
                  onDelete: _ctrl.removeItem,
                ),
              if (ctrl.dinnerItems.isNotEmpty)
                _MealSection(
                  title: 'Dinner',
                  items: ctrl.dinnerItems,
                  onDelete: _ctrl.removeItem,
                ),

              // ── Percent of Daily Goals ─────────────────────────────
              if (ctrl.loggedItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DailyGoalsBar(ctrl: ctrl),
              ],
            ],
          ),
        ),
        );
      }),
    );
  }
}

// ── Barcode Scanner Screen ────────────────────────────────────────────────
class _BarcodeScannerScreen extends StatefulWidget {
  const _BarcodeScannerScreen();

  @override
  State<_BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<_BarcodeScannerScreen> {
  bool _scanned = false;
  final MobileScannerController _scanCtrl = MobileScannerController();

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scanCtrl.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scanCtrl,
            onDetect: (capture) {
              if (_scanned) return;
              final barcode = capture.barcodes.firstOrNull;
              if (barcode?.rawValue == null) return;
              _scanned = true;
              Get.back(result: barcode!.rawValue);
            },
          ),
          // Scan overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Align barcode here',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Food Detail Bottom Sheet ──────────────────────────────────────────────
class _FoodDetailSheet extends StatelessWidget {
  final FoodItem food;
  final String portionSize;
  final List<String> portionSizes;
  final ValueChanged<String?> onPortionChanged;
  final VoidCallback onAdd;

  const _FoodDetailSheet({
    required this.food,
    required this.portionSize,
    required this.portionSizes,
    required this.onPortionChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            food.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Nutrition grid
          Row(
            children: [
              _NutrientBox(
                'Calories',
                '${food.calories}',
                'kcal',
                Colors.orange,
              ),
              const SizedBox(width: 10),
              _NutrientBox(
                'Protein',
                '${food.protein.toStringAsFixed(1)}',
                'g',
                Colors.blue,
              ),
              const SizedBox(width: 10),
              _NutrientBox(
                'Carbs',
                '${food.carbs.toStringAsFixed(1)}',
                'g',
                Colors.green,
              ),
              const SizedBox(width: 10),
              _NutrientBox(
                'Fat',
                '${food.fat.toStringAsFixed(1)}',
                'g',
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Portion size
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: portionSize,
                items: portionSizes
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: const TextStyle(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: onPortionChanged,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Log',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _NutrientBox(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(unit, style: TextStyle(fontSize: 10, color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Meal Tabs ─────────────────────────────────────────────────────────────
class _MealTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onTap;
  const _MealTabs({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Breakfast', 'Lunch', 'Dinner'].map((m) {
        final isSelected = selected == m;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onTap(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.black : const Color(0xFFDDDDDD),
                ),
              ),
              child: Text(
                m,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Previous Meal Chip ────────────────────────────────────────────────────
class _PreviousMealChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PreviousMealChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Daily Summary Card ────────────────────────────────────────────────────
class _DailySummaryCard extends StatelessWidget {
  final FoodLogController ctrl;
  final VoidCallback onAddFood;
  final VoidCallback onAddRecipe;
  const _DailySummaryCard({
    required this.ctrl,
    required this.onAddFood,
    required this.onAddRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onAddFood,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onAddRecipe,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SummaryCell('${ctrl.totalCalories}', 'Calories'),
              _SummaryCell(
                '${ctrl.totalProtein.toStringAsFixed(0)}g',
                'Protein',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryCell('${ctrl.totalCarbs.toStringAsFixed(0)}g', 'Carbs'),
              _SummaryCell('${ctrl.totalFat.toStringAsFixed(0)}g', 'Fat'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryCell(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// ── Meal Section ──────────────────────────────────────────────────────────
class _MealSection extends StatelessWidget {
  final String title;
  final List<FoodItem> items;
  final void Function(FoodItem) onDelete;
  const _MealSection({
    required this.title,
    required this.items,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Dismissible(
            key: Key('${item.name}_${item.meal}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) => onDelete(item),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MacroChip('${item.calories}', 'Cal', Colors.orange),
                      const SizedBox(width: 8),
                      _MacroChip(
                        '${item.carbs.toStringAsFixed(0)}g',
                        'Carbs',
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        '${item.fat.toStringAsFixed(0)}g',
                        'Fat',
                        Colors.red,
                      ),
                      const SizedBox(width: 8),
                      _MacroChip(
                        '${item.protein.toStringAsFixed(0)}g',
                        'Protein',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MacroChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black45),
        ),
      ],
    );
  }
}

// ── Daily Goals Progress Bar ──────────────────────────────────────────────
class _DailyGoalsBar extends StatelessWidget {
  final FoodLogController ctrl;
  const _DailyGoalsBar({required this.ctrl});

  static const int _goalCalories = 1870;
  static const double _goalProtein = 150;
  static const double _goalCarbs = 200;
  static const double _goalFat = 60;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Percent of Your Daily Goals',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const _GoalLabel('Calories'),
              const _GoalLabel('Carbs'),
              const _GoalLabel('Fat'),
              const _GoalLabel('Protein'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _GoalBar(ctrl.totalCalories / _goalCalories),
              _GoalBar(ctrl.totalCarbs / _goalCarbs),
              _GoalBar(ctrl.totalFat / _goalFat),
              _GoalBar(ctrl.totalProtein / _goalProtein),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _GoalPct(ctrl.totalCalories / _goalCalories),
              _GoalPct(ctrl.totalCarbs / _goalCarbs),
              _GoalPct(ctrl.totalFat / _goalFat),
              _GoalPct(ctrl.totalProtein / _goalProtein),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalLabel extends StatelessWidget {
  final String text;
  const _GoalLabel(this.text);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, color: Colors.black54),
    ),
  );
}

class _GoalBar extends StatelessWidget {
  final double ratio;
  const _GoalBar(this.ratio);
  @override
  Widget build(BuildContext context) {
    final pct = ratio.clamp(0.0, 1.0);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 1.0 ? Colors.red : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalPct extends StatelessWidget {
  final double ratio;
  const _GoalPct(this.ratio);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Text(
      '${(ratio * 100).clamp(0, 999).toStringAsFixed(0)}%',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
}

// ── Add Food Sheet ────────────────────────────────────────────────────────
class _AddFoodSheet extends StatefulWidget {
  final String selectedMeal;
  final void Function(FoodItem) onAdd;
  const _AddFoodSheet({required this.selectedMeal, required this.onAdd});

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  late String _meal;

  @override
  void initState() {
    super.initState();
    _meal = widget.selectedMeal;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter food name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    widget.onAdd(
      FoodItem(
        name: _nameCtrl.text.trim(),
        calories: int.tryParse(_calCtrl.text) ?? 0,
        protein: double.tryParse(_proteinCtrl.text) ?? 0,
        carbs: double.tryParse(_carbsCtrl.text) ?? 0,
        fat: double.tryParse(_fatCtrl.text) ?? 0,
        meal: _meal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Food',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SheetField(_nameCtrl, 'Food name'),
          const SizedBox(height: 10),
          // Meal dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD9D9D9)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _meal,
                items: ['Breakfast', 'Lunch', 'Dinner']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _meal = v!),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SheetField(_calCtrl, 'Calories', isNumber: true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetField(_proteinCtrl, 'Protein (g)', isNumber: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SheetField(_carbsCtrl, 'Carbs (g)', isNumber: true),
              ),
              const SizedBox(width: 10),
              Expanded(child: _SheetField(_fatCtrl, 'Fat (g)', isNumber: true)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Food',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Recipe Sheet ──────────────────────────────────────────────────────
class _AddRecipeSheet extends StatefulWidget {
  final void Function(SavedRecipe) onSave;
  const _AddRecipeSheet({required this.onSave});

  @override
  State<_AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends State<_AddRecipeSheet> {
  final _nameCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ingredientsCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter recipe name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    widget.onSave(
      SavedRecipe(
        name: _nameCtrl.text.trim(),
        ingredients: _ingredientsCtrl.text.trim(),
        calories: int.tryParse(_calCtrl.text) ?? 0,
        protein: double.tryParse(_proteinCtrl.text) ?? 0,
        carbs: double.tryParse(_carbsCtrl.text) ?? 0,
        fat: double.tryParse(_fatCtrl.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Recipe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SheetField(_nameCtrl, 'Recipe Name'),
          const SizedBox(height: 10),
          _SheetField(_ingredientsCtrl, 'Ingredients', maxLines: 2),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SheetField(_calCtrl, 'Calories', isNumber: true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetField(_proteinCtrl, 'Protein (g)', isNumber: true),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SheetField(_carbsCtrl, 'Carbs (g)', isNumber: true),
              ),
              const SizedBox(width: 10),
              Expanded(child: _SheetField(_fatCtrl, 'Fat (g)', isNumber: true)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Recipe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared text field for sheets ──────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isNumber;
  final int maxLines;
  const _SheetField(
    this.ctrl,
    this.hint, {
    this.isNumber = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
