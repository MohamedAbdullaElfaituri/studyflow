import 'package:flutter/material.dart';

import 'avatar_image_provider_stub.dart'
    if (dart.library.io) 'avatar_image_provider_io.dart'
    if (dart.library.html) 'avatar_image_provider_web.dart' as avatar_provider;

ImageProvider<Object> avatarImageProvider(String avatarUrl) {
  return avatar_provider.avatarImageProvider(avatarUrl);
}
