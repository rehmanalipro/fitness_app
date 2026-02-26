import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserMediaItem {
  final String id;
  final Uint8List? bytes;
  final String? imageUrl;
  bool isLiked;

  UserMediaItem({
    required this.id,
    this.bytes,
    this.imageUrl,
    this.isLiked = false,
  });
}

class HomeProfileController extends GetxController {
  final RxString displayName = 'Mentisa Mayo'.obs;
  final RxString userName = '@mentisa_fit'.obs;
  final RxString bio = 'Tap edit profile to add your bio'.obs;
  final Rxn<Uint8List> avatarBytes = Rxn<Uint8List>();
  final RxInt followingCount = 14.obs;
  final RxInt followerCount = 38.obs;

  final RxList<UserMediaItem> mediaItems = <UserMediaItem>[
    UserMediaItem(
      id: 'm1',
      imageUrl:
          'https://images.pexels.com/photos/1544376/pexels-photo-1544376.jpeg',
    ),
    UserMediaItem(
      id: 'm2',
      imageUrl:
          'https://images.pexels.com/photos/1884574/pexels-photo-1884574.jpeg',
      isLiked: true,
    ),
    UserMediaItem(
      id: 'm3',
      imageUrl:
          'https://images.pexels.com/photos/1552106/pexels-photo-1552106.jpeg',
    ),
    UserMediaItem(
      id: 'm4',
      imageUrl: 'https://images.pexels.com/photos/34950/pexels-photo.jpg',
      isLiked: true,
    ),
  ].obs;

  void setDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    displayName.value = trimmed;
  }

  void setAvatarBytes(Uint8List bytes) {
    avatarBytes.value = bytes;
  }

  void setProfile({
    required String name,
    required String username,
    required String userBio,
    Uint8List? avatar,
  }) {
    final trimmedName = name.trim();
    final trimmedUsername = username.trim();
    final trimmedBio = userBio.trim();

    if (trimmedName.isNotEmpty) displayName.value = trimmedName;
    if (trimmedUsername.isNotEmpty) {
      userName.value = trimmedUsername.startsWith('@')
          ? trimmedUsername
          : '@$trimmedUsername';
    }
    bio.value = trimmedBio.isEmpty
        ? 'Tap edit profile to add your bio'
        : trimmedBio;
    if (avatar != null) avatarBytes.value = avatar;
  }

  void addMedia(Uint8List bytes) {
    final id =
        'local_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    mediaItems.insert(0, UserMediaItem(id: id, bytes: bytes));
  }

  void toggleLike(String id) {
    final index = mediaItems.indexWhere((item) => item.id == id);
    if (index == -1) return;
    mediaItems[index].isLiked = !mediaItems[index].isLiked;
    mediaItems.refresh();
  } //

  List<UserMediaItem> get likedMediaItems =>
      mediaItems.where((item) => item.isLiked).toList(growable: false);

  int get likesCount => likedMediaItems.length;

  ImageProvider? get avatarProvider {
    final bytes = avatarBytes.value;
    if (bytes != null) return MemoryImage(bytes);
    return const NetworkImage('https://i.pravatar.cc/150?img=47');
  }
}
