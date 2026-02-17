import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeProfileController extends GetxController {
  final RxString displayName = 'Mentisa Mayo'.obs;
  final Rxn<Uint8List> avatarBytes = Rxn<Uint8List>();

  void setDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    displayName.value = trimmed;
  }

  void setAvatarBytes(Uint8List bytes) {
    avatarBytes.value = bytes;
  }

  ImageProvider? get avatarProvider {
    final bytes = avatarBytes.value;
    if (bytes != null) return MemoryImage(bytes);
    return const NetworkImage('https://i.pravatar.cc/150?img=47');
  }
}
