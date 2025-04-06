import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/Driver.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:convert';
import '../main.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

enum ScreenMode {
  Login,
  Otp,
}

class LoginScreen extends StatefulWidget {
  static String id = 'LoginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AppcastConfiguration? _upgradeConfig;
  String? _truck;
  String? _version;
  String? _deviceToken;
  bool _loading = false;
  String verifyCode = "";

  ScreenMode screenMode = ScreenMode.Login;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late StreamController<ErrorAnimationType> _errorController;

  final TextEditingController _tzController = new TextEditingController(
      text: ""); // TODO: remove in prod //54005442 //34975672
  final TextEditingController _otpController =
      new TextEditingController(text: "");

  //truck - 5381668
  //trailer - 5581400
  //54005442

  //truck - 1257379
  //trailer - 9013768
  //34975672

  //Amil mehes
  //truck -
  //trailer -
  //31743271, 28457471

  checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.storage,
      Permission.phone,
      Permission.camera,
    ].request();
  }

  @override
  void initState() {
    super.initState();

    _errorController = StreamController<ErrorAnimationType>();
    checkPermissions();
    checkForUpdate();

    initData();
    initPush();

    // //TODO: remove
    // Future.delayed(const Duration(seconds: 1)).then((value) {
    //   final generalProvider =
    //   Provider.of<GeneralProvider>(context, listen: false);
    //   Driver driver = Driver(tz: "34975672");
    //   generalProvider.driver = driver;
    //   Navigator.of(context).pushNamed("CheckOutCarsChooseLocationScreen");
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  initPush() async {
    try {
      // Register the user for push notifications
      String deviceToken = await Pushy.register();
      setState(() {
        _deviceToken = deviceToken;
      });
      print('Device token: $deviceToken');
    } on PlatformException catch (error) {
      print('Device token error: $error');
    }
  }

  Future<int> sendCode() async {
    setState(() {
      _loading = true;
    });

    FocusScope.of(context).unfocus();
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final clientToken = await UniqueIdentifier.serial;
    final res = await GoPortApi.instance.getVerifyCode(
        generalProvider.serialNumber ?? "",
        _tzController.text,
        _deviceToken!,
        clientToken ?? "");

    setState(() {
      _loading = false;
    });

    return res;
  }

  login({sendCode = false}) async {
    setState(() {
      _loading = true;
    });

    FocusScope.of(context).unfocus();
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final clientToken = await UniqueIdentifier.serial;

    if (screenMode == ScreenMode.Login || sendCode) {
      final res = await GoPortApi.instance.getVerifyCode(
          generalProvider.serialNumber ?? "",
          _tzController.text,
          _deviceToken ?? "",
          clientToken ?? "");
      // final res = await GoPortApi.instance.checkDriver(
      //     generalProvider.serialNumber,
      //     _tzController.text,
      //     _deviceToken,
      //     clientToken);

      setState(() {
        _loading = false;
      });

      if (res == 0) {
        //OK
        GoPortApi.instance.token = Utils.convertToBase64String(
            _tzController.text + ":" + clientToken!);
        setState(() {
          screenMode = ScreenMode.Otp;
        });
        Utils.showToast(AppLocalizations.of(context)
            .translate("We've sent an SMS code your phone number"));
      } else if (res == 1) {
        Utils.showToast(
            AppLocalizations.of(context).translate("User does not exist"));
      } else if (res == 2) {
        Utils.showToast(
            AppLocalizations.of(context).translate("Network problem"));
      } else if (res == 3) {
        Utils.showToast(AppLocalizations.of(context).translate("User locked"));
      }
    } else {
      final res = await GoPortApi.instance.getDriverByVerifyCode(
          generalProvider.serialNumber ?? "",
          _tzController.text,
          _otpController.text);

      setState(() {
        _loading = false;
      });

      if (res == null) {
        Utils.showToast(AppLocalizations.of(context).translate("Wrong code"));
      } else {
        generalProvider.driver = res;
        if (generalProvider.driver!.blockType! > 0) {
          Utils.showAlertDialog(
              context: context,
              title: "",
              message: generalProvider.driver!.blockReason);
        } else if (generalProvider.driver!.phoneNumber!.isEmpty) {
          Utils.showAlertDialog(
              context: context,
              title: "",
              message: AppLocalizations.of(context)
                  .translate("Phone number not set"));
        } else {
          final SharedPreferences prefs = await _prefs;
          prefs.setString(Const.prefsLogOn, "1");
          prefs.setString(Const.prefsLastLoginTz, _tzController.text);
          generalProvider.setIsLoggedIn(true);

          FocusScope.of(context).unfocus();
          _otpController.clear();
          _tzController.clear();

          if (generalProvider.driver!.populationType == 7) {
            //Driver
            await Navigator.of(context).pushNamed('ActionTypeScreen');
            setState(() {
              screenMode = ScreenMode.Login;
            });
          } else if (generalProvider.driver!.populationType == 2) {
            //Custom Broker
            await Navigator.of(context).pushNamed('CustomBrokerScreen');
            setState(() {
              screenMode = ScreenMode.Login;
            });
          }
        }
      }
    }
  }

  void initData() async {
    final SharedPreferences prefs = await _prefs;
    String? sn = prefs.getString(Const.prefsSerialNumber);
    if (sn == null) {
      sn = await Utils.initUDID();
      prefs.setString(Const.prefsSerialNumber, sn);
    }

    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.serialNumber = sn;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;

    setState(() {
      _version = "$version";
      _truck = generalProvider.truck?.num;
    });
  }

  void checkForUpdate() {
    Upgrader.clearSavedSettings(); // REMOVE this for release builds

    // On iOS, the default behavior will be to use the App Store version of
    // the app, so update the Bundle Identifier in example/ios/Runner with a
    // valid identifier already in the App Store.

    // On Android, setup the Appcast below.
    final appcastURL =
        'https://raw.githubusercontent.com/larryaasen/upgrader/master/test/testappcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android']);
    setState(() {
      _upgradeConfig = cfg;
    });
  }

  _onVerificationSucceeded(String serverToken) async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);

    final res = await GoPortApi.instance.getDriver(
        generalProvider.serialNumber ?? "", _tzController.text, serverToken);
    setState(() {
      _loading = false;
    });

    if (res != null) {
      generalProvider.driver = res;
      if (generalProvider.driver!.blockType! > 0) {
        Utils.showAlertDialog(
            context: context,
            title: "",
            message: generalProvider.driver!.blockReason);
      } else if (generalProvider.driver!.phoneNumber!.isEmpty) {
        Utils.showAlertDialog(
            context: context,
            title: "",
            message:
                AppLocalizations.of(context).translate("Phone number not set"));
      } else {
        final SharedPreferences prefs = await _prefs;
        prefs.setString(Const.prefsLogOn, "1");
        prefs.setString(Const.prefsLastLoginTz, _tzController.text);

        generalProvider.setIsLoggedIn(true);
        if (generalProvider.driver!.populationType == 7) {
          //Driver
          Navigator.of(context).pushNamed('ActionTypeScreen');
        } else if (generalProvider.driver!.populationType == 2) {
          //Custom Broker
          Navigator.of(context).pushNamed('CustomBrokerScreen');
        }
      }
    }
  }

  _showServerDialog() {
    List<String> envs = ["PRD", "TEST", "BLUE", "DEV"];
    String currentEnv = "PRD";
    if (GoPortApi.instance.baseURL == Const.ServerEwaveBlue) {
      currentEnv = "BLUE";
    } else if (GoPortApi.instance.baseURL == Const.ServerEwaveTest) {
      currentEnv = "TEST";
    } else if (GoPortApi.instance.baseURL == Const.ServerEwaveDev) {
      currentEnv = "DEV";
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                  AppLocalizations.of(context).translate("Choose environment")),
              children: envs.map((env) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                    String baseURL = "";
                    switch (env) {
                      case "PRD":
                        baseURL = Const.ServerEwaveProd;
                        break;
                      case "BLUE":
                        baseURL = Const.ServerEwaveBlue;
                        break;
                      case "TEST":
                        baseURL = Const.ServerEwaveTest;
                        break;
                      case "DEV":
                        baseURL = Const.ServerEwaveDev;
                        break;
                    }
                    GoPortApi.instance.baseURL = baseURL;
                  },
                  child: Text(env),
                );
              }).toList());
        });
  }

  @override
  Widget build(BuildContext context) {
    final upgrader = Upgrader(
      appcastConfig: _upgradeConfig,
      debugLogging: true,
    );
    return WillPopScope(
      onWillPop: () async {
        if (_loading) {
          setState(() {
            _loading = false;
          });
        } else {
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
        }

        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () => {FocusScope.of(context).unfocus()},
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          body: UpgradeAlert(
            upgrader: upgrader,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Text(
                              "${AppLocalizations.of(context).translate("Version")} $_version ${_truck != null ? "| ${AppLocalizations.of(context).translate("Truck")} $_truck" : ""}",
                              style: TextStyle(
                                  color: colorGray,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("S. number"),
                                    style: TextStyle(
                                        color: colorGray,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                                SizedBox(
                                  width: 0,
                                ),
                                Consumer<GeneralProvider>(
                                  builder: (context, model, _) {
                                    if (model.serverToken != null) {
                                      _onVerificationSucceeded(
                                          model.serverToken ?? "");
                                      model.serverToken = null;
                                    }
                                    return Text(
                                      model.serialNumber ?? "",
                                      style: TextStyle(
                                          color: colorGray,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onLongPress: () {
                          _showServerDialog();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/new_logo1.png",
                              width: 160,
                              height: 160,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      screenMode == ScreenMode.Login
                          ? TextField(
                              autofocus: true,
                              controller: _tzController,
                              decoration: InputDecoration(
                                  focusColor: colorLogo2,
                                  hintText: AppLocalizations.of(context)
                                      .translate("Enter ID"),
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              style: TextStyle(fontSize: 20, color: colorLogo),
                              keyboardType: TextInputType.number,
                            )
                          : PinCodeTextField(
                              autoFocus: true,
                              autoDismissKeyboard: true,
                              appContext: context,
                              backgroundColor: Colors.transparent,
                              pastedTextStyle: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                              length: 5,
                              obscureText: false,
                              blinkWhenObscuring: true,
                              animationType: AnimationType.fade,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: Colors.white,
                                inactiveColor: colorDarkenGray,
                                selectedColor: colorDarkenGray,
                                selectedFillColor: Colors.transparent,
                                inactiveFillColor: Colors.transparent,
                                errorBorderColor: Colors.transparent,
                              ),
                              cursorColor: colorDarkenGray,
                              animationDuration: Duration(milliseconds: 300),
                              enableActiveFill: true,
                              errorAnimationController: _errorController,
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              boxShadows: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: Colors.black12,
                                  blurRadius: 10,
                                )
                              ],
                              onCompleted: (v) {
                                login();
                              },
                              // onTap: () {
                              //   print("Pressed");
                              // },
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  verifyCode = value;
                                });
                              },
                              beforeTextPaste: (text) {
                                print("Allowing to paste $text");
                                //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                return true;
                              },
                            ),
                      SizedBox(height: 30),
                      MaterialButton(
                        textColor: Colors.white,
                        onPressed: login,
                        color: colorLogo,
                        elevation: 6,
                        height: 40,
                        minWidth: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          AppLocalizations.of(context)
                              .translate(screenMode == ScreenMode.Login
                                  ? "Login"
                                  : "Verify")
                              .toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      Visibility(
                        visible: screenMode == ScreenMode.Otp,
                        child: TextButton(
                          child: Text(AppLocalizations.of(context)
                              .translate("Send again")),
                          style: TextButton.styleFrom(
                            foregroundColor: colorDarkenGray,
                          ),
                          onPressed: () {
                            setState(() {
                              login(sendCode: true);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        "assets/images/ewave_logo.png",
                        width: 200,
                      ),
                    )),
                _loading
                    ? AlertDialog(
                        title: Text(
                          AppLocalizations.of(context)
                              .translate("Verifying driver"),
                          style:
                              TextStyle(color: colorDarkenGray, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ))
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
