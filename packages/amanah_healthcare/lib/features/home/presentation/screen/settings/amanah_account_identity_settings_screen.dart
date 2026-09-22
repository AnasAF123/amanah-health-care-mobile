import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahAccountIdentitySettingsScreen extends StatefulWidget {
  const AmanahAccountIdentitySettingsScreen({
    required this.user,
    this.repository = const AmanahAuthRepository(),
    this.onBack,
    super.key,
  });

  final AmanahAuthUser user;
  final AmanahAuthRepository repository;
  final VoidCallback? onBack;

  @override
  State<AmanahAccountIdentitySettingsScreen> createState() =>
      _AmanahAccountIdentitySettingsScreenState();
}

class _AmanahAccountIdentitySettingsScreenState
    extends State<AmanahAccountIdentitySettingsScreen> {
  String _name = '';
  String _phone = '';
  String _email = '';

  List<StaffCredentialModel> _credentials = <StaffCredentialModel>[];
  bool _isLoadingCredentials = true;

  @override
  void initState() {
    super.initState();
    _name = widget.user.staff?.fullName?.trim().isNotEmpty == true
        ? widget.user.staff!.fullName!
        : widget.user.fullName;
    _phone = widget.user.staff?.phoneNumber?.trim().isNotEmpty == true
        ? widget.user.staff!.phoneNumber!
        : widget.user.phone;
    _email = widget.user.email;

    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    try {
      final List<StaffCredentialModel> list =
          await widget.repository.getMyCredentials();
      if (!mounted) return;
      setState(() {
        _credentials = list;
        _isLoadingCredentials = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingCredentials = false;
      });
    }
  }

  Future<void> _editName() async {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah nama lengkap',
      label: 'Nama lengkap beserta gelar dokter',
      initialValue: _name,
      placeholder: 'dr. Nama dokter, Sp.A',
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (trimmed.isNotEmpty) {
          try {
            await widget.repository.updateMyProfile(fullName: trimmed);
            if (!mounted) return;
            setState(() => _name = trimmed);
            _showSuccessSnackBar('Nama profil dokter berhasil diperbarui');
          } catch (e) {
            if (!mounted) return;
            _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
          }
        }
      },
    );
  }

  Future<void> _editPhone() async {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah nomor telepon',
      label: 'Nomor aktif untuk verifikasi dan kontak darurat',
      initialValue: _phone,
      keyboardType: TextInputType.phone,
      placeholder: '+62 812-xxxx-xxxx',
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (trimmed.isNotEmpty) {
          try {
            await widget.repository.updateMyProfile(phoneNumber: trimmed);
            if (!mounted) return;
            setState(() => _phone = trimmed);
            _showSuccessSnackBar('Nomor telepon dokter berhasil diperbarui');
          } catch (e) {
            if (!mounted) return;
            _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
          }
        }
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(
              Icons.check_circle_rounded,
              color: AmanahColorTokens.surfaceLight,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AmanahColorTokens.neutral900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AmanahColorTokens.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openAddCredentialDialog() {
    CredentialType selectedType = CredentialType.sip;
    final TextEditingController numberController = TextEditingController();
    final TextEditingController issuerController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        final ThemeData theme = Theme.of(ctx);
        final bool dark = theme.brightness == Brightness.dark;
        final Color dialogBg = dark
            ? AmanahColorTokens.surfaceElevatedDark
            : AmanahColorTokens.surfaceLight;
        final Color textColor = dark
            ? AmanahColorTokens.pureWhite
            : AmanahColorTokens.neutral900;
        final Color subtextColor = dark
            ? AmanahColorTokens.neutral400
            : AmanahColorTokens.neutral500;
        final Color inputBg = dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
            : AmanahColorTokens.neutral50;
        final Color inputBorder = dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
            : AmanahColorTokens.neutral200;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: dialogBg,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Tambah Kredensial Medis',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daftarkan nomor SIP, STR, atau kredensial legalitas Anda',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Jenis Kredensial
                      Text(
                        'Jenis Kredensial',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<CredentialType>(
                        initialValue: selectedType,
                        dropdownColor: dialogBg,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                        ),
                        items: CredentialType.values.map((CredentialType type) {
                          return DropdownMenuItem<CredentialType>(
                            value: type,
                            child: Text(
                              type.label,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (CredentialType? val) {
                          if (val != null) {
                            setModalState(() => selectedType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Nomor Kredensial
                      Text(
                        'Nomor Kredensial *',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: numberController,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: 503/4421/SIP-D/2026',
                          hintStyle: TextStyle(
                            color: subtextColor.withValues(alpha: 0.60),
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Instansi Penerbit
                      Text(
                        'Instansi Penerbit (Opsional)',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: issuerController,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Dinas Kesehatan DKI Jakarta',
                          hintStyle: TextStyle(
                            color: subtextColor.withValues(alpha: 0.60),
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tanggal Kedaluwarsa
                      Text(
                        'Tanggal Kedaluwarsa (YYYY-MM-DD)',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: expiryController,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '2029-01-01',
                          hintStyle: TextStyle(
                            color: subtextColor.withValues(alpha: 0.60),
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          AmanahButton.text(
                            text: 'Batal',
                            size: AmanahButtonSize.small,
                            customForegroundColor: subtextColor,
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          const SizedBox(width: 8),
                          AmanahButton.primary(
                            text: 'Simpan Kredensial',
                            size: AmanahButtonSize.small,
                            onPressed: () async {
                              final String num = numberController.text.trim();
                              if (num.isEmpty) return;

                              Navigator.of(ctx).pop();
                              try {
                                final StaffCredentialModel created =
                                    await widget.repository.addCredential(
                                  type: selectedType,
                                  number: num,
                                  issuer: issuerController.text.trim().isNotEmpty
                                      ? issuerController.text.trim()
                                      : null,
                                  expiresAt: expiryController.text.trim().isNotEmpty
                                      ? expiryController.text.trim()
                                      : null,
                                );
                                if (!mounted) return;
                                setState(() {
                                  _credentials = <StaffCredentialModel>[
                                    ..._credentials,
                                    created,
                                  ];
                                });
                                _showSuccessSnackBar(
                                  'Kredensial ${selectedType.shortLabel} berhasil ditambahkan',
                                );
                              } catch (e) {
                                if (!mounted) return;
                                _showErrorSnackBar(
                                  e.toString().replaceFirst('Exception: ', ''),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEditCredentialDialog(StaffCredentialModel cred) {
    final TextEditingController numberController =
        TextEditingController(text: cred.credentialNumber);
    final TextEditingController issuerController =
        TextEditingController(text: cred.issuer ?? '');
    final TextEditingController expiryController =
        TextEditingController(text: cred.expiresAt ?? '');
    String status = cred.status;

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        final ThemeData theme = Theme.of(ctx);
        final bool dark = theme.brightness == Brightness.dark;
        final Color dialogBg = dark
            ? AmanahColorTokens.surfaceElevatedDark
            : AmanahColorTokens.surfaceLight;
        final Color textColor = dark
            ? AmanahColorTokens.pureWhite
            : AmanahColorTokens.neutral900;
        final Color subtextColor = dark
            ? AmanahColorTokens.neutral400
            : AmanahColorTokens.neutral500;
        final Color inputBg = dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
            : AmanahColorTokens.neutral50;
        final Color inputBorder = dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
            : AmanahColorTokens.neutral200;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: dialogBg,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Edit Kredensial ${cred.credentialType.shortLabel}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Perbarui nomor, penerbit, atau masa berlaku legalitas',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nomor Kredensial
                      Text(
                        'Nomor Kredensial',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: numberController,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Instansi Penerbit
                      Text(
                        'Instansi Penerbit',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: issuerController,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tanggal Kedaluwarsa
                      Text(
                        'Tanggal Kedaluwarsa (YYYY-MM-DD)',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: expiryController,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: inputBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          AmanahButton.text(
                            text: 'Batal',
                            size: AmanahButtonSize.small,
                            customForegroundColor: subtextColor,
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          const SizedBox(width: 8),
                          AmanahButton.primary(
                            text: 'Simpan Perubahan',
                            size: AmanahButtonSize.small,
                            onPressed: () async {
                              final String num = numberController.text.trim();
                              Navigator.of(ctx).pop();
                              try {
                                final StaffCredentialModel updated =
                                    await widget.repository.updateCredential(
                                  credentialId: cred.id,
                                  number: num.isNotEmpty ? num : null,
                                  issuer: issuerController.text.trim().isNotEmpty
                                      ? issuerController.text.trim()
                                      : null,
                                  expiresAt: expiryController.text.trim().isNotEmpty
                                      ? expiryController.text.trim()
                                      : null,
                                  status: status,
                                );
                                if (!mounted) return;
                                setState(() {
                                  _credentials = _credentials.map((
                                    StaffCredentialModel c,
                                  ) {
                                    return c.id == cred.id ? updated : c;
                                  }).toList();
                                });
                                _showSuccessSnackBar(
                                  'Kredensial ${cred.credentialType.shortLabel} berhasil diperbarui',
                                );
                              } catch (e) {
                                if (!mounted) return;
                                _showErrorSnackBar(
                                  e.toString().replaceFirst('Exception: ', ''),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCredential(StaffCredentialModel cred) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Hapus ${cred.credentialType.label}?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kredensial ${cred.credentialNumber} dari profil Anda?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AmanahColorTokens.danger,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await widget.repository.deleteCredential(cred.id);
                  if (!mounted) return;
                  setState(() {
                    _credentials = _credentials
                        .where((StaffCredentialModel c) => c.id != cred.id)
                        .toList();
                  });
                  _showSuccessSnackBar(
                    'Kredensial ${cred.credentialType.shortLabel} berhasil dihapus',
                  );
                } catch (e) {
                  if (!mounted) return;
                  _showErrorSnackBar(
                    e.toString().replaceFirst('Exception: ', ''),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AmanahThemeTokens.canvas(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Akun & identitas dokter',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  130 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Informasi pribadi dan kontak
                    AmanahSettingSection(
                      title: 'Informasi pribadi dan kontak',
                      children: <Widget>[
                        AmanahSettingEditableRow(
                          label: 'Nama lengkap',
                          value: _name,
                          onEdit: _editName,
                        ),
                        AmanahSettingInfoRow(
                          label: 'Spesialisasi medis',
                          value: widget.user.staff?.profession?.trim().isNotEmpty == true
                              ? widget.user.staff!.profession!
                              : widget.user.displayRole,
                        ),
                        AmanahSettingEditableRow(
                          label: 'Nomor telepon / WhatsApp',
                          value: _phone,
                          onEdit: _editPhone,
                        ),
                        // Immutable Email Row with legal compliance caption
                        AmanahSettingInfoRow(
                          label: 'Email resmi',
                          value: _email,
                          helperText:
                              'Email terdaftar secara permanen untuk keperluan legalitas klinis.',
                          trailing: Icon(
                            Icons.lock_outline_rounded,
                            size: 16,
                            color: AmanahThemeTokens.textTertiary(context).withValues(alpha: 0.60),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Kredensial medis dan legalitas (SIP, STR, KKI, NPWP, NIB)
                    AmanahSettingSection(
                      title: 'Kredensial medis dan legalitas',
                      children: <Widget>[
                        // Loaded API Credentials
                        for (final StaffCredentialModel cred in _credentials)
                          _buildCredentialTile(context, cred, dark),

                        if (_isLoadingCredentials) ...<Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    value: 0.7,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Memuat kredensial medis...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AmanahThemeTokens.textTertiary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (_credentials.isEmpty) ...<Widget>[
                          // Fallback display if no credentials registered yet
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AmanahThemeTokens.textTertiary(context),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Belum ada kredensial SIP/STR terdaftar.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AmanahThemeTokens.textTertiary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                          // Static NPWP / NIB fallback info
                          if (!_credentials.any((StaffCredentialModel c) => c.credentialType == CredentialType.npwp))
                            AmanahSettingInfoRow(
                              label: 'NPWP',
                              value: widget.user.staff?.practitionerId?.trim().isNotEmpty == true
                                  ? widget.user.staff!.practitionerId!
                                  : (widget.user.staff?.idCardNumber?.trim().isNotEmpty == true
                                      ? widget.user.staff!.idCardNumber!
                                      : '-'),
                            ),

                          if (!_credentials.any((StaffCredentialModel c) => c.credentialType == CredentialType.nib))
                            AmanahSettingInfoRow(
                              label: 'Nomor NIB',
                              value: widget.user.staff?.idCardNumber?.trim().isNotEmpty == true
                                  ? widget.user.staff!.idCardNumber!
                                  : '-',
                            ),

                        // Add Credential Action Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openAddCredentialDialog,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 16,
                                    color: AmanahColorTokens.brandPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '+ Tambah Kredensial Medis (SIP / STR)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AmanahColorTokens.brandPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialTile(
    BuildContext context,
    StaffCredentialModel cred,
    bool dark,
  ) {
    final String label = cred.credentialType.label;
    final List<String> details = <String>[
      if (cred.issuer != null && cred.issuer!.trim().isNotEmpty)
        'Penerbit: ${cred.issuer!.trim()}',
      if (cred.expiresAt != null && cred.expiresAt!.trim().isNotEmpty)
        'Berlaku hingga: ${cred.expiresAt!.trim()}',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        color: AmanahThemeTokens.textTertiary(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: cred.isVerified
                            ? AmanahColorTokens.success.withValues(alpha: 0.15)
                            : AmanahColorTokens.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        cred.statusDisplayLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: cred.isVerified
                              ? AmanahColorTokens.success
                              : AmanahColorTokens.warningDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  cred.credentialNumber,
                  style: TextStyle(
                    color: AmanahThemeTokens.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                if (details.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    details.join(' • '),
                    style: TextStyle(
                      color: AmanahThemeTokens.textTertiary(context),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                iconSize: 18,
                tooltip: 'Edit Kredensial',
                color: AmanahThemeTokens.textTertiary(context),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _openEditCredentialDialog(cred),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                iconSize: 18,
                tooltip: 'Hapus Kredensial',
                color: AmanahColorTokens.danger,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _confirmDeleteCredential(cred),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
