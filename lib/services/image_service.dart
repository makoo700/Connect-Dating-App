import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Method to pick image from gallery
  static Future<String?> pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImagePermanently(image);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      _showErrorDialog(context, 'Failed to pick image from gallery');
      return null;
    }
  }

  // Method to take image from camera
  static Future<String?> pickImageFromCamera(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImagePermanently(image);
      }
      return null;
    } catch (e) {
      print('Error taking image with camera: $e');
      _showErrorDialog(context, 'Failed to take image with camera');
      return null;
    }
  }

  // Also update any internal references to the method
  // Method to save image permanently
  static Future<String> _saveImagePermanently(XFile image) async {
    return await saveImagePermanently(image);
  }

  // Change the private _saveImagePermanently method to public by removing the underscore
  // Method to save image permanently
  static Future<String> saveImagePermanently(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final savedImage = await File(image.path).copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  // Method to show image source dialog
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    String? imagePath;

    await showDialog(
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
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImageFromGallery(context).then((value) {
                      imagePath = value;
                    });
                  },
                ),
                GestureDetector(
                  child: ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Camera'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImageFromCamera(context).then((value) {
                      imagePath = value;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    return imagePath;
  }

  // Method to check for lost data
  static Future<List<XFile>?> retrieveLostData(BuildContext context) async {
    try {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) {
        return null;
      }

      if (response.files != null) {
        return response.files;
      } else if (response.file != null) {
        return [response.file!];
      } else {
        _showErrorDialog(context, response.exception?.message ?? 'Unknown error occurred');
        return null;
      }
    } catch (e) {
      print('Error retrieving lost data: $e');
      return null;
    }
  }

  // Helper method to show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
