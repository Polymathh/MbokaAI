// lib/logic/bloc/poster_event.dart
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class PosterEvent extends Equatable {
  const PosterEvent();
  @override
  List<Object> get props => [];
}

class ImageSelected extends PosterEvent {
  final XFile imageFile;
  const ImageSelected(this.imageFile);
  @override
  List<Object> get props => [imageFile];
}

class GeneratePosterRequested extends PosterEvent {
  final String description;
  final String templateName;
  const GeneratePosterRequested(this.description, this.templateName);
  @override
  List<Object> get props => [description, templateName];
}

class PosterReset extends PosterEvent {}