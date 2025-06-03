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
  final String? expiryDate; // add this

  InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    this.image,
    this.expiryDate,
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
    if (expiryDateStr == null) return null;
    final expiryDate = DateTime.tryParse(expiryDateStr);
    if (expiryDate == null) return null;
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference >= 0 ? difference : 0;
  }

  Future<void> getUserInventoryItems() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/user/inventory/get-items'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": UserSession().getUserId()}),
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
    int? userId,
  ) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/user/inventory/update-quantity'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "name": name,
        "quantity": newQuantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update quantity: ${response.body}');
    }
  }

  Future<void> deleteItemFromBackend(
    String name,
    int? userId,
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
            colors: [
              const Color(0xFF1F3354),
              const Color(0xFF3E5879),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearch(),
              _buildFilterChips(),
              Expanded(
                child: _buildInventoryList(groupedItems),
              ),
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
                'Inventory',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${allItems.length} items',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
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
            label: Text(category, style: TextStyle(color: Colors.white)),
            selected: _selectedIndex == i,
            onSelected: (selected) => setState(() => _selectedIndex = i),
            backgroundColor: Colors.white12,
            selectedColor: Colors.white24,
            checkmarkColor: Colors.white,
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

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
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
    final bool isLowStock = item.quantity <= 1;
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
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Low Stock',
                                  style: TextStyle(color: Colors.red[300], fontSize: 12),
                                ),
                              ),
                            if (isExpiringSoon)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Expiring Soon',
                                  style: TextStyle(color: Colors.orange[300], fontSize: 12),
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
                              if (item.quantity > 0) {
                                setState(() => item.quantity--);
                                try {
                                  await updateItemQuantity(
                                    item.name,
                                    item.quantity,
                                    UserSession().getUserId(),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to update quantity: $e')),
                                  );
                                }
                              }
                            },
                          ),
                          Text(
                            '${item.quantity}',
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
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update quantity: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      if (daysLeft != null)
                        Text(
                          '$daysLeft days left',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
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
      builder: (context) => Container(
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
                    'Quantity: ${item.quantity}',
                  ),
                  if (item.expiryDate != null) ...[
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.event_outlined,
                      'Expires in ${calculateDaysLeft(item.expiryDate)} days',
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
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white70),
          ),
        ),
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
      itemBuilder: (context) => [
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
