import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled4/models/task.dart';
import 'package:untitled4/models/category_task.dart';

class TasksHomePage extends StatefulWidget {
  const TasksHomePage({Key? key}) : super(key: key);

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

  List<CategoryModel> categories = [
    CategoryModel(name: 'Design', description: 'UI/UX and graphic work'),
    CategoryModel(name: 'Chores', description: 'Household tasks'),
    CategoryModel(name: 'Shopping', description: 'Shopping and errands'),
  ];

  List<TaskModel> getFilteredTasks() {
    switch (selectedFilter) {
      case 'Done':
        return allTasks.where((t) => t.isCompleted).toList();
      case 'In progress':
        return allTasks
            .where((t) => !t.isCompleted && t.progress < 1.0)
            .toList();
      case 'Scheduled':
        return allTasks
            .where((t) => t.dueDate.isAfter(DateTime.now()))
            .toList();
      case 'All':
      default:
        return allTasks;
    }
  }

  int _selectedIndex = 0;
  final items = [
    Icon(Icons.task, size: 30, color: Color(0xFFF5EFE7)),
    Icon(Icons.category, size: 30, color: Color(0xFFF5EFE7)),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1F3354),
        title: const Text(
          'Task manager',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearch(),
            if (_selectedIndex == 0) _buildFilterChips(),
            SizedBox(height: 16),
            Expanded(
              child:
                  _selectedIndex == 1
                      ? _buildCategoryList()
                      : _inlineTaskList(),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color(0xFF1D2345),
      //   child: Icon(Icons.add, color: Color(0xFFF5EFE7)),
      //   onPressed: () {},
      // ),
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
        color: Color(0xFF1D2345),
        buttonBackgroundColor: Color(0xFF1D2345),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // CircleAvatar(radius: 40),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF213555),
              ),
            ),
            Text(
              'Nayera',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF213555),
              ),
            ),
          ],
        ),
        Spacer(),
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
                    leading: Icon(Icons.new_releases, color: Colors.orange),
                    title: Text('New task assigned.'),
                  ),
                ),
              ],
            );
          },
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
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search features...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: Icon(Icons.filter_list),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Done', 'In progress', 'Scheduled'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          return ActionChip(
            label: Text(f, style: TextStyle(color: Color(0xFFF5EFE7))),
            backgroundColor:
                selectedFilter == f ? Color(0xFF3E5879) : Color(0xFF1D2345),
            onPressed: () => setState(() => selectedFilter = f),
          );
        },
      ),
    );
  }

  Widget _inlineTaskList() {
    return ListView.builder(
      itemCount: getFilteredTasks().length,
      itemBuilder: (context, index) {
        final task = getFilteredTasks()[index];
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
                  final idx = allTasks.indexWhere((t) => t.id == task.id);
                  if (idx != -1) {
                    allTasks[idx] = allTasks[idx].copyWith(isCompleted: val);
                  }
                });
              },
              activeColor: Color(0xFF3E5879),
            ),
            title: Text(task.title, style: TextStyle(color: Color(0xFFF5EFE7))),
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
                  style: TextStyle(color: Color(0xFFF5EFE7), fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryTasks =
            allTasks.where((task) => task.category == category.name).toList();

        return Card(
          color: Color(0xFF1D2345),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              category.name,
              style: TextStyle(
                color: Color(0xFFF5EFE7),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${category.description} • ${categoryTasks.length} tasks',
              style: TextStyle(color: Color(0xFFF5EFE7)),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFFF5EFE7)),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Color(0xFF1D2345),
                      title: Text(
                        '${category.name} Tasks',
                        style: TextStyle(color: Color(0xFFF5EFE7)),
                      ),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: categoryTasks.length,
                          itemBuilder: (context, i) {
                            final task = categoryTasks[i];
                            return ListTile(
                              title: Text(
                                task.title,
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              subtitle: Text(
                                task.description,
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                              trailing: Text(
                                '${(task.progress * 100).toInt()}%',
                                style: TextStyle(color: Color(0xFFF5EFE7)),
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Close',
                            style: TextStyle(color: Color(0xFFF5EFE7)),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        );
      },
    );
  }
}
