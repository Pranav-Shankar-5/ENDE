import 'package:convo/screens/auth.dart';
import 'package:convo/screens/chat.dart';
import 'package:convo/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 220, 248, 198),
  //error: const Color.fromARGB(255, 255, 0, 0), //If not specified then default
);
//Defining a global colorScheme to be applied on all the widgets
//Instead of themeing each widget we globally select a color scheme to be applied across all the widgets

var kDarkColorScheme = ColorScheme.fromSeed(
  //It is optimized for light mode for telling that it should be optimized for dark mode we should set the brightness parameter
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 7, 94, 84),
  //error: const Color.fromARGB(255, 255, 0, 0),
  error: kColorScheme.error,
);
//Defining different color seed for dark mode

void main() async {
  //To not stuck on the main screen we should bind the dependencies and ensure initialization
  //This line is required for using the firebase
  WidgetsFlutterBinding.ensureInitialized();
  //Let the app to initailize through Firebase on the currentPlatform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convo',
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        useMaterial3: true,
      ),
      //Configuring color shades for dark mode
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        useMaterial3: true,
      ),
      //Note that somewhere it is copyWith while somewhere it is styleFrom method used
      themeMode: ThemeMode.system, //Set by default as well

      //The home widget needs to be set based on the authentication token received by the firebase.
      //If the user has logged in recently we need to direct user to the chats screen and if the user has a expired or no authentication token then to the auth screen
      //This checking can be done through the Firebase.instance.
      //Similar to FutureBuilder which listened to the future and then based on state rendered widgets through any one action or returned null we have another widget which the stream builder which based on the
      //given instances perform certain tasks or performing multiple values at a time such as switching between the screen
      //So the StreamBuilder function will be called when ever the stream parameter FirebaseAuth.instance.authStateChanges() will emit a new value and we get the snapshot of the data through Firebase
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            //If we are in a waiting state, waiting for the firebase to authenticate the user instead of showing the auth screen temporarily we will show the splash screen for that waiting duration
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Splashscreen();
            }
            //If firebase emits any data, that means that we have a data/token and the user is already logged in hence the chatscreen or else the auth screen
            if (snapshot.hasData) {
              return const ChatScreen();
            }
            return const AuthScreen();
          }),
    );
  }
}

//Instead of setting up an entire Theme from scratch, it's often better to copy an existing Theme and then just style individual aspects of that Theme.
