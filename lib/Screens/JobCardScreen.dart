import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Dialogs/UpdateSerialDialog.dart';
import 'package:goport/Enums/GateAppStatusEnum.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/BottomNavViewItem.dart';
import 'package:goport/Models/JobCard.dart';
import 'package:goport/Models/JobCardContainer.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:goport/Screens/ActionTypeScreen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobCardScreen extends StatefulWidget {
  static String id = 'JobCardScreen';
  final List<String> items = [];

  @override
  _JobCardScreenState createState() => _JobCardScreenState();
}

class _JobCardScreenState extends State<JobCardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String? _guidID;
  JobCard? _jobCard;
  bool _loading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<BottomNavViewItem> navViewItems = [];

  @override
  void initState() {
    super.initState();

    navViewItems.add(BottomNavViewItem(
        title: "Cancel", image: "ic_action_cancel.png", action: _onCancel));
    navViewItems.add(BottomNavViewItem(
        title: "Print", image: "ic_action_print.png", action: _onPrint));
    navViewItems.add(BottomNavViewItem(
        title: "Confirm",
        image: "ic_action_check_form.png",
        action: _onConfirm));

    Future.delayed(Duration(milliseconds: 100)).then((_) {
      _initialize();
    });
  }

  _test() {
    JobCard jobCard = JobCard();
    jobCard.totalWeight = 5;
    jobCard.allowedWeightTruck = 10;
    jobCard.totalWeight = 20;
    jobCard.id = 10;
    jobCard.createDate = DateTime.now();
    jobCard.guidID = "1234";

    List<PortContainer> containerJobsIn = [];
    containerJobsIn.add(PortContainer(
        id: 1,
        actualCntrNo: "123",
        size: "1",
        containerType: "2",
        shippingAgent: "Me",
        weight: 30,
        positionContainer: "1",
        sealNo: "12",
        fullEmptyContainer: "EMPTY"));
    containerJobsIn.add(PortContainer(
        id: 1,
        actualCntrNo: "123",
        size: "1",
        containerType: "2",
        shippingAgent: "Me",
        weight: 30,
        positionContainer: "1",
        sealNo: "12",
        fullEmptyContainer: "EMPTY"));
    containerJobsIn.add(PortContainer(
        id: 1,
        actualCntrNo: "123",
        size: "1",
        containerType: "2",
        shippingAgent: "Me",
        weight: 30,
        positionContainer: "1",
        sealNo: "12",
        fullEmptyContainer: "EMPTY"));
    containerJobsIn.add(PortContainer(
        id: 1,
        actualCntrNo: "123",
        size: "1",
        containerType: "2",
        shippingAgent: "Me",
        weight: 30,
        positionContainer: "1",
        sealNo: "12",
        fullEmptyContainer: "EMPTY"));

    List<PortContainer> containerJobsOut = [];
    containerJobsOut.add(PortContainer(
        id: 1,
        actualCntrNo: "123",
        size: "1",
        containerType: "2",
        shippingAgent: "Me",
        weight: 30,
        positionContainer: "1",
        sealNo: "12",
        fullEmptyContainer: "EMPTY"));
    containerJobsOut.add(PortContainer(
        id: 1,
        actualCntrNo: "123",
        size: "1",
        containerType: "2",
        shippingAgent: "Me",
        weight: 30,
        positionContainer: "1",
        sealNo: "12",
        fullEmptyContainer: "EMPTY"));

    containerJobsOut.add(PortContainer(
        id: 1,
        actualCntrNo: "123",
        size: "1",
        containerType: "2",
        shippingAgent: "Me",
        weight: 30,
        positionContainer: "1",
        sealNo: "12",
        fullEmptyContainer: "EMPTY"));

    jobCard.containerJobsIn = containerJobsIn;
    jobCard.containerJobsOut = containerJobsOut;
    setState(() {
      _jobCard = jobCard;
    });
  }

  _initialize() async {
    //TODO: remove
    // setState(() {
    //   _guidID = "afe05385-c211-4952-b47a-fa9036cd388b23082021";
    // });
    //Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? guidID = prefs.getString('guidID');
    if (guidID !=null) {
      setState(() {
        _guidID = guidID;
      });
    }
    _loadJobCardData();
  }

  _loadJobCardData() async {
    setState(() {
      _loading = true;
    });

    JobCard? res = await GoPortApi.instance.getJobCardContainers(_guidID ?? "");

    setState(() {
      _loading = false;
      _jobCard = res;
    });
  }

  _onConfirm() {
    _setGateStatus(GateAppStatusEnum.JobCardOK);
  }

  _onCancel() {
    Utils.showConfirmDialog(
        context: context,
        title: "",
        okButton: AppLocalizations.of(context).translate("Yes"),
        cancelButton: AppLocalizations.of(context).translate("No"),
        message: AppLocalizations.of(context)
            .translate("Are you sure you want to cancel this job card?"),
        onOk: () {
          _setGateStatus(GateAppStatusEnum.JobCardCancel);
        });
  }

  _onPrint() {
    _setGateStatus(GateAppStatusEnum.JobCardOKAndPrint);
  }

  _setGateStatus(GateAppStatusEnum gateStatus) async {
    final driver = Provider.of<GeneralProvider>(context, listen: false).driver;

    setState(() {
      _loading = true;
    });

    bool res =
        await GoPortApi.instance.setGateStatus(driver!.tz ?? "", gateStatus);

    setState(() {
      _loading = false;
    });

    if (res) {
      if (gateStatus == GateAppStatusEnum.JobCardCancel) {
        _cancelJobCard();
      } else {
        _jobCard!.approved = true;
        setState(() {});
      }
    } else {
      Utils.showToast(context,
          AppLocalizations.of(context).translate("Error setting status"));
    }
  }

  _onShowSealNumberDialog(PortContainer portContainer) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return UpdateSerialDialog(
            portContainer: portContainer,
            onConfirm: (PortContainer updatedContainer) async {
              Navigator.pop(context, true);

              await _updateJobCardSealNumber(updatedContainer);
            },
            onCancel: () {
              Navigator.pop(context, true);
            },
          );
        });
  }

  _updateJobCardSealNumber(PortContainer container) async {
    setState(() {
      _loading = true;
    });

    JobCardContainer jobCardContainer =
        new JobCardContainer(container: container, guidID: _guidID ?? "");

    bool res = await GoPortApi.instance.updateJobCardSeal(jobCardContainer);

    setState(() {
      _loading = false;
    });

    if (res) {
      final index = _jobCard!.containerJobsOut!
          .indexWhere((element) => element.id == container.id);
      if (index != -1) {
        setState(() {
          _jobCard!.containerJobsOut![index] = container;
        });
      }
    } else {
      Utils.showGeneralErrorToast(context);
    }
  }

  _cancelJobCard() async {
    final driver = Provider.of<GeneralProvider>(context, listen: false).driver;

    setState(() {
      _loading = true;
    });

    bool res =
        await GoPortApi.instance.cancelJobCard(driver!.tz ?? "", _guidID!);

    setState(() {
      _loading = false;
    });

    if (res) {
      Utils.showToast(context,AppLocalizations.of(context)
          .translate("Job card successfully cancelled"));

      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);
      generalProvider.setShowBackButton(false);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ActionTypeScreen()),
          (route) => false);
    } else {
      Utils.showGeneralErrorToast(context);
    }
  }

  Widget _buildContainerItem(
      BuildContext context, PortContainer item, bool allowUpdateSealNum) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.actualCntrNo ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
                      Text(
                        item.containerType ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: colorLightGray),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        item.weight != null ? item.weight.toString() : "",
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
                        AppLocalizations.of(context).translate("Location"),
                        style: TextStyle(
                            color: colorLightGray,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        item.positionContainer ?? "",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  allowUpdateSealNum
                      ? InkWell(
                          onTap: () {
                            _onShowSealNumberDialog(item);
                          },
                          child: Image.asset(
                            "assets/images/ic_photo_camera.png",
                            width: 20,
                            height: 20,
                          ),
                        )
                      : Container(),
                  SizedBox(
                    width: allowUpdateSealNum ? 6 : 0,
                  ),
                  Text(
                    AppLocalizations.of(context).translate("Seal number"),
                    style: TextStyle(
                        color: colorLightGray,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    item.sealNo ?? "",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  item.imageName != null
                      ? Image.file(
                          File(item.imagePath ?? ""),
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: colorDivider,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;

    String createDate = _jobCard != null
        ? Utils.convertDate(_jobCard!.createDate!, "dd/MM/yy kk:mm:ss")
        : "";
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(height: 1, color: colorDivider),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).translate("Job Card"),
                            style: TextStyle(
                                color: colorLightGray,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Text(
                            createDate,
                            style: TextStyle(color: colorLogo2),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: colorDarkenGray, width: 1),
                            borderRadius: BorderRadius.circular(6)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate("Card number"),
                                    style: TextStyle(
                                        color: colorLightGray,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                      _jobCard != null
                                          ? _jobCard!.id!.toString()
                                          : "",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13))
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate("Company"),
                                    style: TextStyle(
                                        color: colorLightGray,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                      driver != null
                                          ? driver.companyName ?? ""
                                          : "",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13))
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)
                                            .translate("Allow weight"),
                                        style: TextStyle(
                                            color: colorLightGray,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                          _jobCard != null &&
                                                  _jobCard!
                                                          .allowedWeightTruck !=
                                                      null
                                              ? _jobCard!.allowedWeightTruck
                                                  .toString()
                                              : "0",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)
                                            .translate("Total weight"),
                                        style: TextStyle(
                                            color: colorLightGray,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                          _jobCard != null &&
                                                  _jobCard!.totalWeight != null
                                              ? _jobCard!.totalWeight.toString()
                                              : "0",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13))
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    _jobCard != null && _jobCard!.containerJobsIn!.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: colorDarkenGray, width: 1),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(6),
                                      topLeft: Radius.circular(6))),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        topLeft: Radius.circular(4)),
                                    child: Container(
                                      color: colorDarkenGray,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      "Import containers"),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          _jobCard!.containerJobsIn!.length,
                                      itemBuilder: (context, index) {
                                        PortContainer portContainer =
                                            _jobCard!.containerJobsIn![index];
                                        return _buildContainerItem(
                                            context, portContainer, false);
                                      })
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    _jobCard != null && _jobCard!.containerJobsOut!.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: colorDarkenGray, width: 1),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(6),
                                      topLeft: Radius.circular(6))),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        topLeft: Radius.circular(4)),
                                    child: Container(
                                      color: colorDarkenGray,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      "Export containers"),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          _jobCard!.containerJobsOut!.length,
                                      itemBuilder: (context, index) {
                                        PortContainer portContainer =
                                            _jobCard!.containerJobsOut![index];
                                        return _buildContainerItem(
                                            context, portContainer, true);
                                      })
                                ],
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
              _jobCard != null && _jobCard!.approved == true
                  ? Container()
                  : Positioned(
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
