import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Enums/GateAppStatusEnum.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActionBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  Function onSupportPressed;
  Function onBackPressed;

  ActionBar({this.scaffoldKey, this.onSupportPressed, this.onBackPressed});

  @override
  Size get preferredSize =>
      new Size.fromHeight(AppBar().preferredSize.height * 1.9);

  @override
  Widget build(BuildContext context) {
    final generalProvider = Provider.of<GeneralProvider>(context, listen: true);
    final driver = generalProvider.driver;
    final showBackButton = generalProvider.showBackButton;
    final truckNum =
        generalProvider.truck != null ? generalProvider.truck.num : "";
    // final trailerNum =
    //     generalProvider.truck != null ? generalProvider.trailer.num : "";
    final trailerNum = (generalProvider.trailer != null
        ? (generalProvider.trailer.num != null
            ? generalProvider.trailer.num
            : "")
        : "");
    // var trailerNum = "";
    // try {
    //   trailerNum =
    //       generalProvider.truck != null ? generalProvider.trailer.num : "";
    // } catch (ex) {}

    String fullName = "";

    if (driver != null) {
      fullName = "${driver.firstName} ${driver.lastName}";
    }
    bool isCustomBroker = driver.populationType == 2;
    final _trackInfoText = isCustomBroker
        ? '${AppLocalizations.of(context).translate("Custom Agent")} ${driver.companyName}'
        : '${AppLocalizations.of(context).translate("Truck")} $truckNum | ${AppLocalizations.of(context).translate("Trailer")} $trailerNum';
    final _fullName = fullName;
    final title = AppLocalizations.of(context).translate("Choose Action");
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

    String env = "";
    if (GoPortApi.instance.baseURL == Const.ServerEwaveBlue) {
      env = "Blue";
    } else if (GoPortApi.instance.baseURL == Const.ServerEwaveTest) {
      env = "Test";
    } else if (GoPortApi.instance.baseURL == Const.ServerEwaveDev) {
      env = "Dev";
    }

    _onSupport() {
      onSupportPressed();
    }

    _onBack() {
      onBackPressed();
    }

    return Column(
      children: [
        Container(
          color: colorLogo,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      child: Image.asset(
                        "assets/images/ic_menu.png",
                        width: 30,
                        height: 30,
                      ),
                      onTap: () {
                        //Open menu
                        scaffoldKey.currentState.openDrawer();
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    showBackButton
                        ? InkWell(
                            onTap: _onBack,
                            child: Image.asset(
                              "assets/images/ic_chevron_left.png",
                              width: 30,
                              height: 30,
                              matchTextDirection: true,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      env,
                      style: TextStyle(
                        color: colorError,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    // Image.asset("assets/images/ic_scale_measurement.png", width: 30, height: 30,),
                    SizedBox(
                      width: 6,
                    ),
                    InkWell(
                      child: Image.asset(
                        "assets/images/ic_call_24.png",
                        width: 24,
                        height: 24,
                      ),
                      onTap: () {
                        //support
                        _onSupport();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullName,
                    style: TextStyle(
                        color: colorGray, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    _trackInfoText,
                    style: TextStyle(color: colorDarkenGray),
                  ),
                ],
              ),
              Image.asset("assets/images/ic_man_user.png",
                  width: 30, height: 30)
            ],
          ),
        ),
      ],
    );
  }
}
