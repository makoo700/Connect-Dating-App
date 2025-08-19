import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerWrapper {
  static Future<String?> pickImage(BuildContext context, {ImageSource source = ImageSource.gallery}) async {
    try {
      // Pick image with reduced quality to avoid memory issues
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        // Get app directory to save the image
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(image.path);
        final savedImage = await File(image.path).copy('${directory.path}/$fileName');

        return savedImage.path;
      }

      return null;
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  static Future<String?> pickImageFromCamera(BuildContext context) async {
    return await pickImage(context, source: ImageSource.camera);
  }

  static Future<String?> pickImageFromGallery(BuildContext context) async {
    return await pickImage(context, source: ImageSource.gallery);
  }

  static void showImageSourceDialog(BuildContext context, Function(String?) onImageSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gallery'),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final imagePath = await pickImageFromGallery(context);
                    onImageSelected(imagePath);
                  },
                ),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Camera'),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final imagePath = await pickImageFromCamera(context);
                    onImageSelected(imagePath);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
