import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';

class AmanahChatMessage {
  const AmanahChatMessage({
    required this.id,
    required this.sender, // 'it' | 'user'
    required this.text,
    required this.time,
  });

  final String id;
  final String sender;
  final String text;
  final String time;
}

class AmanahItChatScreen extends StatefulWidget {
  const AmanahItChatScreen({
    this.user,
    this.onBack,
    this.onTicketCreated,
    super.key,
  });

  final AmanahAuthUser? user;
  final VoidCallback? onBack;
  final void Function(String title, String date)? onTicketCreated;

  @override
  State<AmanahItChatScreen> createState() => _AmanahItChatScreenState();
}

class _AmanahItChatScreenState extends State<AmanahItChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTechnicianTyping = false;

  final List<AmanahChatMessage> _messages = <AmanahChatMessage>[
    const AmanahChatMessage(
      id: 'msg-1',
      sender: 'it',
      text:
          'Halo dr. Amelia, ada kendala pada sistem SIMRS, scanner presensi, atau perangkat poli yang bisa tim IT bantu?',
      time: '08:00',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _handleSendMessage() {
    final String trimmed = _textController.text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();
    final String timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final AmanahChatMessage userMsg = AmanahChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      text: trimmed,
      time: timeStr,
    );

    setState(() {
      _messages.add(userMsg);
      _isTechnicianTyping = true;
      _textController.clear();
    });

    widget.onTicketCreated?.call(trimmed, 'Hari ini, $timeStr');
    _scrollToBottom();

    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      final DateTime replyNow = DateTime.now();
      final String replyTime =
          '${replyNow.hour.toString().padLeft(2, '0')}:${replyNow.minute.toString().padLeft(2, '0')}';
      final AmanahChatMessage itReply = AmanahChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
        sender: 'it',
        text:
            'Laporan Anda sudah kami catat dan dibuatkan tiket penanganan. Teknisi IT sedang memverifikasi kendala ini.',
        time: replyTime,
      );
      setState(() {
        _messages.add(itReply);
        _isTechnicianTyping = false;
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFF8FAFF);
    final Color bottomBarBg = dark ? const Color(0xFF0A0E1A) : Colors.white;
    final Color bottomBarBorder = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);
    final Color inputBg = dark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF8FAFC);
    final Color inputBorder = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color hintColor = dark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header with online status subtitle
            AmanahScreenHeader(
              title: 'Chat teknisi IT',
              subtitle: 'Helpdesk SIMRS · online',
              onBack: widget.onBack,
            ),

            // Messages Viewport
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _messages.length + (_isTechnicianTyping ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == _messages.length && _isTechnicianTyping) {
                    return _buildTypingIndicator(dark);
                  }
                  final AmanahChatMessage msg = _messages[index];
                  final bool isUser = msg.sender == 'user';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        if (!isUser) ...<Widget>[
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(
                                      0xFF0369A1,
                                    ).withValues(alpha: 0.3)
                                  : const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dark
                                    ? const Color(
                                        0xFF38BDF8,
                                      ).withValues(alpha: 0.3)
                                    : const Color(0xFFDBEAFE),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'IT',
                                style: TextStyle(
                                  color: dark
                                      ? const Color(0xFF7DD3FC)
                                      : const Color(0xFF2563EB),
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.76,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF0D66E9)
                                  : (dark
                                        ? const Color(0xFF111624)
                                        : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                              border: !isUser && dark
                                  ? Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : (dark
                                              ? const Color(0xFFE2E8F0)
                                              : const Color(0xFF1E293B)),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.time,
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white.withValues(alpha: 0.70)
                                        : (dark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B)),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isUser) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: Color(0xFF0D66E9),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Sticky Chat Input Bar
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: bottomBarBg,
                border: Border(top: BorderSide(color: bottomBarBorder)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan kendala teknis...',
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12.5,
                        ),
                        filled: true,
                        fillColor: inputBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: inputBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: inputBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D66E9),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AmanahButton.primary(
                    text: 'Kirim',
                    size: AmanahButtonSize.medium,
                    onPressed: _handleSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF0369A1).withValues(alpha: 0.3)
                  : const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'IT',
                style: TextStyle(
                  color: dark
                      ? const Color(0xFF7DD3FC)
                      : const Color(0xFF2563EB),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF111624) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _dot(dark),
                const SizedBox(width: 4),
                _dot(dark),
                const SizedBox(width: 4),
                _dot(dark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool dark) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        shape: BoxShape.circle,
      ),
    );
  }
}
