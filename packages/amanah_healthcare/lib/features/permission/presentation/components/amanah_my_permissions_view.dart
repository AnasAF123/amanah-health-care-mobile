import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_filter_bar.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_empty_permission_view.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_card.dart';

/// Tab Viewport: "Izin Saya"
/// Encapsulates filter bar, pull-to-refresh, empty states, and permission cards list.
class AmanahMyPermissionsView extends StatelessWidget {
  const AmanahMyPermissionsView({
    required this.records,
    required this.statusFilter,
    required this.onFilterSelected,
    required this.onRefresh,
    required this.onItemTap,
    required this.onAddPermission,
    required this.isLoading,
    super.key,
  });

  final List<AmanahPermissionRecord> records;
  final AmanahPermissionStatus? statusFilter;
  final ValueChanged<AmanahPermissionStatus?> onFilterSelected;
  final Future<void> Function() onRefresh;
  final ValueChanged<AmanahPermissionRecord> onItemTap;
  final VoidCallback onAddPermission;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final List<AmanahPermissionRecord> filteredList = statusFilter == null
        ? records
        : records.where((AmanahPermissionRecord r) => r.status == statusFilter).toList();

    final int pendingCount =
        records.where((r) => r.status == AmanahPermissionStatus.menunggu).length;

    return Column(
      children: <Widget>[
        // Filter Chips Bar
        AmanahFilterBar<AmanahPermissionStatus?>(
          selectedValue: statusFilter,
          onSelected: onFilterSelected,
          items: <AmanahFilterBarItem<AmanahPermissionStatus?>>[
            const AmanahFilterBarItem<AmanahPermissionStatus?>(
              value: null,
              label: 'Semua',
            ),
            AmanahFilterBarItem<AmanahPermissionStatus?>(
              value: AmanahPermissionStatus.menunggu,
              label: 'Menunggu',
              badgeCount: pendingCount,
            ),
            const AmanahFilterBarItem<AmanahPermissionStatus?>(
              value: AmanahPermissionStatus.disetujui,
              label: 'Disetujui',
            ),
            const AmanahFilterBarItem<AmanahPermissionStatus?>(
              value: AmanahPermissionStatus.ditolak,
              label: 'Ditolak',
            ),
            const AmanahFilterBarItem<AmanahPermissionStatus?>(
              value: AmanahPermissionStatus.dibatalkan,
              label: 'Dibatalkan',
            ),
          ],
        ),

        // Cards List Viewport with Pull-to-Refresh
        Expanded(
          child: AmanahPullToRefresh(
            onRefresh: onRefresh,
            child: isLoading && records.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredList.isEmpty
                    ? AmanahEmptyPermissionView(
                        onAddPermission: onAddPermission,
                        selectedStatus: statusFilter,
                        onResetFilter: statusFilter != null
                            ? () => onFilterSelected(null)
                            : null,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: filteredList.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (BuildContext context, int index) {
                          final AmanahPermissionRecord item = filteredList[index];
                          return AmanahPermissionCard(
                            item: item,
                            onTap: () => onItemTap(item),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
