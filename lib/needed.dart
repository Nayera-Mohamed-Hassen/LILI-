//button
// ElevatedButton(
// onPressed: () {},
// style: ElevatedButton.styleFrom(
// backgroundColor: Color(0xFF3E5879),
//
// // const Color(0xFF3E5879)
// minimumSize: Size(315, 55),
// shape: RoundedRectangleBorder(
// side: BorderSide(width: 1),
// borderRadius: BorderRadius.circular(5),
// ),
// ),
// child: Text(
// 'Log In',
// style: TextStyle(color: Colors.white, fontSize: 18),
// ),
// ),
//back button
// appBar: AppBar(
// leading: BackButton(),
// backgroundColor: Colors.transparent,
// elevation: 0,
// ),

//container
// Container(
// width: 400,
// height: 200,
// clipBehavior: Clip.antiAlias,
// decoration: BoxDecoration(color: const Color(0xFFF5EFE7)),
// child: Stack(
// children: [
// Positioned(
// left: 20,
// top: 100,
// child: Text(
// 'Log In',
// textAlign: TextAlign.center,
// style: TextStyle(
// color: const Color(0xFF213555),
// fontSize: 64,
// fontFamily: 'Roboto',
// fontWeight: FontWeight.w400,
// height: 1.20,
// ),
// ),
// ),
// ],
// ),
// ),
// Container(
// margin: const EdgeInsets.symmetric(vertical: 20),
// height: 200,
// child: ListView(
// // This next line does the trick.
// scrollDirection: Axis.horizontal,
// children: <Widget>[
// Container(width: 160, color: Colors.red),
// Container(width: 160, color: Colors.blue),
// Container(width: 160, color: Colors.green),
// Container(width: 160, color: Colors.yellow),
// Container(width: 160, color: Colors.orange),
// ],
// ),
// PopupMenuButton<String>(
//   icon: Icon(Icons.notifications),
//   itemBuilder:
//       (BuildContext context) => <PopupMenuEntry<String>>[
//         PopupMenuItem<String>(
//           value: '1',
//           child: ListTile(
//             leading: Icon(Icons.notification_important),
//             title: Text('Task "Project UI" is due today.'),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: '2',
//           child: ListTile(
//             leading: Icon(Icons.new_releases),
//             title: Text('New task "3D Project" assigned.'),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: '3',
//           child: ListTile(
//             leading: Icon(Icons.schedule),
//             title: Text('Meeting at 2 PM.'),
//           ),
//         ),
//       ],
// ),
// SizedBox(
//   height: 40, // Adjust height as needed for the chips
//   child: ListView(
//     scrollDirection: Axis.horizontal,
//     children: [
//       SizedBox(width: 8), // spacing at start
//       ActionChip(
//         label: Text("All"),
//         labelStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Color(0xFFF5EFE7),
//         ),
//         backgroundColor: Color(0xFF3E5879),
//         onPressed: () => print("Perform some action here"),
//       ),
//       SizedBox(width: 8),
//       ActionChip(
//         label: Text("In Progress"),
//         labelStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Color(0xFFF5EFE7),
//         ),
//         backgroundColor: Color(0xFF3E5879),
//         onPressed: () => print("Perform some action here"),
//       ),
//       SizedBox(width: 8),
//       ActionChip(
//         label: Text("Done"),
//         labelStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Color(0xFFF5EFE7),
//         ),
//         backgroundColor: Color(0xFF3E5879),
//         onPressed: () => print("Perform some action here"),
//       ),
//       SizedBox(width: 8),
//       ActionChip(
//         label: Text("Scheduled"),
//         labelStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Color(0xFFF5EFE7),
//         ),
//         backgroundColor: Color(0xFF3E5879),
//         onPressed: () => print("Perform some action here"),
//       ),
//       SizedBox(width: 8),
//       ActionChip(
//         label: Text("filter label"),
//         labelStyle: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Color(0xFFF5EFE7),
//         ),
//         backgroundColor: Color(0xFF3E5879),
//         onPressed: () => print("Perform some action here"),
//       ),
//       SizedBox(width: 8), // spacing at end
//     ],
//   ),
// ),
// Text(
//   'ALL!',
//   textAlign: TextAlign.center,
//   style: TextStyle(
//     fontSize: 25,
//     fontWeight: FontWeight.bold,
//     color: Color(0xFF213555),
//   ),
// ),
// Expanded(
//   child: ListView.builder(
//     itemCount: all_tasks.length,
//     itemBuilder: (context, index) {
//       final task = all_tasks[index];
//       return Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         color: Color(0xFF3E5879),
//         child: ListTile(
//           title: Text(
//             task['title'],
//             style: TextStyle(color: Color(0xFFF5EFE7)),
//           ),
//           subtitle: Text(
//             task['description'],
//             style: TextStyle(color: Color(0xFFF5EFE7)),
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 '${(task['progress'] * 100).toInt()}%',
//                 style: TextStyle(color: Color(0xFFF5EFE7)),
//               ),
//               Text(
//                 task['dueDate'],
//                 style: TextStyle(color: Color(0xFFF5EFE7)),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   ),
// ),
// Expanded(
//   child: ListView.builder(
//     itemCount: filteredTasks.length,
//     itemBuilder: (context, index) {
//       final task = filteredTasks[index];
//       return Card(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//         ),
//         color: Color(0xFF3E5879),
//         child: ListTile(
//           title: Text(
//             task['title'],
//             style: TextStyle(color: Color(0xFFF5EFE7)),
//           ),
//           subtitle: Text(
//             task['description'],
//             style: TextStyle(color: Color(0xFFF5EFE7)),
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 '${(task['progress'] * 100).toInt()}%',
//                 style: TextStyle(color: Color(0xFFF5EFE7)),
//               ),
//               Text(
//                 task['dueDate'],
//                 style: TextStyle(color: Color(0xFFF5EFE7)),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   ),
// ),
// Expanded(
//   child:
//       selectedFilter == 'Categories'
//           ? ListView.builder(
//             itemCount: categories.length,
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               return Card(
//                 color: Color(0xFF3E5879),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: ListTile(
//                   title: Text(
//                     category['name']!,
//                     style: TextStyle(
//                       color: Color(0xFFF5EFE7),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   subtitle: Text(
//                     category['description']!,
//                     style: TextStyle(color: Color(0xFFF5EFE7)),
//                   ),
//                   trailing: IconButton(
//                     icon: Icon(
//                       Icons.play_arrow,
//                       color: Color(0xFFF5EFE7),
//                     ),
//                     onPressed: () {
//                       Navigator.pushNamed(
//                         context,
//                         category['route']!,
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           )
//           : ListView.builder(
//             itemCount: filteredTasks.length,
//             itemBuilder: (context, index) {
//               final task = filteredTasks[index];
//               return Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 color: Color(0xFF3E5879),
//                 child: ListTile(
//                   title: Text(
//                     task['title'],
//                     style: TextStyle(color: Color(0xFFF5EFE7)),
//                   ),
//                   subtitle: Text(
//                     task['description'],
//                     style: TextStyle(color: Color(0xFFF5EFE7)),
//                   ),
//                   trailing: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         '${(task['progress'] * 100).toInt()}%',
//                         style: TextStyle(color: Color(0xFFF5EFE7)),
//                       ),
//                       Text(
//                         task['dueDate'],
//                         style: TextStyle(color: Color(0xFFF5EFE7)),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
// ),
