import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goport/Components/AppDialog.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/AppColors.dart' as AppColors;
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:smart_select/smart_select.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:choice/selection.dart';

class Utils {
  static Future<Directory?> getPicturesDirectoryPath(String ext) async {
    final directory = await getExternalStorageDirectory();
    return directory;
  }

  static Future<String> initUDID() async {
    String? identifier;
    try {
      identifier = await UniqueIdentifier.serial;
    } on PlatformException {
      identifier = '';
    }
    return identifier ?? "";
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
      {required BuildContext context,
      String title = "",
      String? message,
      Function? onOk}) {
    AppDialog alert =
        AppDialog(title: title, message: message, onOK: () => onOk!());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showConfirmDialog({
    BuildContext? context,
    String? title,
    required String message,
    required String okButton,
    String? cancelButton,
    VoidCallback? onCancel,
    required VoidCallback onOk,
  }) {
    AppDialog alert = AppDialog(
      title: title,
      message: message,
      okButton: okButton,
      onOK: onOk,
      onCancel: onCancel,
      cancelButton: cancelButton,
    );

    showDialog(
      context: context!,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // static showSingleChoiceDialog({
  //   required BuildContext context,
  //   required String title,
  //   required List<String> options,
  //   required String selected,
  //   required Function onSelect,
  // }) {
  //   List<S2Choice<String>> choiceItems =
  //       options.map((e) => S2Choice<String>(value: e, title: e)).toList();
  //   return SmartSelect<String>.single(
  //     modalType: S2ModalType.popupDialog,
  //     tileBuilder: (context, state) {
  //       return ListTile(
  //         title: Text(
  //           selected,
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(
  //             color: AppColors.colorLogo2,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         onTap: state.showModal,
  //       );
  //     },
  //     title: title,
  //     selectedValue: selected,
  //     choiceItems: choiceItems,
  //     onChange: (state) {
  //       // Compute index by matching the selected value with the choice items
  //       int index = choiceItems.indexWhere((item) => item.value == state.value);
  //       onSelect(index, state.value);
  //     },
  //   );
  // }
  static showSingleChoiceDialog({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selected,
    required Function onSelect,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Container(
            width: double.maxFinite,
            child: PromptedChoice<String>.single(
              value: selected,
              onChanged: (value) {
                // Compute index by matching the selected value with the options
                int index = options.indexOf(value!);
                onSelect(index, value);
                Navigator.of(context).pop();
              },
              itemBuilder: (ChoiceController<String> state, int index) {
                String option = options[index];
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: state.single,
                  onChanged: (value) {
                    state.select(options[index]);
                  },
                  selected: option == state.value,
                );
              },
              itemCount: options.length,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static String convertToBase64String(String input) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    return stringToBase64.encode(input);
  }

  static String convertImageToBase64(String imagePath) {
    File imageFile = File(imagePath);
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
