// import 'dart:convert';

// import 'package:doctorapp/repositories/auth_repository.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;

// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   late final AuthRepository _authRepository;

//   Future<void> initializeFCM() async {
//     // Request permission for notifications
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted notification permission');
//     } else {
//       print('User declined or has not accepted notification permission');
//     }

//     // Get FCM token
//     String? fcmToken = await _firebaseMessaging.getToken();
//     if (fcmToken != null) {
//       print('FCM Token: $fcmToken');
//       await _authRepository.storeTokenToBackend(fcmToken);
//     }
//   }
// }
