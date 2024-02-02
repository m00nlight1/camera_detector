import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_detect_faces/detector_view.dart';
import 'package:camera_detect_faces/segmentation_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Detect Faces App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
    enableRawSizeMask: true,
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  final _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() async {
    _canProcess = false;
    _segmenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Selfie Segmenter',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final mask = await _segmenter.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null &&
        mask != null) {
      // TODO: Fix SegmentationPainter to rescale on top of camera feed.
      final painter = SegmentationPainter(
        mask,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      // TODO: set _customPaint to draw on top of image
      _text =
          'There is a mask with ${(mask?.confidences ?? []).where((element) => element > 0.8).length} elements';
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
