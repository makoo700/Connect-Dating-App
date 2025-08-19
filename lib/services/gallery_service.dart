import 'package:flutter_dating_app/db/database_helper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class GalleryService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all images for a user
  static Future<List<String>> getUserImages(int userId) async {
    try {
      // In a real app, you would fetch this from a database table
      // For now, we'll simulate it by checking if the user has a profile image
      // and adding some placeholder images

      final user = await _dbHelper.getUserById(userId);
      List<String> images = [];

      if (user != null && user.profileImagePath != null && !user.profileImagePath!.startsWith('assets/')) {
        images.add(user.profileImagePath!);
      }

      // Get app directory to look for user images
      final directory = await getApplicationDocumentsDirectory();
      final userImagesDir = Directory('${directory.path}/user_$userId');

      // Check if directory exists
      if (await userImagesDir.exists()) {
        // List all files in the directory
        final files = await userImagesDir.list().toList();

        // Filter for image files
        for (var file in files) {
          if (file is File) {
            final extension = path.extension(file.path).toLowerCase();
            if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
              images.add(file.path);
            }
          }
        }
      }

      // If no images found, add default profile image
      if (images.isEmpty) {
        images.add('assets/default_profile.png');
      }

      return images;
    } catch (e) {
      print('Error getting user images: $e');
      return ['assets/default_profile.png'];
    }
  }

  // Save an image to a user's gallery
  static Future<String?> saveImageToUserGallery(int userId, File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final userImagesDir = Directory('${directory.path}/user_$userId');

      // Create directory if it doesn't exist
      if (!await userImagesDir.exists()) {
        await userImagesDir.create(recursive: true);
      }

      // Generate unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final savedImage = await imageFile.copy('${userImagesDir.path}/$fileName');

      return savedImage.path;
    } catch (e) {
      print('Error saving image to user gallery: $e');
      return null;
    }
  }
}
