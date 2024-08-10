import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convo/screens/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;
//Create a global instance of the FirebaseAuth class to use it wherever the firebase is required and the concerning methods can be called upon them

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  //Global key with the FormState instance so as to connect it when we submit the form and save the input value

  var _enteredUsername = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isLogin = true;
  File? _selectedImage;

  var _isAuthenticating = false;

  void _submit() async {
    //The ! mark is to tell dart that if the elevated button is available the form will also be available
    final isValid = _form.currentState!.validate();

    //If we have invalid input or in login mode and selectedimage is null we can show a error
    if (!isValid) {
      return;
    }

    if (!_isLogin && _selectedImage == null) {
      //Use the builtin showDialog method to show a popup of information
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Select Image'),
          content: const Text('Please select an Image as Profile picture.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }
    //If the inputs are valid we can now state the currentState as save to trigger the onSave parameters of the TextFormField inputs
    _form.currentState!.save();

    //Check if we are in LogIn or SignUp mode
    //Since the methoda of firebase instances returns a Future object which later is resolved to User credential we can use the async and await keyword
    //Also since the method may throw a FirebaseAuthException we wrap this thing in try on catch block to handle the exception
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        //Login users
        final userCredential = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        print(userCredential);
        print('LogIn successful');
      } else {
        //SignUp users with email and Password which behind the scene is a HTTP request sent by the firebase automatically
        final userCredential = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        print(userCredential);
        print('SignUp successful');

        //Firebase can not store the image on the go with email and password we first need to create the user and then upload the image at the storage
        //Use the ref() to get an snapshot of your firebase storage and use chlid to dive into the folder / or create one if not created already
        //We are saving the image based on the userCredentials and more specifically the uid parameter which is unique and can be identified easily.
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        //Wait for the _selectedImage to be uploaded on the firebase and then fetch the URL to then show the image in the future.
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl);

        //Saving the user details along with imagedownloadurl, email, password and username through the FirebaseFirestore class
        //The instace provides the collection, so called folders wherein we can store the details in a Document format based on the users unique id
        //Upon that we have the set method which takes key value paired maps as input to be stored in the database, followed by the waiting using await keyboard
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
      //Catch the errors from both login and signup modes
    } on FirebaseAuthException catch (error) {
      //We can show a Snackbar if it returns an error
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //Directly show the error message of if it is null and some other problem has occurred simply show failed message
          content: Text(
            error.message ?? 'Authentication Failed.',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      );
      //If we got the error we can now change the _isauthenticating parameter otherwise the user may be stuck and can not perform the login process by changing the credentials
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Since we want to display a image we are using the container widget, which is the most optimized widget for rendering image
              Container(
                margin: const EdgeInsets.all(0.5),
                width: 500,
                child: Image.asset(
                  'assets/images/chat.png',
                ),
              ),

              //To give the form a more professional look we use card widget
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //Conditionally show the Image Picker widget if we are in the SignUp mode
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                icon: Icon(Icons.person_outlined),
                              ),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Username must be atleast 4 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email ID',
                              icon: Icon(Icons.email_outlined),
                            ),
                            //Optimized for Email address input
                            keyboardType: TextInputType.emailAddress,
                            //Since an email address
                            autocorrect: false,
                            //Turn off auto capitalization
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Please enter a valid Email.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              icon: Icon(Icons.password_sharp),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be atleast 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                            ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                foregroundColor: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color.fromARGB(255, 235, 235, 235)
                                    : const Color.fromARGB(255, 0, 0, 0),
                              ),
                              child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
