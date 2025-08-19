import 'package:flutter_dating_app/db/database_helper.dart';
import 'package:flutter_dating_app/models/user.dart';
import 'package:flutter_dating_app/models/match.dart';

class MatchService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get potential matches for a user
  Future<List<User>> getPotentialMatches(User currentUser) async {
    // Get all users
    List<User> allUsers = await _dbHelper.getAllUsers();

    // Filter out current user and already matched users
    List<Match> existingMatches =
        await _dbHelper.getMatchesForUser(currentUser.id!);
    List<int> matchedUserIds =
        existingMatches.map((m) => m.matchedUserId).toList();

    // Filter users based on preferences (age, gender)
    List<User> filteredUsers = allUsers.where((user) {
      // Skip current user
      if (user.id == currentUser.id) return false;

      // Skip already matched users
      if (matchedUserIds.contains(user.id)) return false;

      // Filter by gender preference (simplified for demo)
      // In a real app, you would have a preference setting
      bool genderMatch = true;
      if (currentUser.gender == 'Male') {
        genderMatch = user.gender == 'Female';
      } else if (currentUser.gender == 'Female') {
        genderMatch = user.gender == 'Male';
      }

      // Filter by age (simplified for demo)
      // In a real app, you would have age range preferences
      bool ageMatch = (user.age >= currentUser.age - 5) &&
          (user.age <= currentUser.age + 5);

      return genderMatch && ageMatch;
    }).toList();

    // Calculate match scores and create new user objects with scores
    List<User> usersWithScores = [];
    for (var user in filteredUsers) {
      int score =
          await _dbHelper.calculateMatchScore(currentUser.id!, user.id!);
      usersWithScores.add(user.copyWith(matchScore: score));
    }

    // Sort by match score (highest first)
    usersWithScores
        .sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));

    return usersWithScores;
  }

  // Like a user
  Future<bool> likeUser(int currentUserId, int likedUserId) async {
    try {
      // Calculate match score
      int score = await _dbHelper.calculateMatchScore(currentUserId, likedUserId);

      // Create or update match with isLiked = true
      Match newMatch = Match(
        userId: currentUserId,
        matchedUserId: likedUserId,
        matchScore: score,
        isLiked: true,
        createdAt: DateTime.now(),
      );
      await _dbHelper.insertMatch(newMatch);

      // Check if the other user has liked current user
      List<Match> otherUserMatches =
          await _dbHelper.getMatchesForUser(likedUserId);
      Match? otherUserMatch = otherUserMatches.firstWhere(
        (m) => m.matchedUserId == currentUserId && m.isLiked,
        orElse: () => null as Match,
      );

      if (otherUserMatch != null) {
        // It's a mutual match! Update both records
        // Update current user's match
        List<Match> currentUserMatches =
            await _dbHelper.getMatchesForUser(currentUserId);
        Match currentUserMatch = currentUserMatches.firstWhere(
          (m) => m.matchedUserId == likedUserId,
        );

        Match updatedCurrentUserMatch = currentUserMatch.copyWith(
          isMatched: true,
        );
        await _dbHelper.updateMatch(updatedCurrentUserMatch);

        // Update other user's match
        Match updatedOtherUserMatch = otherUserMatch.copyWith(
          isMatched: true,
        );
        await _dbHelper.updateMatch(updatedOtherUserMatch);

        return true; // Indicates a mutual match
      }

      return false; // No mutual match yet
    } catch (e) {
      print('Like user error: $e');
      return false;
    }
  }

  // Dislike a user
  Future<void> dislikeUser(int currentUserId, int dislikedUserId) async {
    try {
      // Calculate match score
      int score = await _dbHelper.calculateMatchScore(currentUserId, dislikedUserId);

      // Create or update match with isLiked = false
      Match newMatch = Match(
        userId: currentUserId,
        matchedUserId: dislikedUserId,
        matchScore: score,
        isLiked: false,
        createdAt: DateTime.now(),
      );
      await _dbHelper.insertMatch(newMatch);
    } catch (e) {
      print('Dislike user error: $e');
    }
  }

  // Get all matched users
  Future<List<User>> getMatches(int userId) async {
    return await _dbHelper.getMatchedUsers(userId);
  }

  // Get all liked users (not just mutual matches)
  Future<List<User>> getLikedUsers(int userId) async {
    return await _dbHelper.getLikedUsers(userId);
  }
}
