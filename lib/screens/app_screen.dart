import 'package:FlutterOnlineDetection/widgets/camera.dart';
import 'package:flutter/material.dart';

class AppScreen extends StatefulWidget {
  AppScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(widget.title),
        // ),
        body: SafeArea(child: CameraWidget()),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Rotate camera',
          child: Icon(Icons.flip_camera_ios),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
