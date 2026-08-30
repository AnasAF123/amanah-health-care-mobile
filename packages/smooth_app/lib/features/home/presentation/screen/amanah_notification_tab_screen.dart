import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_notification_model.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';

class AmanahNotificationTabScreen extends StatefulWidget {
  const AmanahNotificationTabScreen({
    this.onBack,
    super.key,
  });

  final VoidCallback? onBack;

  static Route<void> route({VoidCallback? onBack}) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => AmanahNotificationTabScreen(onBack: onBack),
    );
  }

  @override
  State<AmanahNotificationTabScreen> createState() =>
      _AmanahNotificationTabScreenState();
}

class _AmanahNotificationTabScreenState
    extends State<AmanahNotificationTabScreen> {
  final AmanahNotificationStore _store = AmanahNotificationStore.instance;
  AmanahNotificationCategory _activeCategory = AmanahNotificationCategory.all;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdated);
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleItemClick(AmanahNotificationItem item) {
    _store.markAsRead(item.id);
    _showNotificationDetail(item);
  }

  void _showNotificationDetail(AmanahNotificationItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (BuildContext modalContext) {
        final bool dark = Theme.of(modalContext).brightness == Brightness.dark;
        return _AmanahNotificationDetailModal(item: item, dark: dark);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final List<AmanahNotificationItem> filteredList =
        _store.getFiltered(_activeCategory);
    final int unreadCount = _store.unreadCount;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // 1. Header (Compact, Symmetric, Unified)
            AmanahScreenHeader(
              title: 'Notifikasi',
              subtitle: unreadCount > 0 ? '$unreadCount belum dibaca' : null,
              onBack: widget.onBack,
              rightAction: _AmanahNotificationOptionsMenu(
                onMarkAllRead: _store.markAllAsRead,
                onClearRead: _store.clearRead,
                dark: dark,
              ),
            ),

            // 2. Category Filter Chips (Horizontal Scrolling)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: AmanahNotificationCategory.values
                      .map((AmanahNotificationCategory category) {
                    final bool isActive = _activeCategory == category;
                    final int count = _store.countForCategory(category);

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _AmanahCategoryChip(
                        category: category,
                        count: count,
                        isActive: isActive,
                        dark: dark,
                        onTap: () {
                          setState(() {
                            _activeCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 3. Notification List Area
            Expanded(
              child: filteredList.isEmpty
                  ? _AmanahEmptyNotificationView(dark: dark)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(
                        height: 1,
                        thickness: 1,
                        color: dark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final AmanahNotificationItem item = filteredList[index];
                        return _AmanahNotificationTile(
                          item: item,
                          dark: dark,
                          onTap: () => _handleItemClick(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmanahCategoryChip extends StatelessWidget {
  const _AmanahCategoryChip({
    required this.category,
    required this.count,
    required this.isActive,
    required this.dark,
    required this.onTap,
  });

  final AmanahNotificationCategory category;
  final int count;
  final bool isActive;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color badgeBg;
    final Color badgeText;

    if (isActive) {
      bgColor = const Color(0xFF0A44FF);
      textColor = Colors.white;
      badgeBg = Colors.white.withValues(alpha: 0.22);
      badgeText = Colors.white;
    } else {
      if (dark) {
        bgColor = Colors.white.withValues(alpha: 0.05);
        textColor = const Color(0xFF94A3B8);
        badgeBg = Colors.white.withValues(alpha: 0.10);
        badgeText = const Color(0xFFCBD5E1);
      } else {
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        badgeBg = const Color(0xFFE2E8F0);
        badgeText = const Color(0xFF334155);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                category.label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
              ),
              if (count > 0) ...<Widget>[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AmanahNotificationTile extends StatelessWidget {
  const _AmanahNotificationTile({
    required this.item,
    required this.dark,
    required this.onTap,
  });

  final AmanahNotificationItem item;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Left Leading 3D ClayIcon + Urgent Badge
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  AmanahClayIcon(
                    size: 32,
                    colorPrimary: item.colorPrimary,
                    colorLight: item.colorLight,
                    colorDark: item.colorDark,
                    icon: item.icon,
                  ),
                  if (item.isUrgent)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dark ? const Color(0xFF0A0E1A) : Colors.white,
                            width: 1.8,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.60),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Middle Title + Desc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: item.isUnread
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: item.isUnread
                            ? (dark ? Colors.white : const Color(0xFF0F172A))
                            : (dark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155)),
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: dark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right Trailing Time + Unread Dot + Chevron
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      if (item.isUnread) ...<Widget>[
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.60),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmanahEmptyNotificationView extends StatelessWidget {
  const _AmanahEmptyNotificationView({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: dark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada notifikasi',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: dark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Semua pembaruan pada kategori ini sudah diperiksa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: dark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmanahNotificationOptionsMenu extends StatelessWidget {
  const _AmanahNotificationOptionsMenu({
    required this.onMarkAllRead,
    required this.onClearRead,
    required this.dark,
  });

  final VoidCallback onMarkAllRead;
  final VoidCallback onClearRead;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: dark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
      ),
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark ? const Color(0xFF111624) : Colors.white,
      elevation: 12,
      onSelected: (String value) {
        if (value == 'mark_all') {
          onMarkAllRead();
        } else if (value == 'clear_read') {
          onClearRead();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'mark_all',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.done_all_rounded,
                  size: 18, color: Color(0xFF06B6D4)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tandai Semua Dibaca',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(
          height: 1,
        ),
        PopupMenuItem<String>(
          value: 'clear_read',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.delete_outline_rounded,
                  size: 18, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Bersihkan Terbaca',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        dark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmanahNotificationDetailModal extends StatelessWidget {
  const _AmanahNotificationDetailModal({
    required this.item,
    required this.dark,
  });

  final AmanahNotificationItem item;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewPaddingOf(context).bottom + 24,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF111624).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFFF1F5F9),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.40 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header: ClayIcon + Category + Timestamp
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AmanahClayIcon(
                      size: 36,
                      colorPrimary: item.colorPrimary,
                      colorLight: item.colorLight,
                      colorDark: item.colorDark,
                      icon: item.icon,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                item.category.label.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0891B2),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '${item.timestamp} WIB',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: dark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                Text(
                  item.desc,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: dark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Action Footer
                Divider(
                  height: 1,
                  thickness: 1,
                  color: dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: dark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: dark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
