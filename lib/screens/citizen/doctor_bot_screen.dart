import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/data/chatbot_data.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:animate_do/animate_do.dart';

class DoctorBotScreen extends StatefulWidget {
  const DoctorBotScreen({super.key});

  @override
  State<DoctorBotScreen> createState() => _DoctorBotScreenState();
}

class _DoctorBotScreenState extends State<DoctorBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isRecording = false;
  final Set<String> _mentionedSymptoms = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messages.isEmpty) {
        _addBotMessage(AppLocalizations.of(context).chatHello);
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
        text: AppLocalizations.of(context).translate('analyze_image'),
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
                "I've analyzed the image. It looks like a common skin irritation. I recommend keeping it clean and monitored. If it spreads or becomes painful, please see a dermatologist.");
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
            text: AppLocalizations.of(context).translate('cough_analysis'),
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
                  "Analysis of your cough pattern suggests a dry cough, likely due to mild throat irritation or allergens. Stay hydrated and try warm salt water gargles.");
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
    final responseKey = ChatbotKnowledgeBase.getResponseKey(userInput);
    final response = AppLocalizations.of(context).translate(responseKey);

    if (ChatbotKnowledgeBase.medicalResponses.containsValue(responseKey)) {
      _mentionedSymptoms.add(responseKey);
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFFDFCFB),
      body: Container(
        decoration: isDark
            ? null
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF7ED), Color(0xFFFDFCFB)],
                ),
              ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark, context),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              if (_messages.length < 3) _buildQuickChips(isDark),
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white.withValues(alpha: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child:
                Icon(Icons.healing_rounded, color: Theme.of(context).primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('bot_inspection_assistant'),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${AppLocalizations.of(context).translate('bot_online')} • ${AppLocalizations.of(context).translate('bot_smart_city_ai')}",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips(bool isDark) {
    final l10n = AppLocalizations.of(context);
    final chips = [
      l10n.translate('fever'),
      l10n.translate('headache'),
      l10n.translate('diet'),
      l10n.translate('vaccine')
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: chips
              .map((symptom) => FadeInRight(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(symptom),
                        onPressed: () => _handleSubmitted(symptom),
                        backgroundColor:
                            isDark ? const Color(0xFF334155) : Colors.white,
                        labelStyle: TextStyle(
                          color: isDark ? Theme.of(context).primaryColor[300] : Theme.of(context).primaryColor[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
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
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: isUser
                ? const Color(0xFF3B82F6)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        Image.file(File(message.imagePath!), fit: BoxFit.cover),
                  ),
                ),
              Text(
                message.text,
                style: GoogleFonts.inter(
                  color: isUser
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF334155)),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey[500],
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
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
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
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context).translate('bot_type_symptoms'),
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleSubmitted(_textController.text),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF3B82F6),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, bool isDark,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: color ?? (isDark ? Theme.of(context).primaryColor[300] : Theme.of(context).primaryColor[600]),
              size: 20),
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
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context).translate('bot_thinking'),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}


