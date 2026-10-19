import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/amanah_permission_form_data.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/amanah_permission_stepper_modal.dart';

export 'package:amanah_healthcare/features/permission/domain/entities/amanah_permission_form_data.dart';

/// Backwards-compatible facade for staff leave permission form.
///
/// Delegates presentation to [AmanahPermissionStepperModal] for the sequential
/// content-replacement flow (stepper without header).
class AmanahPermissionFormDrawer extends StatelessWidget {
  final String doctorName;
  final String doctorRole;
  final String? doctorAvatarUrl;
  final AmanahPermissionRecord? editingRecord;
  final PermissionRepository? repository;

  const AmanahPermissionFormDrawer({
    super.key,
    required this.doctorName,
    required this.doctorRole,
    this.doctorAvatarUrl,
    this.editingRecord,
    this.repository,
  });

  /// Displays the modal using [AmanahPermissionStepperModal].
  static Future<AmanahPermissionFormData?> show({
    required BuildContext context,
    required String doctorName,
    required String doctorRole,
    String? doctorAvatarUrl,
    AmanahPermissionRecord? editingRecord,
    PermissionRepository? repository,
  }) {
    return AmanahPermissionStepperModal.show(
      context: context,
      doctorName: doctorName,
      doctorRole: doctorRole,
      doctorAvatarUrl: doctorAvatarUrl,
      repository: repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AmanahPermissionStepperModal(
      doctorName: doctorName,
      doctorRole: doctorRole,
      doctorAvatarUrl: doctorAvatarUrl,
      repository: repository,
    );
  }
}
