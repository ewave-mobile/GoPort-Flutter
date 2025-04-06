import 'dart:ui';
import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  String? title;
  String? message;
  String okButton;
  String? cancelButton;
  VoidCallback? onOK;
  VoidCallback? onCancel;

  AppDialog(
      { this.title,
      this.message,
      this.okButton = "OK",
      this.onOK,
      this.cancelButton,
      this.onCancel});

  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          elevation: 6,
          actionsPadding: EdgeInsets.all(0),
          buttonPadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          titlePadding: EdgeInsets.all(0),
          title: new Text(
            title ?? "",
            style: textStyle,
          ),
          content: new Text(
            message ?? "",
            style: textStyle,
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text(this.okButton),
              onPressed: () {
                Navigator.pop(context);
                if (onOK != null) {
                  onOK!();
                }
              },
            ),
            this.cancelButton != null
                ? new TextButton(
                    child: Text(this.cancelButton ?? ""),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onCancel != null) {
                        onCancel!();
                      }
                    },
                  )
                : Container(),
          ],
        ));
  }
}
