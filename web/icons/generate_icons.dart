import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<void> main() async {
  // Simple function to generate basic placeholder icons for Stan's List

  final directory = Directory('web/icons');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // List of icon sizes to generate
  final sizes = [16, 32, 64, 128, 192, 512];

  for (final size in sizes) {
    // Create a simple icon with the "SL" text
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw background
    final bgPaint = Paint()..color = const Color(0xff5468ff);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), bgPaint);

    // Draw text
    const text = 'SL';
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: size * 0.5,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Center the text
    final xCenter = (size - textPainter.width) / 2;
    final yCenter = (size - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));

    final picture = recorder.endRecording();
    final img = await picture.toImage(size, size);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    final file = File('web/icons/Icon-${size}.png');
    await file.writeAsBytes(pngBytes!.buffer.asUint8List());

    // Also create maskable icons for the same sizes
    if (size == 192 || size == 512) {
      final maskableFile = File('web/icons/Icon-maskable-${size}.png');
      await maskableFile.writeAsBytes(pngBytes.buffer.asUint8List());
    }
  }

  print('Icons generated successfully!');
}

Future<void> saveImage(
    String imagePath, String outputPath, int width, int height) async {
  final File imageFile = File(imagePath);
  if (!await imageFile.exists()) {
    print('Source image not found: $imagePath');
    return;
  }

  final ui.Codec codec = await ui.instantiateImageCodec(
    imageFile.readAsBytesSync(),
  );
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  ui.Image resizedImage = image;
  if (width != image.width || height != image.height) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        image: image,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high);
    final picture = recorder.endRecording();
    resizedImage = await picture.toImage(width, height);
  }

  final ByteData? byteData =
      await resizedImage.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    await File(outputPath).writeAsBytes(byteData.buffer.asUint8List());
  } else {
    print('Failed to get byteData for $outputPath');
  }
}

Future<void> createMaskableIcon(
    String inputPath, String outputPath, int size) async {
  final File imageFile = File(inputPath);
  if (!await imageFile.exists()) {
    print('Source image not found: $inputPath');
    return;
  }

  final ui.Codec codec = await ui.instantiateImageCodec(
    imageFile.readAsBytesSync(),
  );
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  ui.Image resizedImage = image;
  if (size != image.width || size != image.height) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: image,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high);
    final picture = recorder.endRecording();
    resizedImage = await picture.toImage(size, size);
  }

  final ByteData? byteData =
      await resizedImage.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    await File(outputPath).writeAsBytes(byteData.buffer.asUint8List());
  } else {
    print('Failed to get byteData for maskable icon $outputPath');
  }
}
