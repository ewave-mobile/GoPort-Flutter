import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Models/Driver.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Models/Truck.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralProvider extends ChangeNotifier {
  String? serialNumber;
  String? serverToken;
  bool showBackButton = false;
  Driver? driver;
  Truck? truck;
  Truck? trailer;
  List<PortContainer> selectedInContainers = [];
  List<PortContainer> selectedOutContainers = [];
  bool loggedIn = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  GeneralProvider() {
    initialize();
  }

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? truckJson = prefs.getString(Const.prefsTruck);
    if (truckJson != null && truckJson.isNotEmpty) {
      try {
        truck = Truck.fromJson(jsonDecode(truckJson));
      } catch (e) {
        print("Error parsing truck data: $e");
      }
    }

    String? trailerJson = prefs.getString(Const.prefsTrailer);
    if (trailerJson != null && trailerJson.isNotEmpty) {
      try {
        trailer = Truck.fromJson(jsonDecode(trailerJson));
      } catch (e) {
        print("Error parsing trailer data: $e");
      }
    }
  }

  setShowBackButton(showBackButton) {
    this.showBackButton = showBackButton;
    notifyListeners();
  }

  setTruck(Truck? truck) {
    this.truck = truck;
    notifyListeners();
  }

  setTrailer(Truck? trailer) {
    this.trailer = trailer;
    notifyListeners();
  }

  setServerToken(String serverToken) {
    this.serverToken = serverToken;
    notifyListeners();
  }

  setIsLoggedIn(bool loggedIn) {
    this.loggedIn = loggedIn;
    notifyListeners();
  }
}
