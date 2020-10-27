import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

typedef void Callback(CameraImage cameraImage);

class CameraWidget extends StatefulWidget {
  final Callback onCameraImage;
  CameraWidget(this.onCameraImage);

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  List<CameraDescription> _cameras;
  int _cameraId = 0;
  CameraController cameraController;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    _cameras = await availableCameras();
    cameraController = CameraController(
        _cameras[_cameraId], ResolutionPreset.veryHigh,
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
    widget.onCameraImage(image);
  }

  void _switchCamera() {
    setState(() {
      _cameraInitialized = false;
    });
    setState(() {
      _cameraId = (_cameraId + 1) % _cameras.length;
      initializeCamera();
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: (_cameraInitialized)
                ? CameraPreview(cameraController)
                : CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _switchCamera();
          },
          tooltip: 'Rotate camera',
          child: Icon(
            Icons.flip_camera_ios,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
