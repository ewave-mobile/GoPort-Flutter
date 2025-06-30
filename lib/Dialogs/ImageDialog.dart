import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageDialog extends StatefulWidget {
  static String id = 'ImageDialog';
  final String imagePath;
  final Function onClose;

  ImageDialog({required this.imagePath, required this.onClose});

  @override
  _ImageDialogState createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onClose(),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            child: Image.asset(widget.imagePath),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }
}
