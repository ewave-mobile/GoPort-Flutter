import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Components/BottomNavView.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Helpers/AppLocalizations.dart';
import 'package:goport/Models/BottomNavViewItem.dart';

class ViewHeavyTrafficScreen extends StatefulWidget {
  static String id = 'ViewHeavyTrafficScreen';

  @override
  _ViewHeavyTrafficScreenState createState() => _ViewHeavyTrafficScreenState();
}

class _ViewHeavyTrafficScreenState extends State<ViewHeavyTrafficScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<BottomNavViewItem> navViewItems = [];

  @override
  void initState() {
    navViewItems.add(BottomNavViewItem(
        title: "Prev", image: "ic_left_arrow.png", action: _onPrev));

    super.initState();
  }

  _onPrev() {
    Navigator.of(context).pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(height: 1, color: colorDivider),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      color: colorLightGray,
                      width: 280,
                      height: 80,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 170,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("Security Gate"),
                              style: TextStyle(
                                  color: colorDarkenGray,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(50),bottomLeft: Radius.circular(50)),
                              color: colorLogo2
                            ),
                            child: Center(
                              child: Text("15", style: TextStyle(
                                color: colorLogo, fontSize: 24
                              ),),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      color: colorLightGray,
                      width: 280,
                      height: 80,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 130,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("Front Gate"),
                              style: TextStyle(
                                  color: colorDarkenGray,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                          ),
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(50),bottomLeft: Radius.circular(50)),
                                color: colorLogo2
                            ),
                            child: Center(
                              child: Text("4", style: TextStyle(
                                  color: colorLogo, fontSize: 24
                              ),),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      color: colorLightGray,
                      width: 280,
                      height: 80,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 130,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("Main Gate"),
                              style: TextStyle(
                                  color: colorDarkenGray,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                          ),
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(50),bottomLeft: Radius.circular(50)),
                                color: colorLogo2
                            ),
                            child: Center(
                              child: Text("45", style: TextStyle(
                                  color: colorLogo, fontSize: 24
                              ),),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              child: BottomNavView(
                items: navViewItems,
              )),
        ],
      ),
    );
  }
}
