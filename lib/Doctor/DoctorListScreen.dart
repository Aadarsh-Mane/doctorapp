import 'dart:convert';
import 'package:doctorapp/constants/Urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Doctor {
  final String id;
  final String email;
  final String doctorName;

  Doctor({
    required this.id,
    required this.email,
    required this.doctorName,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'],
      email: json['email'],
      doctorName: json['doctorName'],
    );
  }
}

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<List<Doctor>> _doctorList;
  late IO.Socket socket;

  Future<List<Doctor>> fetchDoctors() async {
    final response =
        await http.get(Uri.parse('${VERCEL_URL}/reception/listDoctors'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('doctors')) {
        List<dynamic> doctorsJson = data['doctors'];
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Doctors key not found in response');
      }
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  @override
  void initState() {
    super.initState();
    _doctorList = fetchDoctors();
    connectToSocket();
  }

  // Connect to the Socket.IO server
  void connectToSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('auth_token');
    print('Token from SharedPreferences: $token');

    socket = IO.io('${VERCEL_URL}', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    socket.on('chatHistory', (chatHistory) {
      print('Received chat history: $chatHistory');
      // You can navigate to the chat screen and display this data
    });

    socket.on('receiveMessage', (message) {
      print('New message received: $message');
      // Handle incoming message
    });

    socket.on('chatStarted', (data) {
      print(data['message']);
      // Notify user that the chat has started
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors List'),
      ),
      body: FutureBuilder<List<Doctor>>(
        future: _doctorList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No doctors found'));
          } else {
            final doctors = snapshot.data!;

            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return ListTile(
                  title: Text(doctor.doctorName),
                  subtitle: Text(doctor.email),
                  onTap: () {
                    // Start a chat with the selected doctor
                    startChat(doctor.id);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  // Initiate a chat with the selected doctor
  void startChat(String otherDoctorId) {
    socket.emit('startChat', {'otherDoctorId': otherDoctorId});
    print('Start chat event emitted with doctor ID: $otherDoctorId');

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatScreen(otherDoctorId: otherDoctorId)),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String otherDoctorId;

  ChatScreen({required this.otherDoctorId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    socket = IO.io('${VERCEL_URL}', <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer YOUR_JWT_TOKEN'},
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
      socket.emit('reconnect'); // Request missed messages when reconnecting
    });

    socket.on('receiveMessage', (message) {
      print('New message received: $message');
      // Handle displaying new messages
    });
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  void sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      socket.emit('sendMessage', {
        'receiver': widget.otherDoctorId,
        'message': message,
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Doctor ${widget.otherDoctorId}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: ListView()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
