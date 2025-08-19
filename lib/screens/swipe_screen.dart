import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dating_app/services/auth_service.dart';
import 'package:flutter_dating_app/services/match_service.dart';
import 'package:flutter_dating_app/models/user.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_dating_app/screens/chat_screen.dart';

class SwipeScreen extends StatefulWidget {
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final MatchService _matchService = MatchService();
  final CardSwiperController _cardController = CardSwiperController();

  List<User> _potentialMatches = [];
  bool _isLoading = true;
  bool _isMatched = false;
  User? _matchedUser;

  @override
  void initState() {
    super.initState();
    _loadPotentialMatches();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPotentialMatches();
  }

  Future<void> _loadPotentialMatches() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser =
        Provider.of<AuthService>(context, listen: false).currentUser;
    if (currentUser != null) {
      final matches = await _matchService.getPotentialMatches(currentUser);
      setState(() {
        _potentialMatches = matches;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSwipe(int index, CardSwiperDirection direction) {
    if (index >= _potentialMatches.length) return;

    final currentUser =
        Provider.of<AuthService>(context, listen: false).currentUser;
    if (currentUser == null) return;

    final potentialMatch = _potentialMatches[index];

    if (direction == CardSwiperDirection.right) {
      // User liked the profile
      _matchService
          .likeUser(currentUser.id!, potentialMatch.id!)
          .then((isMatch) {
        // Show a SnackBar for every like
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You liked this profile'),
            duration: Duration(seconds: 1),
          ),
        );
        if (isMatch) {
          setState(() {
            _isMatched = true;
            _matchedUser = potentialMatch;
          });
        }
      });
      // Remove the card immediately after like
      setState(() {
        _potentialMatches.removeAt(index);
      });
    } else if (direction == CardSwiperDirection.left) {
      // User disliked the profile
      _matchService.dislikeUser(currentUser.id!, potentialMatch.id!);
      // Remove the card immediately after dislike
      setState(() {
        _potentialMatches.removeAt(index);
      });
    }
  }

  void _closeMatchDialog() {
    setState(() {
      _isMatched = false;
      _matchedUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_potentialMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No more profiles to show',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new matches',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _loadPotentialMatches();
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Calculate the number of cards to display (minimum of 3 and available cards)
    final int cardsToDisplay = _potentialMatches.length > 0 ? 1 : 0;

    return Stack(
      children: [
        // Swipe Cards
        Padding(
          padding: EdgeInsets.all(16),
          child: CardSwiper(
            controller: _cardController,
            cardsCount: _potentialMatches.length,
            numberOfCardsDisplayed: cardsToDisplay,
            onSwipe: (int previousIndex, int? currentIndex,
                CardSwiperDirection direction) {
              _handleSwipe(previousIndex, direction);
              return true; // Allow the swipe
            },
            padding: EdgeInsets.all(24),
            cardBuilder: (context, index, _, __) {
              final user = _potentialMatches[index];
              return ProfileCard(user: user);
            },
          ),
        ),

        // Action Buttons
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Dislike Button
              FloatingActionButton(
                heroTag: 'dislike',
                onPressed: () {
                  _cardController.swipeLeft();
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 30,
                ),
              ),

              // Like Button
              FloatingActionButton(
                heroTag: 'like',
                onPressed: () {
                  _cardController.swipeRight();
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.favorite,
                  color: Color(0xFFFF4B91),
                  size: 30,
                ),
              ),
            ],
          ),
        ),

        // Match Dialog
        if (_isMatched)
          MatchDialog(
            matchedUser: _matchedUser!,
            onClose: _closeMatchDialog,
          ),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  final User user;

  const ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Colors.grey.shade300,
                image: DecorationImage(
                  image: user.profileImagePath != null
                      ? FileImage(File(user.profileImagePath!))
                      : AssetImage('assets/default_profile.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Profile Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Age
                  Row(
                    children: [
                      Text(
                        '${user.name}, ${user.age}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        user.gender == 'Male' ? Icons.male : Icons.female,
                        color: user.gender == 'Male'
                            ? Colors.blue
                            : Color(0xFFFF4B91),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Bio
                  Text(
                    user.bio,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),

                  // Interests
                  Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.interests.map((interest) {
                      return Chip(
                        label: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Color(0xFFFF4B91),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MatchDialog extends StatelessWidget {
  final User matchedUser;
  final VoidCallback onClose;

  const MatchDialog({
    required this.matchedUser,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Match Text
            Text(
              'It\'s a Match!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),

            // Match Description
            Text(
              'You and ${matchedUser.name} liked each other',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32),

            // Profile Images
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Current User Image
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage: AssetImage('assets/default_profile.png'),
                  ),
                ),
                SizedBox(width: 16),

                // Matched User Image
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundImage: matchedUser.profileImagePath != null
                        ? FileImage(File(matchedUser.profileImagePath!))
                        : AssetImage('assets/default_profile.png')
                            as ImageProvider,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Send Message Button
            ElevatedButton(
              onPressed: () {
                // Navigate to chat screen
                onClose();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      userId: matchedUser.id!,
                      userName: matchedUser.name,
                    ),
                  ),
                );
              },
              child: Text('Send Message'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 16),

            // Keep Swiping Button
            TextButton(
              onPressed: onClose,
              child: Text(
                'Keep Swiping',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
