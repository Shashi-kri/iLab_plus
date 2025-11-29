import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      ChatMessage(
        text: 'Hello! I\'m your AI Eye Health Assistant. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final String backendUrl = 'http://10.172.120.174:5000/chat'; // Updated to your local IP address

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    print('[DEBUG] _sendMessage called with: ${_messageController.text}');

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    final userMessage = _messageController.text;
    _messageController.clear();

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );
      print('[DEBUG] Backend response status: ${response.statusCode}');
      print('[DEBUG] Backend response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add(
            ChatMessage(
              text: data['response'] ?? 'No response from server.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Error: ${response.statusCode}',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      print('[DEBUG] Exception in _sendMessage: $e');
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Failed to connect to server: $e',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }

    // Scroll to bottom
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _getAIResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('eye') && lowerMessage.contains('pain')) {
      return 'Eye pain can have various causes. I recommend:\n\n1. Rest your eyes from screens\n2. Apply a warm compress\n3. If pain persists, consult an eye doctor immediately.';
    } else if (lowerMessage.contains('exercise') || lowerMessage.contains('yoga')) {
      return 'Great! Here are some eye exercises:\n\n• 20-20-20 Rule: Every 20 min, look at something 20 feet away for 20 seconds\n• Eye Rolling: Slowly roll eyes clockwise, then counterclockwise\n• Palming: Rub hands together and place over closed eyes';
    } else if (lowerMessage.contains('screen') || lowerMessage.contains('computer')) {
      return 'To reduce screen strain:\n\n• Keep screen 20-26 inches away\n• Adjust brightness to match surroundings\n• Use blue light filters\n• Take regular breaks\n• Blink frequently';
    } else if (lowerMessage.contains('food') || lowerMessage.contains('diet')) {
      return 'Foods great for eye health:\n\n🥕 Carrots (Vitamin A)\n🥬 Leafy greens (Lutein)\n🐟 Fish (Omega-3)\n🥚 Eggs (Zinc)\n🍊 Citrus fruits (Vitamin C)';
    } else {
      return 'I understand your concern about eye health. Could you provide more details? I can help with:\n\n• Eye exercises\n• Screen time tips\n• Nutrition advice\n• Common symptoms\n• When to see a doctor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          _buildQuickActions(),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.secondaryLightBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionChip('Eye Exercises', Icons.self_improvement),
            _buildQuickActionChip('Screen Tips', Icons.computer),
            _buildQuickActionChip('Nutrition', Icons.restaurant),
            _buildQuickActionChip('Symptoms', Icons.health_and_safety),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: AppTheme.peachColor),
        label: Text(label),
        backgroundColor: Colors.white,
        side: BorderSide(color: AppTheme.peachColor.withOpacity(0.3)),
        onPressed: () {
          _messageController.text = label;
          _sendMessage();
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppTheme.peachColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Row(
                children: [
                  Icon(Icons.smart_toy, size: 16, color: AppTheme.peachColor),
                  const SizedBox(width: 6),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.peachColor,
                    ),
                  ),
                ],
              ),
            if (!message.isUser) const SizedBox(height: 6),
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : AppTheme.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about eye health...',
                filled: true,
                fillColor: AppTheme.secondaryLightBlue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
            mini: true,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('About AI Chatbot'),
        content: const Text(
          'This AI chatbot can help you with:\n\n'
          '• Eye health tips\n'
          '• Exercise recommendations\n'
          '• Screen time guidance\n'
          '• Nutrition advice\n'
          '• Symptom information\n\n'
          'Note: This is not a substitute for professional medical advice.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
