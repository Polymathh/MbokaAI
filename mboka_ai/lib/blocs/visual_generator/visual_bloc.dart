import 'package:bloc/bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'visual_event.dart';
import 'visual_state.dart';

class VisualBloc extends Bloc<VisualEvent, VisualState> {
  final FirebaseStorage storage;

  VisualBloc({required this.storage}) : super(VisualInitial()) {
    on<UploadImage>(_onUploadImage);
    on<GenerateVisual>(_onGenerateVisual);
  }

  Future<void> _onUploadImage(
      UploadImage event, Emitter<VisualState> emit) async {
    emit(VisualUploading());
    try {
      final file = File(event.imageFile.path);
      final ref = storage
          .ref()
          .child("uploads/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();
      emit(VisualUploaded(imageUrl));
    } catch (e) {
      emit(VisualError(e.toString()));
    }
  }

  Future<void> _onGenerateVisual(
      GenerateVisual event, Emitter<VisualState> emit) async {
    emit(VisualGenerating());
    try {
      // 🔹 Placeholder for AI call — you’ll integrate Replicate or Gemini here.
      // For now, we simulate a 3-second delay.
      await Future.delayed(const Duration(seconds: 3));

      // Normally, you’d send event.imageUrl + event.style to your AI API
      // and get back a new URL (resultImageUrl).
      // Here we just reuse the same image as a mock.
      final resultImageUrl = event.imageUrl;

      emit(VisualGenerated(resultImageUrl));
    } catch (e) {
      emit(VisualError("AI generation failed: ${e.toString()}"));
    }
  }
}
