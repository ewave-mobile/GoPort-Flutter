import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Dialogs/UpdateSerialDialog.dart';
import 'package:goport/Enums/GateAppStatusEnum.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/RootDrawer.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/BottomNavViewItem.dart';
import 'package:goport/Models/JobCard.dart';
import 'package:goport/Models/JobCardContainer.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:goport/main.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';

class MenuScreen extends StatefulWidget {
  static String id = 'MenuScreen';
  final List<String> items = [];
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function onShowTruckDetails;
  final Function onShowLanguage;

  MenuScreen(
      {required this.navigatorKey,
      required this.scaffoldKey,
      required this.onShowTruckDetails,
      required this.onShowLanguage});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _loading = false;
  String _trackInfoText = "";
  String _fullName = "";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<BottomNavViewItem> navViewItems = [];

  @override
  void initState() {
    super.initState();
  }

  _onLogout() {
    final generalProvider = Provider.of<GeneralProvider>(
        _scaffoldKey!.currentContext!,
        listen: false);
    final driver = generalProvider.driver;

    final state = RootDrawer.of(context);
    state!.close();

    Utils.showConfirmDialog(
        context: widget.navigatorKey.currentContext,
        title: "",
        okButton: AppLocalizations.of(context).translate("Yes"),
        cancelButton: AppLocalizations.of(context).translate("No"),
        message: AppLocalizations.of(context).translate(
            "Note, Disconnect From App Will Transfer You To Kiosk Mode, Continue?"),
        onOk: () async {
          bool res = await GoPortApi.instance
              .setGateStatus(driver!.tz ?? "", GateAppStatusEnum.Disconnected);
          final SharedPreferences prefs = await _prefs;
          prefs.setString(Const.prefsLogOn, "0");
          generalProvider.setIsLoggedIn(false);
          generalProvider.driver = null;
          Navigator.pushAndRemoveUntil(
              widget.navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false);
        });
  }

  _onChangeLanguage() {
    if (widget.onShowLanguage != null) {
      final state = RootDrawer.of(context);
      state!.close();
      widget.onShowLanguage();
    }
  }

  _onShowTraffic() {
    final state = RootDrawer.of(context);
    state!.close();
    Navigator.of(widget.navigatorKey.currentContext!)
        .pushNamed("ViewHeavyTrafficScreen");
  }

  _onChangeTruckDetails() {
    if (widget.onShowTruckDetails != null) {
      final state = RootDrawer.of(context);
      state!.close();
      widget.onShowTruckDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;

    final userName = driver!.firstName! + " " + driver.lastName!;
    final serialNumber = generalProvider.serialNumber;

    return Drawer(
      child: Scaffold(
        key: _scaffoldKey,
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          child: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/ic_user_image.png",
                      width: 90,
                      height: 100,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      userName,
                      style: TextStyle(fontSize: 16, color: colorDarkGray),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      serialNumber ?? "",
                      style: TextStyle(fontSize: 16, color: colorLightGray),
                    )
                  ],
                ),
              ),
              Container(
                height: 2,
                color: colorDarkenGray,
              ),
              Column(
                children: [
                  InkWell(
                    onTap: _onLogout,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.asset("assets/images/ic_log_out_24.png",
                              width: 30,
                              height: 30,
                              color: colorLogo,
                              fit: BoxFit.contain),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            AppLocalizations.of(context).translate("Logout"),
                            style:
                                TextStyle(fontSize: 16, color: colorDarkenGray),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: colorDivider,
                  ),
                  InkWell(
                    onTap: _onShowTraffic,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.asset("assets/images/ic_traffic_lights.png",
                              width: 30,
                              height: 30,
                              color: colorLogo,
                              fit: BoxFit.contain),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            AppLocalizations.of(context)
                                .translate("Show traffic"),
                            style:
                                TextStyle(fontSize: 16, color: colorDarkenGray),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: colorDivider,
                  ),
                  InkWell(
                    onTap: _onChangeLanguage,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.asset("assets/images/ic_language_24.png",
                              width: 30,
                              height: 30,
                              color: colorLogo,
                              fit: BoxFit.contain),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            AppLocalizations.of(context)
                                .translate("Change language"),
                            style:
                                TextStyle(fontSize: 16, color: colorDarkenGray),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: colorDivider,
                  ),
                  InkWell(
                    onTap: _onChangeTruckDetails,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.asset("assets/images/ic_settings.png",
                              width: 30,
                              height: 30,
                              color: colorLogo,
                              fit: BoxFit.contain),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            AppLocalizations.of(context)
                                .translate("Change truck details"),
                            style:
                                TextStyle(fontSize: 16, color: colorDarkenGray),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: colorDivider,
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }
}
