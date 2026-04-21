import 'package:flutter/material.dart';

ImageProvider<Object> avatarImageProvider(String avatarUrl) {
  return NetworkImage(avatarUrl);
}
