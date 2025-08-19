import 'package:flutter/material.dart';
import 'package:flutter_dating_app/models/user.dart';
import 'package:flutter_dating_app/screens/chat_screen.dart';
import 'package:flutter_dating_app/services/gallery_service.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({required this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _currentImageIndex = 0;
  List<String> _galleryImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserImages();
  }

  Future<void> _loadUserImages() async {
    setState(() {
      _isLoading = true;
    });

    // Get all images for this user
    final images = await GalleryService.getUserImages(widget.user.id!);

    setState(() {
      _galleryImages = images;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
        backgroundColor: Color(0xFF1E88E5), // Changed from pink to blue
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Image Gallery
                  Container(
                    height: 400,
                    child: Stack(
                      children: [
                        // Main Image
                        PageView.builder(
                          itemCount: _galleryImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Show full screen image view
                                _showFullScreenImage(index);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  image: DecorationImage(
                                    image: _galleryImages[index]
                                            .startsWith('assets/')
                                        ? AssetImage(_galleryImages[index])
                                            as ImageProvider
                                        : FileImage(
                                            File(_galleryImages[index])),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Image Indicators
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _galleryImages.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImageIndex == index
                                      ? Color(
                                          0xFF1E88E5) // Changed from pink to blue
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Info
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Age
                        Row(
                          children: [
                            Text(
                              '${widget.user.name}, ${widget.user.age}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              widget.user.gender == 'Male'
                                  ? Icons.male
                                  : Icons.female,
                              color: widget.user.gender == 'Male'
                                  ? Colors.blue
                                  : Color(
                                      0xFF1E88E5), // Changed from pink to blue
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Bio
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.user.bio,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Interests
                        Text(
                          'Interests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.user.interests.map((interest) {
                            return Chip(
                              label: Text(
                                interest,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Color(
                                  0xFF1E88E5), // Changed from pink to blue
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 24),

                        // Message Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    userId: widget.user.id!,
                                    userName: widget.user.name,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.chat),
                            label: Text('Send Message'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showFullScreenImage(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              '${initialIndex + 1} / ${_galleryImages.length}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Center(
              child: PageView.builder(
                itemCount: _galleryImages.length,
                controller: PageController(initialPage: initialIndex),
                onPageChanged: (index) {
                  // Update the app bar title
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${index + 1} / ${_galleryImages.length}'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Image(
                      image: _galleryImages[index].startsWith('assets/')
                          ? AssetImage(_galleryImages[index]) as ImageProvider
                          : FileImage(File(_galleryImages[index])),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
