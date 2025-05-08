import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:untitled4/models/task.dart';
import 'package:untitled4/models/category_task.dart';
// TaskModel with copyWith

class TasksHomePage extends StatefulWidget {
  @override
  _TasksHomePageState createState() => _TasksHomePageState();
}

class _TasksHomePageState extends State<TasksHomePage> {
  String selectedFilter = 'All';
  List<TaskModel> allTasks = [
    TaskModel(
      id: 1,
      title: 'Project UI',
      description: 'Create UI Design',
      dueDate: DateTime.parse('2022-01-17'),
      priority: 'High',
      progress: 0.3,
      assignedTo: 'Nayera',
      category: 'Design',
    ),
    TaskModel(
      id: 2,
      title: '3D Assets',
      description: 'Model 3D assets',
      dueDate: DateTime.parse('2022-01-18'),
      priority: 'Medium',
      progress: 0.4,
      assignedTo: 'Nayera',
      category: 'Design',
    ),
    TaskModel(
      id: 3,
      title: 'Kitchen Cleaning',
      description: 'Deep clean kitchen',
      dueDate: DateTime.parse('2022-01-19'),
      priority: 'Low',
      progress: 1.0,
      isCompleted: true,
      assignedTo: 'Ali',
      category: 'Chores',
    ),
    TaskModel(
      id: 4,
      title: 'Grocery Shopping',
      description: 'Buy weekly groceries',
      dueDate: DateTime.parse('2022-01-20'),
      priority: 'Medium',
      progress: 0.0,
      assignedTo: 'Sara',
      category: 'Shopping',
    ),
  ];

  List<TaskModel> doneTasks = [
    TaskModel(
      id: 3,
      title: 'Kitchen deep cleaning',
      description: 'Clean the kitchen',
      dueDate: DateTime.parse('2022-01-17'),
      priority: 'Low',
      progress: 1.0,
      category: 'Design',
      isCompleted: true,
      assignedTo: 'Ali',
    ),
    TaskModel(
      id: 4,
      title: 'Balcony decoration',
      description: 'Decorate balcony',
      dueDate: DateTime.parse('2022-01-17'),
      priority: 'Low',
      progress: 1.0,
      category: 'Design',
      isCompleted: true,
      assignedTo: 'Sara',
    ),
  ];

  List<TaskModel> scheduledTasks = [
    TaskModel(
      id: 5,
      title: 'Finish front end',
      description: 'Finish front end of LILI',
      dueDate: DateTime.parse('2025-05-05'),
      priority: 'High',
      progress: 0.0,
      category: 'Chores',
      assignedTo: 'Nayera',
    ),
    TaskModel(
      id: 6,
      title: 'Graduate',
      description: 'Graduation party',
      dueDate: DateTime.parse('2025-10-15'),
      priority: 'Medium',
      progress: 0.0,
      category: 'Chores',
      assignedTo: 'Nayera',
    ),
  ];

  List<TaskModel> inProgressTasks = [
    TaskModel(
      id: 7,
      title: 'Year four of college',
      description: 'Semester 8',
      dueDate: DateTime.parse('2025-05-05'),
      priority: 'High',
      progress: 0.5,
      category: 'Shopping',
      assignedTo: 'Nayera',
    ),
    TaskModel(
      id: 8,
      title: 'Inazuma Eleven',
      description: 'Currently watched series',
      dueDate: DateTime.parse('2025-10-15'),
      priority: 'Low',
      progress: 0.2,
      category: 'Design',
      assignedTo: 'Nayera',
    ),
  ];

  List<CategoryModel> categories = [
    CategoryModel(name: 'Design', description: 'UI/UX and graphic work'),
    CategoryModel(name: 'Chores', description: 'Household tasks'),
    CategoryModel(name: 'Shopping', description: 'Shopping and errands'),
  ];

  List<TaskModel> getFilteredTasks() {
    switch (selectedFilter) {
      case 'Done':
        return doneTasks;
      case 'Scheduled':
        return scheduledTasks;
      case 'In progress':
        return inProgressTasks;
      case 'All':
      default:
        return allTasks;
    }
  }

  int _selectedIndex = 0;
  final items = [
    Icon(Icons.task, size: 30, color: Color(0xFFF5EFE7)),
    Icon(Icons.calendar_today, size: 30, color: Color(0xFFF5EFE7)),
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
    List<TaskModel> tasks = getFilteredTasks();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16),
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
              //
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search features...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.filter_list),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount:
                    [
                      'All',
                      'Done',
                      'In progress',
                      'Scheduled',
                      'Categories',
                    ].length,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f =
                      [
                        'All',
                        'Done',
                        'In progress',
                        'Scheduled',
                        'Categories',
                      ][i];
                  return ActionChip(
                    label: Text(f, style: TextStyle(color: Color(0xFFF5EFE7))),
                    backgroundColor:
                        selectedFilter == f
                            ? Color(0xFF3E5879)
                            : Color(0xFF1D2345),
                    onPressed: () => setState(() => selectedFilter = f),
                  );
                },
              ),
            ),

            Expanded(
              child:
                  selectedFilter == 'Categories'
                      ? ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return Card(
                            color: Color(0xFF1D2345),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                cat.name,
                                style: TextStyle(
                                  color: Color(0xFFF5EFE7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                cat.description,
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                color: Color(0xFFF5EFE7),
                              ),
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => CategoryDetailPage(
                                //       category: cat,
                                //       tasks: allTasks.where((t) => t.category == cat.name).toList(),
                                //     ),
                                //   ),
                                // );
                              },
                            ),
                          );
                        },
                      )
                      : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            color: Color(0xFF1D2345),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (val) {
                                  setState(() {
                                    allTasks =
                                        allTasks
                                            .map(
                                              (t) =>
                                                  t.id == task.id
                                                      ? t.copyWith(
                                                        isCompleted: val,
                                                      )
                                                      : t,
                                            )
                                            .toList();
                                  });
                                },
                                activeColor: Color(0xFF3E5879),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              subtitle: Text(
                                task.description,
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(task.progress * 100).toInt()}%',
                                    style: TextStyle(color: Color(0xFFF5EFE7)),
                                  ),
                                  Text(
                                    '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                    style: TextStyle(
                                      color: Color(0xFFF5EFE7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Expanded(
            //   child:
            //       selectedFilter == 'Categories'
            //           ? SizedBox(
            //             // show only categories
            //             child: ListView.builder(
            //               itemCount: categories.length,
            //               itemBuilder: (context, index) {
            //                 final cat = categories[index];
            //                 return Card(
            //                   color: Color(0xFF1D2345),
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(12),
            //                   ),
            //                   margin: EdgeInsets.symmetric(vertical: 8),
            //                   child: ListTile(
            //                     title: Text(
            //                       cat.name,
            //                       style: TextStyle(
            //                         color: Color(0xFFF5EFE7),
            //                         fontWeight: FontWeight.bold,
            //                       ),
            //                     ),
            //                     subtitle: Text(
            //                       cat.description,
            //                       style: TextStyle(color: Color(0xFFF5EFE7)),
            //                     ),
            //                     trailing: Icon(
            //                       Icons.arrow_forward,
            //                       color: Color(0xFFF5EFE7),
            //                     ),
            //                     onTap: () {
            //                       // Navigator.push(
            //                       //   context,
            //                       //   MaterialPageRoute(
            //                       //     builder:
            //                       //         (_) => CategoryDetailPage(
            //                       //           category: cat,
            //                       //           tasks:
            //                       //               allTasks
            //                       //                   .where(
            //                       //                     (t) =>
            //                       //                         t.category ==
            //                       //                         cat.name,
            //                       //                   )
            //                       //                   .toList(),
            //                       //         ),
            //                       //   ),
            //                       // );
            //                     },
            //                   ),
            //                 );
            //               },
            //             ),
            //           )
            //           : ListView.builder(
            //             // otherwise show tasks
            //             itemCount: tasks.length,
            //             itemBuilder: (context, index) {
            //               final task = tasks[index];
            //               return Card(
            //                 color: Color(0xFF1D2345),
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(12),
            //                 ),
            //                 margin: EdgeInsets.symmetric(vertical: 8),
            //                 child: ListTile(
            //                   leading: Checkbox(
            //                     value: task.isCompleted,
            //                     onChanged: (val) {
            //                       setState(() {
            //                         allTasks =
            //                             allTasks
            //                                 .map(
            //                                   (t) =>
            //                                       t.id == task.id
            //                                           ? t.copyWith(
            //                                             isCompleted: val,
            //                                           )
            //                                           : t,
            //                                 )
            //                                 .toList();
            //                       });
            //                     },
            //                     activeColor: Color(0xFF3E5879),
            //                   ),
            //                   title: Text(
            //                     task.title,
            //                     style: TextStyle(color: Color(0xFFF5EFE7)),
            //                   ),
            //                   subtitle: Text(
            //                     task.description,
            //                     style: TextStyle(color: Color(0xFFF5EFE7)),
            //                   ),
            //                   trailing: Column(
            //                     mainAxisAlignment: MainAxisAlignment.center,
            //                     children: [
            //                       Text(
            //                         '${(task.progress * 100).toInt()}%',
            //                         style: TextStyle(color: Color(0xFFF5EFE7)),
            //                       ),
            //                       Text(
            //                         '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
            //                         style: TextStyle(
            //                           color: Color(0xFFF5EFE7),
            //                           fontSize: 12,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               );
            //             },
            //           ),
            // ),
            SizedBox(height: 16),
            //Expanded(child: _buildTaskList(tasks)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1D2345),
        child: Icon(Icons.add, color: Color(0xFFF5EFE7)),
        onPressed: () {},
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: items,
        index: _selectedIndex,
        height: 60,
        backgroundColor: Colors.transparent,
        color: Color(0xFF1D2345),
        buttonBackgroundColor: Color(0xFF1D2345),
        onTap: _onItemTapped,
      ),
    );
  }
}
