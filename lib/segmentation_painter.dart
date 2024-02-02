import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class SegmentationPainter extends CustomPainter {
  SegmentationPainter(
    this.mask,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final SegmentationMask mask;
  final Size imageSize;
  final Color color = Colors.red;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final width = mask.width;
    final height = mask.height;
    final confidences = mask.confidences;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int tx = translateX(
          x.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        ).round();
        final int ty = translateY(
          y.toDouble(),
          size,
          Size(mask.width.toDouble(), mask.height.toDouble()),
          rotation,
          cameraLensDirection,
        ).round();

        final double opacity = confidences[(y * width) + x] * 0.5;
        paint.color = color.withOpacity(opacity);
        canvas.drawCircle(Offset(tx.toDouble(), ty.toDouble()), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return oldDelegate.mask != mask;
  }
}

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation270deg:
      return canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      switch (cameraLensDirection) {
        case CameraLensDirection.back:
          return x * canvasSize.width / imageSize.width;
        default:
          return canvasSize.width - x * canvasSize.width / imageSize.width;
      }
  }
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
  }
}
