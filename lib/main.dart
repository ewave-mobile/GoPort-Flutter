import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goport/Components/ActionBar.dart';
import 'package:goport/Providers/LocationProvider.dart';
import 'package:goport/Screens/ActionTypeScreen.dart';
import 'package:goport/Screens/AutoLaneScreen.dart';
import 'package:goport/Screens/CheckOutCarsChooseLocationScreen.dart';
import 'package:goport/Screens/CheckOutSummaryScreen.dart';
import 'package:goport/Screens/CustomBrokerScreen.dart';
import 'package:goport/Screens/LoginScreen.dart';
import 'package:goport/Screens/MenuScreen.dart';
import 'package:goport/Screens/ShipyardDataScreen.dart';
import 'package:provider/provider.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Const/Const.dart';
import 'Dialogs/InputTrackDialog.dart';
import 'Enums/GateAppStatusEnum.dart';
import 'Enums/PushyMessageTypeEnum.dart';
import 'Helpers/AppLocalizations.dart';
import 'Helpers/Utils.dart';
import 'Network/GoPortApi.dart';
import 'Providers/GeneralProvider.dart';
import 'Screens/CargoException.dart';
import 'Screens/CheckOutInputChassisScreen.dart';
import 'Screens/DraftJobCardScreen.dart';
import 'Screens/InOutContainersScreen.dart';
import 'Screens/JobCardScreen.dart';
import 'Screens/SplashScreen.dart';
import 'package:get_it/get_it.dart';

import 'Screens/ViewHeavyTrafficScreen.dart';

GetIt getIt = GetIt.instance;
_MyAppState? currentState;

// Please place this code in main.dart,
// After the import statements, and outside any Widget class (top-level)

void backgroundNotificationListener(Map<String, dynamic> data) {
  // Print notification payload data
  if (currentState != null) {
    currentState!.onNewNotification(currentState!, data);
  }
  //getIt<GeneralProvider>().setServerToken("1234");
  // print('Received notification: $data');
  //
  // final messageTypeId = data["messageTypeID"];
  // if (messageTypeId == "16") {
  //   //Verification successful
  //   final token = data["token"];
  //
  //   getIt<GeneralProvider>().setServerToken(token);
  // }
  // Pushy.clearBadge();
}

void main() {
  runApp(MultiProvider(
    child: MyApp(),
    providers: [
      ChangeNotifierProvider<GeneralProvider>(create: (_) => GeneralProvider()),
      ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider())
    ],
  ));
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state!.changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var initialRouteId = LoginScreen.id;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  AppLifecycleState? _appState;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Locale _locale = Locale(Platform.localeName);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appState = state;
    });
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    if (locales != null && locales.isNotEmpty) {
      setState(() {
        _locale = locales.first;
      });
    }
  }

  changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    currentState = this;

    Pushy.listen();
    Pushy.setNotificationListener(backgroundNotificationListener);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onNewNotification(
      _MyAppState appState, Map<String, dynamic> data) async {
    print('Received notification: $data');
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    Provider.of<GeneralProvider>(context, listen: false);
    final SharedPreferences prefs = await _prefs;

    String gate;
    String guidID;
    String message;
    final String driverTZ = data["driverTZ"];

    if (data.containsKey("gate")) {
      gate = data["gate"];
    } else {
      gate = "0";
    }
    if (data.containsKey("guidID")) {
      guidID = data["guidID"];

    } else {
      guidID = "";
    }
    prefs.setString('guidID',  guidID);
    if (data.containsKey("message")) {
      message = data["message"];
    } else {
      message = "";
    }

    final messageTypeId = data["messageTypeID"];
    if (messageTypeId ==
        PushyMessageTypeEnum.SuccessfullyVerified.index.toString()) {
      //Verification successful
      final token = data["token"];
      generalProvider.setServerToken(token);
    } else if (messageTypeId ==
            PushyMessageTypeEnum.GateStatus.index.toString() ||
        messageTypeId == PushyMessageTypeEnum.SendJobCard.index.toString()) {
      //Send job card
      if (messageTypeId == PushyMessageTypeEnum.SendJobCard.index.toString()) {
        prefs.setBool(Const.prefsWaitingJobCard, false);
      }
      if (prefs.getString(Const.prefsLogOn) == "1") {
        ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // Utils.showToast(_navigatorKey.currentContext!,message);
        //_showMessageIncoming(guidID, driverTZ, messageTypeId);
        if (messageTypeId ==
            PushyMessageTypeEnum.SendJobCard.index.toString()) {
          _navigatorKey.currentState?.pushNamed("JobCardScreen");
        }
      } else {
        //TODO: show in-app notification
      }
    } else if (messageTypeId ==
        PushyMessageTypeEnum.ActualJobError.index.toString()) {
      Utils.showAlertDialog(
          context: _navigatorKey.currentContext!,
          title: AppLocalizations.instance.translate("Actual job error"),
          message: message,
          onOk: null);
    } else if (messageTypeId ==
        PushyMessageTypeEnum.ExitThePort.index.toString()) {
      String? message;
      switch (gate) {
        case "4":
          message = AppLocalizations.instance
              .translate("You've successfully finished your job. Good luck!");
          break;
        case "5":
          message = AppLocalizations.instance.translate(
              "Your job in the port has been declined. Please leave the port.");
          break;
        case "13":
          message = AppLocalizations.instance
              .translate("You've successfully finished your job. Good luck!");
          break;
      }


      Function onOk = () async {
        final SharedPreferences prefs = await _prefs;
        prefs.setString(Const.prefsLogOn, "0");
        generalProvider.setIsLoggedIn(false);
        generalProvider.driver = null;
        Navigator.pushAndRemoveUntil(
            _navigatorKey.currentContext!,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      };

      Utils.showAlertDialog(
          context: _navigatorKey.currentContext!,
          title: "",
          message: message ?? "",
          onOk: onOk);
    }
    /*else if (messageTypeId ==    PushyMessageTypeEnum.NotAcceptedApp.index.toString()){
      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    else if (  messageTypeId ==  PushyMessageTypeEnum.GateStatusSendSupport.index.toString()){
      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    else if (  messageTypeId ==  PushyMessageTypeEnum.WaitingJobCard.index.toString()) {
      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }*/
    Pushy.clearBadge();
  }

  _showMessageIncoming(String guidID, String driverTZ, int messageType) {
    String message="";

    switch(messageType){

    }

    if(message!=null&&message!="") {
      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  /*  Map data = {
      "guidID": guidID,
      "driverTZ": driverTZ,
      "pushyMessageType": messageType
    };
    FBroadcast.instance().broadcast(
      Const.eventIncomingMessage,
      value: data,
    );*/
  }

  _onShowLanguage() async {
    List<String> languages = ["English", "עברית", "Русский", "عربي"];
    Locale _locale = Locale(Platform.localeName);
    int selectedIndex;

    switch (_locale.languageCode) {
      case "en":
        selectedIndex = 0;
        break;
      case "he":
        selectedIndex = 1;
        break;
      case "ru":
        selectedIndex = 2;
        break;
      case "ar":
        selectedIndex = 3;
        break;
    }

    switch (await showDialog<String>(
        context: _navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(_navigatorKey.currentContext!)
                .translate("Choose language")),
            children: languages.map((element) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, element);
                },
                child: Text(element),
              );
            }).toList(),
          );
        })) {
      case "English":
        MyApp.setLocale(_navigatorKey.currentContext!,
            Locale.fromSubtags(languageCode: "en"));
        break;
      case "עברית":
        MyApp.setLocale(_navigatorKey.currentContext!,
            Locale.fromSubtags(languageCode: "he"));
        break;
      case "Русский":
        MyApp.setLocale(_navigatorKey.currentContext!,
            Locale.fromSubtags(languageCode: "ru"));
        break;
      case "عربي":
        MyApp.setLocale(_navigatorKey.currentContext!,
            Locale.fromSubtags(languageCode: "ar"));
        break;
    }
  }

  _onShowTrackDialog() {
    showDialog(
        context: _navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return InputTrackDialog(
            onConfirm: (String truckNum, String trailerNum) async {
              Navigator.pop(_navigatorKey.currentContext!, true);

              await _getVehicleDetails(truckNum, trailerNum);
              // _initializeData();
            },
            onCancel: () {
              Navigator.pop(_navigatorKey.currentContext!, true);
            },
          );
        });
  }

  _onSupportPressed(BuildContext context) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;
    Utils.showConfirmDialog(
        context: context,
        title: "",
        okButton: AppLocalizations.of(context).translate("Yes"),
        cancelButton: AppLocalizations.of(context).translate("No"),
        message:
            AppLocalizations.of(context).translate("Confirm sending support?"),
        onOk: () async {
          bool res = await GoPortApi.instance
              .setGateStatus(driver!.tz ?? "", GateAppStatusEnum.SendToSupport);
          Utils.showAlertDialog(
              context: context,
              message: AppLocalizations.of(context).translate(
                  "Some error has occurred, please contact - 088590060"),
              onOk: () async {
                final SharedPreferences prefs = await _prefs;
                generalProvider.setIsLoggedIn(false);
                generalProvider.driver = null;
                prefs.setString(Const.prefsLogOn, "0");
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false);
              });
        });
  }

  _getVehicleDetails(String truck, String trailer) async {
    final context = _navigatorKey.currentContext;
    final generalProvider =
        Provider.of<GeneralProvider>(context!, listen: false);
    final driver = generalProvider.driver;

    // setState(() {
    //   _controlsEnabled = true;
    //   _loading = true;
    // });
    //
    final res = await GoPortApi.instance
        .getVehicleDetails(truck, driver!.tz ?? "", trailer);

    // setState(() {
    //   _loading = false;
    // });

    if (res != null) {
      if (res.isBlock ?? false) {
        Utils.showAlertDialog(context: context, message: res.blockReason);
        //setTruckError();
      } else {
        generalProvider.setTruck(res.truck);
        generalProvider.setTrailer(res.trailer);

        if (driver.companyNumber != generalProvider.truck!.companyNumber) {
          generalProvider.setTruck(null);
          generalProvider.setTrailer(null);
          Utils.showAlertDialog(
              context: context,
              message: AppLocalizations.of(context)
                  .translate("Truck or Trailer Number Not Match"));
        } else {
          // _initializeData();
          // setState(() {
          //   _controlsEnabled = true;
          // });
        }
      }
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    final generalProvider =
        Provider.of<GeneralProvider>(buildContext, listen: true);
    final isLoggedIn = generalProvider.loggedIn;
    return MaterialApp(
      title: 'GoPort',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) => SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        appBar: isLoggedIn
            ? ActionBar(
                scaffoldKey: _scaffoldKey,
                onBackPressed: () =>
                    _navigatorKey.currentState!.pop(buildContext),
                onSupportPressed: () =>
                    this._onSupportPressed(_navigatorKey.currentContext!))
            : null,
        drawer: MenuScreen(
            scaffoldKey: _scaffoldKey,
            navigatorKey: _navigatorKey,
            onShowLanguage: _onShowLanguage,
            onShowTruckDetails: _onShowTrackDialog),
        body: child,
      )),
      home: LoginScreen(),
      initialRoute: initialRouteId,
      navigatorKey: _navigatorKey,
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en', 'EN'),
        const Locale('he', 'HE'),
        const Locale('ru', 'RU'),
        const Locale('ar', 'AR')
      ],
      locale: _locale,
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      onGenerateRoute: (settings) {
        if (settings.name == SplashScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: SplashScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => SplashScreen());
        }
        if (settings.name == LoginScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: LoginScreen.id, arguments: settings.arguments ?? Map()),
              builder: (_) => LoginScreen());
        }
        if (settings.name == ActionTypeScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: ActionTypeScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => ActionTypeScreen());
        }
        if (settings.name == InOutContainersScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: InOutContainersScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => InOutContainersScreen());
        }
        if (settings.name == AutoLaneScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: AutoLaneScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => AutoLaneScreen());
        }
        if (settings.name == DraftJobCardScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: DraftJobCardScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => DraftJobCardScreen());
        }
        if (settings.name == JobCardScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: JobCardScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => JobCardScreen());
        }
        if (settings.name == CheckOutCarsChooseLocationScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: CheckOutCarsChooseLocationScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => CheckOutCarsChooseLocationScreen());
        }
        if (settings.name == CheckOutInputChassisScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: CheckOutInputChassisScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => CheckOutInputChassisScreen());
        }
        if (settings.name == CheckOutSummaryScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: CheckOutSummaryScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => CheckOutSummaryScreen());
        }
        if (settings.name == ViewHeavyTrafficScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: ViewHeavyTrafficScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => ViewHeavyTrafficScreen());
        }
        if (settings.name == CustomBrokerScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: CustomBrokerScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => CustomBrokerScreen());
        }

        if (settings.name == ShipyardDataScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: ShipyardDataScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => ShipyardDataScreen());
        }

        if (settings.name == CargoExceptionScreen.id) {
          return MaterialPageRoute(
              settings: RouteSettings(
                  name: CargoExceptionScreen.id,
                  arguments: settings.arguments ?? Map()),
              builder: (_) => CargoExceptionScreen());
        }

        return null;
      },
    );
  }
}
