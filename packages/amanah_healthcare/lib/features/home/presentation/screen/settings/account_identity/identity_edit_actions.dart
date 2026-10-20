import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_gender_picker_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_region_picker_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_display_extensions.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_validators.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_account_identity_settings_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/state/account_identity_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Mixin encapsulating user editing interactions, validation, and feedback
/// for [AmanahAccountIdentitySettingsScreen].
mixin IdentityEditActions on State<AmanahAccountIdentitySettingsScreen> {
  AccountIdentityController get controller;

  void showSuccessFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perubahan data berhasil disimpan.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showErrorFeedback(String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: AmanahColorTokens.danger));
  }

  /// Unified action executor with mounted check and snackbar notifications.
  Future<void> runAction(Future<bool> Function() action) async {
    final bool ok = await action();
    if (!mounted) return;
    if (ok) {
      showSuccessFeedback();
    } else if (controller.errorMessage != null) {
      showErrorFeedback(controller.errorMessage!);
    }
  }

  /// Single entry point for text-editing dialogs with validation and change-check.
  void editText({
    required String title,
    required String label,
    required String initialValue,
    required Future<bool> Function(String) onSave,
    String? placeholder,
    TextInputType? keyboardType,
    String? Function(String)? validator,
  }) {
    AmanahSettingEditDialog.show(
      context: context,
      title: title,
      label: label,
      initialValue: initialValue,
      placeholder: placeholder,
      keyboardType: keyboardType,
      validator: validator,
      onSave: (String val) async {
        final String trimmed = val.trim();
        if (validator != null) {
          final String? err = validator(trimmed);
          if (err != null) {
            showErrorFeedback(err);
            return;
          }
        }
        if (trimmed != initialValue) {
          await runAction(() => onSave(trimmed));
        }
      },
    );
  }

  /// Single entry point for cascading administrative region pickers.
  Future<void> pickRegion({
    required String title,
    required String? selectedId,
    required Future<List<RegionItem>> Function() loader,
    required Future<bool> Function(RegionItem) onPicked,
    String? blockedReason,
  }) async {
    if (blockedReason != null) {
      showErrorFeedback(blockedReason);
      return;
    }
    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: title,
      selectedId: selectedId,
      loader: loader,
    );
    if (picked != null) {
      await runAction(() => onPicked(picked));
    }
  }

  void editName() {
    editText(
      title: 'Ubah Nama Lengkap',
      label: 'Nama lengkap resmi beserta gelar profesional',
      initialValue: controller.name,
      placeholder: widget.user.isDoctor ? 'dr. Nama Dokter, Sp.A' : 'Nama Lengkap',
      validator: (String v) => v.trim().isEmpty ? 'Nama lengkap tidak boleh kosong.' : null,
      onSave: (String val) => controller.updateField(fullName: val),
    );
  }

  void editNik() {
    editText(
      title: 'Ubah NIK',
      label: '16 digit angka Nomor Induk Kependudukan (KTP)',
      initialValue: controller.nik ?? '',
      keyboardType: TextInputType.number,
      placeholder: '3201xxxxxxxxxxxx',
      validator: IdentityValidators.nik,
      onSave: (String val) => controller.updateField(nationalId: val),
    );
  }

  void editBirthPlace() {
    editText(
      title: 'Ubah Tempat Lahir',
      label: 'Kota atau kabupaten tempat lahir sesuai KTP',
      initialValue: controller.birthPlace ?? '',
      placeholder: 'Contoh: Bandung',
      validator: (String v) => v.trim().isEmpty ? 'Tempat lahir tidak boleh kosong.' : null,
      onSave: (String val) => controller.updateField(birthPlace: val),
    );
  }

  Future<void> editBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial =
        controller.birthDateParsed ?? IdentitySettingsConstants.defaultBirthDate;

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
      final String formatted = controller.formatIsoDate(picked);
      if (formatted != controller.birthDate) {
        await runAction(() => controller.updateField(birthDate: formatted));
      }
    }
  }

  Future<void> editGender() async {
    final String? picked = await AmanahGenderPickerSheet.show(
      context: context,
      selectedGender: controller.gender,
    );
    if (picked != null && picked != controller.gender) {
      await runAction(() => controller.updateField(gender: picked));
    }
  }

  void editPhone() {
    editText(
      title: 'Ubah Nomor Telepon',
      label: 'Nomor WhatsApp / telepon aktif operasional',
      initialValue: controller.phone,
      keyboardType: TextInputType.phone,
      placeholder: '081234567890',
      validator: IdentityValidators.phone,
      onSave: (String val) => controller.updateField(phoneNumber: val),
    );
  }

  void editEmail() {
    editText(
      title: 'Ubah Email Akun',
      label: 'Alamat email institusi atau email resmi staf',
      initialValue: controller.email,
      keyboardType: TextInputType.emailAddress,
      placeholder: 'email@rsamanah.co.id',
      validator: IdentityValidators.email,
      onSave: (String val) => controller.updateField(email: val),
    );
  }

  Future<void> editProvince() => pickRegion(
    title: 'Pilih Provinsi',
    selectedId: controller.province?.id,
    loader: controller.loadProvinces,
    onPicked: controller.updateProvince,
  );

  Future<void> editRegency() => pickRegion(
    title: 'Pilih Kabupaten / Kota',
    selectedId: controller.regency?.id,
    blockedReason: controller.hasProvince ? null : 'Pilih provinsi terlebih dahulu.',
    loader: controller.loadRegencies,
    onPicked: controller.updateRegency,
  );

  Future<void> editDistrict() => pickRegion(
    title: 'Pilih Kecamatan',
    selectedId: controller.district?.id,
    blockedReason: controller.hasRegency ? null : 'Pilih kabupaten/kota terlebih dahulu.',
    loader: controller.loadDistricts,
    onPicked: controller.updateDistrict,
  );

  Future<void> editVillage() => pickRegion(
    title: 'Pilih Kelurahan / Desa',
    selectedId: controller.village?.id,
    blockedReason: controller.hasDistrict ? null : 'Pilih kecamatan terlebih dahulu.',
    loader: controller.loadVillages,
    onPicked: controller.updateVillage,
  );

  void editLine1() {
    editText(
      title: 'Ubah Alamat Lengkap',
      label: 'Nama jalan, nomor rumah, RT / RW',
      initialValue: controller.line1 ?? '',
      placeholder: 'Contoh: Jl. Merdeka No. 10, RT 01/RW 02',
      onSave: (String val) => controller.updateLine1(val),
    );
  }
}
