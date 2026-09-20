import 'dart:async';

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
  late final List<AmanahChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    final String greetingName =
        widget.user?.staff?.fullName?.trim().isNotEmpty == true
            ? widget.user!.staff!.fullName!
            : (widget.user?.fullName.trim().isNotEmpty == true
                ? widget.user!.fullName
                : 'Tenaga Medis');

    _messages = <AmanahChatMessage>[
      AmanahChatMessage(
        id: 'msg-1',
        sender: 'it',
        text:
            'Halo $greetingName, ada kendala pada sistem SIMRS, scanner presensi, atau perangkat poli yang bisa tim IT bantu?',
        time: '08:00',
      ),
    ];
  }

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

    final Color bgColor = AmanahThemeTokens.canvas(context);
    final Color bottomBarBg = AmanahThemeTokens.canvas(context);
    final Color bottomBarBorder = dark
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
        : AmanahColorTokens.neutral100;
    final Color inputBg = dark
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
        : AmanahColorTokens.neutral50;
    final Color inputBorder = dark
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
        : AmanahColorTokens.neutral200;
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color hintColor = AmanahThemeTokens.textTertiary(context);

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
                                  ? AmanahColorTokens.sky.withValues(alpha: 0.30)
                                  : AmanahColorTokens.brandSurface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dark
                                    ? AmanahColorTokens.skySoft.withValues(
                                        alpha: 0.30,
                                      )
                                    : AmanahColorTokens.brandMuted,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'IT',
                                style: TextStyle(
                                  color: dark
                                      ? AmanahColorTokens.skySoft
                                      : AmanahColorTokens.brandAccent,
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
                                  ? AmanahColorTokens.brand
                                  : (dark
                                        ? AmanahColorTokens.surfaceSecondaryDark
                                        : AmanahColorTokens.neutral100),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 16 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 16),
                              ),
                              border: !isUser && dark
                                  ? Border.all(
                                      color: AmanahColorTokens.pureWhite
                                          .withValues(alpha: 0.08),
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
                                        ? AmanahColorTokens.pureWhite
                                        : (dark
                                              ? AmanahColorTokens.neutral200
                                              : AmanahColorTokens.neutral800),
                                    fontSize: 12.5,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.time,
                                  style: TextStyle(
                                    color: isUser
                                        ? AmanahColorTokens.pureWhite
                                            .withValues(alpha: 0.70)
                                        : (dark
                                              ? AmanahColorTokens.neutral400
                                              : AmanahColorTokens.neutral500),
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
                                  ? AmanahColorTokens.neutral800
                                  : AmanahColorTokens.neutral200,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: AmanahColorTokens.brand,
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
                        fontSize: 12.5,
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan kendala teknis...',
                        hintStyle: TextStyle(
                          color: hintColor,
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
                          borderSide: BorderSide(
                            color: dark
                                ? AmanahColorTokens.cyanAccent
                                : AmanahColorTokens.brand,
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
                  ? AmanahColorTokens.sky.withValues(alpha: 0.30)
                  : AmanahColorTokens.brandSurface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'IT',
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.skySoft
                      : AmanahColorTokens.brandAccent,
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
              color: dark
                  ? AmanahColorTokens.surfaceSecondaryDark
                  : AmanahColorTokens.neutral100,
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
        color: dark
            ? AmanahColorTokens.neutral400
            : AmanahColorTokens.neutral500,
        shape: BoxShape.circle,
      ),
    );
  }
}
