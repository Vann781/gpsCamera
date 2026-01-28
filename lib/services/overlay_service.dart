import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class OverlayService {
  static Future<File> addStyledOverlay({
    required String imagePath,
    required String address,
    required double latitude,
    required double longitude,
    required DateTime dateTime,
  }) async {
    final image = await _loadImage(imagePath);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw photo
    canvas.drawImage(image, Offset.zero, Paint());

    // Bottom overlay strip
    final stripHeight = image.height * 0.18;
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        image.height - stripHeight,
        image.width.toDouble(),
        stripHeight,
      ),
      Paint()..color = const Color(0x99000000),
    );

    final padding = 24.0;
    double y = image.height - stripHeight + 20;

    // Address (bold)
    y += _drawText(
      canvas,
      text: address.isNotEmpty ? address : "Locating...",
      x: padding,
      y: y,
      maxWidth: image.width - padding * 2,
      style: TextStyle(
        color: Colors.white,
        fontSize: image.width / 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 6),
        ],
      ),
      maxLines: 2,
    ) + 8;

    // Meta info
    _drawText(
      canvas,
      text:
      "Lat ${latitude.toStringAsFixed(5)}, "
          "Lng ${longitude.toStringAsFixed(5)}\n"
          "${dateTime.day}/${dateTime.month}/${dateTime.year} • "
          "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}:"
          "${dateTime.second.toString().padLeft(2, '0')}",
      x: padding,
      y: y,
      maxWidth: image.width - padding * 2,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: image.width / 32,
        height: 1.4,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 6),
        ],
      ),
    );

    return _exportImage(recorder, image, imagePath);
  }

  // ---------- helpers ----------

  static Future<ui.Image> _loadImage(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    return (await codec.getNextFrame()).image;
  }

  static double _drawText(
      Canvas canvas, {
        required String text,
        required double x,
        required double y,
        required double maxWidth,
        required TextStyle style,
        int? maxLines,
      }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    painter.paint(canvas, Offset(x, y));
    return painter.height;
  }

  static Future<File> _exportImage(
      ui.PictureRecorder recorder,
      ui.Image image,
      String originalPath,
      ) async {
    final picture = recorder.endRecording();
    final finalImage =
    await picture.toImage(image.width, image.height);

    final bytes = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final file =
    File(originalPath.replaceFirst('.jpg', '_overlay.png'));

    await file.writeAsBytes(bytes!.buffer.asUint8List());
    return file;
  }
}
