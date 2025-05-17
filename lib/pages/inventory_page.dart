import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'add_new_itemInventory_page.dart'; // Page to create new item
import 'package:LILI/pages/create_new_categoryInventory_page.dart'; // Page to create new category

class InventoryItem {
  final String name;
  final String category;
  int quantity;
  final String? image;

  InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    this.image,
  });
}

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String searchQuery = '';
  int _selectedIndex = 0;

  List<String> categories = [
    'All',
    'Food',
    'Cleaning Supplies',
    'Toiletries & Personal Care',
    'Medications & First Aid',
  ];

  final List<InventoryItem> allItems = [
    InventoryItem(
      name: 'Tomato',
      category: 'Food',
      quantity: 3,
      image: 'assets/inventory/tomato.jpg',
    ),
    InventoryItem(
      name: 'Garlic',
      category: 'Food',
      quantity: 1,
      image: 'assets/inventory/garlic.jpg',
    ),
    InventoryItem(
      name: 'Salt',
      category: 'Food',
      quantity: 0,
      image: 'assets/inventory/Salt.jpg',
    ),
    InventoryItem(
      name: 'Bandage',
      category: 'Medications & First Aid',
      quantity: 2,
      image: 'assets/inventory/bandage.png',
    ),
    InventoryItem(
      name: 'Toothpaste',
      category: 'Toiletries & Personal Care',
      quantity: 5,
      image: 'assets/inventory/toothpaste.jpg',
    ),
    InventoryItem(
      name: 'Soap',
      category: 'Cleaning Supplies',
      quantity: 2,
      image: 'assets/inventory/soap.jpg',
    ),
  ];

  void _addNewItem(InventoryItem newItem) {
    setState(() {
      allItems.add(newItem);
    });
  }

  void _addNewCategory(String newCategory) {
    setState(() {
      categories.add(newCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    String selectedCategory = categories[_selectedIndex];
    List<InventoryItem> filteredItems = allItems.where((item) {
      return (selectedCategory == 'All' || item.category == selectedCategory) &&
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
                children: categories.map((cat) {
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
                      backgroundColor: _selectedIndex == index
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
              children: groupedItems.entries.map((entry) {
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
                          leading: item.image != null
                              ? Image.asset(
                            item.image!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                              : CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: Icon(Icons.image_not_supported),
                          ),
                          title: Row(
                            children: [
                              Text(item.name),
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
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 0) item.quantity--;
                                  });
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    item.quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Color(0xFF1F3354),
                            ),
                            onPressed: () {
                              setState(() {
                                allItems.remove(item);
                              });
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
        itemBuilder: (BuildContext context) => [
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
