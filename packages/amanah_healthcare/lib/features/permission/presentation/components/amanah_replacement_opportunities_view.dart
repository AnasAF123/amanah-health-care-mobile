import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_replacement_opportunity_card.dart';

/// Tab Viewport: "Jadwal Pengganti"
/// Encapsulates pull-to-refresh, empty states, and replacement opportunity cards list.
/// Top padding (6px) is aligned with the filter chips on "Izin Saya".
class AmanahReplacementOpportunitiesView extends StatelessWidget {
  const AmanahReplacementOpportunitiesView({
    required this.items,
    required this.onRefresh,
    required this.onItemTap,
    required this.onClaim,
    required this.staffProfileId,
    required this.doctorName,
    super.key,
  });

  final List<ReplacementItem> items;
  final Future<void> Function() onRefresh;
  final ValueChanged<ReplacementItem> onItemTap;
  final Future<bool> Function(ReplacementItem) onClaim;
  final String staffProfileId;
  final String doctorName;

  @override
  Widget build(BuildContext context) {
    return AmanahPullToRefresh(
      onRefresh: onRefresh,
      child: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AmanahEmptyState.box(
                  title: 'Tidak Ada Jadwal Pengganti Terbuka',
                  message:
                      'Saat rekan kerja mengajukan izin dan disetujui, sesi dinas yang kosong akan muncul di sini agar dapat Anda klaim.',
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final ReplacementItem item = items[index];
                return AmanahReplacementOpportunityCard(
                  item: item,
                  onTap: () => onItemTap(item),
                  onClaim: () => onClaim(item),
                  currentStaffProfileId: staffProfileId,
                  currentUserName: doctorName,
                );
              },
            ),
    );
  }
}
