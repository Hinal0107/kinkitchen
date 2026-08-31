import 'package:flutter/material.dart';
import 'package:kinkitchen/core/widgets/food_image.dart';
import 'package:kinkitchen/shared/models/menu_category.dart';
import 'package:kinkitchen/modules/restaurant/restaurant_state_provider.dart';
import 'package:kinkitchen/modules/restaurant/dashboard/presentation/pages/restaurant_dashboard_screen.dart';
import 'restaurant_add_category_screen.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  bool _hasFetchedData = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = RestaurantStateScope.of(context);
    if (!_hasFetchedData && !state.isLoading) {
      _hasFetchedData = true;
      Future.microtask(() {
        state.fetchCategories();
      });
    }
  }

  void _openAddCategoryScreen(RestaurantStateProvider state) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantAddCategoryScreen(stateProvider: state),
      ),
    );
    await state.fetchCategories();
  }

  /// Returns regular categories (excluding add-on or special system categories if needed)
  List<MenuCategory> _getDisplayCategories(RestaurantStateProvider state) {
    return state.categories.where((cat) {
      final name = cat.name.toLowerCase();
      return !name.contains('add-on') &&
          !name.contains('addon') &&
          name != 'today' &&
          name != "today's meals" &&
          name != 'tomorrow' &&
          name != "tomorrow's meals";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = RestaurantStateScope.of(context);
    const Color merchantGreen = Color(0xFF00A859);

    final displayCategories = _getDisplayCategories(state);
    final filteredCategories = displayCategories.where((cat) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return cat.name.toLowerCase().contains(query) ||
          cat.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              )
            : const Text(
                'Menu Categories',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFF4B5563),
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: merchantGreen,
        foregroundColor: Colors.white,
        onPressed: () => _openAddCategoryScreen(state),
        child: const Icon(Icons.add),
      ),
      body: displayCategories.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: merchantGreen.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.category_outlined,
                        size: 52,
                        color: merchantGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Categories Added Yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the Floating "+" button below to add your first menu category. Categories will be saved to your menu_categories table.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : filteredCategories.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off_outlined,
                          size: 52,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Category Matching "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: const Text(
                            'Clear Search',
                            style: TextStyle(color: merchantGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                      final bool isActive = category.status.toUpperCase() == 'ACTIVE';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF3F4F6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FoodImage(
                              title: category.name,
                              imageUrl: category.imageUrl,
                              width: 80,
                              height: 80,
                              borderRadius: 12,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Category',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category.description.isNotEmpty
                                        ? category.description
                                        : 'No summary provided',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? merchantGreen
                                              : Colors.grey,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Switch(
                                            activeColor: merchantGreen,
                                            value: isActive,
                                            onChanged: (val) {
                                              state.updateCategory(
                                                category.id,
                                                category.name,
                                                category.description,
                                                val ? 'ACTIVE' : 'INACTIVE',
                                              );
                                            },
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RestaurantAddCategoryScreen(
                                                    stateProvider: state,
                                                    existingCategory: category,
                                                    isEdit: true,
                                                  ),
                                                ),
                                              );
                                              await state.fetchCategories();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              margin: const EdgeInsets.only(right: 6),
                                              child: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF4B5563),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _confirmDeleteCategory(
                                              context,
                                              state,
                                              category.id,
                                              category.name,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFFEF4444),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    RestaurantStateProvider state,
    int id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.deleteCategory(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category "$name" deleted!')),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
