import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/gender_constants.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_gender_picker_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_region_picker_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/state/account_identity_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahAccountIdentitySettingsScreen extends StatefulWidget {
  const AmanahAccountIdentitySettingsScreen({
    required this.user,
    this.onBack,
    super.key,
  });

  final AmanahAuthUser user;
  final VoidCallback? onBack;

  @override
  State<AmanahAccountIdentitySettingsScreen> createState() =>
      _AmanahAccountIdentitySettingsScreenState();
}

class _AmanahAccountIdentitySettingsScreenState
    extends State<AmanahAccountIdentitySettingsScreen> {
  late final AccountIdentityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AccountIdentityController(user: widget.user);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan data berhasil disimpan.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorFeedback(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AmanahColorTokens.danger,
      ),
    );
  }

  Future<void> _handleUpdate(Future<bool> Function() action) async {
    final bool ok = await action();
    if (ok && mounted) {
      _showSuccessFeedback();
    } else if (!ok && mounted && _controller.errorMessage != null) {
      _showErrorFeedback(_controller.errorMessage!);
    }
  }

  // --- Edit Dialogs ---

  void _editName() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah Nama Lengkap',
      label: 'Nama lengkap resmi beserta gelar profesional',
      initialValue: _controller.name,
      placeholder: widget.user.isDoctor
          ? 'dr. Nama Dokter, Sp.A'
          : 'Nama Lengkap',
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (trimmed.isNotEmpty && trimmed != _controller.name) {
          await _handleUpdate(() => _controller.updateField(fullName: trimmed));
        }
      },
    );
  }

  void _editNik() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah NIK',
      label: '16 digit angka Nomor Induk Kependudukan (KTP)',
      initialValue: _controller.nik ?? '',
      keyboardType: TextInputType.number,
      placeholder: '3201xxxxxxxxxxxx',
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (trimmed.length != 16 || !RegExp(r'^\d{16}$').hasMatch(trimmed)) {
          _showErrorFeedback('NIK harus terdiri dari 16 digit angka.');
          return;
        }
        await _handleUpdate(() => _controller.updateField(nationalId: trimmed));
      },
    );
  }

  void _editBirthPlace() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah Tempat Lahir',
      label: 'Kota atau kabupaten tempat lahir sesuai KTP',
      initialValue: _controller.birthPlace ?? '',
      placeholder: 'Contoh: Bandung',
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (trimmed.isNotEmpty && trimmed != (_controller.birthPlace ?? '')) {
          await _handleUpdate(() => _controller.updateField(birthPlace: trimmed));
        }
      },
    );
  }

  Future<void> _editBirthDate() async {
    final DateTime now = DateTime.now();
    DateTime initial = DateTime(1995, 1, 1);
    if (_controller.birthDate != null && _controller.birthDate!.isNotEmpty) {
      final DateTime? parsed = DateTime.tryParse(_controller.birthDate!);
      if (parsed != null) initial = parsed;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      final String formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      if (formatted != _controller.birthDate) {
        await _handleUpdate(() => _controller.updateField(birthDate: formatted));
      }
    }
  }

  Future<void> _editGender() async {
    final String? picked = await AmanahGenderPickerSheet.show(
      context: context,
      selectedGender: _controller.gender,
    );
    if (picked != null && picked != _controller.gender) {
      await _handleUpdate(() => _controller.updateField(gender: picked));
    }
  }

  void _editPhone() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah Nomor Telepon',
      label: 'Nomor WhatsApp / telepon aktif operasional',
      initialValue: _controller.phone,
      keyboardType: TextInputType.phone,
      placeholder: '081234567890',
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (trimmed.length < 9) {
          _showErrorFeedback('Nomor telepon minimal 9 digit.');
          return;
        }
        if (trimmed != _controller.phone) {
          await _handleUpdate(() => _controller.updateField(phoneNumber: trimmed));
        }
      },
    );
  }

  void _editEmail() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah Email Akun',
      label: 'Alamat email institusi atau email resmi staf',
      initialValue: _controller.email,
      keyboardType: TextInputType.emailAddress,
      placeholder: 'email@rsamanah.co.id',
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (!trimmed.contains('@') || !trimmed.contains('.')) {
          _showErrorFeedback('Format email tidak valid.');
          return;
        }
        if (trimmed != _controller.email) {
          await _handleUpdate(() => _controller.updateField(email: trimmed));
        }
      },
    );
  }

  Future<void> _editProvince() async {
    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Provinsi',
      selectedId: _controller.province?.id,
      loader: () => _controller.regionApi.getProvinces(),
    );
    if (picked != null) {
      final bool ok = await _controller.updateProvince(picked);
      if (ok && mounted) {
        _showSuccessFeedback();
      } else if (!ok && mounted && _controller.errorMessage != null) {
        _showErrorFeedback(_controller.errorMessage!);
      }
    }
  }

  Future<void> _editRegency() async {
    if (_controller.province == null || _controller.province!.id.isEmpty) {
      _showErrorFeedback('Pilih provinsi terlebih dahulu.');
      return;
    }

    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Kabupaten / Kota',
      selectedId: _controller.regency?.id,
      loader: () => _controller.regionApi.getRegencies(_controller.province!.id),
    );
    if (picked != null) {
      final bool ok = await _controller.updateRegency(picked);
      if (ok && mounted) {
        _showSuccessFeedback();
      } else if (!ok && mounted && _controller.errorMessage != null) {
        _showErrorFeedback(_controller.errorMessage!);
      }
    }
  }

  Future<void> _editDistrict() async {
    if (_controller.regency == null || _controller.regency!.id.isEmpty) {
      _showErrorFeedback('Pilih kabupaten/kota terlebih dahulu.');
      return;
    }

    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Kecamatan',
      selectedId: _controller.district?.id,
      loader: () => _controller.regionApi.getDistricts(_controller.regency!.id),
    );
    if (picked != null) {
      final bool ok = await _controller.updateDistrict(picked);
      if (ok && mounted) {
        _showSuccessFeedback();
      } else if (!ok && mounted && _controller.errorMessage != null) {
        _showErrorFeedback(_controller.errorMessage!);
      }
    }
  }

  Future<void> _editVillage() async {
    if (_controller.district == null || _controller.district!.id.isEmpty) {
      _showErrorFeedback('Pilih kecamatan terlebih dahulu.');
      return;
    }

    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Kelurahan / Desa',
      selectedId: _controller.village?.id,
      loader: () => _controller.regionApi.getVillages(_controller.district!.id),
    );
    if (picked != null) {
      final bool ok = await _controller.updateVillage(picked);
      if (ok && mounted) {
        _showSuccessFeedback();
      } else if (!ok && mounted && _controller.errorMessage != null) {
        _showErrorFeedback(_controller.errorMessage!);
      }
    }
  }

  void _editLine1() {
    AmanahSettingEditDialog.show(
      context: context,
      title: 'Ubah Alamat Lengkap',
      label: 'Nama jalan, nomor rumah, RT / RW',
      initialValue: _controller.line1 ?? '',
      placeholder: 'Contoh: Jl. Merdeka No. 10, RT 01/RW 02',
      onSave: (String val) async {
        final bool ok = await _controller.updateLine1(val);
        if (ok && mounted) {
          _showSuccessFeedback();
        } else if (!ok && mounted && _controller.errorMessage != null) {
          _showErrorFeedback(_controller.errorMessage!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AmanahThemeTokens.canvas(context);
    final Widget lockTrailing = Icon(
      Icons.lock_rounded,
      size: 16,
      color: AmanahThemeTokens.textTertiary(context),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Akun & Identitas ${widget.user.roleLabel}',
              onBack: widget.onBack,
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (BuildContext ctx, Widget? child) {
                if (_controller.isLoading || _controller.isSaving) {
                  return const LinearProgressIndicator(
                    minHeight: 2,
                    color: AmanahColorTokens.brand,
                  );
                }
                return const SizedBox(height: 2);
              },
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext ctx, Widget? child) {
                  return SingleChildScrollView(
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
                        // Section 1: Data Pribadi & Kependudukan
                        AmanahSettingSection(
                          title: 'Data Pribadi & Kependudukan',
                          children: <Widget>[
                            AmanahSettingEditableRow(
                              label: 'Nama Lengkap (sesuai KTP / Gelar)',
                              value: _controller.name.isNotEmpty
                                  ? _controller.name
                                  : 'Belum diisi',
                              onEdit: _editName,
                            ),
                            AmanahSettingEditableRow(
                              label: 'NIK (Nomor Induk Kependudukan)',
                              value: (_controller.nik != null &&
                                      _controller.nik!.isNotEmpty)
                                  ? _controller.nik!
                                  : 'Belum diisi',
                              onEdit: _editNik,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Tempat Lahir',
                              value: (_controller.birthPlace != null &&
                                      _controller.birthPlace!.isNotEmpty)
                                  ? _controller.birthPlace!
                                  : 'Belum diisi',
                              onEdit: _editBirthPlace,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Tanggal Lahir',
                              value: _controller.formatBirthDateDisplay(),
                              onEdit: _editBirthDate,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Jenis Kelamin',
                              value: GenderConstants.toLabel(_controller.gender),
                              onEdit: _editGender,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Kontak & Penugasan Operasional
                        AmanahSettingSection(
                          title: 'Kontak & Penugasan Operasional',
                          children: <Widget>[
                            AmanahSettingEditableRow(
                              label: 'Nomor WhatsApp / Handphone',
                              value: _controller.phone.isNotEmpty
                                  ? _controller.phone
                                  : 'Belum diisi',
                              onEdit: _editPhone,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Email Akun',
                              value: _controller.email.isNotEmpty
                                  ? _controller.email
                                  : 'Belum diisi',
                              onEdit: _editEmail,
                            ),
                            AmanahSettingInfoRow(
                              label: 'Kode Staf / NIP (Ditetapkan Admin)',
                              value: _controller.staffCode ?? '-',
                              trailing: lockTrailing,
                            ),
                            AmanahSettingInfoRow(
                              label: 'Profesi / Jabatan (Ditetapkan Admin)',
                              value: _controller.profession,
                              trailing: lockTrailing,
                            ),
                            AmanahSettingInfoRow(
                              label: 'Poliklinik Penugasan (Ditetapkan Admin)',
                              value: _controller.poliklinikName ??
                                  (widget.user.isDoctor || widget.user.isMidwife
                                      ? 'Poliklinik Penugasan'
                                      : 'Tidak ada penugasan'),
                              trailing: lockTrailing,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Section 3: Alamat Domisili Kependudukan
                        AmanahSettingSection(
                          title: 'Alamat Domisili Kependudukan',
                          children: <Widget>[
                            AmanahSettingEditableRow(
                              label: 'Provinsi',
                              value: _controller.province?.displayName ??
                                  'Pilih Provinsi',
                              onEdit: _editProvince,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Kabupaten / Kota',
                              value: _controller.regency?.displayName ??
                                  (_controller.province != null
                                      ? 'Pilih Kabupaten / Kota'
                                      : 'Pilih provinsi terlebih dahulu'),
                              onEdit: _editRegency,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Kecamatan',
                              value: _controller.district?.displayName ??
                                  (_controller.regency != null
                                      ? 'Pilih Kecamatan'
                                      : 'Pilih kabupaten/kota terlebih dahulu'),
                              onEdit: _editDistrict,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Kelurahan / Desa',
                              value: _controller.village?.displayName ??
                                  (_controller.district != null
                                      ? 'Pilih Kelurahan / Desa'
                                      : 'Pilih kecamatan terlebih dahulu'),
                              onEdit: _editVillage,
                            ),
                            AmanahSettingEditableRow(
                              label: 'Alamat Lengkap (Jalan, RT/RW, No. Rumah)',
                              value: (_controller.line1 != null &&
                                      _controller.line1!.isNotEmpty)
                                  ? _controller.line1!
                                  : 'Belum diisi',
                              onEdit: _editLine1,
                            ),
                          ],
                        ),
                      ],
                    ),
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
