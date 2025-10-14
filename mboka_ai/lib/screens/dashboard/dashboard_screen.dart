import 'package:flutter/material.dart';
import 'package:mboka_ai/core/services/ai_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../blocs/dashboard/dashboard_bloc.dart';
import '../../../blocs/dashboard/dashboard_event.dart';
import '../../../blocs/dashboard/dashboard_state.dart';
import '../../../widgets/tool_card.dart';
import '../visual_generator/visual_generator_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // New variables for the caption generator
  final TextEditingController _captionController = TextEditingController();
  String? _generatedCaption;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      context.read<DashboardBloc>().add(LoadDashboardData(user!.uid));
    }
  }

  Future<void> _generateCaption() async {
    if (_captionController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedCaption = null;
    });

    try {
      final result = await AIService.generateCaption(_captionController.text);
      setState(() => _generatedCaption = result);
    } catch (e) {
      setState(() => _generatedCaption = "Error: $e");
    }

    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("MbokaAI Dashboard"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            final name = state.userData['name'] ?? 'Hustler';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey, $name 👋",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Here are your MbokaAI tools to hustle smarter:",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // Tools Grid
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 600 ? 2 : 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ToolCard(
                        icon: Icons.image_outlined,
                        title: "AI Visual Generator",
                        description: "Transform your photos into promo posters",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const VisualGeneratorScreen()),
                          );
                        },
                      ),
                      ToolCard(
                        icon: Icons.edit_outlined,
                        title: "Caption Generator",
                        description: "Generate catchy, local-language captions",
                        onTap: () {
                          // Scroll down to caption section
                          Scrollable.ensureVisible(
                            captionKey.currentContext!,
                            duration: const Duration(milliseconds: 400),
                          );
                        },
                      ),
                      ToolCard(
                        icon: Icons.chat_outlined,
                        title: "Chatbot Setup",
                        description: "Automate your WhatsApp or website chats",
                        onTap: () {},
                      ),
                      ToolCard(
                        icon: Icons.analytics_outlined,
                        title: "Growth Analytics",
                        description: "Track your engagement and progress",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text(
                    "AI Caption Generator",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    key: captionKey,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: "Enter your product details (e.g., shoes on sale)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.bolt),
                    label: Text(_isGenerating ? "Generating..." : "Generate Caption"),
                    onPressed: _isGenerating ? null : _generateCaption,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_generatedCaption != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        _generatedCaption!,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),

                  const SizedBox(height: 32),
                  const Text(
                    "Recent Posts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text("Your uploaded posts will appear here"),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is DashboardError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// Add a global key for scrolling to caption generator
final captionKey = GlobalKey();
