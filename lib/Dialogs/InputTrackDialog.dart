import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/Const.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Models/Truck.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputTrackDialog extends StatefulWidget {
  final Function onConfirm;
  final Function onCancel;

  InputTrackDialog({required this.onConfirm, required this.onCancel});

  @override
  _InputTrackDialogState createState() => _InputTrackDialogState();
}

class _InputTrackDialogState extends State<InputTrackDialog> {
  final TextEditingController _trackNumberController =
      new TextEditingController();
  final TextEditingController _trailerController = new TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    final prefs = await _prefs;
    Truck? truck;
    Truck? trailer;
    if (prefs.getString(Const.prefsTruck) != null) {
      truck =
          Truck.fromJson(jsonDecode(prefs.getString(Const.prefsTruck) ?? ""));
    }
    if (prefs.getString(Const.prefsTrailer) != null) {
      trailer =
          Truck.fromJson(jsonDecode(prefs.getString(Const.prefsTrailer) ?? ""));
    }

    if (truck != null) {
      _trackNumberController.text = truck.num;
    }

    if (trailer != null) {
      _trailerController.text = trailer.num;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).translate("Insert truck details"),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: colorGray),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 0.5,
              width: MediaQuery.of(context).size.width,
              color: colorLightGray,
            ),
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: _trackNumberController,
              decoration: InputDecoration(
                  focusColor: colorLogo2,
                  hintText:
                      AppLocalizations.of(context).translate("Truck number"),
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey)),
              style: TextStyle(fontSize: 16, color: colorLogo),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 0,
            ),
            TextField(
              controller: _trailerController,
              decoration: InputDecoration(
                  focusColor: colorLogo2,
                  hintText:
                      AppLocalizations.of(context).translate("Trailer number"),
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey)),
              style: TextStyle(fontSize: 16, color: colorLogo),
              keyboardType: TextInputType.number,
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
                      final truck = _trackNumberController.text;
                      final trailer = _trailerController.text;
                      if (truck != null) {
                        widget.onConfirm(truck, trailer);
                      }
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("Cancel"),
                      style: TextStyle(
                          color: colorGray, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
