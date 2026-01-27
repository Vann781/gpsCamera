// import 'dart:async';
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:gps_camera/services/overlay_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../services/location_service.dart';
// import '../services/galllery_service.dart';
// import '../services/flash_service.dart';
// import '../services/camera_service.dart';
// import '../main.dart';
// import '../filters/filters.dart';
//
// import '../services/geocoding_service.dart';
//
//
// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});
//
//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
//   bool _isPressed = false;
//   bool _isCapturing = false;
//   bool _showFilters = false;
//
//   final CameraFilters filters = CameraFilters();
//
//   double _brightness = 0.0;
//   double _saturation = 1.0;
//   double _contrast = 1.0;
//   double _warmth = 1.0;
//   double _glow = 0.0;
//
//   final FlashService _flashService = FlashService();
//   final CameraService _cameraService = CameraService();
//
//   CameraController? _cameraController;
//   Future<void>? _initializeControllerFuture;
//   String? _lastImagePath;
//
//
//   // UI Overlay
//   String _liveOverlayText = "Fetching location...";
//   String _liveAddress = "";
//   Position? _lastPosition;
//
//   Timer? _timeTimer;
//   Timer? _locationTimer;
//
//   @override
//   void initState() {
//     super.initState();
//
//
//     _setupApp();
//   }
//
//
//
//   Future<void> _setupApp() async {
//     await _requestGalleryPermission();
//
//     final cameraGranted = await Permission.camera.request().isGranted;
//     final locationGranted = await Permission.location.request().isGranted;
//
//     if (!cameraGranted) return;
//
//     _cameraController = _cameraService.createController(
//       _cameraService.getCurrentCamera(cameras),
//     );
//
//     _initializeControllerFuture = _cameraController!.initialize();
//     _startLiveOverlayUpdates();
//     await _initializeControllerFuture;
//
//     if (locationGranted) {
//       await LocationService.getCurrentLocation();
//     }
//
//     setState(() {});
//   }
//   void _startLiveOverlayUpdates() {
//     // Time updates every second
//     _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _updateOverlayText();
//     });
//
//     // Location updates every 3 seconds (DO NOT do every second)
//     _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
//       try {
//         final position = await LocationService.getCurrentLocation();
//         _lastPosition = position;
//
//         // Reverse geocode only if location changed meaningfully
//         _liveAddress = await GeocodingService.getAddressFromLatLng(
//           position.latitude,
//           position.longitude,
//         );
//
//         _updateOverlayText();
//       } catch (_) {}
//     });
//   }
//
//   void _updateOverlayText() {
//     if (_lastPosition == null) return;
//
//     final now = DateTime.now();
//
//     setState(() {
//       _liveOverlayText =
//       "${_liveAddress.isNotEmpty ? _liveAddress : "Locating..."}\n"
//           "Lat: ${_lastPosition!.latitude.toStringAsFixed(6)}, "
//           "Lng: ${_lastPosition!.longitude.toStringAsFixed(6)}\n"
//           "${now.day}/${now.month}/${now.year} • "
//           "${now.hour.toString().padLeft(2, '0')}:"
//           "${now.minute.toString().padLeft(2, '0')}:"
//           "${now.second.toString().padLeft(2, '0')}";
//     });
//   }
//
//   // UI Overlay Finish
//
//   Future<void> _switchCamera() async {
//     if (_cameraController == null) return;
//
//     await _cameraController!.dispose();
//     _cameraService.switchCamera(cameras);
//
//     _cameraController = _cameraService.createController(
//       _cameraService.getCurrentCamera(cameras),
//     );
//
//     _initializeControllerFuture = _cameraController!.initialize();
//     await _initializeControllerFuture;
//
//     setState(() {});
//   }
//
//   Future<void> _requestGalleryPermission() async {
//     if (!Platform.isAndroid) return;
//     final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
//     sdk >= 33
//         ? await Permission.photos.request()
//         : await Permission.storage.request();
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.setFlashMode(FlashMode.off);
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   List<double> _calculateColorMatrix() {
//     final b = _brightness * 255;
//     final s = _saturation;
//     final c = _contrast;
//     final w = _warmth;
//     final g = _glow * 50;
//
//     final lumaR = 0.2126;
//     final lumaG = 0.7152;
//     final lumaB = 0.0722;
//     final invS = 1 - s;
//
//     return [
//       ((invS * lumaR + s) * c) * w,
//       (invS * lumaG) * c,
//       (invS * lumaB) * c,
//       0,
//       b + g,
//       (invS * lumaR) * c,
//       ((invS * lumaG + s) * c),
//       (invS * lumaB) * c,
//       0,
//       b + g,
//       (invS * lumaR) * c,
//       (invS * lumaG) * c,
//       ((invS * lumaB + s) * c),
//       0,
//       b + g,
//       0,
//       0,
//       0,
//       1,
//       0,
//     ];
//   }
//
//   Future<void> _captureImage() async {
//     if (_isCapturing) return;
//     _isCapturing = true;
//
//     // Remove press scale instantly
//     setState(() => _isPressed = false);
//
//     try {
//       // Capture image fast
//       final image = await _cameraController!.takePicture();
//
//       // Show popup immediately
//       _showSavedPopup();
//
//       // Process overlay + save in background
//       _processImage(image.path);
//     } catch (e) {
//       debugPrint("Capture error: $e");
//       _isCapturing = false;
//     }
//   }
//
//   void _processImage(String imagePath) async {
//     try {
//       final position = await LocationService.getCurrentLocation();
//
//       final address = await GeocodingService.getAddressFromLatLng(
//         position.latitude,
//         position.longitude,
//       );
//
//       final text =
//           "$address\nLat: ${position.latitude}, Lng: ${position.longitude}\n Date and Time : ${DateTime.now()}";
//
//       final finalImage = await OverlayService.addOverlay(imagePath, text);
//
//       await GalleryService.saveImage(finalImage.path);
//
//       setState(() => _lastImagePath = finalImage.path);
//     } catch (e) {
//       debugPrint("Background processing error: $e");
//     } finally {
//       File(imagePath).delete().catchError((_) {});
//       _isCapturing = false;
//     }
//   }
//
//
//   void _showSavedPopup() {
//     final overlay = Overlay.of(context);
//     final entry = OverlayEntry(
//       builder: (_) => Positioned(
//         top: 100,
//         left: MediaQuery.of(context).size.width * 0.2,
//         width: MediaQuery.of(context).size.width * 0.6,
//         child: _FadePopup(),
//       ),
//     );
//     overlay.insert(entry);
//
//     // Remove after animation
//     Future.delayed(const Duration(milliseconds: 700), () => entry.remove());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_initializeControllerFuture == null || _cameraController == null) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 // Top bar
//                 Container(
//                   height: 60,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           _flashService.currentFlashMode == FlashMode.torch
//                               ? Icons.flash_on
//                               : Icons.flash_off,
//                           color:
//                           _flashService.currentFlashMode == FlashMode.torch
//                               ? Colors.yellow
//                               : Colors.white,
//                         ),
//                         onPressed: () async {
//                           await _flashService.toggleFlash(_cameraController!);
//                           setState(() {});
//                         },
//                       ),
//
//                       // Filters button
//                       IconButton(
//                         icon: const Icon(Icons.filter_alt, color: Colors.white),
//                         onPressed: () =>
//                             setState(() => _showFilters = !_showFilters),
//                       ),
//
//                       IconButton(
//                         icon: const Icon(
//                           Icons.flip_camera_ios_outlined,
//                           color: Colors.white,
//                         ),
//                         onPressed: _switchCamera,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Camera preview
//                 Expanded(
//                   child: ColorFiltered(
//                     colorFilter: ColorFilter.matrix(_calculateColorMatrix()),
//                     child: CameraPreview(_cameraController!),
//                   ),
//                 ),
//
//                 // Bottom row (capture, gallery)
//                 Container(
//                   color: Colors.black,
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       const Icon(Icons.settings, color: Colors.white),
//
//                       GestureDetector(
//                         onTapDown: (_) {
//                           if (!_isCapturing) setState(() => _isPressed = true);
//                         },
//                         onTapUp: (_) => _captureImage(),
//                         onTapCancel: () => setState(() => _isPressed = false),
//                         child: AnimatedScale(
//                           scale: _isPressed ? 0.92 : 1,
//                           duration: const Duration(milliseconds: 50),
//                           child: Container(
//                             height: 75,
//                             width: 75,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 5),
//                             ),
//                             child: const Padding(
//                               padding: EdgeInsets.all(5),
//                               child: DecoratedBox(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       IconButton(
//                         icon: _lastImagePath == null
//                             ? const Icon(Icons.photo_library, color: Colors.white)
//                             : ClipRRect(
//                           borderRadius: BorderRadius.circular(6),
//                           child: Image.file(
//                             File(_lastImagePath!),
//                             width: 28,
//                             height: 28,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         onPressed: () async {
//                           final picker = ImagePicker();
//                           final image = await picker.pickImage(
//                             source: ImageSource.gallery,
//                           );
//                           if (image != null) {
//                             setState(() => _lastImagePath = image.path);
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             // FILTERS OVERLAY
//             if (_showFilters)
//               Positioned(
//                 top: 70,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   color: Colors.black54,
//                   padding: const EdgeInsets.all(10),
//                   child: Column(
//                     children: [
//                       _buildSlider(
//                           "Brightness", -1, 1, _brightness, (v) => setState(() => _brightness = v)),
//                       _buildSlider(
//                           "Saturation", 0, 2, _saturation, (v) => setState(() => _saturation = v)),
//                       _buildSlider(
//                           "Contrast", 0, 2, _contrast, (v) => setState(() => _contrast = v)),
//                       _buildSlider(
//                           "Warmth", 0.5, 1.5, _warmth, (v) => setState(() => _warmth = v)),
//                       _buildSlider(
//                           "Radiance / Glow", 0, 0.5, _glow, (v) => setState(() => _glow = v)),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSlider(String label, double min, double max, double value,
//       ValueChanged<double> onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white)),
//         Slider(
//           min: min,
//           max: max,
//           value: value,
//           onChanged: onChanged,
//           activeColor: Colors.white,
//           inactiveColor: Colors.white38,
//           thumbColor: Colors.white,
//         ),
//       ],
//     );
//   }
// }
//
// // Fade popup widget
// class _FadePopup extends StatefulWidget {
//   @override
//   __FadePopupState createState() => __FadePopupState();
// }
//
// class __FadePopupState extends State<_FadePopup> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller =
//         AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.black54,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Center(
//             child: Text(
//               "Image saved!",
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../services/camera_service.dart';
import '../services/flash_service.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/overlay_service.dart';
import '../services/galllery_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  final CameraService _cameraService = CameraService();
  final FlashService _flashService = FlashService();

  bool _isPressed = false;
  bool _isCapturing = false;
  bool _showFilters = false;

  String? _lastImagePath;

  // LIVE OVERLAY
  String _liveOverlayText = "Fetching location...";
  Position? _lastPosition;

  Timer? _timeTimer;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    await _requestGalleryPermission();

    if (!await Permission.camera.request().isGranted) return;
    await Permission.location.request();

    _cameraController = _cameraService.createController(
      _cameraService.getCurrentCamera(cameras),
    );

    _initializeControllerFuture = _cameraController!.initialize();
    await _initializeControllerFuture;

    _startLiveOverlayUpdates();
    setState(() {});
  }

  void _startLiveOverlayUpdates() {
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateOverlayText();
    });

    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final pos = await LocationService.getCurrentLocation();
        _lastPosition = pos;
        _updateOverlayText();
      } catch (_) {}
    });
  }

  Future<void> _updateOverlayText() async {
    if (_lastPosition == null) return;

    final address = await GeocodingService.getAddressFromLatLng(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
    );

    final now = DateTime.now();

    setState(() {
      _liveOverlayText =
      "$address\n"
          "Lat: ${_lastPosition!.latitude.toStringAsFixed(6)}, "
          "Lng: ${_lastPosition!.longitude.toStringAsFixed(6)}\n"
          "${now.day}/${now.month}/${now.year} "
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    _isCapturing = true;

    setState(() => _isPressed = false);

    try {
      final image = await _cameraController!.takePicture();
      _showSavedPopup();
      _processImage(image.path);
    } catch (e) {
      debugPrint("Capture error: $e");
      _isCapturing = false;
    }
  }

  Future<void> _processImage(String path) async {
    try {
      final file = await OverlayService.addOverlay(path, _liveOverlayText);
      await GalleryService.saveImage(file.path);
      setState(() => _lastImagePath = file.path);
    } catch (e) {
      debugPrint("Overlay error: $e");
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> _requestGalleryPermission() async {
    if (!Platform.isAndroid) return;
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    sdk >= 33 ? await Permission.photos.request() : await Permission.storage.request();
  }

  void _showSavedPopup() {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => const Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: Center(child: _FadePopup()),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 700), entry.remove);
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _locationTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            CameraPreview(_cameraController!),

            // 🔥 LIVE OVERLAY ON CAMERA
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _liveOverlayText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // BOTTOM CONTROLS
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => _captureImage(),
                  onTapCancel: () => setState(() => _isPressed = false),
                  child: AnimatedScale(
                    scale: _isPressed ? 0.92 : 1,
                    duration: const Duration(milliseconds: 80),
                    child: Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadePopup extends StatelessWidget {
  const _FadePopup();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "Image saved!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
