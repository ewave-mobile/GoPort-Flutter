import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goport/Components/AppDialog.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_select/smart_select.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static Future<Directory> getPicturesDirectoryPath(String ext) async {
    final directory = await getExternalStorageDirectory();
    return directory;
  }

  static Future<String> initUDID() async {
    String identifier;
    try {
      identifier = await UniqueIdentifier.serial;
    } on PlatformException {
      identifier = '';
    }

    return identifier;
  }

  static showGeneralErrorToast(BuildContext context) {
    Utils.showToast(
        AppLocalizations.of(context).translate("Unknown error occurred"));
  }

  static showToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static showAlertDialog(
      {BuildContext context, String title = "", String message, Function onOk}) {
    AppDialog alert = AppDialog(title: title, message: message, onOK: onOk,);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showConfirmDialog(
      {BuildContext context,
      String title,
      String message,
      String okButton,
      String cancelButton,
        VoidCallback onCancel,
      VoidCallback onOk}) {
    AppDialog alert = AppDialog(
      title: title,
      message: message,
      okButton: okButton,
      onOK: onOk,
      onCancel: onCancel,
      cancelButton: cancelButton,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  static showSingleChoiceDialog(
      {BuildContext context,
      String title,
      List<String> options,
      String selected,
      Function onSelect}) {
    List<S2Choice<String>> choiceItems =
        options.map((e) => S2Choice<String>(value: e, title: e)).toList();
    return SmartSelect<String>.single(
        modalType: S2ModalType.popupDialog,
        tileBuilder: (context, state) {
          return ListTile(
            title: Text(selected ?? state.title, textAlign: TextAlign.center, style: TextStyle(
              color: colorLogo2, fontWeight: FontWeight.bold
            ),),
            onTap: state.showModal,
          );
        },
        title: title,
        value: selected,
        choiceItems: choiceItems,
        onChange: (state) {
          int index = choiceItems.indexOf(state.valueObject);
          onSelect(index, state.value);
        });
  }

  static String convertToBase64String(String input) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(input);
  }

  static String convertImageToBase64(String imagePath) {
    File imageFile = new File(imagePath.toString());
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  static String convertImageBytesToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  static String convertDate(DateTime dateTime, String format) {
    DateFormat dateFormat = DateFormat(format);
    final createDate = dateFormat.format(dateTime);
    return createDate;
  }
}
