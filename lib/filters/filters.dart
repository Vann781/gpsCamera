// filters.dart
class CameraFilters {
  // Filter values with defaults
  double brightness = 0.0;  // -1 to 1
  double saturation = 1.0;  // 0 to 2
  double contrast = 1.0;    // 0 to 2
  double warmth = 1.0;      // 0.5 to 1.5
  double glow = 0.0;        // 0 to 0.5

  // Generate color matrix for ColorFiltered
  List<double> getColorMatrix() {
    final b = brightness * 255;
    final s = saturation;
    final c = contrast;
    final w = warmth;
    final g = glow * 50;

    final lumaR = 0.2126;
    final lumaG = 0.7152;
    final lumaB = 0.0722;
    final invS = 1 - s;

    return [
      ((invS * lumaR + s) * c) * w, (invS * lumaG) * c, (invS * lumaB) * c, 0, b + g,
      (invS * lumaR) * c, ((invS * lumaG + s) * c), (invS * lumaB) * c, 0, b + g,
      (invS * lumaR) * c, (invS * lumaG) * c, ((invS * lumaB + s) * c), 0, b + g,
      0, 0, 0, 1, 0,
    ];
  }
}
