import 'package:flutter/material.dart';

import 'package:fitness_app/features/home/models/reel_item.dart';
import 'package:fitness_app/features/home/services/app_api_service.dart';
import 'package:fitness_app/layout/main_layout.dart';

class ReelsWatchScreen extends StatefulWidget {
  final List<ReelItem> items;
  final int initialIndex;

  const ReelsWatchScreen({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  State<ReelsWatchScreen> createState() => _ReelsWatchScreenState();
}

class _ReelsWatchScreenState extends State<ReelsWatchScreen> {
  final AppApiService _apiService = AppApiService();
  final Set<String> _pendingActions = <String>{};
  late final PageController _controller;
  late final List<ReelItem> _items;
  late int _index;

  @override
  void initState() {
    super.initState();
    _items = List<ReelItem>.from(widget.items);
    _index = widget.initialIndex.clamp(0, _items.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _items[_index];

    return MainLayout(
      title: 'Watch',
      currentIndex: -1,
      constrainBody: false,
      useScreenPadding: false,
      highlightCenterAdd: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemCount: _items.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                final item = _items[index];
                final followKey = '${item.userId}_follow';
                return _WatchSlide(
                  item: item,
                  isFollowLoading: _pendingActions.contains(followKey),
                  onFollowTap: () => _toggleFollow(index),
                );
              },
            ),
          ),
          Positioned(
            top: 45,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(current.profileImage),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: SizedBox(
                    width: 264,
                    height: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _WatchTabs(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 92,
            child: SizedBox(
              width: 41,
              height: 317.22,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionIcon(
                    icon: current.isLiked
                        ? Icons.thumb_up_alt
                        : Icons.thumb_up_alt_outlined,
                    label: _formatCount(current.likeCount),
                    active: current.isLiked,
                    isLoading: _pendingActions.contains('${current.id}_like'),
                    onTap: () => _toggleLike(_index),
                  ),
                  _ActionIcon(
                    icon: current.isDisliked
                        ? Icons.thumb_down_alt
                        : Icons.thumb_down_alt_outlined,
                    label: _formatCount(current.dislikeCount),
                    active: current.isDisliked,
                    isLoading: _pendingActions.contains(
                      '${current.id}_dislike',
                    ),
                    onTap: () => _toggleDislike(_index),
                  ),
                  _ActionIcon(
                    icon: current.isFavorite
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    label: _formatCount(current.favoriteCount),
                    active: current.isFavorite,
                    isLoading: _pendingActions.contains(
                      '${current.id}_favorite',
                    ),
                    onTap: () => _toggleFavorite(_index),
                  ),
                  _ActionIcon(icon: Icons.share, label: 'Share'),
                  _ActionIcon(icon: Icons.flag_outlined, label: 'Report'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final key = '${item.id}_like';
    if (_pendingActions.contains(key)) return;

    final targetLiked = !item.isLiked;
    ReelItem next = item.copyWith(
      isLiked: targetLiked,
      likeCount: _safeCount(item.likeCount, targetLiked ? 1 : -1),
    );

    if (targetLiked && item.isDisliked) {
      next = next.copyWith(
        isDisliked: false,
        dislikeCount: _safeCount(item.dislikeCount, -1),
      );
    }

    _updateItem(index, next);
    _setPending(key, true);

    try {
      final result = await _apiService.toggleReelReaction(
        reelId: item.id,
        reactionType: 'like',
        isActive: targetLiked,
      );
      if (result['ok'] != true) {
        _updateItem(index, item);
        _showActionError('Unable to update like');
        return;
      }

      if (targetLiked && item.isDisliked) {
        await _apiService.toggleReelReaction(
          reelId: item.id,
          reactionType: 'dislike',
          isActive: false,
        );
      }

      final payload = _extractPayload(result['data']);
      final resolvedLikeCount = _pickInt(payload, <String>[
        'like_count',
        'likes_count',
        'likes',
        'total_likes',
      ]);
      final resolvedIsLiked = _pickBool(payload, <String>['is_liked', 'liked']);
      _updateItem(
        index,
        _items[index].copyWith(
          likeCount: resolvedLikeCount ?? _items[index].likeCount,
          isLiked: resolvedIsLiked ?? _items[index].isLiked,
        ),
      );
    } catch (_) {
      _updateItem(index, item);
      _showActionError('Unable to connect to server');
    } finally {
      _setPending(key, false);
    }
  }

  Future<void> _toggleDislike(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final key = '${item.id}_dislike';
    if (_pendingActions.contains(key)) return;

    final targetDisliked = !item.isDisliked;
    ReelItem next = item.copyWith(
      isDisliked: targetDisliked,
      dislikeCount: _safeCount(item.dislikeCount, targetDisliked ? 1 : -1),
    );

    if (targetDisliked && item.isLiked) {
      next = next.copyWith(
        isLiked: false,
        likeCount: _safeCount(item.likeCount, -1),
      );
    }

    _updateItem(index, next);
    _setPending(key, true);

    try {
      final result = await _apiService.toggleReelReaction(
        reelId: item.id,
        reactionType: 'dislike',
        isActive: targetDisliked,
      );
      if (result['ok'] != true) {
        _updateItem(index, item);
        _showActionError('Unable to update dislike');
        return;
      }

      if (targetDisliked && item.isLiked) {
        await _apiService.toggleReelReaction(
          reelId: item.id,
          reactionType: 'like',
          isActive: false,
        );
      }

      final payload = _extractPayload(result['data']);
      final resolvedDislikeCount = _pickInt(payload, <String>[
        'dislike_count',
        'dislikes_count',
        'dislikes',
        'total_dislikes',
      ]);
      final resolvedIsDisliked = _pickBool(payload, <String>[
        'is_disliked',
        'disliked',
      ]);
      _updateItem(
        index,
        _items[index].copyWith(
          dislikeCount: resolvedDislikeCount ?? _items[index].dislikeCount,
          isDisliked: resolvedIsDisliked ?? _items[index].isDisliked,
        ),
      );
    } catch (_) {
      _updateItem(index, item);
      _showActionError('Unable to connect to server');
    } finally {
      _setPending(key, false);
    }
  }

  Future<void> _toggleFavorite(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final key = '${item.id}_favorite';
    if (_pendingActions.contains(key)) return;

    final targetFavorite = !item.isFavorite;
    _updateItem(
      index,
      item.copyWith(
        isFavorite: targetFavorite,
        favoriteCount: _safeCount(item.favoriteCount, targetFavorite ? 1 : -1),
      ),
    );
    _setPending(key, true);

    try {
      final result = await _apiService.toggleReelReaction(
        reelId: item.id,
        reactionType: 'favorite',
        isActive: targetFavorite,
      );
      if (result['ok'] != true) {
        _updateItem(index, item);
        _showActionError('Unable to update favorite');
        return;
      }

      final payload = _extractPayload(result['data']);
      final resolvedFavoriteCount = _pickInt(payload, <String>[
        'favorite_count',
        'favourite_count',
        'favorites_count',
        'favourites_count',
        'favorites',
        'favourites',
        'bookmarks',
      ]);
      final resolvedIsFavorite = _pickBool(payload, <String>[
        'is_favorite',
        'is_favourite',
        'favorite',
        'favourite',
      ]);
      _updateItem(
        index,
        _items[index].copyWith(
          favoriteCount: resolvedFavoriteCount ?? _items[index].favoriteCount,
          isFavorite: resolvedIsFavorite ?? _items[index].isFavorite,
        ),
      );
    } catch (_) {
      _updateItem(index, item);
      _showActionError('Unable to connect to server');
    } finally {
      _setPending(key, false);
    }
  }

  Future<void> _toggleFollow(int index) async {
    if (index < 0 || index >= _items.length) return;
    final item = _items[index];
    final key = '${item.userId}_follow';
    if (_pendingActions.contains(key)) return;

    final shouldFollow = !item.isFollowing;
    _updateItem(
      index,
      item.copyWith(
        isFollowing: shouldFollow,
        creatorFollowerCount: _safeCount(
          item.creatorFollowerCount,
          shouldFollow ? 1 : -1,
        ),
        viewerFollowingCount: _safeCount(
          item.viewerFollowingCount,
          shouldFollow ? 1 : -1,
        ),
      ),
    );
    _setPending(key, true);

    try {
      final result = await _apiService.followUser(
        userId: item.userId,
        follow: shouldFollow,
      );
      if (result['ok'] != true) {
        _updateItem(index, item);
        _showActionError('Unable to update follow');
        return;
      }

      final payload = _extractPayload(result['data']);
      final resolvedFollowing = _pickBool(payload, <String>[
        'is_following',
        'following',
      ]);
      final creatorFollowerCount = _pickInt(payload, <String>[
        'creator_follower_count',
        'follower_count',
        'followers',
      ]);
      final viewerFollowingCount = _pickInt(payload, <String>[
        'viewer_following_count',
        'my_following_count',
        'following_count',
      ]);
      _updateItem(
        index,
        _items[index].copyWith(
          isFollowing: resolvedFollowing ?? _items[index].isFollowing,
          creatorFollowerCount:
              creatorFollowerCount ?? _items[index].creatorFollowerCount,
          viewerFollowingCount:
              viewerFollowingCount ?? _items[index].viewerFollowingCount,
        ),
      );
    } catch (_) {
      _updateItem(index, item);
      _showActionError('Unable to connect to server');
    } finally {
      _setPending(key, false);
    }
  }

  void _updateItem(int index, ReelItem item) {
    if (!mounted || index < 0 || index >= _items.length) return;
    setState(() => _items[index] = item);
  }

  void _setPending(String key, bool value) {
    if (!mounted) return;
    setState(() {
      if (value) {
        _pendingActions.add(key);
      } else {
        _pendingActions.remove(key);
      }
    });
  }

  int _safeCount(int current, int delta) {
    return (current + delta).clamp(0, 1 << 31);
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      final shortened = (value / 1000000).toStringAsFixed(
        value % 1000000 == 0 ? 0 : 1,
      );
      return '${shortened}M';
    }
    if (value >= 1000) {
      final shortened = (value / 1000).toStringAsFixed(
        value % 1000 == 0 ? 0 : 1,
      );
      return '${shortened}K';
    }
    return '$value';
  }

  Map<String, dynamic> _extractPayload(dynamic raw) {
    if (raw is! Map<String, dynamic>) return <String, dynamic>{};
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) return nested;
    return raw;
  }

  int? _pickInt(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  bool? _pickBool(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
    }
    return null;
  }

  void _showActionError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WatchSlide extends StatelessWidget {
  final ReelItem item;
  final VoidCallback onFollowTap;
  final bool isFollowLoading;

  const _WatchSlide({
    required this.item,
    required this.onFollowTap,
    required this.isFollowLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.previewImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.black87),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22000000), Color(0x88000000)],
            ),
          ),
        ),
        Positioned(
          left: 14,
          bottom: 72,
          child: SizedBox(
            width: 332,
            height: 78,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage(item.profileImage),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.normalizedHandle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: isFollowLoading ? null : onFollowTap,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(82, 30),
                        side: BorderSide(
                          color: item.isFollowing
                              ? const Color(0x80FFFFFF)
                              : Colors.white,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: Text(
                        item.isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.descriptionWithTags,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WatchTabs extends StatelessWidget {
  const _WatchTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0x4D000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explore',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            'Following',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            'For You',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool isLoading;

  const _ActionIcon({
    required this.icon,
    required this.label,
    this.onTap,
    this.active = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? const Color(0xFFFF4D6D) : Colors.white;
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
