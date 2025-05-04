import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class TasksHomePage extends StatefulWidget {
  @override
  _TasksHomePageState createState() => _TasksHomePageState();
}

// const Color(0xFF213555)
class _TasksHomePageState extends State<TasksHomePage> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> all_tasks = [
    {
      'title': 'Project UI',
      'description': 'Create UI Design with Prototype',
      'progress': 0.3,
      'dueDate': 'Mon, 17 Jan 2022',
    },
    {
      'title': '3D Project',
      'description': 'Create UI Design with 3D Assets',
      'progress': 0.4,
      'dueDate': 'Mon, 17 Jan 2022',
    },
  ];
  final List<Map<String, dynamic>> done_tasks = [
    {
      'title': 'Kitchen deep cleaning ',
      'description': 'clean all the kithchen',
      'progress': 100,
      'dueDate': 'Mon, 17 Jan 2022',
    },
    {
      'title': 'Balcony decoration ',
      'description': 'Create UI Design with 3D Assets',
      'progress': 100,
      'dueDate': 'Mon, 17 Jan 2022',
    },
  ];
  final List<Map<String, dynamic>> schedueld_tasks = [
    {
      'title': 'Finish front end ',
      'description': 'finsh all the front end of lili',
      'progress': 100,
      'dueDate': 'Mon, 5 may 2025',
    },
    {
      'title': 'Graduate ',
      'description': 'Graduation party',
      'progress': 100,
      'dueDate': 'Mon, 15 oct 2025',
    },
    {
      'title': 'Finish front end ',
      'description': 'finsh all the front end of lili',
      'progress': 100,
      'dueDate': 'Mon, 5 may 2025',
    },
    {
      'title': 'Finish front end ',
      'description': 'finsh all the front end of lili',
      'progress': 100,
      'dueDate': 'Mon, 5 may 2025',
    },
    {
      'title': 'Finish front end ',
      'description': 'finsh all the front end of lili',
      'progress': 100,
      'dueDate': 'Mon, 5 may 2025',
    },
    {
      'title': 'Finish front end ',
      'description': 'finsh all the front end of lili',
      'progress': 100,
      'dueDate': 'Mon, 5 may 2025',
    },
    {
      'title': 'Finish front end ',
      'description': 'finsh all the front end of lili',
      'progress': 100,
      'dueDate': 'Mon, 5 may 2025',
    },
  ];
  final List<Map<String, dynamic>> in_progress_tasks = [
    {
      'title': 'Year four of college',
      'description': 'semester 8',
      'progress': 100,
      'dueDate': 'Mon, 5 may 2025',
    },
    {
      'title': 'Inazuma eleven ',
      'description': 'currently watched series',
      'progress': 100,
      'dueDate': 'Mon, 15 oct 2025',
    },
  ];
  final List<Map<String, String>> categories = [
    {
      'name': 'Cleaning',
      'description': 'Chores related to cleaning tasks.',
      'route': '/cleaning',
    },
    {
      'name': 'Cooking',
      'description': 'Cooking-related activities.',
      'route': '/cooking',
    },
    {
      'name': 'Shopping',
      'description': 'Shopping tasks and groceries.',
      'route': '/shopping',
    },
  ];
  List<Map<String, dynamic>> getFilteredTasks() {
    switch (selectedFilter) {
      case 'All':
        return all_tasks;
      case 'Done':
        return done_tasks;
      case 'Scheduled':
        return schedueld_tasks;
      case 'In progress':
        return in_progress_tasks;
      default:
        return []; // You can add more filters here
    }
  }

  int _selectedIndex = 0;

  final items = [
    Icon(Icons.category_rounded, size: 30, color: Color(0xFFF5EFE7)),
    // Icon(Icons.category_rounded, size: 30, color: Color(0xFFF5EFE7)),
    Icon(Icons.calendar_month_outlined, size: 30, color: Color(0xFFF5EFE7)),
    // Icon(Icons.person, size: 30, color: Color(0xFFF5EFE7)),
  ];

  final List<Widget> _pages = [
    Center(child: Text('Home')),
    // Center(child: Text('Categories')),
    Center(child: Text('Calender')),
    // Center(child: Text('Settings')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTasks = getFilteredTasks();
    return Scaffold(
      // routes: {
      //   '/cleaning': (context) => CleaningPage(),
      //   '/cooking': (context) => CookingPage(),
      //   '/shopping': (context) => ShoppingPage(),
      // },
      // appBar: AppBar(
      //   title: Text('Manage your Daily tasks'),
      //   actions: [
      //     CircleAvatar(
      //       backgroundImage: AssetImage('assets/images/nayera.jpg'),
      //     ),
      //     SizedBox(width: 16),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackButton(),
                CircleAvatar(
                  // backgroundImage: AssetImage('assets/images/nayera.jgp'),
                  radius: 40,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF213555),
                      ),
                    ),
                    Text(
                      'Nayera',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF213555),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTapDown: (details) {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        0,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(
                              Icons.notification_important,
                              color: Color(0xFF3E5879),
                            ),
                            title: Text('Project UI is due today.'),
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(
                              Icons.new_releases,
                              color: Colors.orange,
                            ),
                            title: Text('New task assigned.'),
                          ),
                        ),
                      ],
                    );
                  },
                  // const Color(0xFF1D2345)
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1D2345),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.notifications, color: Color(0xFFF5EFE7)),
                  ),
                ),
                // IconButton(onPressed: (){}, icon: )
              ],
            ),

            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(width: 8),
                  ActionChip(
                    label: Text("All"),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5EFE7),
                    ),
                    backgroundColor: Color((0xFF1D2345)),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'All';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  ActionChip(
                    label: Text("Done"),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5EFE7),
                    ),
                    backgroundColor: Color((0xFF1D2345)),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'Done';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  ActionChip(
                    label: Text("In progress"),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5EFE7),
                    ),
                    backgroundColor: Color((0xFF1D2345)),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'In progress';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  ActionChip(
                    label: Text("Scheduled"),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5EFE7),
                    ),
                    backgroundColor: Color((0xFF1D2345)),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'Scheduled';
                      });
                    },
                  ),

                  SizedBox(width: 8),
                  ActionChip(
                    label: Text("Categories"),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5EFE7),
                    ),
                    backgroundColor: Color((0xFF1D2345)),
                    onPressed: () {
                      setState(() {
                        selectedFilter = 'Categories';
                      });
                    },
                  ),
                  // Add more filters if needed
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              '$selectedFilter Tasks',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF213555),
              ),
            ),
            SizedBox(height: 2),

            Expanded(
              child:
                  selectedFilter == 'Categories'
                      ? ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Card(
                            color: Color((0xFF1D2345)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                category['name']!,
                                style: TextStyle(
                                  color: Color(0xFFF5EFE7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                category['description']!,
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: Color(0xFFF5EFE7),
                              ),
                              onTap: () {
                                // If you want to do something on category tap (e.g., navigate to details)
                                // you can implement it here, but the list itself won't be a pop-up.
                              },
                            ),
                          );
                        },
                      )
                      : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Color((0xFF1D2345)),
                            child: ListTile(
                              title: Text(
                                task['title'],
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              subtitle: Text(
                                task['description'],
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(task['progress'] * 100).toInt()}%',
                                    style: TextStyle(color: Color(0xFFF5EFE7)),
                                  ),
                                  Text(
                                    task['dueDate'],
                                    style: TextStyle(color: Color(0xFFF5EFE7)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),

      floatingActionButton: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'task') {
            Navigator.pushNamed(context, '/create new task');
            // Open New Task form
          } else if (value == 'category') {
            Navigator.pushNamed(context, '/create new category');
            // Open New Category form
          }
        },
        offset: Offset(0, -100),
        color: Color(0xFFF5EFE7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        icon: FloatingActionButton(
          backgroundColor: Color((0xFF1D2345)),
          child: Icon(Icons.add, size: 30, color: Color(0xFFF5EFE7)),
          onPressed: null, // Leave null to use PopupMenuButton's onSelected
        ),
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'task',
                child: Row(
                  children: [
                    Icon(Icons.task, color: Color((0xFF1D2345))),
                    SizedBox(width: 10),
                    Text(
                      "New Task",
                      style: TextStyle(color: Color((0xFF1D2345))),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'category',
                child: Row(
                  children: [
                    Icon(Icons.category, color: Color((0xFF1D2345))),
                    SizedBox(width: 10),
                    Text(
                      "New Category",
                      style: TextStyle(color: Color((0xFF1D2345))),
                    ),
                  ],
                ),
              ),
            ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: _selectedIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: Color((0xFF1D2345)),
        buttonBackgroundColor: Color((0xFF1D2345)),
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
