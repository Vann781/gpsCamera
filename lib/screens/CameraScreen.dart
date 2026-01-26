import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../services/location_service.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  @override
  void initState() {
    super.initState();
    print("SETUP STARTED");
    _setupApp();
  }
  // Future<void> _setupApp() async{
  //
  //   bool granted = await PermissionService.requestPermissions();
  //   print("PERMISSION RESULT: $granted");
  //   if(!granted){
  //     throw Exception("Permission not granted");
  //
  //   }
  //
  //   print("CREATING CAMERA");
  //   _cameraController = CameraController(
  //     cameras[0],
  //     ResolutionPreset.high,
  //   );
  //   _initializeControllerFuture =   _cameraController?.initialize();
  //
  //   print("GETTING LOCATION");
  //   try {
  //     Position position = await LocationService.getCurrentLocation();
  //     print("LAT : ${position.latitude}");
  //     print("LNG : ${position.longitude}");
  //   }
  //   catch (e){
  //     print("Location error : $e");
  //   }
  //   setState(() {});
  //
  // }

  Future<void> _setupApp() async {
    print("SETUP STARTED");

    bool cameraGranted = await Permission.camera.request().isGranted;
    bool locationGranted = await Permission.location.request().isGranted;
    bool storageGranted = await Permission.storage.request().isGranted;

    if (!cameraGranted) {
      print("⚠️ Camera permission denied, camera won't work");
    }
    if (!locationGranted) {
      print("⚠️ Location permission denied, GPS won't work");
    }
    if (!storageGranted) {
      print("⚠️ Storage permission denied, saving photos won't work");
    }

// Proceed with whatever is granted
    if (cameraGranted) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      _initializeControllerFuture = _cameraController?.initialize();
    }
    if (locationGranted) {
      Position pos = await LocationService.getCurrentLocation();
      print("LAT: ${pos.latitude}, LNG: ${pos.longitude}");
    }


    // 4️⃣ Refresh UI
    setState(() {});
  }

  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jab tak controller ready nahi
    if (_initializeControllerFuture == null || _cameraController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;
            return Stack(
                  children: [Center(child: CameraPreview(_cameraController!)),
                    Positioned(
                      bottom: 100,
                      left: 0,   // Stretch to the left edge
                      right: 0,  // Stretch to the right edge
                      child: Center(
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: FloatingActionButton(
                            backgroundColor: Colors.grey,
                            hoverColor: Colors.white70,
                            child: Icon(Icons.camera_alt),
                            onPressed: () async {
                              try {
                                await _initializeControllerFuture;
                                final image = await _cameraController!.takePicture();
                                print("Photo saved at: ${image.path}");
                                // Optional: show confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Photo captured!')),
                                );
                              } catch (e) {
                                print("Error capturing photo: $e");
                              }
                            },
                          ),
                        ),
                      ),
                    )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );

  }
}
