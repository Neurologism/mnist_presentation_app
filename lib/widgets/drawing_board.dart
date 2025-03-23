import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter/material.dart';
import 'package:mnist_presentation_app/utils/image_convert.dart';
import 'package:mnist_presentation_app/logger.dart';

class MNISTDrawingBoard extends StatefulWidget {
  final Function(ImageProvider)? onChange;
  final double size;

  const MNISTDrawingBoard({
    super.key,
    this.onChange,
    this.size = 280, // Default size for the drawing area
  });

  @override
  State<MNISTDrawingBoard> createState() => _MNISTDrawingBoardState();
}

class _MNISTDrawingBoardState extends State<MNISTDrawingBoard> {
  final DrawingController _controller = DrawingController();

  @override
  void initState() {
    super.initState();
    _controller.setStyle(color: Colors.black, strokeWidth: 15.0);
    _onChanged();
  }

  void _onChanged() async {
    logger.d('Drawing changed');
    if (widget.onChange != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      final imageByteData = await _controller.cachedImage?.toByteData(format: ImageByteFormat.png);
      if (imageByteData != null) {
        final image = MemoryImage(Uint8List.view(imageByteData.buffer));
        widget.onChange!(
            await mnistConvertedImage(image)
        );
      } else { // return just white image
        final whiteImageData = Uint8List(28 * 28 * 4);
        for (int i = 0; i < whiteImageData.length; i += 4) {
          whiteImageData[i] = 255;     // R
          whiteImageData[i + 1] = 255; // G
          whiteImageData[i + 2] = 255; // B
          whiteImageData[i + 3] = 255; // A
        }
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        final paint = Paint()..color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, 28, 28), paint);
        final picture = recorder.endRecording();
        final img = await picture.toImage(28, 28);
        final byteData = await img.toByteData(format: ImageByteFormat.png);
        final whiteImage = MemoryImage(byteData!.buffer.asUint8List());
        widget.onChange!(whiteImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: DrawingBoard(
            controller: _controller,
            onPointerUp: (_) => _onChanged(),
            background: Container(
              color: Colors.grey[200],
              width: widget.size,
              height: widget.size,
            ),
        ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            onPressed: () {
              _controller.clear();
              _onChanged();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}