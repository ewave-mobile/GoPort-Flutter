import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goport/Const/AppColors.dart';
import 'package:goport/Models/Event.dart';

class EventScrollWidget extends StatefulWidget {
  @override
  _EventScrollWidgetState createState() => _EventScrollWidgetState();

  final List<Event> events;

  EventScrollWidget({this.events});
}

class _EventScrollWidgetState extends State<EventScrollWidget> {
  double screenWidth;
  Timer timer;
  int currentIndex = 0;

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // To handle AutoScroll
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timer = Timer.periodic(Duration(seconds: 3), (time) {
        scrollController.animateTo(
            (currentIndex + 1) * screenWidth,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn);
        currentIndex++;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    // return only 2 data model for first and second item
    return Container(
      height: 30,
      child: ListView.builder(
          controller: scrollController,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            // Here you can return your own items repeat based on index 
            return _buildRow(widget.events[index % 2]);
          }),
    );
  }

  // Build Your item
  Widget _buildRow(Event event) {
    return Container(
      width: screenWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.iruaTeur,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: colorDarkGray),
          ),
        ],
      ),
    );
  }
}