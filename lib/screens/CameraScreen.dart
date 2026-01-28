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
//
// import 'dart:async';
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:gps_camera/services/overlay_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'camera_settings_screen.dart';
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
// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});
//
//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen>
//     with TickerProviderStateMixin {
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

//   final FlashService _flashService = FlashService();
//   final CameraService _cameraService = CameraService();
//
//   CameraController? _cameraController;
//   Future<void>? _initializeControllerFuture;
//   String? _lastImagePath;
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
//     _setupApp();
//   }
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
//
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
//           "${_liveAddress.isNotEmpty ? _liveAddress : "Locating..."}\n"
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
//   // settings screen
//   Future<void> _reinitializeCamera() async {
//     await _cameraController?.dispose();
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
//                               _flashService.currentFlashMode == FlashMode.torch
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
//                   child: Stack(
//                     children: [
//                       ColorFiltered(
//                         colorFilter: ColorFilter.matrix(
//                           _calculateColorMatrix(),
//                         ),
//                         child: CameraPreview(_cameraController!),
//                       ),
//
//                       // 🔥 LIVE OVERLAY ON CAMERA
//                       Positioned(
//                         left: 12,
//                         bottom: 12,
//                         right: 12,
//                         child: IgnorePointer(
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.35),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               _liveOverlayText,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 height: 1.3,
//                                 shadows: [
//                                   Shadow(color: Colors.black, blurRadius: 4),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Bottom row (capture, gallery)
//                 Container(
//                   color: Colors.black,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 25,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.settings, color: Colors.white),
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             PageRouteBuilder(
//                               transitionDuration: const Duration(
//                                 milliseconds: 300,
//                               ),
//                               pageBuilder: (_, __, ___) => CameraSettingsScreen(
//                                 cameras: cameras,
//                                 selectedCamera: _cameraService.currentIndex,
//                                 selectedResolution:
//                                     _cameraService.currentResolution,
//                                 onCameraChanged: (index) async {
//                                   _cameraService.setCamera(index);
//                                   await _reinitializeCamera();
//                                 },
//                                 onResolutionChanged: (preset) async {
//                                   _cameraService.setResolution(preset);
//                                   await _reinitializeCamera();
//                                 },
//                               ),
//                               transitionsBuilder: (_, animation, __, child) {
//                                 return SlideTransition(
//                                   position: Tween<Offset>(
//                                     begin: const Offset(0, 1),
//                                     end: Offset.zero,
//                                   ).animate(animation),
//                                   child: child,
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
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
//                             ? const Icon(
//                                 Icons.photo_library,
//                                 color: Colors.white,
//                               )
//                             : ClipRRect(
//                                 borderRadius: BorderRadius.circular(6),
//                                 child: Image.file(
//                                   File(_lastImagePath!),
//                                   width: 28,
//                                   height: 28,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
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
//                         "Brightness",
//                         -1,
//                         1,
//                         _brightness,
//                         (v) => setState(() => _brightness = v),
//                       ),
//                       _buildSlider(
//                         "Saturation",
//                         0,
//                         2,
//                         _saturation,
//                         (v) => setState(() => _saturation = v),
//                       ),
//                       _buildSlider(
//                         "Contrast",
//                         0,
//                         2,
//                         _contrast,
//                         (v) => setState(() => _contrast = v),
//                       ),
//                       _buildSlider(
//                         "Warmth",
//                         0.5,
//                         1.5,
//                         _warmth,
//                         (v) => setState(() => _warmth = v),
//                       ),
//                       _buildSlider(
//                         "Radiance / Glow",
//                         0,
//                         0.5,
//                         _glow,
//                         (v) => setState(() => _glow = v),
//                       ),
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
//   Widget _buildSlider(
//     String label,
//     double min,
//     double max,
//     double value,
//     ValueChanged<double> onChanged,
//   ) {
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
// class __FadePopupState extends State<_FadePopup>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
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
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:gps_camera/services/overlay_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../services/orientation_service.dart';
// import 'camera_settings_screen.dart';
//
// import '../services/location_service.dart';
// import '../services/galllery_service.dart';
// import '../services/flash_service.dart';
// import '../services/camera_service.dart';
// import '../main.dart';
// import '../filters/filters.dart';
//
// // for screen rotation logic :
// import 'dart:math';
//
// import '../services/geocoding_service.dart';
//
// class CameraScreen extends StatefulWidget {
//   const CameraScreen({super.key});
//
//   @override
//   State<CameraScreen> createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen>
//     with TickerProviderStateMixin {
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
//   // for screen rotation
//   double _uiRotation = 0.0;
//
//   final FlashService _flashService = FlashService();
//   final CameraService _cameraService = CameraService();
//
//   CameraController? _cameraController;
//   Future<void>? _initializeControllerFuture;
//   String? _lastImagePath;
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
//     _setupApp();
//   }
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
//     _cameraController?.addListener(() {
//       final newRotation = OrientationService.rotationFromDevice(
//         _cameraController!.value.deviceOrientation,
//       );
//
//       if (_uiRotation != newRotation) {
//         setState(() => _uiRotation = newRotation);
//       }
//     });
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
//
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
//           "${_liveAddress.isNotEmpty ? _liveAddress : "Locating..."}\n"
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
//   // settings screen
//   Future<void> _reinitializeCamera() async {
//     await _cameraController?.dispose();
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
//     _timeTimer?.cancel();
//     _locationTimer?.cancel();
//     super.dispose();
//   }
//
//   // @override
//   // void dispose() {
//   //   _cameraController?.setFlashMode(FlashMode.off);
//   //   _cameraController?.dispose();
//   //   super.dispose();
//   // }
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
//       final finalImage = await OverlayService.addStyledOverlay(
//         imagePath: imagePath,
//         address: address,
//         latitude: position.latitude,
//         longitude: position.longitude,
//         dateTime: DateTime.now(),
//       );
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
//       body: Padding(
//         padding: const EdgeInsets.only(
//           left: 0.0,
//           top: 0.8,
//           right: 0.0,
//           bottom: 20,
//         ),
//
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 // Top bar
//                 Container(
//                   height: 60,
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.35),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           _flashService.currentFlashMode == FlashMode.torch
//                               ? Icons.flash_on
//                               : Icons.flash_off,
//                           color:
//                               _flashService.currentFlashMode == FlashMode.torch
//                               ? Colors.yellow
//                               : Colors.white,
//                         ),
//                         onPressed: () async {
//                           await _flashService.toggleFlash(_cameraController!);
//                           setState(() {});
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.filter_alt, color: Colors.white),
//                         onPressed: () =>
//                             setState(() => _showFilters = !_showFilters),
//                       ),
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
//                   child: Stack(
//                     children: [
//                       // Inside your build method, replace the CameraPreview part:
//                       Expanded(
//                         child: LayoutBuilder(
//                           builder: (context, constraints) {
//                             return ClipRect( // 1. Prevents preview from overlapping other UI
//                               child: OverflowBox(
//                                 alignment: Alignment.center,
//                                 child: FittedBox(
//                                   fit: BoxFit.cover, // 2. Forces preview to fill the container
//                                   child: SizedBox(
//                                     // 3. Manually sets dimensions based on the camera controller
//                                     width: constraints.maxWidth,
//                                     height: constraints.maxWidth * _cameraController!.value.aspectRatio,
//                                     child: ColorFiltered(
//                                       colorFilter: ColorFilter.matrix(_calculateColorMatrix()),
//                                       child: CameraPreview(_cameraController!),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       // 🔥 LIVE OVERLAY ON CAMERA
//                       Positioned(
//                         left: 12,
//                         bottom: 12,
//                         right: 12,
//                         child: IgnorePointer(
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.45),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.08),
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _liveAddress.isNotEmpty
//                                       ? _liveAddress
//                                       : "Locating...",
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     height: 1.3,
//                                     shadows: [
//                                       Shadow(
//                                         color: Colors.black,
//                                         blurRadius: 6,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 if (_lastPosition != null)
//                                   Text(
//                                     "Lat ${_lastPosition!.latitude.toStringAsFixed(5)}, "
//                                     "Lng ${_lastPosition!.longitude.toStringAsFixed(5)}",
//                                     style: TextStyle(
//                                       color: Colors.white.withOpacity(0.85),
//                                       fontSize: 11,
//                                     ),
//                                   ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • "
//                                   "${DateTime.now().hour.toString().padLeft(2, '0')}:"
//                                   "${DateTime.now().minute.toString().padLeft(2, '0')}:"
//                                   "${DateTime.now().second.toString().padLeft(2, '0')}",
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.7),
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Bottom row (capture, gallery) with rotation
//                 Container(
//                   color: Colors.black,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 20,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Positioned(
//                         left: 12,
//                         bottom: 21,
//                         child: OrientationService.rotateUI(
//                           _uiRotation,
//                           IconButton(
//                             icon: const Icon(Icons.settings, color: Colors.white),
//                             onPressed: () {
//                               Navigator.of(context).push(
//                                 PageRouteBuilder(
//                                   transitionDuration: const Duration(
//                                     milliseconds: 300,
//                                   ),
//                                   pageBuilder: (_, __, ___) =>
//                                       CameraSettingsScreen(
//                                         cameras: cameras,
//                                         selectedCamera:
//                                             _cameraService.currentIndex,
//                                         selectedResolution:
//                                             _cameraService.currentResolution,
//                                         onCameraChanged: (index) async {
//                                           _cameraService.setCamera(index);
//                                           await _reinitializeCamera();
//                                         },
//                                         onResolutionChanged: (preset) async {
//                                           _cameraService.setResolution(preset);
//                                           await _reinitializeCamera();
//                                         },
//                                       ),
//                                   transitionsBuilder: (_, animation, __, child) {
//                                     return SlideTransition(
//                                       position: Tween<Offset>(
//                                         begin: const Offset(0, 1),
//                                         end: Offset.zero,
//                                       ).animate(animation),
//                                       child: child,
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//
//                       OrientationService.rotateUI(
//                         _uiRotation,
//                         GestureDetector(
//                           onTapDown: (_) {
//                             if (!_isCapturing)
//                               setState(() => _isPressed = true);
//                           },
//                           onTapUp: (_) => _captureImage(),
//                           onTapCancel: () => setState(() => _isPressed = false),
//                           child: AnimatedScale(
//                             scale: _isPressed ? 0.92 : 1,
//                             duration: const Duration(milliseconds: 50),
//                             child: Container(
//                               height: 75,
//                               width: 75,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: Colors.white,
//                                   width: 5,
//                                 ),
//                               ),
//                               child: const Padding(
//                                 padding: EdgeInsets.all(5),
//                                 child: DecoratedBox(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       OrientationService.rotateUI(
//                         _uiRotation,
//                         IconButton(
//                           icon: _lastImagePath == null
//                               ? const Icon(
//                                   Icons.photo_library,
//                                   color: Colors.white,
//                                 )
//                               : ClipRRect(
//                                   borderRadius: BorderRadius.circular(6),
//                                   child: Image.file(
//                                     File(_lastImagePath!),
//                                     width: 28,
//                                     height: 28,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                           onPressed: () async {
//                             final picker = ImagePicker();
//                             final image = await picker.pickImage(
//                               source: ImageSource.gallery,
//                             );
//                             if (image != null) {
//                               setState(() => _lastImagePath = image.path);
//                             }
//                           },
//                         ),
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
//                         "Brightness",
//                         -1,
//                         1,
//                         _brightness,
//                         (v) => setState(() => _brightness = v),
//                       ),
//                       _buildSlider(
//                         "Saturation",
//                         0,
//                         2,
//                         _saturation,
//                         (v) => setState(() => _saturation = v),
//                       ),
//                       _buildSlider(
//                         "Contrast",
//                         0,
//                         2,
//                         _contrast,
//                         (v) => setState(() => _contrast = v),
//                       ),
//                       _buildSlider(
//                         "Warmth",
//                         0.5,
//                         1.5,
//                         _warmth,
//                         (v) => setState(() => _warmth = v),
//                       ),
//                       _buildSlider(
//                         "Radiance / Glow",
//                         0,
//                         0.5,
//                         _glow,
//                         (v) => setState(() => _glow = v),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// Widget _buildSlider(
//   String label,
//   double min,
//   double max,
//   double value,
//   ValueChanged<double> onChanged,
// ) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label, style: const TextStyle(color: Colors.white)),
//       Slider(
//         min: min,
//         max: max,
//         value: value,
//         onChanged: onChanged,
//         activeColor: Colors.white,
//         inactiveColor: Colors.white38,
//         thumbColor: Colors.white,
//       ),
//     ],
//   );
// }
//
// // Fade popup widget
// class _FadePopup extends StatefulWidget {
//   @override
//   __FadePopupState createState() => __FadePopupState();
// }
//
// class __FadePopupState extends State<_FadePopup>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//
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
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import '../services/camera_service.dart';
import '../services/flash_service.dart';
import '../services/galllery_service.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/orientation_service.dart';
import '../services/overlay_service.dart';
import 'camera_settings_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final FlashService _flashService = FlashService();

  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  bool _isPressed = false;
  bool _isCapturing = false;
  bool _showFilters = false;

  double _uiRotation = 0.0;

  String _liveAddress = '';
  Position? _lastPosition;

  Timer? _timeTimer;
  Timer? _locationTimer;

  String? _lastImagePath;

  double _brightness = 0.0;
  double _saturation = 1.0;
  double _contrast = 1.0;
  double _warmth = 1.0;
  double _glow = 0.0;

  @override
  void initState() {
    super.initState();

    // 🔒 LOCK APP ORIENTATION
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _setupApp();
  }

  Future<void> _setupApp() async {
    await _requestGalleryPermission();

    final camGranted = await Permission.camera.request().isGranted;
    final locGranted = await Permission.location.request().isGranted;
    if (!camGranted) return;

    _cameraController = _cameraService.createController(
      _cameraService.getCurrentCamera(cameras),
    );

    /// 🔄 ROTATION LISTENER (overlay only)
    _cameraController!.addListener(() {
      final r = OrientationService.rotationFromDevice(
        _cameraController!.value.deviceOrientation,
      );
      if (r != _uiRotation) {
        setState(() => _uiRotation = r);
      }
    });

    _initializeControllerFuture = _cameraController!.initialize();
    await _initializeControllerFuture;

    if (locGranted) {
      _startLiveOverlayUpdates();
    }

    setState(() {});
  }

  void _startLiveOverlayUpdates() {
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });

    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        _lastPosition = await LocationService.getCurrentLocation();
        _liveAddress = await GeocodingService.getAddressFromLatLng(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
        );
        setState(() {});
      } catch (_) {}
    });
  }

  Future<void> _requestGalleryPermission() async {
    if (!Platform.isAndroid) return;
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    sdk >= 33
        ? await Permission.photos.request()
        : await Permission.storage.request();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timeTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    _isCapturing = true;
    setState(() => _isPressed = false);

    final image = await _cameraController!.takePicture();
    _showSavedPopup();
    _processImage(image.path);
  }

  Future<void> _processImage(String path) async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final addr = await GeocodingService.getAddressFromLatLng(
        pos.latitude,
        pos.longitude,
      );

      final img = await OverlayService.addStyledOverlay(
        imagePath: path,
        address: addr,
        latitude: pos.latitude,
        longitude: pos.longitude,
        dateTime: DateTime.now(),
      );

      await GalleryService.saveImage(img.path);
      setState(() => _lastImagePath = img.path);
    } finally {
      File(path).delete().catchError((_) {});
      _isCapturing = false;
    }
  }

  void _showSavedPopup() {
    final entry = OverlayEntry(
      builder: (_) => const Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: _FadePopup(),
      ),
    );
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(milliseconds: 700), entry.remove);
  }

  List<double> _colorMatrix() {
    final b = _brightness * 255;
    final s = _saturation;
    final c = _contrast;
    final w = _warmth;
    final g = _glow * 50;

    return [
      c * s * w, 0, 0, 0, b + g,
      0, c * s, 0, 0, b + g,
      0, 0, c * s, 0, b + g,
      0, 0, 0, 1, 0,
    ];
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
      body: Column(
        children: [
          _CameraTopBar(
            flashService: _flashService,
            controller: _cameraController!,
            onFilter: () => setState(() => _showFilters = !_showFilters),
            onSwitch: () async {
              await _cameraController!.dispose();
              _cameraService.switchCamera(cameras);
              _setupApp();
            },
          ),
          Expanded(
            child: Stack(
              children: [
                _CameraPreviewLayer(
                  controller: _cameraController!,
                  matrix: _colorMatrix(),
                ),
                _LiveGpsOverlay(
                  rotation: _uiRotation,
                  address: _liveAddress,
                  position: _lastPosition,
                ),
              ],
            ),
          ),
          _CameraBottomBar(
            rotation: _uiRotation,
            isPressed: _isPressed,
            lastImagePath: _lastImagePath,
            onCaptureDown: () => setState(() => _isPressed = true),
            onCaptureUp: _captureImage,
            onGalleryPick: _pickFromGallery,
            onSettings: _openSettings,
          ),
          if (_showFilters)
            _FiltersOverlay(
              brightness: _brightness,
              saturation: _saturation,
              contrast: _contrast,
              warmth: _warmth,
              glow: _glow,
              onChanged: (b, s, c, w, g) {
                setState(() {
                  _brightness = b;
                  _saturation = s;
                  _contrast = c;
                  _warmth = w;
                  _glow = g;
                });
              },
            ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraSettingsScreen(
          cameras: cameras,
          selectedCamera: _cameraService.currentIndex,
          selectedResolution: _cameraService.currentResolution,
          onCameraChanged: (_) async => _setupApp(),
          onResolutionChanged: (_) async => _setupApp(),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _lastImagePath = img.path);
  }
}
class _CameraTopBar extends StatelessWidget {
  final FlashService flashService;
  final CameraController controller;
  final VoidCallback onFilter;
  final VoidCallback onSwitch;

  const _CameraTopBar({
    required this.flashService,
    required this.controller,
    required this.onFilter,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              flashService.currentFlashMode == FlashMode.torch
                  ? Icons.flash_on
                  : Icons.flash_off,
              color: flashService.currentFlashMode == FlashMode.torch
                  ? Colors.yellow
                  : Colors.white,
            ),
            onPressed: () async {
              await flashService.toggleFlash(controller);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: onFilter,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined,
                color: Colors.white),
            onPressed: onSwitch,
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewLayer extends StatelessWidget {
  final CameraController controller;
  final List<double> matrix;

  const _CameraPreviewLayer({
    required this.controller,
    required this.matrix,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth *
                    controller.value.aspectRatio,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(matrix),
                  child: CameraPreview(controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class _LiveGpsOverlay extends StatelessWidget {
  final double rotation;
  final String address;
  final Position? position;

  const _LiveGpsOverlay({
    required this.rotation,
    required this.address,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: IgnorePointer(
        child: OrientationService.rotateUI(
          rotation,
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.isNotEmpty ? address : "Locating...",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (position != null)
                  Text(
                    "Lat ${position!.latitude.toStringAsFixed(5)}, "
                        "Lng ${position!.longitude.toStringAsFixed(5)}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} • "
                      "${DateTime.now().hour.toString().padLeft(2, '0')}:"
                      "${DateTime.now().minute.toString().padLeft(2, '0')}:"
                      "${DateTime.now().second.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _FiltersOverlay extends StatelessWidget {
  final double brightness;
  final double saturation;
  final double contrast;
  final double warmth;
  final double glow;

  final Function(double, double, double, double, double) onChanged;

  const _FiltersOverlay({
    required this.brightness,
    required this.saturation,
    required this.contrast,
    required this.warmth,
    required this.glow,
    required this.onChanged,
  });

  Widget _slider(String label, double min, double max, double value,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Slider(
          min: min,
          max: max,
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          inactiveColor: Colors.white38,
          thumbColor: Colors.white,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _slider("Brightness", -1, 1, brightness,
                    (v) => onChanged(v, saturation, contrast, warmth, glow)),
            _slider("Saturation", 0, 2, saturation,
                    (v) => onChanged(brightness, v, contrast, warmth, glow)),
            _slider("Contrast", 0, 2, contrast,
                    (v) => onChanged(brightness, saturation, v, warmth, glow)),
            _slider("Warmth", 0.5, 1.5, warmth,
                    (v) => onChanged(brightness, saturation, contrast, v, glow)),
            _slider("Radiance / Glow", 0, 0.5, glow,
                    (v) => onChanged(brightness, saturation, contrast, warmth, v)),
          ],
        ),
      ),
    );
  }
}


class _CameraBottomBar extends StatelessWidget {
  final double rotation;
  final bool isPressed;
  final String? lastImagePath;

  final VoidCallback onCaptureDown;
  final VoidCallback onCaptureUp;
  final VoidCallback onGalleryPick;
  final VoidCallback onSettings;

  const _CameraBottomBar({
    required this.rotation,
    required this.isPressed,
    required this.lastImagePath,
    required this.onCaptureDown,
    required this.onCaptureUp,
    required this.onGalleryPick,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OrientationService.rotateUI(
            rotation,
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: onSettings,
            ),
          ),
          OrientationService.rotateUI(
            rotation,
            GestureDetector(
              onTapDown: (_) => onCaptureDown(),
              onTapUp: (_) => onCaptureUp(),
              onTapCancel: () {},
              child: AnimatedScale(
                scale: isPressed ? 0.92 : 1,
                duration: const Duration(milliseconds: 50),
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
          OrientationService.rotateUI(
            rotation,
            IconButton(
              icon: lastImagePath == null
                  ? const Icon(Icons.photo_library, color: Colors.white)
                  : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(lastImagePath!),
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
              onPressed: onGalleryPick,
            ),
          ),
        ],
      ),
    );
  }
}
class _FadePopup extends StatefulWidget {
  const _FadePopup();

  @override
  State<_FadePopup> createState() => __FadePopupState();
}

class __FadePopupState extends State<_FadePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Image saved!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}