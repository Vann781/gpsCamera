import 'package:camera/camera.dart';

class CameraService{
  int _currentCameraIndex = 0 ;
  ResolutionPreset _currentResolution = ResolutionPreset.high;
  int get currentIndex => _currentCameraIndex;
  ResolutionPreset get currentResolution => _currentResolution;

   CameraDescription getCurrentCamera(List<CameraDescription> cameras){
     return cameras[_currentCameraIndex];


   }
   void switchCamera(List<CameraDescription> cameras){
     _currentCameraIndex = (_currentCameraIndex+1)%cameras.length;
   }

   void setCamera(int index){
     _currentCameraIndex =  index;
   }

void setResolution(ResolutionPreset preset){
     _currentResolution = preset;
}


   CameraController createController(CameraDescription camera){
     return    CameraController(
       camera,
       _currentResolution,
       enableAudio: false,
     );
   }

}