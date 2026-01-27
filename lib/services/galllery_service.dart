import 'dart:io';
import 'package:gal/gal.dart';

class GalleryService {
  static Future<void> saveImage(String imagePath) async {
    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception("Image file not found");
    }

    await Gal.putImage(
      file.path,
      album: 'GPS Camera', // optional, but recommended
    );

  }
}
