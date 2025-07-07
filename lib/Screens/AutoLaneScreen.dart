import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Dialogs/ImageDialog.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/BottomNavViewItem.dart';
import 'package:goport/Models/NotTakePhotoReason.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Network/GoPortApi.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AutoLaneScreen extends StatefulWidget {
  static String id = 'AutoLaneScreen';

  @override
  _AutoLaneScreenState createState() => _AutoLaneScreenState();
}

class _AutoLaneScreenState extends State<AutoLaneScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<BottomNavViewItem> navViewItems = [];
  late TextEditingController _serialNumController;
  List<PortContainer> _inContainers = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  NotTakePhotoReason? _notTakePhotoReason;
  String? _currentImagePath;
  bool _loading = false;

  @override
  void initState() {
    navViewItems.add(BottomNavViewItem(
        title: "Prev", image: "ic_left_arrow.png", action: _onPrev));
    navViewItems.add(BottomNavViewItem(
        title: "Staffed Path",
        image: "ic_action_undo.png",
        action: _onStaffedPath));
    navViewItems.add(BottomNavViewItem(
        title: "Next", image: "ic_right_arrow.png", action: _onNext));
    _initialize();

    super.initState();
  }

  Widget _buildListItem(BuildContext context, int index) {
    final item = _inContainers[index];
    _serialNumController = new TextEditingController(text: item.plombaNumber);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.actualCntrNo ?? "",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).translate("Seal Number"),
                        style: TextStyle(
                            fontSize: 16,
                            color: colorLightGray,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 140,
                        child: TextField(
                          onChanged: (plombaNumber) {
                            item.plombaNumber = plombaNumber;
                          },
                          controller: _serialNumController,
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 4),
                              focusColor: colorLogo2,
                              hintStyle:
                                  TextStyle(fontSize: 20, color: Colors.grey)),
                          style: TextStyle(fontSize: 20, color: colorLogo),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  item.imageName != null
                      ? InkWell(
                          onTap: () {
                            _onTakePicture(item);
                          },
                          child: Image.file(
                            File(item.imagePath ?? ""),
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ))
                      : Container(),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                      onTap: () {
                        _onTakePicture(item);
                      },
                      child: GestureDetector(
                        child: Image.asset(
                          "assets/images/ic_photo_camera.png",
                          width: 30,
                          height: 30,
                        ),
                        onLongPress: () {
                          setState(() {
                            _currentImagePath = item.imagePath;
                          });
                        },
                      ))
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width,
            color: colorLogo2,
          )
        ],
      ),
    );
  }

  _onTakePicture(PortContainer portContainer) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 10);


    setState(() {
      portContainer.imagePath = photo?.path ?? "";

      DateFormat dateFormat = DateFormat("yyyyMMddHHmmss");
      String createDate = dateFormat.format(DateTime.now());
      portContainer.imageName =
          portContainer.actualCntrNo! + "_" + createDate + ".jpg";

    });
  }

  _onPrev() {
    Navigator.of(context).pop(context);
  }

  _onStaffedPath() {
    for (PortContainer portContainer in _inContainers) {
      portContainer.imagePath = null;
      portContainer.imageName = null;
      portContainer.plombaNumber = null;
    }

    _onAutoLaneNextClicked(true, null);
  }

  _onNext() {
    if (_checkValidAutoLane()) {
      Utils.showConfirmDialog(
          context: context,
          title: "",
          okButton: AppLocalizations.of(context).translate("Yes"),
          cancelButton: AppLocalizations.of(context).translate("No"),
          message: AppLocalizations.of(context)
              .translate("Do You Approve Seal Number?"),
          onOk: () {
            _onAutoLaneNextClicked(false, null);
          });
    } else {
      Utils.showAlertDialog(
          context: context,
          message: AppLocalizations.of(context)
              .translate("Photo And Seal Number Are Mandatory"));
    }
  }

  _onAutoLaneNextClicked(bool skip, NotTakePhotoReason? reason) {
    if (!skip) {
      _notTakePhotoReason = reason;
    }
    _showDraftJobCard();
  }

  _showDraftJobCard() {
    Navigator.of(context).pushNamed("DraftJobCardScreen",
        arguments: _notTakePhotoReason != null
            ? {"notTakePhotoReasonId": _notTakePhotoReason?.id ?? ""}
            : {});
  }

  _checkValidAutoLane() {
    bool res = true;
    for (PortContainer c in _inContainers) {
      if (_checkContainerTypeNotMustSealNo(c.containerType ?? "")) {
        return true;
      }

      if (c.plombaNumber == null ||
          c.plombaNumber!.isEmpty ||
          c.imagePath == null ||
          c.imagePath!.isEmpty) {
        res = false;
      }
    }
    return res;
  }

  _checkContainerTypeNotMustSealNo(String containerType) {
    return containerType == "PL" ||
        containerType == "TK" ||
        containerType == "BL";
  }

  _initialize() async {
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    setState(() {
      _inContainers = generalProvider.selectedInContainers;
    });
  }

  _onFloatActionPressed() async {
    List<NotTakePhotoReason> res =
        await GoPortApi.instance.getNotTakePhotoReasons();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(
                  AppLocalizations.of(context).translate("Choose reason type")),
              children: res.map((reason) {
                return SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                    _onAutoLaneNextClicked(false, reason);
                  },
                  child: Text(reason.description),
                );
              }).toList());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: null,
      bottomSheet: Padding(padding: EdgeInsets.only(bottom: 0.0)),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 40),
        child: FloatingActionButton(
          onPressed: () {
            _onFloatActionPressed();
          },
          child: Container(
            child: Image.asset(
              "assets/images/ic_cancel_image.png",
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
                  Expanded(
                    child: ListView.builder(
                        itemCount: _inContainers.length,
                        itemBuilder: (BuildContext buildContext, int index) {
                          return _buildListItem(buildContext, index);
                        }),
                  ),
                ],
              ),
              Positioned(
                  bottom: 0,
                  child: BottomNavView(
                    items: navViewItems,
                  )),
              _currentImagePath != null
                  ? ImageDialog(
                      imagePath: _currentImagePath ?? "",
                      onClose: () {
                        setState(() {
                          _currentImagePath = null;
                        });
                      },
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
