import 'package:flutter/material.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';

class AmanahPermissionDetailDrawer extends StatelessWidget {
  const AmanahPermissionDetailDrawer({
    required this.item,
    required this.onEdit,
    required this.onCancel,
    super.key,
  });

  final AmanahPermissionRecord item;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  static Future<void> show({
    required BuildContext context,
    required AmanahPermissionRecord item,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (BuildContext ctx) => AmanahPermissionDetailDrawer(
        item: item,
        onEdit: onEdit,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    final Color bgColor =
        dark ? const Color(0xFF0A0E1A) : const Color(0xFFFFFFFF);
    final Color borderColor =
        dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor =
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color sectionBg =
        dark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC);
    final Color sectionBorder =
        dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.88,
        minHeight: 480,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.80 : 0.30),
            blurRadius: 45,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Interactive Drag Handle
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Detail perizinan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F5F9),
                    foregroundColor: subtextColor,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Body Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Status Banner
                  _buildStatusBanner(dark),
                  const SizedBox(height: 14),

                  // 2. Applicant Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sectionBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sectionBorder),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.20)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              item.userAvatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Container(
                                  color: const Color(0xFF0A44FF)
                                      .withValues(alpha: 0.30),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.userRole,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Date Interval (2-column grid)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sectionBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: sectionBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Mulai Izin',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: subtextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.formattedStartDate,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: sectionBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: sectionBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Selesai Izin',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: subtextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.formattedEndDate,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Reason / Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: sectionBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sectionBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Pesan / Alasan Perizinan:',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: subtextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.reason,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Substitute Doctor (if present)
                  if (item.substituteDoctor != null &&
                      item.substituteDoctor!.isNotEmpty) ...<Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sectionBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: sectionBorder),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 16,
                            color: Color(0xFF06B6D4),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Dokter Pengganti:',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: subtextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.substituteDoctor!,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 6. Reviewer / HRD Notes (if present)
                  if (item.reviewerNotes != null &&
                      item.reviewerNotes!.isNotEmpty) ...<Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: sectionBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sectionBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Catatan Verifikasi:',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: subtextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.reviewerNotes!,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                              height: 1.45,
                            ),
                          ),
                          if (item.reviewerName != null) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              'Oleh: ${item.reviewerName}',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 7. Actions Footer
                  if (item.status == AmanahPermissionStatus.menunggu) ...<Widget>[
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onEdit();
                            },
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text(
                              'Edit Izin',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A44FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onCancel();
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: Color(0xFFEF4444),
                            ),
                            label: const Text(
                              'Batalkan',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: dark
                                    ? const Color(0xFFEF4444)
                                        .withValues(alpha: 0.30)
                                    : const Color(0xFFFECDD3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (item.status == AmanahPermissionStatus.disetujui) ...<Widget>[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.30)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: dark
                              ? const Color(0xFF10B981).withValues(alpha: 0.20)
                              : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Izin telah disetujui (Terkonfirmasi di SIMRS)',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: dark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(bool dark) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final IconData icon;

    switch (item.status) {
      case AmanahPermissionStatus.menunggu:
        bgColor = dark
            ? const Color(0xFF451A03).withValues(alpha: 0.40)
            : const Color(0xFFFFFBEB);
        borderColor = dark
            ? const Color(0xFFF59E0B).withValues(alpha: 0.30)
            : const Color(0xFFFDE68A);
        textColor = dark ? const Color(0xFFFBBF24) : const Color(0xFF92400E);
        icon = Icons.access_time_rounded;

      case AmanahPermissionStatus.disetujui:
        bgColor = dark
            ? const Color(0xFF064E3B).withValues(alpha: 0.40)
            : const Color(0xFFECFDF5);
        borderColor = dark
            ? const Color(0xFF10B981).withValues(alpha: 0.30)
            : const Color(0xFFA7F3D0);
        textColor = dark ? const Color(0xFF34D399) : const Color(0xFF065F46);
        icon = Icons.check_circle_rounded;

      case AmanahPermissionStatus.ditolak:
        bgColor = dark
            ? const Color(0xFF4C0519).withValues(alpha: 0.40)
            : const Color(0xFFFFF1F2);
        borderColor = dark
            ? const Color(0xFFF43F5E).withValues(alpha: 0.30)
            : const Color(0xFFFECDD3);
        textColor = dark ? const Color(0xFFFB7185) : const Color(0xFF9F1239);
        icon = Icons.cancel_rounded;

      case AmanahPermissionStatus.dibatalkan:
        bgColor = dark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F5F9);
        borderColor = dark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0);
        textColor = dark ? const Color(0xFFA1A1AA) : const Color(0xFF475569);
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status: ${item.status.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.durationDays} Hari Izin',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
