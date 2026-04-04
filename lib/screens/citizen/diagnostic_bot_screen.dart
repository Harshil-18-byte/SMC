import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/core/theme/theme_switcher.dart';

class DiagnosticBotScreen extends StatefulWidget {
  const DiagnosticBotScreen({super.key});

  @override
  State<DiagnosticBotScreen> createState() => _DiagnosticBotScreenState();
}

class _DiagnosticBotScreenState extends State<DiagnosticBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isRecording = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messages.isEmpty) {
        _addBotMessage("SMC TACTICAL DIAGNOSTIC UNIT ONLINE. Please provide Asset ID or describe the structural anomaly for automated integrity analysis.");
      }
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty || _isTyping) return;

    final userText = text.trim();
    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: userText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _addBotMessage(_generateMockResponse(userText));
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final userMessage = ChatMessage(
        text: "Analyzing uploaded image metadata...",
        isUser: true,
        timestamp: DateTime.now(),
        imagePath: image.path,
      );

      setState(() {
        _messages.add(userMessage);
        _isTyping = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _addBotMessage(
                "Image analysis complete. Structural integrity appears within registered safety margins. No immediate anomalies detected in spectral signature.");
          });
        }
      });
    }
  }

  void _recordAudio() {
    setState(() => _isRecording = true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
          final userMessage = ChatMessage(
            text: "Acoustic telemetry sample recorded.",
            isUser: true,
            timestamp: DateTime.now(),
            audioPath: "mock_audio_path.m4a",
          );
          _messages.add(userMessage);
          _isTyping = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isTyping = false;
              _addBotMessage(
                  "Acoustic analysis complete. Frequency patterns indicate stable operational oscillation.");
            });
          }
        });
      }
    });
  }

  void _addBotMessage(String text) {
    final message = ChatMessage(
      text: "",
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
    );

    setState(() {
      _messages.add(message);
    });

    _animateTyping(message, text);
  }

  void _animateTyping(ChatMessage message, String fullText) {
    int charIndex = 0;
    Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        charIndex += 2;
        if (charIndex >= fullText.length) {
          message.text = fullText;
          message.isTyping = false;
          timer.cancel();
        } else {
          message.text = fullText.substring(0, charIndex);
        }
      });
    });
  }

  String _generateMockResponse(String userInput) {
    return "Telemetry received. Correlating structural parameters for identifier: $userInput. All systems optimal.";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: const SMCBackButton(),
        title: Text('TACTICAL DIAGNOSTIC BOT', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              _buildStatusBar(isDark),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  reverse: true,
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == 0) {
                      return const _TypingIndicator();
                    }
                    final messageIndex = _isTyping
                        ? _messages.length - 1 - (index - 1)
                        : _messages.length - 1 - index;
                    return _buildMessageBubble(_messages[messageIndex], isDark);
                  },
                ),
              ),
              if (_messages.length < 5) _buildQuickChips(isDark),
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFF1E293B),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "CORE DIAGNOSTIC LINK • ACTIVE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey[400],
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips(bool isDark) {
    final chips = [
      'Structural Integrity',
      'Power Grid',
      'Sensor Calibration',
      'Network Status'
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: chips
              .map((label) => FadeInRight(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(label),
                        onPressed: () => _handleSubmitted(label),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isUser = message.isUser;
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(message.imagePath!), fit: BoxFit.cover),
                  ),
                ),
              Text(
                message.text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          _buildIconButton(Icons.add_a_photo_rounded, _pickImage, isDark),
          _buildIconButton(
              _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
              _recordAudio,
              isDark,
              color: _isRecording ? Colors.red : null),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Enter telemetry query...",
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleSubmitted(_textController.text),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 18),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}

class ChatMessage {
  String text;
  final bool isUser;
  final DateTime timestamp;
  bool isTyping;
  String? imagePath;
  String? audioPath;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
    this.imagePath,
    this.audioPath,
  });
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              "ANALYZING...",
              style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
