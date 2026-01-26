import 'package:geolocator/geolocator.dart';

class LocationService{
  static Future<Position> getCurrentLocation() async{
    bool serviceEnabled;
    LocationPermission permission;



    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled){
      throw Exception("Location services are disabled⚠️");

    }
    permission= await Geolocator.checkPermission();
    if (permission ==  LocationPermission.denied ){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied){
        throw Exception("Location Service Denied");
      }

    }
    if (permission==LocationPermission.deniedForever){
      throw Exception("Location permission is denied Permanently🥲" );
    }
    return await Geolocator.getCurrentPosition();
  }
}
//