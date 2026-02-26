import 'dart:typed_data';
import 'package:get/get.dart';

class ChallengePost {
  final String id;
  final String author;
  final String timeAgo;
  final String title;
  final String target;
  final String category;
  final String fitnessLevel;
  final String description;
  final bool isMine;
  final String? avatarUrl;
  final Uint8List? imageBytes;
  int likes;
  bool isLiked;
  bool isDisliked;
  bool accepted;
  final List<String> replies;

  ChallengePost({
    required this.id,
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.target,
    required this.category,
    required this.fitnessLevel,
    required this.description,
    required this.isMine,
    this.avatarUrl,
    this.imageBytes,
    required this.likes,
    this.isLiked = false,
    this.isDisliked = false,
    required this.accepted,
    required this.replies,
  });
}

class ChallengesFeedController extends GetxController {
  int _counter = 3;

  final List<ChallengePost> _publicPosts = [
    ChallengePost(
      id: 'public_1',
      author: 'Maude Hall',
      timeAgo: '14 min',
      title: 'Push-Up Challenge',
      target: 'Do 100 push-ups in 1 minute',
      category: 'Medium',
      fitnessLevel: 'Beginner',
      description:
          'Do 100 push-ups with proper form in under one minute. Keep your core tight and elbows controlled.',
      isMine: false,
      avatarUrl: 'https://i.pravatar.cc/120?img=24',
      likes: 2,
      accepted: false,
      replies: [],
    ),
    ChallengePost(
      id: 'public_2',
      author: 'Chris Fox',
      timeAgo: '8 min',
      title: 'Plank Hold Challenge',
      target: 'Hold plank for 3 minutes',
      category: 'Medium',
      fitnessLevel: 'Intermediate',
      description:
          'Maintain a straight body line from head to heels and hold a forearm plank for three minutes.',
      isMine: false,
      avatarUrl: 'https://i.pravatar.cc/120?img=12',
      likes: 4,
      accepted: false,
      replies: [],
    ),
  ];

  final List<ChallengePost> _myPosts = [];

  List<ChallengePost> get publicPosts => List.unmodifiable(_publicPosts);
  List<ChallengePost> get myPosts => List.unmodifiable(_myPosts);

  ChallengePost? findById(String id) {
    for (final post in [..._myPosts, ..._publicPosts]) {
      if (post.id == id) return post;
    }
    return null;
  }

  void addMyPost({
    required String title,
    required String target,
    required String category,
    required String fitnessLevel,
    required String description,
    Uint8List? imageBytes,
  }) {
    _counter += 1;
    _myPosts.insert(
      0,
      ChallengePost(
        id: 'my_$_counter',
        author: 'You',
        timeAgo: 'Just now',
        title: title,
        target: target,
        category: category,
        fitnessLevel: fitnessLevel,
        description: description,
        isMine: true,
        imageBytes: imageBytes,
        likes: 0,
        accepted: false,
        replies: [],
      ),
    );
    update();
  }

  void likePost(String id) {
    final post = findById(id);
    if (post == null) return;
    if (post.isLiked) {
      post.isLiked = false;
      if (post.likes > 0) post.likes -= 1;
    } else {
      post.isLiked = true;
      post.likes += 1;
      if (post.isDisliked) {
        post.isDisliked = false;
      }
    }
    update();
  }

  void dislikePost(String id) {
    final post = findById(id);
    if (post == null) return;
    if (post.isDisliked) {
      post.isDisliked = false;
    } else {
      post.isDisliked = true;
      if (post.isLiked) {
        post.isLiked = false;
        if (post.likes > 0) post.likes -= 1;
      }
    }
    update();
  }

  void acceptPost(String id) {
    final post = findById(id);
    if (post == null) return;
    post.accepted = true;
    update();
  }

  void addReply(String id, String reply) {
    final trimmed = reply.trim();
    if (trimmed.isEmpty) return;

    final post = findById(id);
    if (post == null) return;
    post.replies.add(trimmed);
    update();
  }
}
