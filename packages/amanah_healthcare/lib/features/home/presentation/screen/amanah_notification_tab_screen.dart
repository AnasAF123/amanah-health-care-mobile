import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_filter_bar.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/notification/amanah_notification_detail_modal.dart';
import 'package:amanah_healthcare/features/home/presentation/components/notification/amanah_notification_tile.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
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
        return AmanahNotificationDetailModal(item: item);
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
      backgroundColor: dark
          ? AmanahColorTokens.canvasDark
          : AmanahColorTokens.canvasLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // 1. Unified Master Header Bar
            AmanahScreenHeader(
              title: 'Notifikasi',
              subtitle: unreadCount > 0
                  ? '$unreadCount belum dibaca'
                  : 'Semua sudah dibaca',
              onBack: widget.onBack,
              trailing: _AmanahNotificationOptionsMenu(
                dark: dark,
                onMarkAllRead: () => _store.markAllAsRead(),
                onClearRead: () => _store.clearRead(),
              ),
            ),

            // 2. Filter Bar
            AmanahFilterBar<AmanahNotificationCategory>(
              selectedValue: _activeCategory,
              onSelected: (AmanahNotificationCategory cat) {
                setState(() => _activeCategory = cat);
              },
              items: AmanahNotificationCategory.values
                  .map(
                    (AmanahNotificationCategory cat) =>
                        AmanahFilterBarItem<AmanahNotificationCategory>(
                      value: cat,
                      label: cat.label,
                      badgeCount: _store.countForCategory(cat),
                    ),
                  )
                  .toList(),
            ),

            // 3. Notification List Viewport / Empty State
            Expanded(
              child: AmanahPullToRefresh(
                onRefresh: () async {
                  await Future<void>.delayed(
                    const Duration(milliseconds: 600),
                  );
                },
                child: filteredList.isEmpty
                    ? Center(
                        child: AmanahEmptyState.viewport(
                          title:
                              _activeCategory == AmanahNotificationCategory.all
                                  ? 'Belum Ada Notifikasi'
                                  : 'Tidak Ada Notifikasi',
                          message:
                              _activeCategory == AmanahNotificationCategory.all
                                  ? 'Semua notifikasi penting terkait antrean, jadwal shift, dan update klinis akan muncul di sini.'
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
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: filteredList.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                          height: 1,
                          thickness: 1,
                          color: dark
                              ? AmanahColorTokens.surfaceLight.withValues(
                                  alpha: 0.05,
                                )
                              : AmanahColorTokens.neutral100,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final AmanahNotificationItem item =
                              filteredList[index];
                          return AmanahNotificationTile(
                            item: item,
                            dark: dark,
                            onTap: () => _handleItemClick(item),
                          );
                        },
                      ),
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
        color: dark
            ? AmanahColorTokens.neutral200
            : AmanahColorTokens.neutral600,
      ),
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: dark
          ? AmanahColorTokens.surfaceSecondaryDark
          : AmanahColorTokens.surfaceLight,
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
              Icon(
                Icons.done_all_rounded,
                size: 18,
                color: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brandAccent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tandai Semua Dibaca',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: dark
                        ? AmanahColorTokens.surfaceLight
                        : AmanahColorTokens.neutral900,
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
