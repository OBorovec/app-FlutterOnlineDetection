import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:FlutterOnlineDetection/models/recognition.dart';

class DetectionsWidget extends StatelessWidget {
  final List<dynamic> recognitions;
  final int screenH;
  final int screenW;

  const DetectionsWidget(this.recognitions, this.screenH, this.screenW);

  List<Widget> _renderBoxes() {
    double offset = -10;
    return recognitions.map((re) {
      offset = offset + 14;
      return Positioned(
        left: 10,
        top: offset,
        width: screenW.toDouble(),
        height: screenH.toDouble(),
        child: Text(
          "${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            color: Color.fromRGBO(37, 213, 253, 1.0),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: recognitions.length > 0 ? _renderBoxes() : [],
    );
  }
}
