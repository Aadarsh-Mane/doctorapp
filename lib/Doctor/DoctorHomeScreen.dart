// import 'package:doctorapp/constants/app_color.dart';
// import 'package:doctorapp/models/getDoctorProfile.dart';
// import 'package:doctorapp/providers/auth_providers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class DoctorHomeScreen extends ConsumerWidget {
//   final String doctorImage =
//       "assets/images/doctor1.png"; // Replace with actual image asset path

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final fetchProfileValue = ref.watch(fetchDoctorProfile);

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color.fromARGB(255, 98, 146, 200),
//               AppColors.lightBlueBottom,
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 40), // Space from top
//               fetchProfileValue.when(
//                 data: (DoctorProfile doctorProfile) {
//                   return ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Container(
//                       width: double.infinity, // Make card full width
//                       height: 160, // Height of the card
//                       padding: const EdgeInsets.all(16.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.3), // Shadow color
//                             spreadRadius: 3, // Spread radius of the shadow
//                             blurRadius: 5, // Blur radius of the shadow
//                             offset: Offset(0, 3), // Offset of the shadow
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           // Circular image using CircleAvatar
//                           CircleAvatar(
//                             radius: 40, // Radius for the circular avatar
//                             backgroundImage:
//                                 AssetImage(doctorImage), // Doctor image
//                           ),
//                           SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   doctorProfile
//                                       .doctorName, // Displaying the doctor's name
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   doctorProfile
//                                       .usertype, // Displaying the usertype as email
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 Text(
//                                   doctorProfile
//                                       .email, // Displaying the usertype as email
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//                 loading: () => Center(
//                     child:
//                         CircularProgressIndicator()), // Show a loading indicator while fetching data
//                 error: (err, stack) =>
//                     Center(child: Text("Error: $err")), // Show error message
//               ),
//               SizedBox(height: 20), // Space between card and other elements
//               // Additional UI elements can go here
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
