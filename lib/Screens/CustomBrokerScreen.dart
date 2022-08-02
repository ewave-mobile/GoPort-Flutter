import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/AvailableJobs.dart';
import 'package:goport/Models/BottomNavViewItem.dart';
import 'package:goport/Models/DraftJobCard.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Models/SaveContainersToDraft.dart';
import 'package:goport/Models/Technician.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:goport/Screens/ActionTypeScreen.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomBrokerScreen extends StatefulWidget {
  static String id = 'CustomBrokerScreen';

  @override
  _CustomBrokerScreenState createState() => _CustomBrokerScreenState();
}

class _CustomBrokerScreenState extends State<CustomBrokerScreen> {
  bool _loading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _cardHeight = 180.0;

  onCargoExceptionTapped() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.setShowBackButton(true);
    await Navigator.of(context).pushNamed("CargoExceptionScreen");
    generalProvider.setShowBackButton(false);
  }

  onShipyardTapped() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.setShowBackButton(true);
    await Navigator.of(context).pushNamed("ShipyardDataScreen");
    generalProvider.setShowBackButton(false);
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    return WillPopScope(
      onWillPop: () {
        Utils.showConfirmDialog(
            context: context,
            title: "",
            okButton: AppLocalizations.of(context).translate("Yes"),
            cancelButton: AppLocalizations.of(context).translate("No"),
            message: AppLocalizations.of(context)
                .translate("Are you sure you want to exit the app?"),
            onOk: () {
              exit(0);
            });
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: colorLightenGray,
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Container(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1, color: colorDarkGray),
                    SizedBox(
                      height: 14,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context).translate("Choose Action"),
                        style: TextStyle(
                            color: colorGray,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(height: 1, color: colorDivider),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Card(
                            elevation: 2,
                            child: InkWell(
                              enableFeedback: false,
                              onTap: onShipyardTapped,
                              child: Container(
                                height: _cardHeight,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 0),
                                alignment: Alignment.center,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        Image.asset(
                                          "assets/images/ic_boat_with_containers.png",
                                          width: 60,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate("Shipyard Details"),
                                          style: TextStyle(
                                              color: colorGray,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Card(
                            elevation: 2,
                            child: InkWell(
                              enableFeedback: false,
                              onTap: onCargoExceptionTapped,
                              child: Container(
                                height: _cardHeight,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 0),
                                alignment: Alignment.center,
                                width:
                                    MediaQuery.of(context).size.width / 2 - 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        Image.asset(
                                          "assets/images/ic_update.png",
                                          width: 60,
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate("Cargo Exception"),
                                          style: TextStyle(
                                              color: colorGray,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
