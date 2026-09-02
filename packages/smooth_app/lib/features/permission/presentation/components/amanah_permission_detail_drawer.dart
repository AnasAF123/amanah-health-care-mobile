import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
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
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahPermissionDetailDrawer(
        item: item,
        onEdit: onEdit,
        onCancel: onCancel,
      ),
    );
  }

  void _showPdfInfoToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Membuka dokumen perizinan (${item.id.toUpperCase()})...',
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AmanahRadius.pill),
        ),
        backgroundColor: AmanahColorTokens.neutral900,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AmanahBottomSheetScaffold(
      title: 'Detail perizinan',
      subtitle: item.formattedDateRange,
      minHeight: 480,
      maxHeightFactor: 0.88,
      trailing: _PermissionDetailOverflow(
        item: item,
        onDownloadPdf: () => _showPdfInfoToast(context),
        onEdit: () {
          Navigator.of(context).pop();
          onEdit();
        },
        onCancel: () {
          Navigator.of(context).pop();
          onCancel();
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  item.type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: AmanahSpacing.md),
              _PermissionStatusPill(status: item.status),
            ],
          ),
          const SizedBox(height: AmanahSpacing.lg),
          const _PermissionDivider(),
          _PermissionInfoRow(
            label: 'Mulai Izin',
            value: item.formattedStartDate,
          ),
          _PermissionInfoRow(
            label: 'Selesai Izin',
            value: item.formattedEndDate,
          ),
          _PermissionInfoRow(
            label: 'Durasi',
            value: '${item.durationDays} Hari Kerja',
            semanticValue: 'Durasi: ${item.durationDays} Hari Kerja',
          ),
          const _PermissionDivider(),
          _PermissionTextSection(
            title: 'Pesan / Alasan Perizinan',
            body: item.reason,
          ),
          if (item.substituteDoctor != null &&
              item.substituteDoctor!.isNotEmpty &&
              item.substituteDoctor != '-') ...<Widget>[
            const _PermissionDivider(),
            _SubstituteDoctorSection(name: item.substituteDoctor!),
          ],
          if (item.reviewerNotes != null &&
              item.reviewerNotes!.isNotEmpty) ...<Widget>[
            const _PermissionDivider(),
            _PermissionTextSection(
              title: 'Catatan Verifikasi',
              body: item.reviewerNotes!,
              footer: item.reviewerName == null
                  ? null
                  : 'Oleh: ${item.reviewerName}',
            ),
          ],
          if (item.status == AmanahPermissionStatus.disetujui) ...<Widget>[
            const SizedBox(height: AmanahSpacing.lg),
            const _ApprovedNotice(),
          ],
        ],
      ),
    );
  }
}

class _PermissionDetailOverflow extends StatelessWidget {
  const _PermissionDetailOverflow({
    required this.item,
    required this.onDownloadPdf,
    required this.onEdit,
    required this.onCancel,
  });

  final AmanahPermissionRecord item;
  final VoidCallback onDownloadPdf;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bool canMutate = item.status == AmanahPermissionStatus.menunggu;

    return PopupMenuButton<String>(
      tooltip: 'Aksi perizinan',
      icon: Icon(
        Icons.more_vert_rounded,
        color: AmanahThemeTokens.textSecondary(context),
      ),
      constraints: const BoxConstraints(minWidth: 190, maxWidth: 240),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AmanahRadius.lg),
      ),
      color: AmanahThemeTokens.elevatedSurface(context),
      elevation: 12,
      onSelected: (String value) {
        switch (value) {
          case 'pdf':
            onDownloadPdf();
            break;
          case 'edit':
            onEdit();
            break;
          case 'cancel':
            onCancel();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'pdf',
          child: _MenuItemLabel(
            icon: Icons.file_download_outlined,
            label: 'Unduh PDF',
            tone: AmanahStatusTone.brand,
          ),
        ),
        if (canMutate) ...<PopupMenuEntry<String>>[
          const PopupMenuDivider(height: 1),
          const PopupMenuItem<String>(
            value: 'edit',
            child: _MenuItemLabel(
              icon: Icons.edit_outlined,
              label: 'Edit Izin',
              tone: AmanahStatusTone.brand,
            ),
          ),
          const PopupMenuItem<String>(
            value: 'cancel',
            child: _MenuItemLabel(
              icon: Icons.delete_outline_rounded,
              label: 'Batalkan',
              tone: AmanahStatusTone.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _MenuItemLabel extends StatelessWidget {
  const _MenuItemLabel({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final AmanahStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final AmanahTone resolvedTone = AmanahThemeTokens.status(tone);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 18, color: resolvedTone.primary),
        const SizedBox(width: AmanahSpacing.sm),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tone == AmanahStatusTone.danger
                  ? resolvedTone.dark
                  : AmanahThemeTokens.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _PermissionStatusPill extends StatelessWidget {
  const _PermissionStatusPill({required this.status});

  final AmanahPermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final AmanahTone tone = _toneFor(status);
    final Color background = dark
        ? tone.dark.withValues(alpha: 0.30)
        : tone.surface;
    final Color foreground = dark ? tone.light : tone.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AmanahRadius.pill),
        border: Border.all(
          color: dark ? tone.primary.withValues(alpha: 0.32) : tone.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: tone.primary,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 7, height: 7),
            ),
            const SizedBox(width: AmanahSpacing.xs),
            Text(
              status.label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AmanahTone _toneFor(AmanahPermissionStatus status) {
    switch (status) {
      case AmanahPermissionStatus.menunggu:
        return AmanahThemeTokens.status(AmanahStatusTone.warning);
      case AmanahPermissionStatus.disetujui:
        return AmanahThemeTokens.status(AmanahStatusTone.success);
      case AmanahPermissionStatus.ditolak:
        return AmanahThemeTokens.status(AmanahStatusTone.danger);
      case AmanahPermissionStatus.dibatalkan:
        return AmanahThemeTokens.status(AmanahStatusTone.neutral);
    }
  }
}

class _PermissionInfoRow extends StatelessWidget {
  const _PermissionInfoRow({
    required this.label,
    required this.value,
    this.semanticValue,
  });

  final String label;
  final String value;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticValue,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AmanahThemeTokens.textSecondary(context),
                ),
              ),
            ),
            const SizedBox(width: AmanahSpacing.lg),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AmanahThemeTokens.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTextSection extends StatelessWidget {
  const _PermissionTextSection({
    required this.title,
    required this.body,
    this.footer,
  });

  final String title;
  final String body;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AmanahThemeTokens.textPrimary(context),
            ),
          ),
          const SizedBox(height: AmanahSpacing.sm),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AmanahThemeTokens.textSecondary(context),
              height: 1.5,
            ),
          ),
          if (footer != null) ...<Widget>[
            const SizedBox(height: AmanahSpacing.xs),
            Text(
              footer!,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AmanahThemeTokens.textTertiary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubstituteDoctorSection extends StatelessWidget {
  const _SubstituteDoctorSection({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.lg),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundColor: AmanahThemeTokens.status(
              AmanahStatusTone.brand,
            ).primary.withValues(alpha: 0.14),
            child: const Icon(
              Icons.person,
              size: 20,
              color: AmanahColorTokens.brand,
            ),
          ),
          const SizedBox(width: AmanahSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Dokter Pengganti',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AmanahSpacing.xs),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
                Text(
                  'Dokter Spesialis Anak / Dokter Pengganti',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AmanahThemeTokens.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedNotice extends StatelessWidget {
  const _ApprovedNotice();

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final AmanahTone tone = AmanahThemeTokens.status(AmanahStatusTone.success);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? tone.dark.withValues(alpha: 0.28) : tone.surface,
        borderRadius: BorderRadius.circular(AmanahRadius.lg),
        border: Border.all(
          color: dark ? tone.primary.withValues(alpha: 0.30) : tone.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: dark ? tone.light : tone.onSurface,
            ),
            const SizedBox(width: AmanahSpacing.sm),
            Expanded(
              child: Text(
                'Izin telah disetujui (Terkonfirmasi di SIMRS)',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: dark ? tone.light : tone.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDivider extends StatelessWidget {
  const _PermissionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AmanahThemeTokens.outline(context),
    );
  }
}
