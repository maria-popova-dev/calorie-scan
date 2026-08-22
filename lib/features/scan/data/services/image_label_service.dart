import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ImageLabelService {
  final _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  Future<List<String>> labelImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels = await _labeler.processImage(inputImage);

    return labels.map((label) => label.label).toList();
  }

  void dispose() {
    _labeler.close();
  }
}