import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dating_app/services/auth_service.dart';
import 'dart:io';
import 'package:flutter_dating_app/services/image_service.dart';
import 'package:flutter_dating_app/services/gallery_service.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> _galleryImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  Future<void> _loadGalleryImages() async {
    setState(() {
      _isLoading = true;
    });

    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final images = await GalleryService.getUserImages(user.id!);

      setState(() {
        _galleryImages = images;
        _isLoading = false;
      });
    } else {
      setState(() {
        _galleryImages = ['assets/default_profile.png'];
        _isLoading = false;
      });
    }
  }

  Future<void> _addImage() async {
    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) return;

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
                      final imagePath =
                          await ImageService.pickImageFromGallery(context);
                      if (imagePath != null) {
                        // Save to user's gallery
                        final savedPath =
                            await GalleryService.saveImageToUserGallery(
                          user.id!,
                          File(imagePath),
                        );

                        if (savedPath != null) {
                          setState(() {
                            _galleryImages.add(savedPath);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Image added to gallery'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('Camera'),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final imagePath =
                          await ImageService.pickImageFromCamera(context);
                      if (imagePath != null) {
                        // Save to user's gallery
                        final savedPath =
                            await GalleryService.saveImageToUserGallery(
                          user.id!,
                          File(imagePath),
                        );

                        if (savedPath != null) {
                          setState(() {
                            _galleryImages.add(savedPath);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Image added to gallery'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error showing image source dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open image picker'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewImage(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              '${index + 1} / ${_galleryImages.length}',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  Navigator.pop(context);
                  _deleteImage(index);
                },
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image(
                  image: _galleryImages[index].startsWith('assets/')
                      ? AssetImage(_galleryImages[index]) as ImageProvider
                      : FileImage(File(_galleryImages[index])),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteImage(int index) {
    if (_galleryImages[index].startsWith('assets/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot delete default image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Image'),
        content: Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Delete the file
                final file = File(_galleryImages[index]);
                if (await file.exists()) {
                  await file.delete();
                }

                setState(() {
                  _galleryImages.removeAt(index);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Image deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error deleting image: $e');
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete image'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _galleryImages.length + 1, // +1 for the add button
        itemBuilder: (context, index) {
          if (index == _galleryImages.length) {
            // Add button
            return GestureDetector(
              onTap: _addImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF1E88E5), // Changed from pink to blue
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: Color(0xFF1E88E5), // Changed from pink to blue
                  ),
                ),
              ),
            );
          } else {
            // Gallery image
            return GestureDetector(
              onTap: () => _viewImage(index),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: _galleryImages[index].startsWith('assets/')
                        ? AssetImage(_galleryImages[index]) as ImageProvider
                        : FileImage(File(_galleryImages[index])),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        backgroundColor: Color(0xFF1E88E5), // Changed from pink to blue
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
