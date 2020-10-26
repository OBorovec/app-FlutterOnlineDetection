import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraWidget extends StatefulWidget {
  CameraWidget({Key key}) : super(key: key);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool _cameraInitialized = false;
  CameraImage _savedImage;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.veryHigh,
        enableAudio: false);
    cameraController.initialize().then((_) async {
      // Start ImageStream
      await cameraController
          .startImageStream((CameraImage image) => _processCameraImage(image));
      setState(() {
        _cameraInitialized = true;
      });
    });
  }

  void _processCameraImage(CameraImage image) async {
    setState(() {
      _savedImage = image;
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: (_cameraInitialized)
            ? CameraPreview(cameraController)
            : CircularProgressIndicator());
  }
}
