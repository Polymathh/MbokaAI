abstract class VisualState {}

class VisualInitial extends VisualState {}

class VisualUploading extends VisualState {}

class VisualUploaded extends VisualState {
  final String imageUrl;
  VisualUploaded(this.imageUrl);
}

class VisualGenerating extends VisualState {}

class VisualGenerated extends VisualState {
  final String resultImageUrl;
  VisualGenerated(this.resultImageUrl);
}

class VisualError extends VisualState {
  final String message;
  VisualError(this.message);
}
