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
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Models/Technician.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InOutContainersScreen extends StatefulWidget {
  static String id = 'InOutContainersScreen';

  @override
  _InOutContainersScreenState createState() => _InOutContainersScreenState();
}

class _InOutContainersScreenState extends State<InOutContainersScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PortContainer> containers = [];
  late bool _loading;
  AvailableJobs? _availableJobs;
  List<Technician?> _techniciansList = [];
  TabController? _tabController;
  List<PortContainer> _selectedInContainers = [];
  List<PortContainer> _selectedOutContainers = [];
  List<BottomNavViewItem> navViewItems = [];

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    navViewItems.add(BottomNavViewItem(
        title: "Prev", image: "ic_left_arrow.png", action: _onPrev));
    navViewItems.add(BottomNavViewItem(
        title: "Next", image: "ic_right_arrow.png", action: _onNext));
    _loadData();

    super.initState();
  }

  _loadData() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;
    final truck = generalProvider.truck;

    setState(() {
      _loading = true;
    });

    AvailableJobs? res =
        await GoPortApi.instance.getAvailableJobs(driver!.tz ?? "", truck!.num);

    setState(() {
      _loading = false;
    });

    if (res != null) {
      if (res.containerJobsIn.isNotEmpty || res.containerJobsOut.isNotEmpty) {
        List<PortContainer> selectedInContainers = res.containerJobsIn
            .where((item) => item.draftID != null && item.draftID! > 0)
            .toList();
        List<PortContainer> selectedOutContainers = res.containerJobsOut
            .where((item) => item.draftID != null && item.draftID! > 0)
            .toList();

        List<Technician?> techniciansList =
            await GoPortApi.instance.getTechnicians();
        setState(() {
          _availableJobs = res;
          _techniciansList = techniciansList;
          _selectedInContainers = selectedInContainers;
          _selectedOutContainers = selectedOutContainers;
        });
      } else {
        Utils.showAlertDialog(
            context: context,
            message: AppLocalizations.of(context)
                .translate("Containers Not Found For Import &amp; Export"));
      }
    }
  }

  _onPrev() {
    Navigator.of(context).pop(context);
  }

  _onNext() {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    final driver = generalProvider.driver;
    generalProvider.selectedInContainers = _selectedInContainers;
    generalProvider.selectedOutContainers = _selectedOutContainers;

    //TODO: remove
    if (driver!.autoLaneAuthorization! && _selectedInContainers.length > 0) {
      Utils.showToast(context,AppLocalizations.of(context).translate(
          "You are approved for green path, please enter seal number and picture"));

      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.of(context).pushNamed("AutoLaneScreen");
      });
    } else {
      if (_selectedInContainers.length == 0 &&
          _selectedOutContainers.length == 0) {
        Utils.showAlertDialog(
            context: context, message: "No containers selected");
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pushNamed("DraftJobCardScreen");
        });
      }
    }
  }

  Widget _buildOutListItem(BuildContext context, int index) {
    final item = _availableJobs!.containerJobsOut[index];
    return Container(
      color: _selectedOutContainers.contains(item)
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
                        value: _selectedOutContainers.contains(item),
                        onChanged: (value) {
                          if (_selectedOutContainers.contains(item)) {
                            _selectedOutContainers.remove(item);
                          } else {
                            _selectedOutContainers.add(item);
                          }
                          setState(() {});
                        }),
                    SizedBox(
                      width: 6,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          item.pickUpPlanTime2 ?? "",
                          style: TextStyle(
                              color: colorLightGray,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
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
    final item = _availableJobs!.containerJobsIn[index];
    return Container(
      color: _selectedInContainers.contains(item)
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
                        value: _selectedInContainers.contains(item),
                        onChanged: (value) {
                          if (_selectedInContainers.contains(item)) {
                            _selectedInContainers.remove(item);
                          } else {
                            _selectedInContainers.add(item);
                          }
                          setState(() {});
                        }),
                    SizedBox(
                      width: 6,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          item.pickUpPlanTime2 ?? "",
                          style: TextStyle(
                              color: colorLightGray,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
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
    return Column(
      children: [
        Container(
          height: 1,
          color: colorDivider,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: _availableJobs!.containerJobsIn.length,
            itemBuilder: (BuildContext buildContext, int index) {
              return _buildInListItem(buildContext, index);
            }),
      ],
    );
  }

  Widget _buildOutListView(BuildContext buildContext) {
    return Column(
      children: [
        Container(
          height: 1,
          color: colorDivider,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: _availableJobs!.containerJobsOut.length,
            itemBuilder: (BuildContext buildContext, int index) {
              return _buildOutListItem(buildContext, index);
            }),
      ],
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
                                    '${AppLocalizations.of(context).translate("In Containers")} (${_availableJobs != null ? _availableJobs!.containerJobsOut.length : 0})',
                              ),
                              Tab(
                                text:
                                    '${AppLocalizations.of(context).translate("Out Containers")} (${_availableJobs != null ? _availableJobs!.containerJobsIn.length : 0})',
                              )
                            ],
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.tab,
                          ),
                          _availableJobs != null
                              ? AnimatedBuilder(
                                  animation: _tabController!.animation!,
                                  builder: (ctx, child) {
                                    if (_tabController!.index == 0) {
                                      return _buildOutListView(context);
                                    } else
                                      return _buildInListView(context);
                                  })
                              : Container(),
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
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
