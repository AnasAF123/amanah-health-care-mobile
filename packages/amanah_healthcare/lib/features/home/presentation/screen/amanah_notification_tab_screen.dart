import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_filter_bar.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/notification/amanah_notification_components.dart';
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
    _store.addListener(_onStoreUpdated);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _store.loadNotifications();
      }
    });
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
      backgroundColor: AmanahThemeTokens.canvas(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Notifikasi',
              subtitle: unreadCount > 0 ? '$unreadCount belum dibaca' : null,
              onBack: widget.onBack,
              rightAction: AmanahNotificationOptionsMenu(
                onMarkAllRead: _store.markAllAsRead,
                onClearRead: _store.clearRead,
                dark: dark,
              ),
            ),
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
            Expanded(
              child: AmanahPullToRefresh(
                onRefresh: () async {
                  await _store.loadNotifications();
                },
                child: filteredList.isEmpty
                    ? SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
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
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: filteredList.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: dark
                                  ? AmanahColorTokens.pureWhite.withValues(
                                      alpha: 0.05,
                                    )
                                  : AmanahColorTokens.neutral100,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final AmanahNotificationItem item = filteredList[index];
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
