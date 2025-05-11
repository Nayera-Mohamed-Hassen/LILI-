//background colour
// Color(0xFFF2F2F2)
//text colour
//const Color(0xFF1D2345)
//text bulider
// Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//       int maxLines = 1,
//     }) {
//   return TextField(
//     controller: controller,
//     maxLines: maxLines,
//     decoration: InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       filled: true,
//       fillColor: Colors.white,
//     ),
//   );
// }
//background
//backgroundColor: const Color(0xFFF2F2F2),
// Widget _buildHeader() {
//   return Row(
//     children: [
//       // CircleAvatar(radius: 40),
//       SizedBox(width: 10),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Good Morning!',
//             style: TextStyle(
//               fontSize: 25,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF213555),
//             ),
//           ),
//           Text(
//             'Nayera',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF213555),
//             ),
//           ),
//         ],
//       ),
//       Spacer(),
//       GestureDetector(
//         onTapDown: (details) {
//           showMenu(
//             context: context,
//             position: RelativeRect.fromLTRB(
//               details.globalPosition.dx,
//               details.globalPosition.dy,
//               0,
//               0,
//             ),
//             items: [
//               PopupMenuItem(
//                 child: ListTile(
//                   leading: Icon(
//                     Icons.notification_important,
//                     color: Color(0xFF3E5879),
//                   ),
//                   title: Text('Project UI is due today.'),
//                 ),
//               ),
//               PopupMenuItem(
//                 child: ListTile(
//                   leading: Icon(Icons.new_releases, color: Colors.orange),
//                   title: Text('New task assigned.'),
//                 ),
//               ),
//             ],
//           );
//         },
//         child: Container(
//           padding: EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Color(0xFF1D2345),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Icon(Icons.notifications, color: Color(0xFFF5EFE7)),
//         ),
//       ),
//     ],
//   );
// }
