import 'package:flutter/material.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Models/BottomNavViewItem.dart';

class BottomNavView extends StatelessWidget {
  final List<BottomNavViewItem> items;

  BottomNavView({required this.items});

  Widget _buildMenuItem(BuildContext context, BottomNavViewItem item) {
    return InkWell(
      onTap: () => item.action(),
      child: Column(
        children: [
          Image.asset(
            "assets/images/" + item.image,
            width: 20,
            height: 20,
            color: colorGray,
            matchTextDirection: true,
          ),
          SizedBox(
            height: 8,
          ),
          Text(AppLocalizations.of(context).translate(item.title),
              style: TextStyle(color: colorGray, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: colorLightenGray,
          border: Border(top: BorderSide(color: colorGray))),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items.map((item) => _buildMenuItem(context, item)).toList(),
      ),
    );
  }
}
