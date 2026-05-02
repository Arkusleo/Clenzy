import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class SafetyChatScreen extends StatefulWidget {
  const SafetyChatScreen({super.key});

  @override
  State<SafetyChatScreen> createState() => _SafetyChatScreenState();
}

class _SafetyChatScreenState extends State<SafetyChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your Clenzy Safety Assistant. How can I help ensure your peace of mind today?',
      'isUser': false,
      'time': DateTime.now(),
    }
  ];

  final List<String> _dummyResponses = [
    "I've checked the profile of your upcoming service provider. They have passed all our rigorous background checks and hold a 99% safety rating.",
    "Clenzy's SafeGuard policy ensures that your payment and physical security are our top priorities. You can always hit the Emergency SOS button if you feel unsafe.",
    "Your professional's identity is fully verified. We also track their location during the service to ensure everything goes smoothly.",
    "Is there anything specific you would like me to review regarding your bookings or our safety protocols?",
    "I'm here 24/7. If you need any immediate assistance, just let me know!",
  ];
  int _responseIndex = 0;

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    setState(() {
      _messages.insert(0, {
        'text': text,
        'isUser': true,
        'time': DateTime.now(),
      });
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI thinking and responding
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.insert(0, {
            'text': _dummyResponses[_responseIndex],
            'isUser': false,
            'time': DateTime.now(),
          });
          _responseIndex = (_responseIndex + 1) % _dummyResponses.length;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030303) : const Color(0xFFFBFBFF),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              reverse: true,
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == 0) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: _buildTypingIndicator(isDark),
                  );
                }
                
                final int msgIndex = _isTyping ? index - 1 : index;
                final message = _messages[msgIndex];
                
                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  child: _buildMessageBubble(
                    message['text'],
                    message['isUser'],
                    isDark,
                  ),
                );
              },
            ),
          ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0D0F14).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF3366FF), Color(0xFF2563EB)]),
              boxShadow: [BoxShadow(color: const Color(0xFF3366FF).withValues(alpha: 0.3), blurRadius: 10)],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Safety Assistant',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'AI Online',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? Colors.white60 : Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF3366FF), Color(0xFF2563EB)]),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isUser 
                    ? const Color(0xFF3366FF) 
                    : (isDark ? const Color(0xFF141820) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 24),
                ),
                border: isUser ? null : Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8ECF4)
                ),
                boxShadow: isUser ? [
                  BoxShadow(color: const Color(0xFF3366FF).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))
                ] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isUser 
                      ? Colors.white 
                      : (isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF1E293B)),
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 28), // balance visual spacing
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF3366FF), Color(0xFF2563EB)]),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141820) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8ECF4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(150),
                const SizedBox(width: 4),
                _buildDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Opacity(
          opacity: (value * 0.5) + 0.5,
          child: Transform.translate(
            offset: Offset(0, -3 * value),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF3366FF),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
      onEnd: () {
        // This makes it loop smoothly
      },
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF030303) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8ECF4),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141820) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSubmitted,
                      decoration: InputDecoration(
                        hintText: 'Ask about Clenzy safety...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSubmitted(_textController.text),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF3366FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3366FF).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
