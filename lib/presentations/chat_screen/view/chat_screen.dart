import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String selectedUserId;
  final String selectedUserName;

  ChatScreen({required this.selectedUserId, required this.selectedUserName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late final String chatId;

  @override
  void initState() {
    super.initState();
    chatId = getChatId(currentUser!.uid, widget.selectedUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.selectedUserName}'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.selectedUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final isOnline = userData?['isOnline'] ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  isOnline ? Icons.online_prediction : Icons.offline_bolt,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messageStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Show newest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isCurrentUser = message['senderId'] == currentUser!.uid;

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
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

  Stream<QuerySnapshot> messageStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp')
        .snapshots()
        .handleError((error) {
          print('Stream error: $error');
        });
  }

  String getChatId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort(); 
    return '${users[0]}_${users[1]}';
  }

  Future<void> sendMessage() async {
    if (messageController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'senderId': currentUser?.uid,
          'receiverId': widget.selectedUserId,
          'message': messageController.text,
          'timestamp': Timestamp.now(),
          'chatId': chatId,
        });
        messageController.clear();
      } catch (error) {
        print('Error sending message: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatScreen extends StatefulWidget {
//   final String selectedUserId;
//   final String selectedUserName;

//   ChatScreen({required this.selectedUserId, required this.selectedUserName});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.selectedUserName}'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _messageStream(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(child: Text('No messages yet'));
//                 }

//                 final messages = snapshot.data!.docs;

//                 print('Fetched ${messages.length} messages'); // Debug: Print number of messages fetched

//                 return ListView.builder(
//                   reverse: true, // Show newest messages at the bottom
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message = messages[index].data() as Map<String, dynamic>;
//                     final isCurrentUser = message['senderId'] == currentUser!.uid;

//                     return Align(
//                       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
//                         margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                         decoration: BoxDecoration(
//                           color: isCurrentUser ? Colors.blueAccent : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Text(
//                           message['message'] ?? '', // Handle case where message is null
//                           style: TextStyle(
//                             color: isCurrentUser ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       labelText: 'Enter your message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Stream<QuerySnapshot> _messageStream() {
//     final chatId = _getChatId(currentUser!.uid, widget.selectedUserId);
//     print('Listening to chatId: $chatId'); // Debug: Print chatId

//     return FirebaseFirestore.instance
//         .collection('messages')
//         .where('chatId', isEqualTo: chatId)
//         .orderBy('timestamp')
//         .snapshots()
//         .handleError((error) {
//           // Handle errors
//           print('Stream error: $error');
//         });
//   }

//   String _getChatId(String user1, String user2) {
//     List<String> users = [user1, user2];
//     users.sort(); // Ensure consistent ordering
//     final chatId = '${users[0]}_${users[1]}';
//     print('Generated chatId: $chatId'); // Debug: Print chatId
//     return chatId;
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.isNotEmpty) {
//       try {
//         final chatId = _getChatId(currentUser!.uid, widget.selectedUserId);
//         await FirebaseFirestore.instance.collection('messages').add({
//           'senderId': currentUser?.uid,
//           'receiverId': widget.selectedUserId,
//           'message': _messageController.text,
//           'timestamp': Timestamp.now(),
//           'chatId': chatId,
//         });

//         // Trigger a UI refresh
//         setState(() {
//           _messageController.clear(); // Clear the input field
//         });

//       } catch (error) {
//         print('Error sending message: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to send message')),
//         );
//       }
//     }
//   }
// }
