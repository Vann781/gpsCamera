import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class OverlayService {
  static Future<File> addOverlay(
      String imagePath,
      String text,
      ) async {
    // Load image
    final bytes = await File(imagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw original photo
    canvas.drawImage(image, Offset.zero, Paint());

    // Draw black strip
    final stripHeight = image.height * 0.15;
    final paint = Paint()..color = Color(0x99000000);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        image.height - stripHeight,
        image.width.toDouble(),
        stripHeight,
      ),
      paint,
    );

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: image.width / 26,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: image.width.toDouble());

    textPainter.paint(
      canvas,
      Offset(20, image.height - stripHeight + 20),
    );

    // Export image
    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(image.width, image.height);
    final pngBytes =
    await finalImage.toByteData(format: ui.ImageByteFormat.png);

    final newFile =
    File(imagePath.replaceFirst('.jpg', '_overlay.png'));

    await newFile.writeAsBytes(pngBytes!.buffer.asUint8List());

    return newFile;
  }
}
