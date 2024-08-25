import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wincept_task/presentations/chat_screen/view/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("CHATIFY",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          final users = snapshot.data!.docs;
          if (users.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index].data() as Map<String, dynamic>;

              if (!userDoc.containsKey('userId')) {
                return Container(); 
              }

              if (userDoc['userId'] == currentUser!.uid) {
                return Container();
              }

              return ListTile(
                
                title: Text(userDoc['name'] ?? 'No name'),
                subtitle: Text(userDoc['email'] ?? 'No email'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            selectedUserId: userDoc['userId'],
                            selectedUserName: userDoc['name'],
                          )));
                },
              );
            },
          );
        },
      ),
    );
  }
}
