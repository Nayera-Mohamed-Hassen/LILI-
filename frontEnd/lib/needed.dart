// //button
// // ElevatedButton(
// // onPressed: () {},
// // style: ElevatedButton.styleFrom(
// // backgroundColor: Color(0xFF3E5879),
// //
// // // const Color(0xFF3E5879)
// // minimumSize: Size(315, 55),
// // shape: RoundedRectangleBorder(
// // side: BorderSide(width: 1),
// // borderRadius: BorderRadius.circular(5),
// // ),
// // ),
// // child: Text(
// // 'Log In',
// // style: TextStyle(color: Colors.white, fontSize: 18),
// // ),
// // ),
// //back button
// // appBar: AppBar(
// // leading: BackButton(),
// // backgroundColor: Colors.transparent,
// // elevation: 0,
// // ),
//
// //container
// // Container(
// // width: 400,
// // height: 200,
// // clipBehavior: Clip.antiAlias,
// // decoration: BoxDecoration(color: const Color(0xFFF5EFE7)),
// // child: Stack(
// // children: [
// // Positioned(
// // left: 20,
// // top: 100,
// // child: Text(
// // 'Log In',
// // textAlign: TextAlign.center,
// // style: TextStyle(
// // color: const Color(0xFF213555),
// // fontSize: 64,
// // fontFamily: 'Roboto',
// // fontWeight: FontWeight.w400,
// // height: 1.20,
// // ),
// // ),
// // ),
// // ],
// // ),
// // ),
// // Container(
// // margin: const EdgeInsets.symmetric(vertical: 20),
// // height: 200,
// // child: ListView(
// // // This next line does the trick.
// // scrollDirection: Axis.horizontal,
// // children: <Widget>[
// // Container(width: 160, color: Colors.red),
// // Container(width: 160, color: Colors.blue),
// // Container(width: 160, color: Colors.green),
// // Container(width: 160, color: Colors.yellow),
// // Container(width: 160, color: Colors.orange),
// // ],
// // ),
// // PopupMenuButton<String>(
// //   icon: Icon(Icons.notifications),
// //   itemBuilder:
// //       (BuildContext context) => <PopupMenuEntry<String>>[
// //         PopupMenuItem<String>(
// //           value: '1',
// //           child: ListTile(
// //             leading: Icon(Icons.notification_important),
// //             title: Text('Task "Project UI" is due today.'),
// //           ),
// //         ),
// //         PopupMenuItem<String>(
// //           value: '2',
// //           child: ListTile(
// //             leading: Icon(Icons.new_releases),
// //             title: Text('New task "3D Project" assigned.'),
// //           ),
// //         ),
// //         PopupMenuItem<String>(
// //           value: '3',
// //           child: ListTile(
// //             leading: Icon(Icons.schedule),
// //             title: Text('Meeting at 2 PM.'),
// //           ),
// //         ),
// //       ],
// // ),
// // SizedBox(
// //   height: 40, // Adjust height as needed for the chips
// //   child: ListView(
// //     scrollDirection: Axis.horizontal,
// //     children: [
// //       SizedBox(width: 8), // spacing at start
// //       ActionChip(
// //         label: Text("All"),
// //         labelStyle: TextStyle(
// //           fontWeight: FontWeight.bold,
// //           color: Color(0xFFF5EFE7),
// //         ),
// //         backgroundColor: Color(0xFF3E5879),
// //         onPressed: () => print("Perform some action here"),
// //       ),
// //       SizedBox(width: 8),
// //       ActionChip(
// //         label: Text("In Progress"),
// //         labelStyle: TextStyle(
// //           fontWeight: FontWeight.bold,
// //           color: Color(0xFFF5EFE7),
// //         ),
// //         backgroundColor: Color(0xFF3E5879),
// //         onPressed: () => print("Perform some action here"),
// //       ),
// //       SizedBox(width: 8),
// //       ActionChip(
// //         label: Text("Done"),
// //         labelStyle: TextStyle(
// //           fontWeight: FontWeight.bold,
// //           color: Color(0xFFF5EFE7),
// //         ),
// //         backgroundColor: Color(0xFF3E5879),
// //         onPressed: () => print("Perform some action here"),
// //       ),
// //       SizedBox(width: 8),
// //       ActionChip(
// //         label: Text("Scheduled"),
// //         labelStyle: TextStyle(
// //           fontWeight: FontWeight.bold,
// //           color: Color(0xFFF5EFE7),
// //         ),
// //         backgroundColor: Color(0xFF3E5879),
// //         onPressed: () => print("Perform some action here"),
// //       ),
// //       SizedBox(width: 8),
// //       ActionChip(
// //         label: Text("filter label"),
// //         labelStyle: TextStyle(
// //           fontWeight: FontWeight.bold,
// //           color: Color(0xFFF5EFE7),
// //         ),
// //         backgroundColor: Color(0xFF3E5879),
// //         onPressed: () => print("Perform some action here"),
// //       ),
// //       SizedBox(width: 8), // spacing at end
// //     ],
// //   ),
// // ),
// // Text(
// //   'ALL!',
// //   textAlign: TextAlign.center,
// //   style: TextStyle(
// //     fontSize: 25,
// //     fontWeight: FontWeight.bold,
// //     color: Color(0xFF213555),
// //   ),
// // ),
// // Expanded(
// //   child: ListView.builder(
// //     itemCount: all_tasks.length,
// //     itemBuilder: (context, index) {
// //       final task = all_tasks[index];
// //       return Card(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(15),
// //         ),
// //         color: Color(0xFF3E5879),
// //         child: ListTile(
// //           title: Text(
// //             task['title'],
// //             style: TextStyle(color: Color(0xFFF5EFE7)),
// //           ),
// //           subtitle: Text(
// //             task['description'],
// //             style: TextStyle(color: Color(0xFFF5EFE7)),
// //           ),
// //           trailing: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 '${(task['progress'] * 100).toInt()}%',
// //                 style: TextStyle(color: Color(0xFFF5EFE7)),
// //               ),
// //               Text(
// //                 task['dueDate'],
// //                 style: TextStyle(color: Color(0xFFF5EFE7)),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     },
// //   ),
// // ),
// // Expanded(
// //   child: ListView.builder(
// //     itemCount: filteredTasks.length,
// //     itemBuilder: (context, index) {
// //       final task = filteredTasks[index];
// //       return Card(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(15),
// //         ),
// //         color: Color(0xFF3E5879),
// //         child: ListTile(
// //           title: Text(
// //             task['title'],
// //             style: TextStyle(color: Color(0xFFF5EFE7)),
// //           ),
// //           subtitle: Text(
// //             task['description'],
// //             style: TextStyle(color: Color(0xFFF5EFE7)),
// //           ),
// //           trailing: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 '${(task['progress'] * 100).toInt()}%',
// //                 style: TextStyle(color: Color(0xFFF5EFE7)),
// //               ),
// //               Text(
// //                 task['dueDate'],
// //                 style: TextStyle(color: Color(0xFFF5EFE7)),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     },
// //   ),
// // ),
// // Expanded(
// //   child:
// //       selectedFilter == 'Categories'
// //           ? ListView.builder(
// //             itemCount: categories.length,
// //             itemBuilder: (context, index) {
// //               final category = categories[index];
// //               return Card(
// //                 color: Color(0xFF3E5879),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(15),
// //                 ),
// //                 child: ListTile(
// //                   title: Text(
// //                     category['name']!,
// //                     style: TextStyle(
// //                       color: Color(0xFFF5EFE7),
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   subtitle: Text(
// //                     category['description']!,
// //                     style: TextStyle(color: Color(0xFFF5EFE7)),
// //                   ),
// //                   trailing: IconButton(
// //                     icon: Icon(
// //                       Icons.play_arrow,
// //                       color: Color(0xFFF5EFE7),
// //                     ),
// //                     onPressed: () {
// //                       Navigator.pushNamed(
// //                         context,
// //                         category['route']!,
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               );
// //             },
// //           )
// //           : ListView.builder(
// //             itemCount: filteredTasks.length,
// //             itemBuilder: (context, index) {
// //               final task = filteredTasks[index];
// //               return Card(
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(15),
// //                 ),
// //                 color: Color(0xFF3E5879),
// //                 child: ListTile(
// //                   title: Text(
// //                     task['title'],
// //                     style: TextStyle(color: Color(0xFFF5EFE7)),
// //                   ),
// //                   subtitle: Text(
// //                     task['description'],
// //                     style: TextStyle(color: Color(0xFFF5EFE7)),
// //                   ),
// //                   trailing: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Text(
// //                         '${(task['progress'] * 100).toInt()}%',
// //                         style: TextStyle(color: Color(0xFFF5EFE7)),
// //                       ),
// //                       Text(
// //                         task['dueDate'],
// //                         style: TextStyle(color: Color(0xFFF5EFE7)),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// // ),
// // Navigator.pushNamed(context, '/signup');
// // floatingActionButton: FloatingActionButton(
// //   backgroundColor: Color(0xFF3E5879), // Your purple shade
// //   child: Icon(Icons.add, size: 30, color: Color(0xFFF5EFE7)),
// //   onPressed: () {
// //     // Navigator.pushNamed(context, '/create new task');
// //     //option 1
// //     // showModalBottomSheet(
// //     //   context: context,
// //     //   shape: RoundedRectangleBorder(
// //     //     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //     //   ),
// //     //   backgroundColor: Colors.white,
// //     //   builder: (context) {
// //     //     return Padding(
// //     //       padding: const EdgeInsets.symmetric(vertical: 20),
// //     //       child: Column(
// //     //         mainAxisSize: MainAxisSize.min,
// //     //         children: [
// //     //           ListTile(
// //     //             leading: Icon(Icons.task, color: Colors.purple[300]),
// //     //             title: Text("New Task"),
// //     //             onTap: () {
// //     //               Navigator.pop(context);
// //     //               // Navigate to or show New Task form
// //     //             },
// //     //           ),
// //     //           ListTile(
// //     //             leading: Icon(Icons.category, color: Colors.purple[300]),
// //     //             title: Text("New Category"),
// //     //             onTap: () {
// //     //               Navigator.pop(context);
// //     //               // Navigate to or show New Category form
// //     //             },
// //     //           ),
// //     //         ],
// //     //       ),
// //     //     );
// //     //   },
// //     // );
// //
// //     // Add new task
// //   },
// // ),
//
// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
//
// class TasksHomePage extends StatefulWidget {
//   @override
//   _TasksHomePageState createState() => _TasksHomePageState();
// }
//
// // const Color(0xFF213555)
// class _TasksHomePageState extends State<TasksHomePage> {
//   String selectedFilter = 'All';
//

//   final List<Map<String, String>> categories = [
//     {
//       'name': 'Cleaning',
//       'description': 'Chores related to cleaning tasks.',
//       'route': '/cleaning',
//     },
//     {
//       'name': 'Cooking',
//       'description': 'Cooking-related activities.',
//       'route': '/cooking',
//     },
//     {
//       'name': 'Shopping',
//       'description': 'Shopping tasks and groceries.',
//       'route': '/shopping',
//     },
//   ];
//   List<Map<String, dynamic>> getFilteredTasks() {
//     switch (selectedFilter) {
//       case 'All':
//         return all_tasks;
//       case 'Done':
//         return done_tasks;
//       case 'Scheduled':
//         return schedueld_tasks;
//       case 'In progress':
//         return in_progress_tasks;
//       default:
//         return []; // You can add more filters here
//     }
//   }
//
//   int _selectedIndex = 0;
//
//   final items = [
//     Icon(Icons.category_rounded, size: 30, color: Color(0xFFF5EFE7)),
//     // Icon(Icons.category_rounded, size: 30, color: Color(0xFFF5EFE7)),
//     Icon(Icons.calendar_month_outlined, size: 30, color: Color(0xFFF5EFE7)),
//     // Icon(Icons.person, size: 30, color: Color(0xFFF5EFE7)),
//   ];
//
//   final List<Widget> _pages = [
//     Center(child: Text('Home')),
//     // Center(child: Text('Categories')),
//     Center(child: Text('Calender')),
//     // Center(child: Text('Settings')),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//
//             SizedBox(height: 20),
//             Text(
//               '$selectedFilter Tasks',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 25,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF213555),
//               ),
//             ),
//             SizedBox(height: 2),
//
//             Expanded(
//               child:
//               selectedFilter == 'Categories'
//                   ? ListView.builder(
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final category = categories[index];
//                   return Card(
//                     color: Color((0xFF1D2345)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: ListTile(
//                       title: Text(
//                         category['name']!,
//                         style: TextStyle(
//                           color: Color(0xFFF5EFE7),
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       subtitle: Text(
//                         category['description']!,
//                         style: TextStyle(color: Color(0xFFF5EFE7)),
//                       ),
//                       trailing: Icon(
//                         Icons.arrow_forward,
//                         color: Color(0xFFF5EFE7),
//                       ),
//                       onTap: () {
//                         // If you want to do something on category tap (e.g., navigate to details)
//                         // you can implement it here, but the list itself won't be a pop-up.
//                       },
//                     ),
//                   );
//                 },
//               )
//                   : ListView.builder(
//                 itemCount: filteredTasks.length,
//                 itemBuilder: (context, index) {
//                   final task = filteredTasks[index];
//                   return Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     color: Color((0xFF1D2345)),
//                     child: ListTile(
//                       title: Text(
//                         task['title'],
//                         style: TextStyle(color: Color(0xFFF5EFE7)),
//                       ),
//                       subtitle: Text(
//                         task['description'],
//                         style: TextStyle(color: Color(0xFFF5EFE7)),
//                       ),
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '${(task['progress'] * 100).toInt()}%',
//                             style: TextStyle(color: Color(0xFFF5EFE7)),
//                           ),
//                           Text(
//                             task['dueDate'],
//                             style: TextStyle(color: Color(0xFFF5EFE7)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),

//       floatingActionButton: PopupMenuButton<String>(
//         onSelected: (value) {
//           if (value == 'task') {
//             Navigator.pushNamed(context, '/create new task');
//             // Open New Task form
//           } else if (value == 'category') {
//             Navigator.pushNamed(context, '/create new category');
//             // Open New Category form
//           }
//         },
//         offset: Offset(0, -100),
//         color: Color(0xFFF5EFE7),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         icon: FloatingActionButton(
//           backgroundColor: Color((0xFF1D2345)),
//           child: Icon(Icons.add, size: 30, color: Color(0xFFF5EFE7)),
//           onPressed: null, // Leave null to use PopupMenuButton's onSelected
//         ),
//         itemBuilder:
//             (context) => [
//           PopupMenuItem(
//             value: 'task',
//             child: Row(
//               children: [
//                 Icon(Icons.task, color: Color((0xFF1D2345))),
//                 SizedBox(width: 10),
//                 Text(
//                   "New Task",
//                   style: TextStyle(color: Color((0xFF1D2345))),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuItem(
//             value: 'category',
//             child: Row(
//               children: [
//                 Icon(Icons.category, color: Color((0xFF1D2345))),
//                 SizedBox(width: 10),
//                 Text(
//                   "New Category",
//                   style: TextStyle(color: Color((0xFF1D2345))),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//
//       bottomNavigationBar: CurvedNavigationBar(
//         items: items,
//         index: _selectedIndex,
//         height: 60,
//         backgroundColor: Colors.transparent,
//         color: Color((0xFF1D2345)),
//         buttonBackgroundColor: Color((0xFF1D2345)),
//         animationDuration: Duration(milliseconds: 300),
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
// bottomNavigationBar: BottomNavigationBar(
//   currentIndex: _selectedIndex,
//   selectedItemColor: Colors.green[800],
//   unselectedItemColor: Colors.grey,
//   onTap: _onItemTapped,
//   items: const [
//     BottomNavigationBarItem(
//       icon: Icon(Icons.home),
//       label: 'Home',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.credit_card),
//       label: 'My Cards',
//     ),
//     BottomNavigationBarItem(
//       icon: Icon(Icons.analytics),
//       label: 'Analytics',
//       ),
//     ],
//   ),
// );
// bottomNavigationBar: CurvedNavigationBar(
//   items: items,
//   index: _selectedIndex,
//   height: 60,
//   backgroundColor: Colors.transparent,
//   color: Color(0xFF1D2345),
//   buttonBackgroundColor: Color(0xFF1D2345),
//   onTap: _onItemTapped,
// ),
// _buildDropdown('Category'),
// const SizedBox(height: 16),
// _buildDatePicker(),
// const SizedBox(height: 16),
// _buildTimePicker(),
