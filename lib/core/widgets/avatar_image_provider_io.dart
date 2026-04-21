import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object> avatarImageProvider(String avatarUrl) {
  final uri = Uri.tryParse(avatarUrl);
  final scheme = uri?.scheme.toLowerCase();

  if (scheme == 'http' ||
      scheme == 'https' ||
      scheme == 'data' ||
      scheme == 'blob') {
    return NetworkImage(avatarUrl);
  }

  if (scheme == 'file' && uri != null) {
    return FileImage(File.fromUri(uri));
  }

  return FileImage(File(avatarUrl));
}
