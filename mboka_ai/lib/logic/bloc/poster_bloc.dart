// lib/logic/bloc/poster_bloc.dart
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
// import 'package:image_picker/image_picker.dart';
import '../../data/repositories/poster_repository.dart';
import 'poster_event.dart';
import 'poster_state.dart';

class PosterBloc extends Bloc<PosterEvent, PosterState> {
  final PosterRepository _posterRepository;

  PosterBloc({required PosterRepository posterRepository})
      : _posterRepository = posterRepository,
        super(const PosterState()) {
    on<ImageSelected>(_onImageSelected);
    on<GeneratePosterRequested>(_onGeneratePosterRequested);
    on<PosterReset>((_, emit) => emit(const PosterState()));
  }

  void _onImageSelected(ImageSelected event, Emitter<PosterState> emit) {
    emit(state.copyWith(
      status: PosterStatus.imageSelected,
      productFile: event.imageFile,
      errorMessage: null,
      generatedPosterBase64: null,
    ));
  }

  Future<void> _onGeneratePosterRequested(
      GeneratePosterRequested event, Emitter<PosterState> emit) async {
    if (state.productFile == null) {
      emit(state.copyWith(
          status: PosterStatus.failure,
          errorMessage: 'Please select a product image first.'));
      return;
    }

    emit(state.copyWith(
        status: PosterStatus.loading, errorMessage: null));

    try {
      // 1. Convert image to Base64
      final bytes = await state.productFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Call the backend function
      final base64Poster = await _posterRepository.generatePoster(
        base64Image: base64Image,
        description: event.description,
        templateName: event.templateName,
      );

      // 3. Success state
      emit(state.copyWith(
        status: PosterStatus.success,
        generatedPosterBase64: base64Poster,
      ));

    } catch (e) {
      // 4. Failure state (network, API limit, etc.)
      emit(state.copyWith(
        status: PosterStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}