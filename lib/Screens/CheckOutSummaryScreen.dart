
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/BottomNavViewItem.dart';
import 'package:goport/Models/Chassis.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:goport/Screens/ActionTypeScreen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class CheckOutSummaryScreen extends StatefulWidget {
  static String id = 'CheckOutSummaryScreen';

  @override
  _CheckOutSummaryScreenState createState() => _CheckOutSummaryScreenState();
}

class _CheckOutSummaryScreenState extends State<CheckOutSummaryScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _loading = false;
  TabController? _tabController;
  List<BottomNavViewItem> navViewItems = [];
  List<Chassis> _chassis = [];

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
  }

  _onPrev() {
    Navigator.of(context).pop(context);
  }

  _onNext() {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.setShowBackButton(false);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ActionTypeScreen()),
        (route) => false);
  }

  _onReportDamage(Chassis chassis) async {
    setState(() {
      _loading = true;
    });

    bool res = await GoPortApi.instance.damageReporting(chassis);

    setState(() {
      _loading = false;
    });

    Utils.showToast(context,AppLocalizations.of(context)
        .translate(res ? "SMS was successfully sent" : "Failed to send SMS"));
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = _chassis[index];
    return Dismissible(
      key: Key(item.chassisID ?? ""),
      onDismissed: (direction) {
        Utils.showConfirmDialog(
            context: context,
            title: "",
            okButton: AppLocalizations.of(context).translate("Delete"),
            cancelButton: AppLocalizations.of(context).translate("Cancel"),
            message: AppLocalizations.of(context)
                .translate("Are you sure you want to delete this item?"),
            onOk: () {
              _onChassisRemoved(_chassis[index]);
            });
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
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
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                            .translate("Manufacturer") +
                                        ":",
                                    style: TextStyle(
                                        color: colorLightGray, fontSize: 12),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    item.manufacturer ?? "",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 18,
                              ),
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                            .translate("Model") +
                                        ":",
                                    style: TextStyle(
                                        color: colorLightGray, fontSize: 12),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    item.model ?? "",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 12),
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
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: FloatingActionButton(
                  onPressed: () {
                    _onReportDamage(item);
                  },
                  child: Container(
                    child: Image.asset(
                      "assets/images/ic_attach_file.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                  elevation: 6,
                  backgroundColor: colorLogo2,
                ),
              )
            ],
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
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate("Summary"),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorDarkenGray,
                              fontSize: 18),
                        ),
                        Text(
                          _chassis.length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorLogo2,
                              fontSize: 18),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(height: 1, color: colorDivider),
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 60),
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
      });
    } else {
      Utils.showToast(context,
          AppLocalizations.of(context).translate("Shilda not available"));
    }
  }
}
