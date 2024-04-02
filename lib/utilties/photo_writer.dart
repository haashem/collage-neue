import 'dart:ui';

import 'package:photo_manager/photo_manager.dart';

sealed class PhotoWriterError {}

class CouldNotSavePhoto extends PhotoWriterError {
  @override
  String toString() {
    return 'Could not save photo';
  }
}

class Unknown extends PhotoWriterError {
  final Object error;
  Unknown(this.error);

  @override
  String toString() {
    return 'Unknown error: $error';
  }
}

typedef AssetId = String;

class PhotoWriter {}
