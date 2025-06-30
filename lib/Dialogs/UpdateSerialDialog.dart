import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Dialogs/ImageDialog.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateSerialDialog extends StatefulWidget {
  final Function onConfirm;
  final Function onCancel;
  final PortContainer portContainer;

  UpdateSerialDialog(
      {required this.onConfirm,
      required this.onCancel,
      required this.portContainer});

  @override
  _UpdateSerialDialogState createState() => _UpdateSerialDialogState();
}

class _UpdateSerialDialogState extends State<UpdateSerialDialog> {
  late TextEditingController _serialNumController;
  late Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late String _currentImagePath;
  late PortContainer _portContainer;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    setState(() {
      _serialNumController =
          new TextEditingController(text: widget.portContainer.plombaNumber);
      _portContainer = widget.portContainer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.portContainer;

    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          width: 100,
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
                                hintStyle: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
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
                              _currentImagePath = item.imagePath ?? "";
                            });
                          },
                        ))
                  ],
                )
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      final serialNum = _serialNumController.text;
                      _portContainer.sealNo = serialNum;
                      widget.onConfirm(_portContainer);
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("OK"),
                      style: TextStyle(
                          color: colorGray, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("Cancel"),
                      style: TextStyle(
                          color: colorGray, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            _currentImagePath != null
                ? ImageDialog(
                    imagePath: _currentImagePath,
                    onClose: () {
                      setState(() {
                        _currentImagePath = "";
                      });
                    },
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  _onTakePicture(PortContainer portContainer) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 10);
    if (photo != null) {
      portContainer.imagePath = photo.path;

      DateFormat dateFormat = DateFormat("yyyyMMddHHmmss");
      String createDate = dateFormat.format(DateTime.now());
      portContainer.imageName =
          portContainer.actualCntrNo! + "_" + createDate + ".jpg";
      String base64Image = Utils.convertImageToBase64(photo.path);
      portContainer.image = base64Image;

      setState(() {
        _portContainer = portContainer;
      });
    }
  }
}
