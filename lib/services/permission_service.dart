import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var locationStatus = await Permission.location.request();
    var storageStatus = await Permission.storage.request();




    if (cameraStatus.isGranted && locationStatus.isGranted && storageStatus.isGranted){
      return true;

    }
    else{
      return false;
    }

  }
}