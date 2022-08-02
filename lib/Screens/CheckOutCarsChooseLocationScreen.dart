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
import 'package:goport/Models/Chassis.dart';
import 'package:goport/Models/ImporterChassis.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOutCarsChooseLocationScreen extends StatefulWidget {
  static String id = 'CheckOutCarsChooseLocationScreen';

  @override
  _CheckOutCarsChooseLocationScreenState createState() =>
      _CheckOutCarsChooseLocationScreenState();
}

class _CheckOutCarsChooseLocationScreenState
    extends State<CheckOutCarsChooseLocationScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _loading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TabController _tabController;
  List<BottomNavViewItem> navViewItems = [];
  List<String> _importers = [];
  List<ImporterChassis> _chassis = [];
  List<Chassis> _chosenChassis = [];
  List<Chassis> _availableChassis = [];
  String _currentImporter;
  bool _chooseImportersVisible = false;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: 2, vsync: this);
    navViewItems.add(BottomNavViewItem(
        title: "Prev", image: "ic_left_arrow.png", action: _onPrev));
    navViewItems.add(BottomNavViewItem(
        title: "Next", image: "ic_right_arrow.png", action: _onNext));

    Future.delayed(const Duration(seconds: 0)).then((value) {
      _loadData();
    });
  }

  _loadData() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;
    final truck = generalProvider.truck;

    setState(() {
      _loading = true;
    });

    Map args = ModalRoute.of(context).settings.arguments as Map;
    String guid = args["guid"].replaceAll("\"", "");

    List<String> res = await GoPortApi.instance.getImporter(guid);

    setState(() {
      _loading = false;
    });

    if (res != null) {
      setState(() {
        _importers = res;
      });
    }
  }

  _onPrev() {
    Utils.showConfirmDialog(
        context: context,
        title: "",
        okButton: AppLocalizations.of(context).translate("Yes"),
        cancelButton: AppLocalizations.of(context).translate("No"),
        message: AppLocalizations.of(context).translate("The data you entered will be deleted, confirm?"),
        onOk: () {
          Navigator.of(context).pop();
        });
  }

  _onNext() async {
    if (_chassis.length > 0) {
      int index = _chassis.indexWhere((element) => element.selected != null && element.selected);
      if (index != -1) {
        Map args = ModalRoute.of(context).settings.arguments as Map;
        String guidID = args["guid"].replaceAll("\"", "");

        List<ImporterChassis> selectedChassis =
            _chassis.where((e) => e.selected != null && e.selected).toList();

        setState(() {
          _loading = true;
        });

        List<Chassis> res = await GoPortApi.instance
            .getChassisByLocation(guidID, selectedChassis);

        setState(() {
          _loading = false;
        });

        if (res != null) {
          List<Chassis> chosenChassis = [];
          for (Chassis c in res) {
            if (c.isLoaded != null && c.isLoaded == true) {
              chosenChassis.add(c);
            }
          }

          setState(() {
            _chosenChassis = chosenChassis;
            _availableChassis = res;
          });
        }

        Navigator.of(context)
            .pushNamed('CheckOutInputChassisScreen', arguments: {
          "guidID": guidID,
          "chosenChassis": _chosenChassis,
          "availableChassis": _availableChassis
        });
        return;
      }
    }

    Utils.showToast(
        AppLocalizations.of(context).translate("You must choose location"));
  }

  _loadChassis() async {
    setState(() {
      _loading = true;
    });

    Map args = ModalRoute.of(context).settings.arguments as Map;
    String guid = args["guid"].replaceAll("\"", "");

    List<ImporterChassis> res =
        await GoPortApi.instance.getChassisByImporter(guid, _currentImporter);

    setState(() {
      _loading = false;
    });

    if (res != null) {
      setState(() {
        _chassis = res;
      });
    }
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = _chassis[index];
    return InkWell(
      onTap: () {
        item.selected = item.selected != null ? !item.selected : true;
        setState(() {

        });
      },
      child: Container(
        color: item.selected != null && item.selected ? colorBackground : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        item.location,
                        style: TextStyle(
                            color: colorLogo2,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)
                                .translate("Manufacturer") + ":",
                            style:
                                TextStyle(color: colorLightGray, fontSize: 13),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Text(
                            item.manufacturer,
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Model") + ":",
                            style:
                                TextStyle(color: colorLightGray, fontSize: 13),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Text(
                            item.model,
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: colorLogo,
                            ),
                            child: Text(
                              item.qty.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Container(
              height: 1,
              color: colorDivider,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Utils.showConfirmDialog(
            context: context,
            title: "",
            okButton: AppLocalizations.of(context).translate("Yes"),
            cancelButton: AppLocalizations.of(context).translate("No"),
            message: AppLocalizations.of(context).translate("The data you entered will be deleted, confirm?"),
            onOk: () {
              Navigator.of(context).pop();
            });
        return Future.value(false);
      },
      child: Scaffold(
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
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        child: Center(
                      child: Utils.showSingleChoiceDialog(
                          context: context,
                          title: AppLocalizations.of(context)
                              .translate("Choose importer"),
                          options: _importers,
                          selected: _currentImporter,
                          onSelect: (index, value) {
                            setState(() {
                              _currentImporter = value;
                              _loadChassis();
                            });
                          }),
                    )),
                    Container(height: 1, color: colorDivider),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: _chassis.length,
                          itemBuilder: (context, index) {
                            return _buildListItem(context, index);
                          }),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
                Positioned(
                    bottom: 0,
                    child: BottomNavView(
                      items: navViewItems,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
