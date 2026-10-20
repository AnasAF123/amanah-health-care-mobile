import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/features/authentication/data/staff_credential_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

enum ProfileStatus { initial, loading, success, failure, saving }

class StaffProfileStore extends ChangeNotifier {
  StaffProfileStore._({StaffCredentialRepository? repository})
      : _repository = repository ?? const StaffCredentialRepository();

  static final StaffProfileStore instance = StaffProfileStore._();

  final StaffCredentialRepository _repository;
  AmanahStaffProfile? _profile;
  ProfileStatus _status = ProfileStatus.initial;
  String? _errorMessage;

  AmanahStaffProfile? get profile => _profile;
  ProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ProfileStatus.loading;
  bool get isSaving => _status == ProfileStatus.saving;
  bool get hasError => _status == ProfileStatus.failure;

  @visibleForTesting
  StaffProfileStore.forTesting({StaffCredentialRepository? repository})
      : _repository = repository ?? const StaffCredentialRepository();

  void seed(AmanahStaffProfile profile) {
    _profile = profile;
    _status = ProfileStatus.success;
    notifyListeners();
  }

  void seedFromUser(AmanahAuthUser user) {
    if (_profile == null && user.staff != null) {
      _profile = user.staff;
      _status = ProfileStatus.success;
      notifyListeners();
    }
  }

  Future<void> fetchProfile({bool force = false, StaffCredentialRepository? repository}) async {
    if (_status == ProfileStatus.loading) return;
    if (_profile != null && !force && repository == null) return;

    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final StaffCredentialRepository repo = repository ?? _repository;
      _profile = await repo.getMyProfile();
      _status = ProfileStatus.success;
    } catch (e) {
      _status = ProfileStatus.failure;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? birthPlace,
    String? birthDate,
    String? gender,
    String? nationalId,
    String? licenseNumber,
    Map<String, dynamic>? address,
  }) async {
    _status = ProfileStatus.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.updateMyProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        birthPlace: birthPlace,
        birthDate: birthDate,
        gender: gender,
        nationalId: nationalId,
        licenseNumber: licenseNumber,
        address: address,
      );
      _status = ProfileStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = ProfileStatus.failure;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
