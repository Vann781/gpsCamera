import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class FlashService{
  FlashMode _currentFlashMode = FlashMode.off;
  FlashMode get currentFlashMode=> _currentFlashMode;
  Future<void> toggleFlash(CameraController controller) async {
    try{
    if (_currentFlashMode == FlashMode.off){
      await controller.setFlashMode(FlashMode.torch);
      _currentFlashMode = FlashMode.torch;

    }
    else {
      await controller.setFlashMode(FlashMode.off);
      _currentFlashMode = FlashMode.off;
    }}

    on CameraException catch (e){

      debugPrint('Flash error  : ${e.code}- ${e.description}');
    }

    Future<void> turnOff(CameraController controller) async  {
        try{
          await controller.setFlashMode(FlashMode.off);
          _currentFlashMode = FlashMode.off;
        }
        catch(_){}
    }

  }
}