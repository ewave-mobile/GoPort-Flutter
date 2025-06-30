import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Const/AppColors.dart' as AppColors;
import 'package:goport/Const/Const.dart';
import 'package:goport/Dialogs/ImageDialog.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Helpers/Utils.dart';
import 'package:goport/Models/Chassis.dart';
import 'package:goport/Models/PortContainer.dart';
import 'package:goport/Providers/GeneralProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Carso motors - UU1K6729

class AddChassisNumDialog extends StatefulWidget {
  final void Function(Chassis) onConfirm;
  final void Function()? onCancel;
  final List<Chassis> availableChassis;
  final List<Chassis> chosenChassis;

  const AddChassisNumDialog({
    Key? key,
    required this.onConfirm,
    this.onCancel,
    required this.availableChassis,
    required this.chosenChassis,
  }) : super(key: key);

  @override
  _AddChassisNumDialogState createState() => _AddChassisNumDialogState();
}

class _AddChassisNumDialogState extends State<AddChassisNumDialog> {
  final TextEditingController _shildaController = TextEditingController();
  // Example: if you need SharedPreferences later.
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Chassis? _chosenChassis;
  List<Chassis> _chassisNotChosen = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _loadNotChosenChassis();
  }

  void _loadNotChosenChassis() {
    List<Chassis> chassisNotChosen = [];
    for (Chassis chassis in widget.availableChassis) {
      // Check if not already chosen
      bool isChosen = widget.chosenChassis
          .any((fill) => fill.chassisID == chassis.chassisID);
      if (!isChosen) {
        chassisNotChosen.add(chassis);
      }
    }

    setState(() {
      _chassisNotChosen = chassisNotChosen;
    });
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
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 260,
                  child: Autocomplete<Chassis>(
                    fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      return TextField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)
                              .translate("Shilda number"),
                          hintText: AppLocalizations.of(context)
                              .translate("Enter Shilda number"),
                        ),
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        style: const TextStyle(color: Colors.black),
                      );
                    },
                    displayStringForOption: (Chassis option) =>
                        option.chassisID ?? "",
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty ||
                          textEditingValue.text.length < 4) {
                        return const Iterable<Chassis>.empty();
                      }
                      return _chassisNotChosen.where((Chassis option) {
                        return option.chassisID!
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (Chassis selection) {
                      setState(() {
                        _chosenChassis = selection;
                      });
                    },
                    optionsViewBuilder: (
                      BuildContext context,
                      AutocompleteOnSelected<Chassis> onSelected,
                      Iterable<Chassis> options,
                    ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          child: Container(
                            width: 260,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(10.0),
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Chassis option = options.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  option.chassisID!,
                                                  style: const TextStyle(
                                                    color: AppColors.colorLogo2,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${AppLocalizations.of(context).translate("Manufacturer")}:",
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .colorLightGray,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      option.manufacturer ?? "",
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${AppLocalizations.of(context).translate("Model")}:",
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .colorLightGray,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      option.model ?? "",
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 1,
                                        color: AppColors.colorDivider,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  _chosenChassis != null
                      ? "assets/images/ic_verification_checkmark_symbol.png"
                      : "assets/images/ic_pencil_edit_button.png",
                  width: 20,
                  height: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_chassisNotChosen.isNotEmpty && _chosenChassis != null)
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "${AppLocalizations.of(context).translate("Manufacturer")}:",
                        style: const TextStyle(
                          color: AppColors.colorLightGray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _chosenChassis!.manufacturer ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "${AppLocalizations.of(context).translate("Model")}:",
                        style: const TextStyle(
                          color: AppColors.colorLightGray,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _chosenChassis!.model ?? "",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (_chosenChassis == null) {
                        Utils.showToast(context,AppLocalizations.of(context)
                            .translate("Shilda number is mandatory"));
                      } else {
                        widget.onConfirm(_chosenChassis!);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("OK"),
                      style: const TextStyle(
                        color: AppColors.colorGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      if (widget.onCancel != null) {
                        widget.onCancel!();
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("Cancel"),
                      style: const TextStyle(
                        color: AppColors.colorGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
