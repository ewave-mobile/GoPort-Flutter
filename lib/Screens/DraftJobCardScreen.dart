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
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftJobCardScreen extends StatefulWidget {
  static String id = 'DraftJobCardScreen';

  @override
  _DraftJobCardScreenState createState() => _DraftJobCardScreenState();
}

class _DraftJobCardScreenState extends State<DraftJobCardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PortContainer> containers = [];
  int _notTakePhotoReasonId = -1;
  bool _loading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TabController? _tabController;
  List<BottomNavViewItem> navViewItems = [];

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);

    navViewItems.add(BottomNavViewItem(
        title: "Prev", image: "ic_left_arrow.png", action: _onPrev));
    navViewItems.add(BottomNavViewItem(
        title: "Cancel", image: "ic_action_delete.png", action: _onCancel));
    navViewItems.add(BottomNavViewItem(
        title: "Confirm", image: "ic_action_stop.png", action: _onConfirm));

    super.initState();

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      _initialize();
    });
  }

  _initialize() async {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    setState(() {
      if (arguments.containsKey("notTakePhotoReasonId")) {
        _notTakePhotoReasonId = arguments["notTakePhotoReasonId"];
      }
    });
  }

  _onPrev() {
    Navigator.of(context).pop(context);
  }

  _onCancel() {
    Utils.showConfirmDialog(
        context: context,
        title: "",
        okButton: AppLocalizations.of(context).translate("Confirm"),
        cancelButton: AppLocalizations.of(context).translate("Cancel"),
        message: AppLocalizations.of(context).translate("Cancel job card?"),
        onOk: () async {
          final driver =
              Provider.of<GeneralProvider>(context, listen: false).driver;

          setState(() {
            _loading = true;
          });

          bool res = await GoPortApi.instance
              .deleteDriverDraftContainers(driver!.tz ?? "");

          setState(() {
            _loading = false;
          });

          if (res) {
            final generalProvider =
                Provider.of<GeneralProvider>(context, listen: false);
            generalProvider.selectedInContainers = [];
            generalProvider.selectedOutContainers = [];

            _goToMainScreen();
          }
        });
  }

  _onConfirm() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;

    List<DraftJobCard> draftsList = [];

    setState(() {
      _loading = true;
    });

    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    final createDate = dateFormat.format(DateTime.now());

    for (PortContainer portContainer in generalProvider.selectedInContainers) {
      // if (portContainer.pickUpPlanTime.isEmpty) {
      //   showAlertDialog(
      //       context: context,
      //       message: AppLocalizations.of(context)
      //           .translate("Cannot save containers without plan"));
      //   setState(() {
      //     _loading = false;
      //   });
      //   return;
      // }

      DraftJobCard draft = new DraftJobCard(
        id: portContainer.draftID!,
        containerJobTypeID: 1,
        driverTZ: driver!.tz,
        containerNo: portContainer.actualCntrNo,
        createDate: DateTime.now(),
      );

      if (_notTakePhotoReasonId != -1) {
        draft.notTakePhotoReasonID = _notTakePhotoReasonId;
      } else {
        draft.plombaNumber = portContainer.plombaNumber;
        if (portContainer.imagePath != null) {
          draft.imageName = portContainer.imageName;
          draft.imagePath = portContainer.imagePath;

          try {
            String base64Image =
                Utils.convertImageToBase64(draft.imagePath ?? "");
            draft.image = base64Image;
          } on Exception catch (_) {}
        }
      }
      draftsList.add(draft);
    }

    for (PortContainer portContainer in generalProvider.selectedOutContainers) {
      // if (portContainer.pickUpPlanTime.isEmpty) {
      //   showAlertDialog(
      //       context: context,
      //       message: AppLocalizations.of(context)
      //           .translate("Cannot save containers without plan"));
      //   setState(() {
      //     _loading = true;
      //   });
      //   return;
      // }

      DraftJobCard draft = new DraftJobCard(
        id: portContainer.draftID!,
        containerJobTypeID: 2,
        driverTZ: driver!.tz,
        containerNo: portContainer.actualCntrNo,
        createDate: DateTime.now(),
      );
      draftsList.add(draft);
    }

    SaveContainersToDraft saveContainersToDraft = new SaveContainersToDraft(
        driverTZ: driver!.tz ?? "", containersToAdd: draftsList);

    String? res =
        await GoPortApi.instance.saveContainersToDraft(saveContainersToDraft);

    setState(() {
      _loading = false;
    });

    res = res != null ? res.replaceAll("\"", "") : "";

    if (res == "ok") {
      Utils.showToast(context,AppLocalizations.of(context).translate("Draft is ready"));
      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);
      generalProvider.selectedInContainers = [];
      generalProvider.selectedOutContainers = [];

      _goToMainScreen();
    } else if (res == "reject") {
      Utils.showConfirmDialog(
          message: AppLocalizations.of(context)
              .translate("Containers are not valid"),
          onOk: () {
            _goToMainScreen();
          },
          okButton: AppLocalizations.of(context).translate("Confirm"));
    } else if (res == "serviceError") {
      Utils.showToast(context,AppLocalizations.of(context).translate("Service error"));
    } else {
      Utils.showToast(context,res);
    }
  }

  _goToMainScreen() {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    generalProvider.setShowBackButton(false);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ActionTypeScreen()),
        (route) => false);
  }

  Widget _buildOutListItem(BuildContext context, int index) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    List<PortContainer> selectedOutContainers =
        generalProvider.selectedOutContainers;
    final item = selectedOutContainers[index];
    return Container(
      color: selectedOutContainers.contains(item)
          ? colorBackground
          : Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                        value: selectedOutContainers.contains(item),
                        onChanged: null),
                    SizedBox(
                      width: 6,
                    ),
                    Column(
                      children: [
                        Text(
                          item.actualCntrNo ?? "",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        item.pickUpPlanTime2 != null &&
                                item.pickUpPlanTime2 != ""
                            ? Text(
                                item.pickUpPlanTime2 ?? "",
                                style: TextStyle(
                                    color: colorLightGray,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    item.containerType == "DG"
                        ? Image.asset(
                            "assets/images/ic_warning_red.png",
                            width: 20,
                            height: 20,
                          )
                        : Container(),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Text(
                        item.containerType ?? "",
                        style: TextStyle(
                            color: colorLightGray,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("Agent"),
                      style: TextStyle(
                          color: colorLightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.shippingAgent ?? "",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("Status"),
                      style: TextStyle(
                          color: colorLightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.informationStatus ?? "",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("Company"),
                      style: TextStyle(
                          color: colorLightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.shipperCompanyName ?? "",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    item.remarks != null && item.remarks!.isNotEmpty
                        ? Text(
                            item.remarks!,
                            style: TextStyle(
                                color: colorError,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Container(
            height: 1,
            color: colorDivider,
          )
        ],
      ),
    );
  }

  Widget _buildInListItem(BuildContext context, int index) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    List<PortContainer> selectedInContainers =
        generalProvider.selectedInContainers;
    final item = selectedInContainers[index];
    return Container(
      color: selectedInContainers.contains(item)
          ? colorBackground
          : Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                        value: selectedInContainers.contains(item),
                        onChanged: null),
                    SizedBox(
                      width: 6,
                    ),
                    Column(
                      children: [
                        Text(
                          item.actualCntrNo ?? "",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        item.pickUpPlanTime2 != null &&
                                item.pickUpPlanTime2 != ""
                            ? Text(
                                item.pickUpPlanTime2 ?? "",
                                style: TextStyle(
                                    color: colorLightGray,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    item.fullEmptyContainer != null &&
                            item.fullEmptyContainer!.isNotEmpty
                        ? Image.asset(
                            item.fullEmptyContainer == "EMPTY"
                                ? "assets/images/ic_box_empty.png"
                                : "assets/images/ic_box_fill.png",
                            width: 20,
                            height: 20,
                          )
                        : Container(),
                    SizedBox(
                      width: 6,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Text(
                        item.size ?? "",
                        style: TextStyle(
                            color: colorLightGray,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("Type"),
                      style: TextStyle(
                          color: colorLightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.containerType ?? "",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    item.remarks != null && item.remarks!.isNotEmpty
                        ? Text(
                            item.remarks!,
                            style: TextStyle(
                                color: colorError,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )
                        : Container(),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).translate("Weight"),
                      style: TextStyle(
                          color: colorLightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.weight.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "",
                      style: TextStyle(
                          color: colorLightGray,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Container(
            height: 1,
            color: colorDivider,
          )
        ],
      ),
    );
  }

  Widget _buildInListView(BuildContext buildContext) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    List<PortContainer> selectedOutContainers =
        generalProvider.selectedOutContainers ?? [];
    return ListView.builder(
        shrinkWrap: true,
        itemCount: selectedOutContainers.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return _buildOutListItem(buildContext, index);
        });
  }

  Widget _buildOutListView(BuildContext buildContext) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    List<PortContainer> selectedInContainers =
        generalProvider.selectedInContainers ?? [];
    return ListView.builder(
        shrinkWrap: true,
        itemCount: selectedInContainers.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return _buildInListItem(buildContext, index);
        });
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
                      AppLocalizations.of(context).translate("-Draft-"),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorLightGray,
                          fontSize: 20),
                    ),
                  ),
                  Container(height: 1, color: colorDivider),
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints.expand(),
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          TabBar(
                            unselectedLabelColor: Colors.black,
                            labelColor: colorLogo2,
                            tabs: [
                              Tab(
                                text:
                                    '${AppLocalizations.of(context).translate("In Containers")}',
                              ),
                              Tab(
                                text:
                                    '${AppLocalizations.of(context).translate("Out Containers")}',
                              )
                            ],
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                          ),
                          AnimatedBuilder(
                              animation: _tabController!.animation!,
                              builder: (ctx, child) {
                                if (_tabController!.index == 0) {
                                  return _buildInListView(context);
                                } else {
                                  return _buildOutListView(context);
                                }
                              })
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                  bottom: 0,
                  child: BottomNavView(
                    items: navViewItems,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
