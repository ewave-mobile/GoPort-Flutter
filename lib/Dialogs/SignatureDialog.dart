import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

class SignatureDialog extends StatefulWidget {
  final Function onConfirm;
  final Function onCancel;

  SignatureDialog({required this.onConfirm, required this.onCancel});

  @override
  _SignatureDialogState createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<SignatureDialog> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
    onDrawStart: () => print('onDrawStart called!'),
    onDrawEnd: () => print('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 350,
        child: Column(
          children: [
            Signature(
              controller: _controller,
              height: 300,
              backgroundColor: Colors.white,
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width - 60,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                      onTap: () {
                        _controller.clear();
                      },
                      child: Container(
                          padding: EdgeInsets.all(8),
                          color: colorLightGray,
                          width: 40,
                          height: 40,
                          child: Image.asset(
                            "assets/images/eraser.png",
                            width: 40,
                            height: 40,
                          ))),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      if (_controller.isNotEmpty) {
                        Uint8List? data = await _controller.toPngBytes();
                        if (data != null) {
                          widget.onConfirm(data);
                        }
                      } else {
                        Utils.showToast(AppLocalizations.of(context)
                            .translate("Signature is missing"));
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 60 - 90,
                      color: colorLightGray,
                      alignment: Alignment.center,
                      height: 40,
                      child: Text(
                        AppLocalizations.of(context)
                            .translate("Confirm signature"),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
