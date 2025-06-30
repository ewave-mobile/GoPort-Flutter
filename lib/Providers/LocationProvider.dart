import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/DriverGpsTracking.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:latlng/latlng.dart';
import 'package:provider/provider.dart';

import 'GeneralProvider.dart';

class LocationProvider extends ChangeNotifier {
  late Timer timer;
  bool _inPolygon = false;
  var context;

  List<LatLng> areaPort = [
    LatLng(31.82873, 34.65899),
    LatLng(31.81521, 34.64238),
    LatLng(31.83125, 34.64050),
    LatLng(31.83696, 34.65613)
  ];

  void initialize(BuildContext context) {
    this.context = context;
  }

  void start() {
    timer = Timer.periodic(Duration(seconds: Const.locationInterval),
        (Timer t) async {
      final location = await _getLocation();
      if (location != null) {
        LatLng latLng = new LatLng(location.latitude, location.longitude);
        if (_isPointInPolygon(latLng, areaPort)) {
          if (!_inPolygon) {
            _inPolygon = true;
            Utils.showToast(context,AppLocalizations.of(context)
                .translate("You found in the port area"));
          }

          _sendLocationToServer(latLng);
        } else {
          f(_inPolygon) {
            _inPolygon = false;
            Utils.showToast(context,AppLocalizations.of(context)
                .translate("You left the port area"));
          }
        }
      }
    });
  }

  _sendLocationToServer(LatLng location) async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);

    DriverGpsTracking driverGpsTracking = new DriverGpsTracking();
    driverGpsTracking.lat = location.latitude;
    driverGpsTracking.lng = location.longitude;
    driverGpsTracking.serialNumber = generalProvider.serialNumber;
    driverGpsTracking.trackingDate = DateTime.now();

    bool res = await GoPortApi.instance.addDriverGpsTracking(driverGpsTracking);
  }

  void stop() {
    timer.cancel();
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (_rayCastIntersect(point, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool _rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }
}
