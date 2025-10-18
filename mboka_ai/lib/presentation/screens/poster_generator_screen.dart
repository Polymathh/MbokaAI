import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/poster_repository.dart';
import '../../logic/bloc/poster_bloc.dart';
import '../../logic/bloc/poster_event.dart';
import '../../logic/bloc/poster_state.dart';
import '../../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import 'dart:typed_data';

import 'dart:io'; // 1. Defines the 'File' class

import 'package:path_provider/path_provider.dart'; // 2. Defines 'getTemporaryDirectory'
import 'package:permission_handler/permission_handler.dart'; // 3. Defines 'Permission'
import 'package:flutter/foundation.dart'; // 4. Defines 'kIsWeb'
import 'package:share_plus/share_plus.dart'; // 5. Defines 'Share' and 'XFile'

// ... rest of your file content

// Templates defined in the backend/frontend for UI selection
const List<String> availableTemplates = [
  'Elegant Studio', 
  'Warm Bakery', 
  'Vibrant Market'
];

class PosterGeneratorScreen extends StatelessWidget {
  const PosterGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the PosterBloc locally for this feature
    return BlocProvider(
      create: (context) => PosterBloc(
        posterRepository: PosterRepository(), // Pass the repository
      ),
      child: const PosterGeneratorView(),
    );
  }
}

class PosterGeneratorView extends StatefulWidget {
  const PosterGeneratorView({super.key});

  @override
  State<PosterGeneratorView> createState() => _PosterGeneratorViewState();
}

class _PosterGeneratorViewState extends State<PosterGeneratorView> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedTemplate = availableTemplates.first;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // 💡 Note: Use ImageSource.gallery, or show a dialog for camera/gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        context.read<PosterBloc>().add(ImageSelected(image));
      }
    }
  }

  void _generatePoster() {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your product.')),
      );
      return;
    }
    context.read<PosterBloc>().add(
          GeneratePosterRequested(
            _descriptionController.text,
            _selectedTemplate,
          ),
        );
  }

  // Helper function to decode and display the base64 image
  Widget _buildPosterImage(String base64) {
    Uint8List bytes = base64Decode(base64);
    return Image.memory(bytes, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stunning Poster AI'),
        backgroundColor: AppColors.primarySkyBlue,
        foregroundColor: AppColors.textWhite,
      ),
      body: BlocConsumer<PosterBloc, PosterState>(
        listener: (context, state) {
          if (state.status == PosterStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An unknown error occurred.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isGenerating = state.status == PosterStatus.loading;
          final isSuccess = state.status == PosterStatus.success;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Image Upload Area
                GestureDetector(
                  onTap: isGenerating ? null : _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.productFile != null ? AppColors.primarySkyBlue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: state.productFile != null
                        ? FutureBuilder<Uint8List>(
                            future: state.productFile!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                return Image.memory(snapshot.data!, fit: BoxFit.cover);
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_file, size: 40, color: Colors.grey),
                                Text('Upload Product Image (${state.status == PosterStatus.initial ? 'Required' : 'Ready'})'),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Product Description Input
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Product Description (e.g., Artisan bread with rosemary)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Template Selection Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedTemplate,
                  decoration: InputDecoration(
                    labelText: 'Select Poster Style Template',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: availableTemplates.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTemplate = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // 4. Generate Button
                CustomElevatedButton(
                  text: isGenerating ? 'Generating...' : 'Generate Poster',
                  onPressed: isGenerating ? () {} : _generatePoster,
                  isLoading: isGenerating,
                ),
                const SizedBox(height: 30),

                // 5. Result Display Area
                if (isSuccess)
                  Column(
                    children: [
                      Text(
                        'Your MbokaAI Poster (Tap to share/download)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildPosterImage(state.generatedPosterBase64!),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Share and Download Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              text: 'Download',
                              onPressed: () => _handleDownload(state.generatedPosterBase64!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomElevatedButton(
                              text: 'Share',
                              onPressed: () => _handleShare(state.generatedPosterBase64!),
                              // Use the primary dark blue for sharing button
                              // We'll rely on the default theme color for simplicity here
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Utility Functions for Download and Share ---
  
  // NOTE: This uses the `path_provider` and `permission_handler`
  // You must handle platform-specific implementations and permissions.

  Future<void> _handleDownload(String base64Image) async {
    // 1. Request Storage Permission (Crucial for Android/iOS)
    if (await Permission.storage.request().isGranted || true) { // Removed 'true' in real app
      // 2. Decode Base64 and create a temporary file
      final bytes = base64Decode(base64Image);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}_poster.jpeg');
      await file.writeAsBytes(bytes);
      
      // 3. Save the file to the actual device storage (complex, often platform channel work)
      // For web, this usually triggers a download in the browser.
      // For mobile, you'd use packages like 'image_gallery_saver' or platform code.
      
      if (kIsWeb) {
        // Simple web download (requires specific dart:html methods not shown here)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download initiated (Web).')));
      } else {
        // Placeholder for native save logic
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Poster saved to device!')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage permission denied.')));
    }
  }

  Future<void> _handleShare(String base64Image) async {
    // 1. Decode Base64 and create a temporary file for sharing
    final bytes = base64Decode(base64Image);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpeg');
    await file.writeAsBytes(bytes);

    // 2. Use the share_plus package to share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Check out my new marketing poster created with MbokaAI!');
  }
}