import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import '../user_session.dart';
import 'add_new_itemInventory_page.dart'; // Page to create new item
import 'package:LILI/pages/create_new_categoryInventory_page.dart'; // Page to create new category

class InventoryItem {
  final String name;
  final String category;
  int quantity;
  final String? image;
  final String? expiryDate;
  final String unit;
  final double amount;

  InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    this.image,
    this.expiryDate,
    this.unit = "pieces",
    this.amount = 1.0,
  });
}

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  void initState() {
    super.initState();
    getUserInventoryItems();
  }

  String searchQuery = '';
  int _selectedIndex = 0;

  List<String> categories = [
    'All',
    'Food',
    'Cleaning Supplies',
    'Toiletries & Personal Care',
    'Medications & First Aid',
  ];

  final List<InventoryItem> allItems = [];

  int? calculateDaysLeft(String? expiryDateStr) {
    if (expiryDateStr == null || expiryDateStr.isEmpty) return null;
    final expiryDate = DateTime.tryParse(expiryDateStr);
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference >= 0 ? difference : 0;
  }

  Future<void> getUserInventoryItems() async {
    final userId = UserSession().getUserId();
    if (userId == null || userId.isEmpty) {
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/inventory/get-items'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<InventoryItem> loadedItems =
            data.map((item) {
              return InventoryItem(
                name: item['name'],
                category: item['category'],
                quantity: item['quantity'],
                image: item['image'],
                expiryDate: item['expiry_date'],
                unit: item['unit'] ?? "pieces",
                amount: item['amount'] ?? 1.0,
              );
            }).toList();

        setState(() {
          allItems.clear();
          allItems.addAll(loadedItems);
        });
      } else {
        throw Exception('Failed to load inventory: ${response.body}');
      }
    } catch (e) {
      print('Error fetching inventory: $e');
    }
  }

  void _addNewItem(InventoryItem newItem) async {
    setState(() {
      allItems.add(newItem);
    });
    await getUserInventoryItems();
  }

  void _addNewCategory(String newCategory) {
    setState(() {
      categories.add(newCategory);
    });
    getUserInventoryItems();
  }

  Future<void> updateItemQuantity(
    String name,
    int newQuantity,
    String? userId, {
    String unit = "pieces",
    double amount = 1.0,
  }) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/user/inventory/update-quantity'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "name": name,
        "quantity": newQuantity,
        "unit": unit,
        "amount": amount,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      
      // If the item was deleted (quantity reached 0), remove it from the UI
      if (result["status"] == "deleted") {
        setState(() {
          allItems.removeWhere((item) => item.name == name);
        });
      }
    } else {
      throw Exception('Failed to update quantity: ${response.body}');
    }
  }

  Future<void> deleteItemFromBackend(
    String name,
    String? userId,
    String? expiry,
  ) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/user/inventory/delete'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "name": name, "expiry": expiry}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.body}');
    }
  }

  // Smart low stock detection based on units and amounts
  bool isLowStock(InventoryItem item) {
    if (item.category != "Food") return false;
    
    // Define low stock thresholds for different units
    switch (item.unit.toLowerCase()) {
      case 'kg':
      case 'kilograms':
        return item.quantity * item.amount < 0.5; // Less than 0.5kg total
      case 'l':
      case 'liters':
      case 'litres':
        return item.quantity * item.amount < 0.5; // Less than 0.5L total
      case 'g':
      case 'grams':
        return item.quantity * item.amount < 100; // Less than 100g total
      case 'ml':
      case 'milliliters':
        return item.quantity * item.amount < 100; // Less than 100ml total
      case 'pieces':
      case 'pcs':
      case 'units':
        return item.quantity <= 1; // 1 or fewer pieces
      case 'packets':
      case 'packs':
        return item.quantity <= 1; // 1 or fewer packets
      case 'bottles':
      case 'cans':
        return item.quantity <= 1; // 1 or fewer bottles/cans
      default:
        return item.quantity <= 1; // Default to 1 or fewer
    }
  }

  // Format quantity display with units
  String formatQuantity(InventoryItem item) {
    if (item.unit.toLowerCase() == 'pieces' || item.unit.toLowerCase() == 'pcs') {
      return '${item.quantity}';
    } else {
      double totalAmount = item.quantity * item.amount;
      if (totalAmount == totalAmount.toInt()) {
        return '${totalAmount.toInt()} ${item.unit}';
      } else {
        return '${totalAmount.toStringAsFixed(1)} ${item.unit}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedCategory = categories[_selectedIndex];
    List<InventoryItem> filteredItems =
        allItems.where((item) {
          return (selectedCategory == 'All' ||
                  item.category == selectedCategory) &&
              item.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

    Map<String, List<InventoryItem>> groupedItems = {};
    for (var item in filteredItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1F3354), const Color(0xFF3E5879)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHeader(),
              _buildSearch(),
              _buildFilterChips(),
              Expanded(child: _buildInventoryList(groupedItems)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${allItems.length} items',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search items...',
            hintStyle: TextStyle(color: Colors.white60),
            prefixIcon: Icon(Icons.search, color: Colors.white60),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, i) {
          final category = categories[i];
          return FilterChip(
            label: Text(
              category,
              style: TextStyle(color: const Color(0xFF1F3354)),
            ),
            selected: _selectedIndex == i,
            onSelected: (selected) => setState(() => _selectedIndex = i),
            backgroundColor: Colors.white12,
            selectedColor: Colors.white24,
            checkmarkColor: const Color(0xFF1F3354),
            side: BorderSide(color: Colors.white24),
          );
        },
      ),
    );
  }

  Widget _buildInventoryList(Map<String, List<InventoryItem>> groupedItems) {
    if (groupedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Define the priority order for categories
    final List<String> categoryPriority = [
      'Food',
      'Cleaning Supplies',
      'Toiletries & Personal Care',
      'Medications & First Aid',
    ];

    // Sort categories based on priority order
    final List<String> sortedCategories = groupedItems.keys.toList()
      ..sort((a, b) {
        final aIndex = categoryPriority.indexOf(a);
        final bIndex = categoryPriority.indexOf(b);
        
        // If both categories are in the priority list, sort by their position
        if (aIndex != -1 && bIndex != -1) {
          return aIndex.compareTo(bIndex);
        }
        // If only one is in the priority list, prioritize it
        if (aIndex != -1) return -1;
        if (bIndex != -1) return 1;
        // If neither is in the priority list, sort alphabetically
        return a.compareTo(b);
      });

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final items = groupedItems[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...items.map((item) => _buildItemCard(item)),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    final daysLeft = calculateDaysLeft(item.expiryDate);
    final bool isLowStock = this.isLowStock(item);
    final bool isExpiringSoon = daysLeft != null && daysLeft <= 7;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showItemDetails(item),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (item.image != null)
                    Container(
                      width: 48,
                      height: 48,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(item.image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2, color: Colors.white),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            if (isLowStock)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Low Stock',
                                  style: TextStyle(
                                    color: Colors.red[300],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (isExpiringSoon)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Expiring Soon',
                                  style: TextStyle(
                                    color: Colors.orange[300],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.white70),
                            onPressed: () async {
                              if (item.quantity > 1) {
                                setState(() => item.quantity--);
                                try {
                                  await updateItemQuantity(
                                    item.name,
                                    item.quantity,
                                    UserSession().getUserId(),
                                    unit: item.unit,
                                    amount: item.amount,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update quantity: $e',
                                      ),
                                    ),
                                  );
                                }
                              } else if (item.quantity == 1) {
                                // Show confirmation dialog when quantity would reach 0
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xFF1F3354),
                                      title: Text(
                                        'Delete Item?',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: Text(
                                        'Setting quantity to 0 will delete "${item.name}" from your inventory. Continue?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            setState(() => item.quantity = 0);
                                            try {
                                              await updateItemQuantity(
                                                item.name,
                                                0,
                                                UserSession().getUserId(),
                                                unit: item.unit,
                                                amount: item.amount,
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${item.name} removed from inventory'),
                                                  backgroundColor: Colors.green.withOpacity(0.8),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to delete item: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red[300]),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                          Text(
                            this.formatQuantity(item),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.white70),
                            onPressed: () async {
                              setState(() => item.quantity++);
                              try {
                                await updateItemQuantity(
                                  item.name,
                                  item.quantity,
                                  UserSession().getUserId(),
                                  unit: item.unit,
                                  amount: item.amount,
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update quantity: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      if (daysLeft != null)
                        Text(
                          '$daysLeft days left',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        )
                      else if (item.expiryDate != null && item.expiryDate!.isEmpty)
                        Text(
                          'No expiry',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetails(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Color(0xFF1F3354),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(Icons.category_outlined, item.category),
                      SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.inventory_2_outlined,
                        'Quantity: ${this.formatQuantity(item)}',
                      ),
                      if (item.expiryDate != null && item.expiryDate!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.event_outlined,
                          'Expires in ${calculateDaysLeft(item.expiryDate)} days',
                        ),
                      ] else ...[
                        SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.event_outlined,
                          'No expiry',
                        ),
                      ],
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await deleteItemFromBackend(
                              item.name,
                              UserSession().getUserId(),
                              item.expiryDate,
                            );
                            setState(() {
                              allItems.remove(item);
                            });
                            Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.3),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Delete Item',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 20),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.white70))),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'Item') {
          final newItem = await Navigator.push<InventoryItem>(
            context,
            MaterialPageRoute(builder: (context) => CreateNewItemPage()),
          );
          if (newItem != null) {
            _addNewItem(newItem);
          }
        } else if (value == 'category') {
          final newCategory = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => AddNewCategoryPage()),
          );
          if (newCategory != null && newCategory.isNotEmpty) {
            _addNewCategory(newCategory);
          }
        }
      },
      offset: Offset(0, -100),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.add, size: 30, color: Color(0xFF1F3354)),
        onPressed: null,
      ),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'Item',
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Color(0xFF1F3354)),
                  SizedBox(width: 12),
                  Text(
                    'Add New Item',
                    style: TextStyle(color: Color(0xFF1F3354)),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'category',
              child: Row(
                children: [
                  Icon(Icons.category_outlined, color: Color(0xFF1F3354)),
                  SizedBox(width: 12),
                  Text(
                    'Add New Category',
                    style: TextStyle(color: Color(0xFF1F3354)),
                  ),
                ],
              ),
            ),
          ],
    );
  }
}
