import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo/screens/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(), //orderBy creates an order based on timestamp of the messages
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        //Check for the condition where we do not have the data or may be have the data but the list of messages be empty
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Something went wrong ...'),
          );
        }

        //If all the checks are failed means that we have some data and hence we can render that using the Listview Builder widget which is the most optimized widget for showing a so called list of messages
        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 30,
              left: 12,
              right: 12,
            ),
            //To show the list in an opposite order
            reverse: true,
            //Total length of the message
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessages[index].data();
              //Every chat message is loaded index by index
              //To check if we are at the last message and whether the next message id from the same user or a different user using the isSame variable
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;

              final nextUserIsSame = nextMessageUserId == currentMessageUserId;

              //If the same user is going to text or a sequence of message is there
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
                //Check if the user which is logged in is the currentuser who has sent the message
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId);
              }
            }
            //=> Text(
            //   loadedMessages[index].data()['text'],
            // ),
            //The text at the specified index called by data method and the key to get it
            );
      },
    );
  }
}
