import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'package:FlutterOnlineDetection/widgets/camera.dart';
import 'package:FlutterOnlineDetection/widgets/detections.dart';

enum DetectionMode { ImageClassification, ObjectDetection, PoseDetection }

class AppScreen extends StatefulWidget {
  AppScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  bool _model_loaded = false;
  bool _isDetecting = false;

  DetectionMode _mode = DetectionMode.ImageClassification;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  loadModel() async {
    String res;
    switch (_mode) {
      case DetectionMode.ImageClassification:
        res = await Tflite.loadModel(
            model: "assets/mobilenet_v1_1.0_224.tflite",
            labels: "assets/mobilenet_v1_1.0_224.txt",
            numThreads: 1);
        break;
      case DetectionMode.ObjectDetection:
        print('TBD');
        break;
      case DetectionMode.PoseDetection:
        print('TBD');
        break;
      default:
        print('Uknown mode...');
    }
    print(res);
  }

  setDetectionMode(detectionMode) {
    print('Changing detection mode to $detectionMode.');
    setState(() {
      _mode = detectionMode;
    });
    loadModel();
  }

  onCameraImage(cameraImage) {
    if (!_isDetecting) {
      _isDetecting = true;
      switch (_mode) {
        case DetectionMode.ImageClassification:
          List<Uint8List> imageTranformed = new List();
          cameraImage.planes.map((plane) {
            imageTranformed.add(Uint8List.fromList(plane.bytes));
          });
          Tflite.runModelOnFrame(
            bytesList: imageTranformed,
            imageHeight: cameraImage.height,
            imageWidth: cameraImage.width,
            numResults: 2,
            threshold: 0.1,
          ).then((recognitions) {
            print("$recognitions");
            // _recognitions = recognitions;
            // _imageHeight = cameraImage.height;
            // _imageWidth = cameraImage.width;
          });
          _isDetecting = false;
          print("finished");
          break;
        default:
      }
    }
  }

  @override
  void dispose() {
    closeTfLite();
    super.dispose();
  }

  closeTfLite() async {
    await Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(children: [
      CameraWidget(onCameraImage),
      DetectionsWidget(_recognitions, _imageHeight, _imageWidth),
      Align(
        alignment: Alignment.centerRight,
        child: Column(
          children: [
            IconButton(
                color: Colors.black,
                icon: Icon(Icons.image_rounded, color: Colors.grey),
                onPressed: () {
                  setDetectionMode(DetectionMode.ImageClassification);
                }),
            IconButton(
                icon: Icon(Icons.search_rounded, color: Colors.grey),
                onPressed: () {
                  setDetectionMode(DetectionMode.ObjectDetection);
                }),
            IconButton(
                icon: Icon(Icons.person_search_rounded, color: Colors.grey),
                onPressed: () {
                  setDetectionMode(DetectionMode.PoseDetection);
                })
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      )
    ]));
  }
}
