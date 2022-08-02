import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Models/Driver.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Models/Truck.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralProvider extends ChangeNotifier {
    String serialNumber;
    String serverToken;
    bool showBackButton = false;
    Driver driver;
    Truck truck;
    Truck trailer;
    List<PortContainer> selectedInContainers;
    List<PortContainer> selectedOutContainers;
    bool loggedIn = false;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    GeneralProvider() {
        initialize();
    }

    initialize() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (prefs.getString(Const.prefsTruck)!= null) {
            truck = Truck.fromJson(jsonDecode(prefs.getString(Const.prefsTruck)));
        }
        if (prefs.getString(Const.prefsTrailer)!= null) {
            trailer = Truck.fromJson(jsonDecode(prefs.getString(Const.prefsTrailer)));
        }
    }

    setShowBackButton(showBackButton) {
        this.showBackButton = showBackButton;
        notifyListeners();
    }

    setTruck(Truck truck) {
        this.truck = truck;
        notifyListeners();
    }

    setTrailer(Truck trailer) {
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