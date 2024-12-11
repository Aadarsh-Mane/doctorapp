// import 'package:doctorapp/constants/app_color.dart';
// import 'package:doctorapp/providers/auth_providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class HomeScreen extends ConsumerWidget {
//   final String doctorImage =
//       "assets/images/doctor1.png"; // Replace with actual image asset path

//   @override
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final fetchProfileValue = ref.watch(doctorProfileProvider);

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               AppColors.lightBlueTop,
//               AppColors.lightBlueBottom,
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: fetchProfileValue.when(
//             data: (doctorProfile) => Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 40), // Space from top
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Container(
//                     width: double.infinity, // Make card full width
//                     height: 160, // Increased height of the card
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.3), // Shadow color
//                           spreadRadius: 3, // Spread radius of the shadow
//                           blurRadius: 5, // Blur radius of the shadow
//                           offset: Offset(0, 3), // Offset of the shadow
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 40,
//                           backgroundImage:
//                               AssetImage(doctorImage), // Doctor image
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Name : ${doctorProfile.doctorName}',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Type: ${doctorProfile.usertype}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               Text(
//                                 'Email: ${doctorProfile.email}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20), // Space between card and other elements
//               ],
//             ),
//             loading: () => Center(child: CircularProgressIndicator()),
//             error: (err, stack) => Center(child: Text('Error: $err')),
//           ),
//         ),
//       ),
//     );
//   }
// }
