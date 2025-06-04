import 'package:LILI/user_session.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:LILI/models/task.dart';
import 'package:LILI/models/category_task.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:LILI/pages/create_new_task_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:LILI/services/task_service.dart';

class TasksHomePage extends StatefulWidget {
  const TasksHomePage({Key? key}) : super(key: key);

  @override
  _TasksHomePageState createState() => _TasksHomePageState();
}

class _TasksHomePageState extends State<TasksHomePage> {
  String selectedFilter = 'All';
  String searchQuery = '';
  bool isLoading = true;
  String? error;

  List<TaskModel> allTasks = [];

  List<CategoryModel> categories = [
    CategoryModel(name: 'Design', description: 'UI/UX and graphic work'),
    CategoryModel(name: 'Chores', description: 'Household tasks'),
    CategoryModel(name: 'Shopping', description: 'Shopping and errands'),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch tasks when the page loads
    Provider.of<TaskService>(context, listen: false).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final filteredTasks = taskService.getFilteredTasks(
          filter: selectedFilter,
          searchQuery: searchQuery,
        );

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
                  _buildHeader(taskService),
                  _buildSearch(),
                  if (_selectedIndex == 0) _buildFilterChips(),
                  SizedBox(height: 16),
                  Expanded(
                    child: _selectedIndex == 1
                        ? _buildCategoryList(taskService)
                        : _selectedIndex == 2
                            ? _buildPeopleList(taskService)
                            : _buildTaskList(taskService, filteredTasks),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildHeader(TaskService taskService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${taskService.getPendingTasksCount()} tasks pending',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 25.0,
            lineWidth: 4.0,
            percent: taskService.getCompletionRate(),
            center: Text(
              '${(taskService.getCompletionRate() * 100).toInt()}%',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            progressColor: Colors.white,
            backgroundColor: Colors.white24,
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
            hintText: 'Search tasks...',
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
    final filters = ['All', 'Done', 'In progress', 'Scheduled'];
    return Container(
      height: 40,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          return FilterChip(
            label: Text(f, style: TextStyle(color: Color(0xFF1F3354))),
            selected: selectedFilter == f,
            onSelected: (selected) => setState(() => selectedFilter = f),
            backgroundColor: Colors.white12,
            selectedColor: Colors.white24,
            checkmarkColor: Color(0xFF1F3354),
            side: BorderSide(color: Colors.white24),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(TaskService taskService, List<TaskModel> tasks) {
    if (taskService.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (taskService.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              taskService.error!,
              style: TextStyle(color: Colors.white70, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => taskService.fetchTasks(),
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF1F3354),
              ),
            ),
          ],
        ),
      );
    }

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => taskService.fetchTasks(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Dismissible(
            key: Key(task.id),
            background: _buildDismissBackground(),
            secondaryBackground: _buildDismissBackground(isEndToStart: true),
            onDismissed: (direction) async {
              final success = await taskService.deleteTask(task);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete task'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Card(
              margin: EdgeInsets.only(bottom: 12),
              color: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white24),
              ),
              child: InkWell(
                onTap: () => _showTaskDetails(task),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: task.isCompleted,
                              onChanged: (val) async {
                                if (val != null) {
                                  final success = await taskService.updateTaskStatus(task, val);
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to update task status'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              checkColor: Colors.white,
                              fillColor: MaterialStateProperty.resolveWith<
                                Color
                              >((Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors.white24;
                                }
                                return Colors.transparent;
                              }),
                              side: BorderSide(color: Colors.white60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text(
                          task.description,
                          style: TextStyle(color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTaskChip(
                            task.category,
                            icon: Icons.category_outlined,
                          ),
                          SizedBox(width: 8),
                          _buildTaskChip(
                            task.assignedTo,
                            icon: Icons.person_outline,
                          ),
                          Spacer(),
                          _buildTaskChip(
                            DateFormat('MMM d').format(task.dueDate),
                            icon: Icons.calendar_today_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskChip(String label, {required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white60),
          SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDismissBackground({bool isEndToStart = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isEndToStart ? Alignment.centerRight : Alignment.centerLeft,
      child: Icon(Icons.delete_outline, color: Colors.white),
    );
  }

  void _showTaskDetails(TaskModel task) {
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
                        task.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.description_outlined,
                        task.description,
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        DateFormat('MMMM d, y').format(task.dueDate),
                      ),
                      SizedBox(height: 12),
                      _buildDetailRow(Icons.person_outline, task.assignedTo),
                      SizedBox(height: 12),
                      _buildDetailRow(Icons.category_outlined, task.category),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                // Edit task
                                Navigator.pop(
                                  context,
                                ); // Close the bottom sheet
                                final editedTask = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => CreateNewTaskPage(
                                          categories: categories,
                                          taskToEdit: task,
                                        ),
                                  ),
                                );
                                if (editedTask != null &&
                                    editedTask is TaskModel) {
                                  setState(() {
                                    final index = allTasks.indexWhere(
                                      (t) => t.id == task.id,
                                    );
                                    if (index != -1) {
                                      allTasks[index] = editedTask;
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white24,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Edit Task',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  allTasks.removeWhere((t) => t.id == task.id);
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.3),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Delete Task',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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
        if (value == 'task') {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewTaskPage(categories: categories),
            ),
          );
          if (newTask != null && newTask is TaskModel) {
            setState(() {
              allTasks.add(newTask);
            });
          }
        } else if (value == 'category') {
          final newCategory = await Navigator.pushNamed(
            context,
            '/create new category',
          );
          if (newCategory != null && newCategory is CategoryModel) {
            setState(() {
              categories.add(newCategory);
            });
          }
        }
      },
      offset: Offset(0, -100),
      color: Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      icon: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.add, size: 30, color: Color(0xFF1F3354)),
        onPressed: null,
      ),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'task',
              child: Row(
                children: [
                  Icon(Icons.task, color: Color(0xFF1F3354)),
                  SizedBox(width: 10),
                  Text("New Task", style: TextStyle(color: Color(0xFF1F3354))),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'category',
              child: Row(
                children: [
                  Icon(Icons.category, color: Color(0xFF1F3354)),
                  SizedBox(width: 10),
                  Text(
                    "New Category",
                    style: TextStyle(color: Color(0xFF1F3354)),
                  ),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildBottomNavBar() {
    return CurvedNavigationBar(
      items: items,
      index: _selectedIndex,
      height: 60,
      backgroundColor: Color(0xFF3E5879),
      color: Color(0xFF1F3354),
      buttonBackgroundColor: Color(0xFF1F3354),
      onTap: _onItemTapped,
    );
  }

  int _selectedIndex = 0;
  final items = [
    Icon(Icons.task, size: 30, color: Color(0xFFF5EFE7)),
    Icon(Icons.category, size: 30, color: Color(0xFFF5EFE7)),
    Icon(
      Icons.person,
      size: 30,
      color: Color(0xFFF5EFE7),
    ), // ➕ Added People tab
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildCategoryList(TaskService taskService) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryTasks =
            allTasks.where((task) => task.category == category.name).toList();

        return Card(
          color: Color(0xFF1F3354),
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
                      backgroundColor: Color(0xFF1F3354),
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
                              // trailing: Text(
                              //   '${(task.progress * 100).toInt()}%',
                              //   style: TextStyle(color: Color(0xFFF5EFE7)),
                              // ),
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

  Widget _buildPeopleList(TaskService taskService) {
    // Group tasks by person
    final Map<String, List<TaskModel>> peopleMap = {};
    for (var task in allTasks) {
      peopleMap.putIfAbsent(task.assignedTo, () => []).add(task);
    }

    return ListView.builder(
      itemCount: peopleMap.keys.length,
      itemBuilder: (context, index) {
        final person = peopleMap.keys.elementAt(index);
        final personTasks = peopleMap[person]!;
        // final avgProgress =
        //     personTasks.map((t) => t.progress).reduce((a, b) => a + b) /
        //     personTasks.length;

        return Card(
          color: Color(0xFF1F3354),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF3E5879),
              child: Text(person[0], style: TextStyle(color: Colors.white)),
            ),
            title: Text(
              person,
              style: TextStyle(
                color: Color(0xFFF5EFE7),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // subtitle: Text(
            //   '${personTasks.length} tasks • ${(avgProgress * 100).toInt()}% done',
            //   style: TextStyle(color: Color(0xFFF5EFE7)),
            // ),
            trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFFF5EFE7)),
            onTap: () {
              // Optionally show a list of that person's tasks in a dialog
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFF1F3354),
                    title: Text(
                      '$person\'s Tasks',
                      style: TextStyle(color: Color(0xFFF5EFE7)),
                    ),
                    content: Container(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: personTasks.length,
                        itemBuilder: (context, i) {
                          final task = personTasks[i];
                          return ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(color: Color(0xFFF5EFE7)),
                            ),
                            // subtitle: Text(
                            //   '${task.progress * 100}%',
                            //   style: TextStyle(color: Color(0xFFF5EFE7)),
                            // ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
