import 'package:image_picker/image_picker.dart';

abstract class VisualEvent {}

class UploadImage extends VisualEvent {
  final XFile imageFile;
  UploadImage(this.imageFile);
}

class GenerateVisual extends VisualEvent {
  final String imageUrl;
  final String style;
  GenerateVisual(this.imageUrl, this.style);
}
