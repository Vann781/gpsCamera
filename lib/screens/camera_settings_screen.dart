import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraSettingsScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  final int selectedCamera;
  final ResolutionPreset selectedResolution;
  final Function(int) onCameraChanged;
  final Function(ResolutionPreset) onResolutionChanged;

  const CameraSettingsScreen({
    super.key,
    required this.cameras,
    required this.onCameraChanged,
    required this.onResolutionChanged,
    required this.selectedCamera,
    required this.selectedResolution,
  });


  static const resolutions={
    ResolutionPreset.high : "High",
    ResolutionPreset.low: "Low",
    ResolutionPreset.ultraHigh: "Ultra High",
    ResolutionPreset.medium: "Medium",
    ResolutionPreset.veryHigh: "Very High",
      ResolutionPreset.max: "Max"
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Camera Settings"),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Camera Selection
            const Text("Camera",
              style: TextStyle(color: Colors.white,
              fontSize: 18 )),
            const SizedBox(height: 8,),

            ...List.generate(cameras.length, (index){
              final cam = cameras[index];
              return RadioListTile<int>(
                value: index,
                groupValue: selectedCamera,
                onChanged: (v)=>onCameraChanged(v!),
                title: Text(
                  cam.lensDirection.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white
                  ),

                ),
                activeColor: Colors.white,
              );
            }),
            const Divider(color: Colors.white24),
            /// RESOLUTION  SELECTION
              const Text("Resolution ",
                  style: TextStyle(color: Colors.white,fontSize: 18),),
            const SizedBox(height: 8,),


            ...resolutions.entries.map((entry){
              return RadioListTile<ResolutionPreset>(
                value: entry.key,
                groupValue: selectedResolution,
                onChanged: (v)=>onResolutionChanged(v!) ,
                title: Text(
                  entry.value,
                  style:  const TextStyle(color: Colors.white),
                ),
                activeColor: Colors.white,
              );
            })
          ],
        ),
      ),
    );
  }
}