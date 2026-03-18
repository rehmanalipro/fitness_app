import 'dart:typed_data';

class UserVideoItem {
  final String id;
  final String userId;
  final String userName;
  final String userHandle;
  final String? profileImageUrl;
  final Uint8List? profileImageBytes;
  final String? videoPath;   // local file
  final String? videoUrl;    // remote url
  final String? thumbUrl;
  final String caption;
  final List<String> hashtags;
  final String timeAgo;
  int likeCount;
  int dislikeCount;
  int commentCount;
  int favoriteCount;
  bool isLiked;
  bool isDisliked;
  bool isFavorite;
  bool isFollowing;
  final bool isMine;
  final List<String> comments;

  UserVideoItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userHandle,
    this.profileImageUrl,
    this.profileImageBytes,
    this.videoPath,
    this.videoUrl,
    this.thumbUrl,
    this.caption = '',
    this.hashtags = const [],
    this.timeAgo = 'Just now',
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.favoriteCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isFavorite = false,
    this.isFollowing = false,
    this.isMine = false,
    List<String>? comments,
  }) : comments = comments ?? [];

  String get descriptionWithTags {
    final tags = hashtags
        .where((t) => t.trim().isNotEmpty)
        .map((t) => t.startsWith('#') ? t : '#$t')
        .join(' ');
    if (caption.trim().isEmpty) return tags;
    if (tags.isEmpty) return caption.trim();
    return '${caption.trim()} $tags';
  }

  String get normalizedHandle {
    final t = userHandle.trim();
    if (t.isEmpty) return '@${userName.replaceAll(' ', '_').toLowerCase()}';
    return t.startsWith('@') ? t : '@$t';
  }
}
