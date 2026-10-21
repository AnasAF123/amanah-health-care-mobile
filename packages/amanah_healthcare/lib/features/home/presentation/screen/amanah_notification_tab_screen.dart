import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/notification/amanah_notification_detail_modal.dart';
import 'package:amanah_healthcare/features/home/presentation/components/notification/amanah_notification_tile.dart';
import 'package:amanah_healthcare/features/home/presentation/components/notification/notification_skeleton_view.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahNotificationTabScreen extends StatefulWidget {
  const AmanahNotificationTabScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  static Route<void> route({VoidCallback? onBack}) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => AmanahNotificationTabScreen(onBack: onBack),
    );
  }

  @override
  State<AmanahNotificationTabScreen> createState() => _AmanahNotificationTabScreenState();
}

class _AmanahNotificationTabScreenState extends State<AmanahNotificationTabScreen> {
  final AmanahNotificationStore _store = AmanahNotificationStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.fetchMyNotifications();
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
    final List<AmanahNotificationItem> notificationList = _store.notifications;
    final int unreadCount = _store.unreadCount;

    return Scaffold(
      backgroundColor: dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // 1. Unified Master Header Bar
            AmanahScreenHeader(
              title: 'Notifikasi',
              subtitle: unreadCount > 0 ? '$unreadCount belum dibaca' : 'Semua sudah dibaca',
              onBack: widget.onBack,
              trailing: unreadCount > 0
                  ? IconButton(
                      icon: Icon(
                        Icons.done_all_rounded,
                        size: 20,
                        color: dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand,
                      ),
                      tooltip: 'Tandai Semua Dibaca',
                      onPressed: () => _store.markAllAsRead(),
                    )
                  : null,
            ),

            // 2. Notification List Viewport / Skeleton / Empty State
            Expanded(
              child: AmanahPullToRefresh(
                onRefresh: () async {
                  await _store.fetchMyNotifications();
                },
                child: _store.isLoading && notificationList.isEmpty
                    ? const NotificationSkeletonView()
                    : notificationList.isEmpty
                    ? SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: AmanahEmptyState.box(
                          title: 'Belum Ada Notifikasi',
                          message:
                              'Semua pembaruan antrean klinis dan operasional akan tampil di sini secara real-time.',
                          actionText: (widget.onBack != null || Navigator.of(context).canPop())
                              ? 'Kembali'
                              : null,
                          actionLeadingIcon:
                              (widget.onBack != null || Navigator.of(context).canPop())
                              ? Icons.arrow_back_rounded
                              : null,
                          onAction: (widget.onBack != null || Navigator.of(context).canPop())
                              ? () {
                                  if (widget.onBack != null) {
                                    widget.onBack!.call();
                                  } else {
                                    Navigator.of(context).maybePop();
                                  }
                                }
                              : null,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: notificationList.length,
                        separatorBuilder: (BuildContext context, int index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: dark
                              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                              : AmanahColorTokens.neutral100,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final AmanahNotificationItem item = notificationList[index];
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
