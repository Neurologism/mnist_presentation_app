import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mnist_presentation_app/logger.dart';

/// Class to load and execute the onnx mnist model
class Predictor {
  final ValueNotifier<bool> loaded = ValueNotifier<bool>(false);
  OrtSession? _session;
  String? _modelPath;

  /// Loads an ONNX model from file system
  Future<bool> loadModel() async {
    try {
      // Open file picker and select model
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'Select MNIST ONNX model',
      );

      if (result == null || result.files.single.path == null) {
        logger.w('Model loading cancelled');
        return false;
      }

      _modelPath = result.files.single.path!;
      logger.d('Loading model from $_modelPath');

      //OrtEnv.instance.release();
      OrtEnv.instance.init(level: OrtLoggingLevel.verbose, logId: 'ONNX');

      _session = OrtSession.fromFile(File(_modelPath!), OrtSessionOptions());
      logger.d('Input names: ${_session?.inputNames}');
      loaded.value = true;
      logger.i('Model loaded successfully');
      return true;
    } catch (e) {
      logger.e('Failed to load model: $e');
      loaded.value = false;
      return false;
    }
  }

  /// Evaluates the image with the loaded model and returns predictions
  Future<Map<int, double>> evaluate(ImageProvider image) async {
    // Default result if model is not loaded or fails
    Map<int, double> defaultResult = {
      0: 0.1, 1: 0.1, 2: 0.1, 3: 0.1, 4: 0.1,
      5: 0.1, 6: 0.1, 7: 0.1, 8: 0.1, 9: 0.1
    };

    if (_session == null) {
      logger.w('No model loaded, returning default results');
      return defaultResult;
    }

    try {
      // Convert image to byte data
      final completer = Completer<ui.Image>();
      final imageStream = image.resolve(const ImageConfiguration());
      final listener = ImageStreamListener((info, _) {
        completer.complete(info.image);
      }, onError: (e, stackTrace) {
        completer.completeError(e);
      });

      imageStream.addListener(listener);
      final uiImage = await completer.future;

      // Convert image to input tensor format (1x1x28x28)
      final byteData = await uiImage.toByteData();
      if (byteData == null) {
        logger.e('Could not get image byte data');
        return defaultResult;
      }

      // Preprocess image to match model input requirements
      // Assuming the model expects normalized grayscale values in [0,1]
      var inputData = Float32List(1 * 1 * 28 * 28);
      for (int i = 0; i < 28 * 28; i++) {
        final pixel = byteData.getUint8(i * 4); // Just taking R value as grayscale
        inputData[i] = pixel / 255.0; // Normalize to [0,1]
      }

      // Create tensor
      final inputTensor = OrtValueTensor.createTensorWithDataList(inputData, [1, 1, 28, 28]);
      final inputs = {'Input3': inputTensor};

      // Run inference
      final result = _session!.run(OrtRunOptions(), inputs);
      // Run inference
      final output = result[0]?.value as List<dynamic>;

      // Convert output to Map<int, double>
      Map<int, double> predictions = {};
      logger.i(output);
      for (int i = 0; i < output[0].length; i++) {
        logger.i('Prediction $i: ${output[0][i]}');
        final double confidence = output[0][i].toDouble();
        predictions[i] = confidence <= 0 ? 0 : confidence;
      }
      logger.d(predictions);
      logger.d('Model prediction completed');
      return predictions;
    } catch (e, stack) {
      logger.e('Error during prediction: $e');
      debugPrintStack(stackTrace: stack);
      return defaultResult;
    }
  }

  /// Unloads the model and releases resources
  void unloadModel() {
    if (_session != null) {
      OrtEnv.instance.release();
      _session = null;
      _modelPath = null;
      loaded.value = false;
      logger.i('Model unloaded');
    }
  }
}