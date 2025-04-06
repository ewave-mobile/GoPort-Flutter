import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Dialogs/AddChassisNumDialog.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/AvailableJobs.dart';
import 'package:goport/Models/BottomNavViewItem.dart';
import 'package:goport/Models/Chassis.dart';
import 'package:goport/Models/ImporterChassis.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOutInputChassisScreen extends StatefulWidget {
  static String id = 'CheckOutInputChassisScreen';

  @override
  _CheckOutInputChassisScreenState createState() =>
      _CheckOutInputChassisScreenState();
}

class _CheckOutInputChassisScreenState extends State<CheckOutInputChassisScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _loading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TabController? _tabController;
  List<BottomNavViewItem> navViewItems = [];
  List<String> _importers = [];
  List<Chassis> _chassis = [];
  String? _currentImporter;
  String? _quantityText;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: 2, vsync: this);
    navViewItems.add(BottomNavViewItem(
        title: "Prev", image: "ic_left_arrow.png", action: _onPrev));
    navViewItems.add(BottomNavViewItem(
        title: "Next", image: "ic_right_arrow.png", action: _onNext));

    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  _loadData() {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    List<Chassis> chosenChassis = args["chosenChassis"];

    setState(() {
      _chassis = chosenChassis;
    });

    _setQtyText();
  }

  _onPrev() {
    Navigator.of(context).pop(context);
  }

  _onNext() {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    List<Chassis> availableChassis = args["availableChassis"];
    String guidID = args["guidID"];

    Navigator.of(context).pushNamed('CheckOutSummaryScreen', arguments: {
      "guidID": guidID,
      "chosenChassis": _chassis,
      "availableChassis": availableChassis
    });
  }

  _onFloatActionPressed() {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    List<Chassis> availableChassis = args["availableChassis"];
    List<Chassis> chosenChassis = args["chosenChassis"];
    String guidID = args["guidID"];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddChassisNumDialog(
            availableChassis: availableChassis,
            chosenChassis: chosenChassis,
            onConfirm: (Chassis currentChassis) async {
              Navigator.pop(context, true);

              currentChassis.guidID = guidID;

              setState(() {
                _loading = true;
              });

              bool res =
                  await GoPortApi.instance.setChassisLoaded(currentChassis);

              setState(() {
                _loading = false;
              });
              if (res != null) {
                setState(() {
                  _chassis.add(currentChassis);
                });
                _setQtyText();
              } else {
                setState(() {
                  int index = _chassis.indexWhere((element) =>
                      element.chassisID == currentChassis.chassisID);
                  if (index != -1) {
                    _chassis.removeAt(index);
                  }
                });

                _setQtyText();
                Utils.showToast(AppLocalizations.of(context)
                    .translate("Shilda not available"));
              }
            },
            onCancel: () {
              Navigator.pop(context, true);
            },
          );
        });
  }

  _setQtyText() {
    Map args = ModalRoute.of(context)!.settings.arguments as Map;
    List<Chassis> availableChassis = args["availableChassis"];
    String qty = "${_chassis.length} / ${availableChassis.length}";
    setState(() {
      _quantityText = qty;
    });
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = _chassis[index];
    return Dismissible(
      key: Key(item.chassisID ?? ""),
      confirmDismiss: (DismissDirection direction) async {
        return await Utils.showConfirmDialog(
            context: context,
            title: "",
            okButton: AppLocalizations.of(context).translate("Delete"),
            cancelButton: AppLocalizations.of(context).translate("Cancel"),
            message: AppLocalizations.of(context)
                .translate("Are you sure you want to delete this item?"),
            onCancel: () => false,
            onOk: () {
              _onChassisRemoved(_chassis[index]);
            });
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: colorLogo2),
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      item.chassisID ?? "",
                      style: TextStyle(
                          color: colorLogo2,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )
                  ],
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
                          AppLocalizations.of(context)
                                  .translate("Manufacturer") +
                              ":",
                          style: TextStyle(color: colorLightGray, fontSize: 14),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          item.manufacturer ?? "",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context).translate("Model") + ":",
                          style: TextStyle(color: colorLightGray, fontSize: 14),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          item.model ?? "",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Container(
        margin: EdgeInsets.only(top: 50),
        child: FloatingActionButton(
          onPressed: () {
            _onFloatActionPressed();
          },
          child: Container(
            child: Image.asset(
              "assets/images/ic_playlist_add.png",
              width: 20,
              height: 20,
            ),
          ),
          elevation: 6,
          backgroundColor: colorLogo2,
        ),
      ),
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
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('Enter shilda number'),
                        style: TextStyle(
                            color: colorGray,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 70),
                        itemCount: _chassis.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _buildListItem(context, index);
                        }),
                  ),
                ],
              ),
              Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          _quantityText ?? "",
                          style: TextStyle(
                              color: colorGray,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.all(6),
                        color: colorDivider,
                        width: MediaQuery.of(context).size.width,
                      ),
                      BottomNavView(
                        items: navViewItems,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  _onChassisRemoved(Chassis currentChassis) async {
    setState(() {
      _loading = true;
    });

    bool res = await GoPortApi.instance.removeChosenChassis(currentChassis.id);

    setState(() {
      _loading = false;
    });
    if (res != null) {
      setState(() {
        _chassis.remove(currentChassis);
        _setQtyText();
      });
    } else {
      Utils.showToast(
          AppLocalizations.of(context).translate("Shilda not available"));
    }
  }
}
