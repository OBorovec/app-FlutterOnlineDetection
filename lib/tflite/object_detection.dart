import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'package:FlutterOnlineDetection/models/recognition.dart';

class ObjectDetection {
  Interpreter _interpreter;
  List<String> _labels;

  static const String MODEL_FILE_NAME = "detect.tflite";
  static const String LABEL_FILE_NAME = "labelmap.txt";

  /// Shapes and types o tensors
  List<List<int>> _outputShapes;
  List<TfLiteType> _outputTypes;

  static const int INPUT_SIZE = 300;
  ImageProcessor imageProcessor;
  int padSize;

  static const int NUM_RESULTS = 10;
  static const double THRESHOLD = 0.6;

  ObjectDetection({
    Interpreter interpreter,
    List<String> labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  void loadModel({Interpreter interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  void loadLabels({List<String> labels}) async {
    try {
      _labels =
          labels ?? await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  Interpreter get interpreter => _interpreter;
  List<String> get labels => _labels;

  TensorImage getPreProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    imageProcessor = ImageProcessorBuilder()
        // Padding the image
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        // Resizing to input size
        .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  List<Recognition> predict(imageLib.Image image) {
    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null;
    }

    TensorImage inputImage = TensorImage.fromImage(image);
    inputImage = getPreProcessedImage(inputImage);

    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);

    List<Object> inputs = [inputImage.buffer];

    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    _interpreter.runForMultipleInputs(inputs, outputs);

    int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));

    int labelOffset = 1;
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    List<Recognition> recognitions = [];
    for (int i = 0; i < resultsCount; i++) {
      var score = outputScores.getDoubleValue(i);
      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      var label = _labels.elementAt(labelIndex);

      if (score > THRESHOLD) {
        Rect transformedRect = imageProcessor.inverseTransformRect(
            locations[i], image.height, image.width);
        recognitions.add(
          Recognition(label, score, transformedRect),
        );
      }
    }

    return recognitions;
  }
}
