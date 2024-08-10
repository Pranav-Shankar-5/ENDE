import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();
    //Clear the Data

    //Send to the firebase
    //To store the chats based on the current user we can use the FirebaseAuth class to get the current user
    final user = FirebaseAuth.instance.currentUser!;
    //We need to also get the userdata from firestore which in turns sends the HTTP request to the server fethching the imageurl and userid
    //However this data can also be stored locally on the device using solutions liks riverPod for state management
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    //Approach 1 was to use the document formatted data as we used in saving the image url
    //Approach 2 would be to use the add method wherein we do not hard code the path instead it is automatically done by firebase
    //print(userData.data()!['username']);
    //print(userData.data()!['image_url']);
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 2, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                label: Text('Message'),
              ),
              // decoration: InputDecoration(
              //   labelText: 'Message',
              //   fillColor: Theme.of(context)
              //       .colorScheme
              //       .secondaryContainer
              //       .withOpacity(0.1),
              //   filled: true,
              //   border: OutlineInputBorder(
              //     borderRadius: BorderRadius.circular(50.0),
              //     borderSide: BorderSide.none,
              //   ),
              // ),
              autocorrect: true,
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            child: IconButton(
              onPressed: _submitMessage,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
    );
  }
}
