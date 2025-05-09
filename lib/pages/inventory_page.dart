import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class InventoryItem {
  final String name;
  final String category;
  int quantity;
  final String image;

  InventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.image,
  });
}

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String searchQuery = '';
  int _selectedIndex = 0;

  final List<String> categories = [
    'All',
    'Food',
    'Cleaning Supplies',
    'Toiletries & Personal Care',
    'Medications & First Aid',
  ];

  final List<IconData> categoryIcons = [
    Icons.dashboard,
    Icons.fastfood,
    Icons.cleaning_services,
    Icons.personal_injury,
    Icons.medical_services,
  ];

  final List<InventoryItem> allItems = [
    InventoryItem(name: 'Tomato', category: 'Food', quantity: 3, image: '🍅'),
    InventoryItem(name: 'Garlic', category: 'Food', quantity: 1, image: '🧄'),
    InventoryItem(name: 'Salt', category: 'Food', quantity: 0, image: '🧂'),
    InventoryItem(
      name: 'Bandage',
      category: 'Medications & First Aid',
      quantity: 2,
      image: '🩹',
    ),
    InventoryItem(
      name: 'Toothpaste',
      category: 'Toiletries & Personal Care',
      quantity: 5,
      image: '🪥',
    ),
    InventoryItem(
      name: 'Soap',
      category: 'Cleaning Supplies',
      quantity: 2,
      image: '🧼',
    ),
  ];

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
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                //suffixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
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
                              color:
                                  _selectedIndex == index
                                      ? Color(0xFFF5EFE7)
                                      : Colors
                                          .black, // Change color based on selection
                            ),
                          ),
                          backgroundColor:
                              _selectedIndex == index
                                  ? Color(0xFF1F3354)
                                  : Colors.transparent,
                          // Change background color based on selection
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
            // Inventory Items
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
                            child: ListTile(
                              leading: Text(
                                item.image,
                                style: TextStyle(fontSize: 30),
                              ),
                              title: Text(item.name),
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
                              trailing:
                                  item.quantity <= 1
                                      ? Tooltip(
                                        message: 'Low in stock',
                                        child: Icon(
                                          Icons.circle,
                                          color: Colors.red,
                                          size: 12,
                                        ),
                                      )
                                      : null,
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
      // Curved Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        items:
            categoryIcons
                .map((icon) => Icon(icon, size: 30, color: Colors.white))
                .toList(),
        index: _selectedIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: Color(0xFF1F3354),
        buttonBackgroundColor: Color(0xFF1F3354),
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      // Floating Action Button with PopupMenuButton
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'Item') {
            Navigator.pushNamed(context, '/new item inventory');
            // Open New Task form
          } else if (value == 'category') {
            Navigator.pushNamed(context, '/new category inventory');
            // Open New Category form
          }
        },
        offset: Offset(0, -100),
        color: Color(0xFFF5EFE7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        icon: FloatingActionButton(
          backgroundColor: Color(0xFF1F3354),
          child: Icon(Icons.add, size: 30, color: Color(0xFFF5EFE7)),
          onPressed: null, // Leave null to use PopupMenuButton's onSelected
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
