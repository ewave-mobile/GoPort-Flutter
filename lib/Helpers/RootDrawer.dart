import 'package:flutter/material.dart';

class RootDrawer {
  static DrawerControllerState? of(BuildContext context) {
    // Method returns State<StatefulWidget>? which is nullable
    final State<StatefulWidget>? state =
        context.findRootAncestorStateOfType<DrawerControllerState>();

    // Cast to the correct type if not null
    return state as DrawerControllerState?;
  }
}
