import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

// takes an image of any size and converts it to a 28x28 grayscale image
Future<ImageProvider> mnistConvertedImage(ImageProvider source) async {
  // Create an ImageStream from the source
  final ImageStream stream = source.resolve(const ImageConfiguration());

  // Get the image info from the stream
  final Completer<ImageInfo> completer = Completer<ImageInfo>();
  final ImageStreamListener listener = ImageStreamListener(
        (ImageInfo info, bool _) => completer.complete(info),
    onError: (dynamic exception, StackTrace? stackTrace) =>
        completer.completeError(exception, stackTrace),
  );

  stream.addListener(listener);
  final ImageInfo imageInfo = await completer.future;
  stream.removeListener(listener);

  // Get the dimensions of the image
  final int width = imageInfo.image.width;
  final int height = imageInfo.image.height;

  // Create a Picture to render the image into
  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Paint paint = Paint()..filterQuality = FilterQuality.low;

  // Draw the original image to a 28x28 square
  canvas.drawImageRect(
    imageInfo.image,
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Rect.fromLTWH(0, 0, 28, 28),
    paint,
  );

  // Convert to a grayscale image
  final picture = recorder.endRecording();
  final image = await picture.toImage(28, 28);

  // Convert the UI Image to an ImageProvider
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  return MemoryImage(buffer);
}
