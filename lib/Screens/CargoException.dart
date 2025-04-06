import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Dialogs/SignatureDialog.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/AvailableJobs.dart';
import 'package:goport/Models/BottomNavViewItem.dart';
import 'package:goport/Models/ChargeException.dart';
import 'package:goport/Models/DraftJobCard.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Models/SaveContainersToDraft.dart';
import 'package:goport/Models/Ship.dart';
import 'package:goport/Models/Technician.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:goport/Screens/ActionTypeScreen.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CargoExceptionScreen extends StatefulWidget {
  static String id = 'CargoExceptionScreen';

  @override
  _CargoExceptionScreenState createState() => _CargoExceptionScreenState();
}

class _CargoExceptionScreenState extends State<CargoExceptionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _loading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int expandedIndex = 0;
  final TextEditingController _containerNumController =
      new TextEditingController();
  final TextEditingController _truckNumController = new TextEditingController();
  final TextEditingController _trailerNumController =
      new TextEditingController();

  bool _containerNumMissing = false;
  bool _truckNumMissing = false;

  final TextEditingController _declaredClosureController =
      new TextEditingController();
  final TextEditingController _activeClosureController =
      new TextEditingController();
  final TextEditingController _declaredWeightController =
      new TextEditingController();
  final TextEditingController _activeWeightController =
      new TextEditingController();
  final TextEditingController _goodsController = new TextEditingController();

  bool _wrongClosure = false;
  bool _wrongWeight = false;
  bool _wrongGoods = false;

  bool _declaredClosureMissing = false;
  bool _activeClosureMissing = false;
  bool _declaredWeightMissing = false;
  bool _activeWeightMissing = false;
  bool _goodsMissing = false;

  Uint8List? _signatureData;

  @override
  void initState() {
    super.initState();
  }

  _onUpdateCargoException() async {
    setState(() {
      _loading = true;
    });

    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    ChargeException chargeException = new ChargeException();
    chargeException.driverTZ = generalProvider.driver!.tz;
    chargeException.driverName = generalProvider.driver!.firstName! +
        " " +
        generalProvider.driver!.lastName!;
    chargeException.companyName = generalProvider.driver!.companyName;
    chargeException.containerNum = _containerNumController.text;
    chargeException.truckNum = _truckNumController.text;
    chargeException.trailerNum = _trailerNumController.text;

    chargeException.sealNotMatch = _wrongClosure;
    if (_wrongClosure) {
      chargeException.sealNotMatchDeclared = _declaredClosureController.text;
      chargeException.sealNotMatchActually = _activeClosureController.text;
    }

    chargeException.weightMismatched = _wrongWeight;
    if (_wrongWeight) {
      chargeException.weightMismatchedDeclared = _declaredWeightController.text;
      chargeException.weightMismatchedActually = _activeWeightController.text;
    }

    chargeException.goodsMismatched = _wrongGoods;
    if (_wrongGoods) {
      chargeException.goodsMismatchedRemark = _goodsController.text;
    }

    String base64Image = Utils.convertImageBytesToBase64(_signatureData!);
    chargeException.signature = base64Image;

    chargeException.createDate = DateTime.now();

    bool res = await GoPortApi.instance.updateChargeException(chargeException);

    setState(() {
      _loading = false;
    });

    if (res) {
      Utils.showToast(AppLocalizations.of(context)
          .translate("The details were successfully submitted."));
      Navigator.pop(context, true);
    } else {
      Utils.showToast(AppLocalizations.of(context)
          .translate("The details failed to submit."));
    }
  }

  onShowSignatureDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SignatureDialog(
            onConfirm: (Uint8List data) async {
              setState(() {
                _signatureData = data;
              });
              Navigator.pop(context, true);
            },
            onCancel: () {
              Navigator.pop(context, true);
            },
          );
        });
  }

  Widget _buildListItem(BuildContext context, int index) {
    switch (index) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color:
                            index <= expandedIndex ? colorLogo2 : buttonColor,
                        shape: BoxShape.circle),
                    child: expandedIndex > index
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              "assets/images/ic_checkmark.png",
                              width: 14,
                              height: 14,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              index.toString(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    AppLocalizations.of(context).translate("Cargo Details"),
                    style: TextStyle(
                      color: expandedIndex == index ? Colors.black : colorGray,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              expandedIndex == index
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Align(
                        child: Column(
                          children: [
                            TextField(
                              controller: _containerNumController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  focusColor: _containerNumMissing
                                      ? colorError
                                      : colorLogo2,
                                  labelText: AppLocalizations.of(context)
                                      .translate("Container/cargo number"),
                                  hintText: AppLocalizations.of(context)
                                      .translate(
                                          "Enter container/cargo number"),
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            _containerNumMissing
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate("Mandatory field"),
                                          style: TextStyle(
                                              color: colorError, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 6,
                            ),
                            TextField(
                              controller: _truckNumController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  focusColor: _truckNumMissing
                                      ? colorError
                                      : colorLogo2,
                                  hintText: AppLocalizations.of(context)
                                      .translate("Enter truck number"),
                                  labelText: AppLocalizations.of(context)
                                      .translate("Truck number"),
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            _truckNumMissing
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate("Mandatory field"),
                                          style: TextStyle(
                                              color: colorError, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: 6,
                            ),
                            TextField(
                              keyboardType: TextInputType.number,
                              controller: _trailerNumController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  focusColor: colorLogo2,
                                  hintText: AppLocalizations.of(context)
                                      .translate("Enter trailer number"),
                                  labelText: AppLocalizations.of(context)
                                      .translate("Trailer number"),
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                child: Container(
                                  color: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 6),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Next"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _containerNumMissing = false;
                                    _truckNumMissing = false;
                                    if (_containerNumController.text.isEmpty) {
                                      setState(() {
                                        _containerNumMissing = true;
                                      });
                                    } else if (_truckNumController
                                        .text.isEmpty) {
                                      setState(() {
                                        _truckNumMissing = true;
                                      });
                                    } else {
                                      expandedIndex = 1;
                                    }
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color:
                            index <= expandedIndex ? colorLogo2 : buttonColor,
                        shape: BoxShape.circle),
                    child: expandedIndex > index
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset("assets/images/ic_checkmark.png",
                                width: 14, height: 14),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              index.toString(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    AppLocalizations.of(context).translate("Delay Reason"),
                    style: TextStyle(
                      color: expandedIndex == index ? Colors.black : colorGray,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              expandedIndex == index
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                      value: _wrongClosure,
                                      onChanged: (value) {
                                        setState(() {
                                          _wrongClosure = !_wrongClosure;
                                        });
                                      }),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate("Closure mismatch"),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 0,
                              ),
                              _wrongClosure
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 100,
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      _declaredClosureController,
                                                  decoration: InputDecoration(
                                                      focusColor:
                                                          _declaredClosureMissing
                                                              ? colorError
                                                              : colorLogo2,
                                                      hintText: AppLocalizations
                                                              .of(context)
                                                          .translate(
                                                              "Declared"),
                                                      labelText:
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  "Declared"),
                                                      hintStyle: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey)),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              _declaredClosureMissing
                                                  ? Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "Mandatory field"),
                                                            style: TextStyle(
                                                                color:
                                                                    colorError,
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: 100,
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      _activeClosureController,
                                                  decoration: InputDecoration(
                                                      focusColor:
                                                          _activeClosureMissing
                                                              ? colorError
                                                              : colorLogo2,
                                                      hintText: AppLocalizations
                                                              .of(context)
                                                          .translate("Actual"),
                                                      labelText:
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  "Actual"),
                                                      hintStyle: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey)),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              _activeClosureMissing
                                                  ? Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "Mandatory field"),
                                                            style: TextStyle(
                                                                color:
                                                                    colorError,
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                      value: _wrongWeight,
                                      onChanged: (value) {
                                        setState(() {
                                          _wrongWeight = !_wrongWeight;
                                        });
                                      }),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate("Weight mismatch"),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              _wrongWeight
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 100,
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      _declaredWeightController,
                                                  decoration: InputDecoration(
                                                      focusColor:
                                                          _declaredWeightMissing
                                                              ? colorError
                                                              : colorLogo2,
                                                      hintText: AppLocalizations
                                                              .of(context)
                                                          .translate(
                                                              "Declared"),
                                                      labelText:
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  "Declared"),
                                                      hintStyle: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey)),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              _declaredWeightMissing
                                                  ? Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "Mandatory field"),
                                                            style: TextStyle(
                                                                color:
                                                                    colorError,
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: 100,
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      _activeWeightController,
                                                  decoration: InputDecoration(
                                                      focusColor:
                                                          _activeWeightMissing
                                                              ? colorError
                                                              : colorLogo2,
                                                      hintText: AppLocalizations
                                                              .of(context)
                                                          .translate("Actual"),
                                                      labelText:
                                                          AppLocalizations.of(
                                                                  context)
                                                              .translate(
                                                                  "Actual"),
                                                      hintStyle: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.grey)),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              _activeWeightMissing
                                                  ? Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            AppLocalizations.of(
                                                                    context)
                                                                .translate(
                                                                    "Mandatory field"),
                                                            style: TextStyle(
                                                                color:
                                                                    colorError,
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                  value: _wrongGoods,
                                  onChanged: (value) {
                                    setState(() {
                                      _wrongGoods = !_wrongGoods;
                                    });
                                  }),
                              Text(
                                AppLocalizations.of(context)
                                    .translate("Goods mismatch"),
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          _wrongGoods
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 150,
                                        color: Colors.white,
                                        child: TextField(
                                          controller: _goodsController,
                                          maxLines: null,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      _goodsMissing
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            "Mandatory field"),
                                                    style: TextStyle(
                                                        color: colorError,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Container(
                                  color: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 6),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Prev"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    expandedIndex = 0;
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  color: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 6),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Next"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    bool error = false;
                                    if (_wrongClosure) {
                                      if (_declaredClosureController
                                          .text.isEmpty) {
                                        _declaredClosureMissing = true;
                                        error = true;
                                      }
                                      if (_activeClosureController
                                          .text.isEmpty) {
                                        _activeClosureMissing = true;
                                        error = true;
                                      }
                                    } else if (_wrongWeight) {
                                      if (_declaredWeightController
                                          .text.isEmpty) {
                                        _declaredWeightMissing = true;
                                        error = true;
                                      }
                                      if (_activeWeightController
                                          .text.isEmpty) {
                                        _activeWeightMissing = true;
                                        error = true;
                                      }
                                    } else if (_wrongGoods) {
                                      if (_goodsController.text.isEmpty) {
                                        _goodsMissing = true;
                                        error = true;
                                      }
                                    } else {
                                      Utils.showToast(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  "Delay reason is missing"));
                                      return;
                                    }

                                    if (!error) {
                                      setState(() {
                                        expandedIndex = 2;
                                      });
                                    }
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        );
      case 2:
        return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color:
                              index <= expandedIndex ? colorLogo2 : buttonColor,
                          shape: BoxShape.circle),
                      child: expandedIndex > index
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                  "assets/images/ic_checkmark.png",
                                  width: 14,
                                  height: 14),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                index.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppLocalizations.of(context).translate("Signature"),
                      style: TextStyle(
                        color:
                            expandedIndex == index ? Colors.black : colorGray,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                expandedIndex == index
                    ? Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: onShowSignatureDialog,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: colorGray)),
                                  width:
                                      MediaQuery.of(context).size.width - 100,
                                  height: 100,
                                  child: _signatureData != null
                                      ? Image.memory(_signatureData!)
                                      : Container(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  "assets/images/ic_signature.png",
                                  width: 30,
                                  height: 30,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Container(
                                  color: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 6),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Prev"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    expandedIndex = 1;
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  color: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 6),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Next"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    if (_signatureData == null) {
                                      Utils.showToast(AppLocalizations.of(
                                              context)
                                          .translate("Signature is mandatory"));
                                    } else {
                                      setState(() {
                                        expandedIndex = 3;
                                      });
                                    }
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      )
                    : Container(),
              ],
            ));
      case 3:
        return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color:
                              index <= expandedIndex ? colorLogo2 : buttonColor,
                          shape: BoxShape.circle),
                      child: expandedIndex > index
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                  "assets/images/ic_checkmark.png",
                                  width: 14,
                                  height: 14),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                index.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppLocalizations.of(context).translate("Finish"),
                      style: TextStyle(
                        color:
                            expandedIndex == index ? Colors.black : colorGray,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                expandedIndex == index
                    ? Column(
                        children: [
                          Text(
                              AppLocalizations.of(context)
                                  .translate("Press to send the details"),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: colorDarkenGray,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: Container(
                                  color: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 6),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Prev"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    expandedIndex = 2;
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  color: buttonColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 6),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Next"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _onUpdateCargoException();
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      )
                    : Container(),
              ],
            ));
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () => {FocusScope.of(context).unfocus()},
        child: ModalProgressHUD(
          inAsyncCall: _loading,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(height: 1, color: colorDivider),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)
                            .translate("Cargo Exception"),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorLightGray,
                            fontSize: 20),
                      ),
                    ),
                    Container(height: 1, color: colorDivider),
                    ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        shrinkWrap: true,
                        itemCount: 4,
                        itemBuilder: (BuildContext buildContext, int index) {
                          return _buildListItem(buildContext, index);
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
