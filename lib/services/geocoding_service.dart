import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static Future<String> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return "Unknown location";

      final place = placemarks.first;

      return [
        place.name,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e != null && e!.isNotEmpty).join(', ');
    } catch (e) {
      return "Location unavailable";
    }
  }
}
