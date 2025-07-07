import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/ActionBar.dart';
import 'package:goport/Dialogs/InputTrackDialog.dart';
import 'package:goport/Components/TagScrollWidget.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/Event.dart';
import 'package:goport/Models/Responses/EventResponse.dart';
import 'package:goport/Models/Truck.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:goport/Providers/LocationProvider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionTypeScreen extends StatefulWidget {
  static String id = 'ActionTypeScreen';

  @override
  _ActionTypeScreenState createState() => _ActionTypeScreenState();
}

class _ActionTypeScreenState extends State<ActionTypeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _controlsEnabled = false;
  bool _loading = false;
  String _trackInfoText = '';
  String _fullName = '';
  bool _hasJobDraft = false;
  List<Event> _events = [];
  final _cardHeight = 140.0;
  bool _enterTrackVisible = true;
  late AnimationController animation;
  late Animation<double> _fadeInFadeOut;

  @override
  void initState() {
    super.initState();
    initialize();
    _checkExistsDraft();
    _checkJobCardExists();

    WidgetsBinding.instance.addObserver(this);

    _startLocationTracker();

    animation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 0.5).animate(animation);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animation.forward();
      }
    });
    animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    if (state == AppLifecycleState.resumed) {
      generalProvider.setShowBackButton(false);
      _checkExistsDraft();
      _checkJobCardExists();
    }
  }

  _startLocationTracker() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.initialize(context);
    locationProvider.start();
  }

  _checkExistsDraft() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    bool res = await GoPortApi.instance
        .checkExistsDraft(generalProvider.driver!.tz ?? "");
    if (res) {
      setState(() {
        _hasJobDraft = true;
      });
    }
  }

  _checkJobCardExists() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    String guidID = await GoPortApi.instance
            .getJobCardGuidIDByDriver(generalProvider.driver?.tz ?? "") ??
        "";
    if (guidID != null && guidID != "null") {
      guidID = guidID.replaceAll("\"", "");
      generalProvider.setShowBackButton(true);
      WidgetsBinding.instance.removeObserver(this);
      await Navigator.of(context)
          .pushNamed("JobCardScreen", arguments: {"guidID": guidID});
      WidgetsBinding.instance.addObserver(this);
      generalProvider.setShowBackButton(false);
      _checkJobCardExists();
    }
  }

  initialize() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;
    final SharedPreferences prefs = await _prefs;
    Truck? truck;
    Truck? trailer;
    if (prefs.getString(Const.prefsTruck) != null) {
      truck =
          Truck.fromJson(jsonDecode(prefs.getString(Const.prefsTruck) ?? ""));
    }
    if (prefs.getString(Const.prefsTrailer) != null &&
        prefs.getString(Const.prefsTrailer) != "null") {
      trailer =
          Truck.fromJson(jsonDecode(prefs.getString(Const.prefsTrailer) ?? ""));
    }

    String fullName = "";

    if (driver != null) {
      fullName = "${driver.firstName} ${driver.lastName}";
    }

    setState(() {
      _trackInfoText = '${AppLocalizations.of(context).translate("Truck")} ---';
      _fullName = fullName;
    });

    if (truck != null && trailer != null) {
      _getVehicleDetails(truck.num ?? "", trailer.num ?? "");
    } else if (truck != null) {
      _getVehicleDetails(truck.num ?? "", "");
    }

    EventResponse? res = await GoPortApi.instance.getEvents();
    if (res != null) {
      setState(() {
        _events = res.iruimList;
      });
    }
  }

  _getVehicleDetails(String truck, String trailer) async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;

    setState(() {
      _controlsEnabled = true;
      _loading = true;
    });

    final res = await GoPortApi.instance
        .getVehicleDetails(truck, driver!.tz ?? "", trailer);

    setState(() {
      _loading = false;
    });

    if (res != null) {
      if (res.isBlock ?? false) {
        Utils.showAlertDialog(context: context, title: res.blockReason ?? "");
        setTruckError();
      } else {
        generalProvider.setTruck(res.truck);
        generalProvider.setTrailer(res.trailer);
        if (driver.companyNumber != generalProvider.truck?.companyNumber) {
          generalProvider.setTruck(null);
          generalProvider.setTrailer(null);
          Utils.showAlertDialog(
              context: context,
              message: AppLocalizations.of(context)
                  .translate("Truck or Trailer Number Not Match"));
          _controlsEnabled = false;
        } else {
          // generalProvider.truck = res.truck;
          // generalProvider.trailer = res.trailer;

          _initializeData();
          setState(() {
            _controlsEnabled = true;
          });
        }
      }
    }
  }

  _initializeData() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final truck = generalProvider.truck?.num;
    final trailer = generalProvider.trailer?.num;
    final prefs = await _prefs;
    prefs.setString(Const.prefsTrailer, jsonEncode(generalProvider.trailer));
    prefs.setString(Const.prefsTruck, jsonEncode(generalProvider.truck));

    String fullName = "";

    final driver = generalProvider.driver;
    if (driver != null) {
      fullName = "${driver.firstName} ${driver.lastName}";
    }

    setState(() {
      _trackInfoText =
          '${AppLocalizations.of(context).translate("Truck")} $truck | ${AppLocalizations.of(context).translate("Trailer")} $trailer';
      _fullName = fullName;
    });
  }

  setTruckError() {
    setState(() {
      _controlsEnabled = false;
    });
  }

  onShowTrackDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InputTrackDialog(
            onConfirm: (String truckNum, String trailerNum) async {
              Navigator.pop(context, true);

              await _getVehicleDetails(truckNum, trailerNum);
              _initializeData();
            },
            onCancel: () {
              Navigator.pop(context, true);
            },
          );
        });
  }

  onExportTapped() {
    if (_controlsEnabled) {}
  }

  onImportTapped() {
    if (_controlsEnabled) {}
  }

  onGeneralTapped() {}

  onExportCarsTapped() async {
    setState(() {
      _loading = true;
    });

    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;
    final res = await GoPortApi.instance.getDriverGuidID(driver!.tz ?? "");

    setState(() {
      _loading = false;
    });

    if (res != null && res != "null") {
      generalProvider.setShowBackButton(true);
      await Navigator.of(context).pushNamed('CheckOutCarsChooseLocationScreen',
          arguments: {"guid": res});
      generalProvider.setShowBackButton(false);
      _checkJobCardExists();
    } else {
      Utils.showAlertDialog(
          context: context,
          title: AppLocalizations.of(context)
              .translate("You are not in the port area"));
    }
  }

  onContainersTapped() async {
    if (_controlsEnabled) {
      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);
      final truck = generalProvider.truck;
      if (truck != null && (truck.isByPass ?? false)) {
        Utils.showAlertDialog(
            context: context,
            message: AppLocalizations.of(context)
                .translate("You are not allowed to the containers"));
      } else {
        generalProvider.setShowBackButton(true);
        await Navigator.of(context).pushNamed("InOutContainersScreen");
        generalProvider.setShowBackButton(false);
        _checkJobCardExists();
      }
    }
  }

  onEnterTrackNumber() {
    onShowTrackDialog();
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
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             _fullName,
                    //             style: TextStyle(
                    //                 color: colorGray,
                    //                 fontWeight: FontWeight.bold),
                    //           ),
                    //           SizedBox(height: 6,),
                    //           Text(
                    //             _trackInfoText,
                    //             style: TextStyle(
                    //                 color: colorLightGray,
                    //                 fontWeight: FontWeight.bold),
                    //           )
                    //         ],
                    //       ),
                    //       Image.asset("assets/images/ic_man_user.png",
                    //           width: 30, height: 30)
                    //     ],
                    //   ),
                    // ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: _controlsEnabled ? 1 : 0.4,
                              child: Card(
                                elevation: 2,
                                child: InkWell(
                                  enableFeedback: false,
                                  onTap: onContainersTapped,
                                  child: Container(
                                    height: _cardHeight,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 0),
                                    alignment: Alignment.center,
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            40,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _hasJobDraft
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Image.asset(
                                                  "assets/images/ic_drafts.png",
                                                  fit: BoxFit.contain,
                                                  color: colorAccent,
                                                  width: 30,
                                                ),
                                              )
                                            : Container(),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/images/ic_container_on_a_crane.png",
                                                width: 40,
                                                fit: BoxFit.contain,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                AppLocalizations.of(context)
                                                    .translate("Containers"),
                                                style: TextStyle(
                                                    color: colorGray,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: _controlsEnabled ? 1 : 0.4,
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                child: InkWell(
                                  enableFeedback: false,
                                  onTap: onImportTapped,
                                  child: Container(
                                    height: _cardHeight,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 0),
                                    alignment: Alignment.center,
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            40,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Align(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/images/ic_box_in.png",
                                                width: 40,
                                                fit: BoxFit.contain,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          "Import General Cargo"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: colorGray,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: _controlsEnabled ? 1 : 0.4,
                              child: Card(
                                elevation: 2,
                                color: Colors.white,
                                child: InkWell(
                                  enableFeedback: false,
                                  onTap: onExportTapped,
                                  child: Container(
                                    height: _cardHeight,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 0),
                                    alignment: Alignment.center,
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            40,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Align(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                "assets/images/ic_box_out.png",
                                                width: 40,
                                                fit: BoxFit.contain,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  AppLocalizations.of(context)
                                                      .translate(
                                                          "Export General Cargo"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: colorGray,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Visibility(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  elevation: 2,
                                  color: Colors.white,
                                  child: InkWell(
                                    enableFeedback: false,
                                    onTap: onExportCarsTapped,
                                    child: Container(
                                      height: _cardHeight,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 0),
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          40,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Align(
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  "assets/images/ic_directions_car.png",
                                                  width: 40,
                                                  fit: BoxFit.contain,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            "Export Cars"),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: colorGray,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: 0.4,
                                  child: Card(
                                    elevation: 2,
                                    color: Colors.white,
                                    child: InkWell(
                                      enableFeedback: false,
                                      onTap: onGeneralTapped,
                                      child: Container(
                                        height: _cardHeight,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 0),
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                40,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Align(
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/images/ic_action_general.png",
                                                    width: 40,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate("General"),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: colorGray,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            visible: generalProvider.truck != null &&
                                (generalProvider.truck!.isByPass ?? false))
                      ],
                    )
                  ],
                ),
                Visibility(
                  visible: generalProvider.truck == null,
                  child: Positioned(
                      width: MediaQuery.of(context).size.width,
                      bottom: 10,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: [
                            FadeTransition(
                              opacity: _fadeInFadeOut,
                              child: InkWell(
                                onTap: onEnterTrackNumber,
                                child: Container(
                                  color: colorError,
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    AppLocalizations.of(context).translate(
                                        "Press Here To Enter Truck Number"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(height: 1, color: colorDarkGray),
                            _events.length > 0
                                ? EventScrollWidget(events: _events)
                                : Container(),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
