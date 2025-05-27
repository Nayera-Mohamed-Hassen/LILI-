import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import '../user_session.dart';
import 'add_new_itemInventory_page.dart'; // Page to create new item
import 'package:LILI/pages/create_new_categoryInventory_page.dart'; // Page to create new category

final int? userId = UserSession().getUserId();

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
      appBar: AppBar(
        title: Text('Inventory Manager', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F3354),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    categories.map((cat) {
                      int index = categories.indexOf(cat);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ActionChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF2F2F2),
                            ),
                          ),
                          backgroundColor:
                              _selectedIndex == index
                                  ? Color(0xFF1F3354)
                                  : Color(0xFF3E5879),
                          onPressed: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  groupedItems.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: Color(0xFF1F3354),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (item) => Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                color: Color(0xFF1F3354),
                                width: 1,
                              ),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF1F3354),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading:
                                  item.image != null
                                      ? Image.asset(
                                        item.image!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                      : CircleAvatar(
                                        backgroundColor: Colors.grey[300],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Color(0xFF1F3354),
                                        ),
                                      ),
                              title: Row(
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      color: Color(0xFF1F3354),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.quantity <= 1) ...[
                                    SizedBox(width: 6),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                  if (item.expiryDate != null) ...[
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Color(0xFF3E5879),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${calculateDaysLeft(item.expiryDate)} days left',
                                      style: TextStyle(
                                        color: Color(0xFF3E5879),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              subtitle: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      color: Color(0xFF1F3354),
                                    ),
                                    onPressed: () async {
                                      if (item.quantity > 0) {
                                        setState(() {
                                          item.quantity--;
                                        });
                                        try {
                                          await updateItemQuantity(
                                            item.name,
                                            item.quantity,
                                            UserSession().getUserId(),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to update quantity: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      color: Color(0xFF1F3354),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      color: Color(0xFF1F3354),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        item.quantity++;
                                      });
                                      try {
                                        await updateItemQuantity(
                                          item.name,
                                          item.quantity,
                                          UserSession().getUserId(),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Color(0xFF1F3354),
                                ),
                                onPressed: () async {
                                  try {
                                    await deleteItemFromBackend(
                                      item.name,
                                      UserSession().getUserId(),
                                      item.expiryDate,
                                    ); // Call API
                                    setState(() {
                                      allItems.remove(item); // Remove from UI
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete: $e'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: PopupMenuButton<String>(
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
        color: Color(0xFFF2F2F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        icon: FloatingActionButton(
          backgroundColor: Color(0xFF1F3354),
          child: Icon(Icons.add, size: 30, color: Color(0xFFF2F2F2)),
          onPressed: null,
        ),
        itemBuilder:
            (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Item',
                child: Text('Create New Item'),
              ),
              PopupMenuItem<String>(
                value: 'category',
                child: Text('Create New Category'),
              ),
            ],
      ),
    );
  }
}
