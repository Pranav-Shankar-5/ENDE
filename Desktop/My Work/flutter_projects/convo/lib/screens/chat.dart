import 'package:convo/screens/widgets/chat_messages.dart';
import 'package:convo/screens/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //To show notifications we take prior permission from the user in the below initstate method
  //Also the chat screen is the most suited widget for implemenatation of push notification logic as only authenticated user would have reached the chat screen and hence the right position to ask for permission

  //This is a helper method as the fcm.requestpermissin returns a Future object and init is not recommended to be used as async
  void setupPushNotifications() async {
    //Instance of CLoud Messaging
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    //Approach 1 of sending the notification
    //Address of the device on which the app is running, used to then process notification from cloud
    //This token could also be sent to a backend via HTTP or Firestore SDK
    final token = await fcm.getToken();
    print(token);

    //Approach 2
    //Below function is kind of a broadcast channel which will send notifications to all the subscribed device
    fcm.subscribeToTopic('chat');

    //However in both the cases we need to use the Functions property of the firebase and modify the index.js code over there to trigger a notification from backend if any message is received.
  }

  @override
  void initState() {
    super.initState();

    //Call setup notification
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ConVo',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //We need to sign out the user on pressing this button
              FirebaseAuth.instance.signOut();
              //This we emit a stream to the stream builder widget and hence the if block is checked and failed and that is where the auth screen is shown again
            },
            icon: const Icon(Icons.logout),
            //color: Theme.of(context).colorScheme.primary,
            highlightColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image or color
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Theme.of(context).brightness == Brightness.light
                    ? const AssetImage('assets/images/background_light.jpeg')
                    : const AssetImage(
                        'assets/images/background_dark.jpeg'), // Add your background image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          const Column(
            children: [
              Expanded(
                child: ChatMessages(),
              ),
              NewMessage(),
            ],
          ),
        ],
      ),
    );
  }
}
