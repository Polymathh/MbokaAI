// lib/logic/bloc/poster_state.dart
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

enum PosterStatus { initial, imageSelected, loading, success, failure }

class PosterState extends Equatable {
  final PosterStatus status;
  final String? errorMessage;
  final XFile? productFile;
  final String? generatedPosterBase64;

  const PosterState({
    this.status = PosterStatus.initial,
    this.errorMessage,
    this.productFile,
    this.generatedPosterBase64,
  });

  PosterState copyWith({
    PosterStatus? status,
    String? errorMessage,
    XFile? productFile,
    String? generatedPosterBase64,
  }) {
    return PosterState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      productFile: productFile ?? this.productFile,
      generatedPosterBase64: generatedPosterBase64,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, productFile, generatedPosterBase64];
}