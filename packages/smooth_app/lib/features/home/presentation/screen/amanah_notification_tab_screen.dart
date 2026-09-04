import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_notification_model.dart';
import 'package:smooth_app/features/home/domain/amanah_visual_role.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_empty_state.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_filter_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahNotificationTabScreen extends StatefulWidget {
  const AmanahNotificationTabScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  static Route<void> route({VoidCallback? onBack}) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          AmanahNotificationTabScreen(onBack: onBack),
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
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext modalContext) {
        return _AmanahNotificationDetailModal(item: item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final List<AmanahNotificationItem> filteredList = _store.getFiltered(
      _activeCategory,
    );
    final int unreadCount = _store.unreadCount;

    return Scaffold(
      backgroundColor: AmanahThemeTokens.canvas(context),
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

            // 2. Category Filter Chips (shared master filter bar)
            AmanahFilterBar<AmanahNotificationCategory>(
              selectedValue: _activeCategory,
              onSelected: (AmanahNotificationCategory category) {
                setState(() => _activeCategory = category);
              },
              items: AmanahNotificationCategory.values
                  .map(
                    (AmanahNotificationCategory category) =>
                        AmanahFilterBarItem<AmanahNotificationCategory>(
                          value: category,
                          label: category.label,
                          badgeCount: _store.countForCategory(category),
                        ),
                  )
                  .toList(),
            ),

            // 3. Notification List Area
            Expanded(
              child: filteredList.isEmpty
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: AmanahEmptyState.box(
                        title: 'Belum Ada Notifikasi',
                        message: _activeCategory == AmanahNotificationCategory.all
                            ? 'Semua pembaruan operasional klinis dan jadwal praktik sudah diperiksa.'
                            : 'Tidak ada pemberitahuan pada kategori "${_activeCategory.label}".',
                        actionText: _activeCategory !=
                                AmanahNotificationCategory.all
                            ? 'Lihat Semua Kategori'
                            : null,
                        actionLeadingIcon: _activeCategory !=
                                AmanahNotificationCategory.all
                            ? Icons.clear_all_rounded
                            : null,
                        onAction: _activeCategory !=
                                AmanahNotificationCategory.all
                            ? () => setState(
                                () => _activeCategory =
                                    AmanahNotificationCategory.all,
                              )
                            : null,
                      ),
                    )
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
                    tone: item.visual.tone,
                    icon: item.visual.icon,
                  ),
                  if (item.isUrgent)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AmanahColorTokens.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dark
                                ? const Color(0xFF0A0E1A)
                                : Colors.white,
                            width: 1.8,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AmanahColorTokens.danger.withValues(
                                alpha: 0.60,
                              ),
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
                            color: AmanahColorTokens.brandAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AmanahColorTokens.brandLight.withValues(
                                  alpha: 0.60,
                                ),
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
        color: dark
            ? AmanahColorTokens.neutral200
            : AmanahColorTokens.neutral600,
      ),
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AmanahThemeTokens.elevatedSurface(context),
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
              const Icon(
                Icons.done_all_rounded,
                size: 18,
                color: AmanahColorTokens.brandAccent,
              ),
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
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'clear_read',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AmanahColorTokens.danger,
              ),
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
                    color: dark
                        ? AmanahColorTokens.dangerBorder
                        : AmanahColorTokens.dangerDark,
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
  const _AmanahNotificationDetailModal({required this.item});

  final AmanahNotificationItem item;

  @override
  Widget build(BuildContext context) {
    return AmanahBottomSheetScaffold(
      title: 'Detail notifikasi',
      subtitle: '${item.timestamp} WIB',
      maxHeightFactor: 0.58,
      minHeight: 320,
      trailing: AmanahClayIcon(
        size: 36,
        tone: item.visual.tone,
        icon: item.visual.icon,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.category.label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AmanahColorTokens.brandAccent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AmanahSpacing.sm),
          Text(
            item.title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AmanahThemeTokens.textPrimary(context),
              height: 1.25,
            ),
          ),
          const SizedBox(height: AmanahSpacing.lg),
          Text(
            item.desc,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AmanahThemeTokens.textSecondary(context),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

extension _AmanahNotificationVisualResolver on AmanahNotificationVisual {
  AmanahIconTone get tone {
    switch (this) {
      case AmanahNotificationVisual.queueVitals:
        return AmanahIconTone.queue;
      case AmanahNotificationVisual.clinicalCritical:
        return AmanahIconTone.clinicalCritical;
      case AmanahNotificationVisual.clinicalConsult:
        return AmanahIconTone.clinicalConsult;
      case AmanahNotificationVisual.shiftSchedule:
        return AmanahIconTone.shift;
      case AmanahNotificationVisual.clinicalReport:
        return AmanahIconTone.documents;
      case AmanahNotificationVisual.shiftReminder:
        return AmanahIconTone.success;
    }
  }

  IconData get icon {
    switch (this) {
      case AmanahNotificationVisual.queueVitals:
        return Icons.monitor_heart_outlined;
      case AmanahNotificationVisual.clinicalCritical:
        return Icons.error_outline_rounded;
      case AmanahNotificationVisual.clinicalConsult:
        return Icons.chat_bubble_outline_rounded;
      case AmanahNotificationVisual.shiftSchedule:
        return Icons.calendar_today_outlined;
      case AmanahNotificationVisual.clinicalReport:
        return Icons.description_outlined;
      case AmanahNotificationVisual.shiftReminder:
        return Icons.access_time_rounded;
    }
  }
}
