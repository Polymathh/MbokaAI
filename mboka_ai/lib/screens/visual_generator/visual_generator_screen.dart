import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../blocs/visual_generator/visual_bloc.dart';
import '../../../blocs/visual_generator/visual_event.dart';
import '../../../blocs/visual_generator/visual_state.dart';

class VisualGeneratorScreen extends StatefulWidget {
  const VisualGeneratorScreen({super.key});

  @override
  State<VisualGeneratorScreen> createState() => _VisualGeneratorScreenState();
}

class _VisualGeneratorScreenState extends State<VisualGeneratorScreen> {
  final ImagePicker _picker = ImagePicker();
  String selectedStyle = "Modern";

  Future<void> _pickImage(BuildContext context) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      context.read<VisualBloc>().add(UploadImage(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Visual Generator"),
        backgroundColor: Colors.green[700],
      ),
      body: BlocConsumer<VisualBloc, VisualState>(
        listener: (context, state) {
          if (state is VisualError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (state is VisualInitial || state is VisualError)
                  _buildUploadSection(context),

                if (state is VisualUploading)
                  const Center(child: CircularProgressIndicator()),

                if (state is VisualUploaded) _buildGenerateSection(context, state),

                if (state is VisualGenerating)
                  const Center(child: CircularProgressIndicator()),

                if (state is VisualGenerated)
                  _buildResultSection(context, state.resultImageUrl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Expanded(
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.upload),
          label: const Text("Upload Product Image"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateSection(BuildContext context, VisualUploaded state) {
    return Expanded(
      child: Column(
        children: [
          Image.network(state.imageUrl, height: 200),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedStyle,
            items: const [
              DropdownMenuItem(value: "Modern", child: Text("Modern")),
              DropdownMenuItem(value: "Luxury", child: Text("Luxury")),
              DropdownMenuItem(value: "Street", child: Text("Street")),
              DropdownMenuItem(value: "Minimal", child: Text("Minimal")),
            ],
            onChanged: (v) => setState(() => selectedStyle = v!),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context
                .read<VisualBloc>()
                .add(GenerateVisual(state.imageUrl, selectedStyle)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text("Generate Poster"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(BuildContext context, String imageUrl) {
    return Expanded(
      child: Column(
        children: [
          Image.network(imageUrl, height: 300),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _pickImage(context),
            icon: const Icon(Icons.refresh),
            label: const Text("Generate Another"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
          ),
        ],
      ),
    );
  }
}
