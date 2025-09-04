import 'dart:convert';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Models/Ship.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShipyardDataScreen extends StatefulWidget {
  static String id = 'ShipyardDataScreen';

  @override
  _ShipyardDataScreenState createState() => _ShipyardDataScreenState();
}

class _ShipyardDataScreenState extends State<ShipyardDataScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Ship> ships = [];
  bool _loading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _initialize();
    // _test();
    super.initState();
  }

  _test() {
    ships.add(Ship("ship_NO", "shipnamE_ENG", "stat", "sochen", "razif",
        "lasT_UPDATE", "x_GPS", "y_GPS", "zakef", false));
    setState(() {});
  }

  _initialize() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;

    setState(() {
      _loading = true;
    });

    final res = await GoPortApi.instance.getShipsStatus(driver!.idNumber!, "");

    setState(() {
      _loading = false;
    });

    if (res != null) {
      setState(() {
        ships = res.shipsList;
      });
    }
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = ships[index];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.shipnamE_ENG ?? "",
                    style: TextStyle(fontSize: 18, color: colorLogo2),
                  ),
                ],
              ),
              Text(
                item.ship_NO ?? "",
                style: TextStyle(fontSize: 18, color: colorPrimary),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.stat ?? "",
              style: TextStyle(fontSize: 18, color: colorPrimary),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Dock"),
                    style: TextStyle(fontSize: 18, color: colorLightGray),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    item.razif ?? "",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).translate("Zakef"),
                    style: TextStyle(fontSize: 18, color: colorLightGray),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    item.zakef ?? "",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            color: colorDivider,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(height: 1, color: colorDivider),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).translate("Ships"),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorLightGray,
                          fontSize: 20),
                    ),
                  ),
                  Container(height: 1, color: colorDivider),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: ships.length,
                        itemBuilder: (BuildContext buildContext, int index) {
                          return _buildListItem(buildContext, index);
                        }),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
