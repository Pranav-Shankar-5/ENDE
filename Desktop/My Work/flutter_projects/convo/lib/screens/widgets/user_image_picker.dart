import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  //A function recieved from auth screen to transfer the pickedImage to the firebase
  final void Function(File pickedImage) onPickImage;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile; //The final file that is picked
  //The below is the method to pick image from the ImagePicker package

  //Preloading the no user image
  final ImageProvider _defaultImage =
      const AssetImage('assets/images/no_user.png');

  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxHeight: 300,
      maxWidth: 300,
    );

    //The user may not select anything so in that case we do not update the UI.
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    //Execute the onPickImage function which we receive from auth screen
    widget.onPickImage(_pickedImageFile!);
  }

  //The Image Picker Dialod to be opened upon image upload press
  void _showPickerDialog() {
    //A optimized BottomSheet to select/capture the image
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  //Pick image from Gallery
                  _pickImage(ImageSource.gallery);
                  //Return Back to the screen
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  //Capture Image
                  _pickImage(ImageSource.camera);
                  //Return Back to the screen
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //Below is a widget for picking up the image and showing the selected image as profile using the CircleAvatar widget
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: _defaultImage,
          foregroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : _defaultImage,
          //foregroundImage: _pickedImageFile != null ? FileImage(_pickedImageFile!) : const AssetImage('assets/images/no_user.jpg') as ImageProvider<Object>,
        ),
        TextButton.icon(
          onPressed: _showPickerDialog,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
      ],
    );
  }
}
