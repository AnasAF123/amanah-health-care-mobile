import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/authentication/data/region_api_service.dart';
import 'package:amanah_healthcare/features/authentication/data/staff_profile_store.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';

class AccountIdentityController extends ChangeNotifier {
  AccountIdentityController({
    required this.user,
    StaffProfileStore? store,
    RegionApiService? regionApi,
    TimeService? timeService,
  }) : _store = store ?? StaffProfileStore.instance,
       _regionApi = regionApi ?? RegionApiService(),
       _timeService = timeService ?? DefaultTimeService() {
    _initFromUser();
    _store.addListener(_onStoreUpdated);
  }

  final AmanahAuthUser user;
  final StaffProfileStore _store;
  final RegionApiService _regionApi;
  final TimeService _timeService;

  late String _name;
  late String _phone;
  late String _email;
  String? _profession;
  String? _staffCode;
  String? _nik;
  String? _birthPlace;
  String? _birthDate;
  String? _gender;
  String? _poliklinikName;

  RegionItem? _province;
  RegionItem? _regency;
  RegionItem? _district;
  RegionItem? _village;
  String? _line1;

  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String get profession => _profession ?? user.roleName;
  String? get staffCode => _staffCode;
  String? get nik => _nik;
  String? get birthPlace => _birthPlace;
  String? get birthDate => _birthDate;
  DateTime? get birthDateParsed {
    if (_birthDate == null || _birthDate!.isEmpty) return null;
    return DateTime.tryParse(_birthDate!);
  }

  String? get gender => _gender;
  String? get poliklinikName => _poliklinikName;
  String get poliklinikDisplay {
    if (_poliklinikName != null && _poliklinikName!.isNotEmpty) {
      return _poliklinikName!;
    }
    return user.isClinical ? 'Belum ditentukan' : 'Tidak ada penugasan';
  }

  RegionItem? get province => _province;
  RegionItem? get regency => _regency;
  RegionItem? get district => _district;
  RegionItem? get village => _village;
  String? get line1 => _line1;

  bool get hasProvince => _province != null && _province!.id.isNotEmpty;
  bool get hasRegency => _regency != null && _regency!.id.isNotEmpty;
  bool get hasDistrict => _district != null && _district!.id.isNotEmpty;

  bool get isLoading => _store.isLoading;
  bool get isSaving => _store.isSaving;
  String? get errorMessage => _store.errorMessage;

  @visibleForTesting
  RegionApiService get regionApi => _regionApi;
  StaffProfileStore get store => _store;

  /// Loads list of provinces from region service.
  Future<List<RegionItem>> loadProvinces() => _regionApi.getProvinces();

  /// Loads list of regencies for the currently selected province.
  Future<List<RegionItem>> loadRegencies() {
    if (_province == null || _province!.id.isEmpty) {
      return Future.value(<RegionItem>[]);
    }
    return _regionApi.getRegencies(_province!.id);
  }

  /// Loads list of districts for the currently selected regency.
  Future<List<RegionItem>> loadDistricts() {
    if (_regency == null || _regency!.id.isEmpty) {
      return Future.value(<RegionItem>[]);
    }
    return _regionApi.getDistricts(_regency!.id);
  }

  /// Loads list of villages for the currently selected district.
  Future<List<RegionItem>> loadVillages() {
    if (_district == null || _district!.id.isEmpty) {
      return Future.value(<RegionItem>[]);
    }
    return _regionApi.getVillages(_district!.id);
  }

  /// Formats date to canonical ISO-8601 `yyyy-MM-dd` using TimeService SSOT.
  String formatIsoDate(DateTime date) => _timeService.formatDate(date, style: 'iso');

  void _initFromUser() {
    _name = user.fullName;
    _phone = user.staff?.phoneNumber ?? user.phone;
    _email = user.email;
    _profession = user.staff?.profession ?? user.roleName;
    _staffCode = user.staff?.staffCode;
    _poliklinikName = user.staff?.poliklinikName;

    final AmanahStaffProfile? staff = _store.profile ?? user.staff;
    if (staff != null) {
      _applyStaffProfile(staff);
    }
  }

  void _applyStaffProfile(AmanahStaffProfile staff) {
    if (staff.fullName != null && staff.fullName!.isNotEmpty) {
      _name = staff.fullName!;
    }
    if (staff.phoneNumber != null && staff.phoneNumber!.isNotEmpty) {
      _phone = staff.phoneNumber!;
    }
    if (staff.profession != null && staff.profession!.isNotEmpty) {
      _profession = staff.profession!;
    }
    _staffCode = staff.staffCode;
    _nik = staff.nationalId;
    _poliklinikName = staff.poliklinikName;
    _birthPlace = staff.birthPlace;
    _birthDate = staff.birthDate;
    _gender = staff.gender;

    final AmanahStaffAddress? addr = staff.addressModel;
    if (addr != null) {
      _province = (addr.provinceName != null && addr.provinceName!.isNotEmpty)
          ? RegionItem(id: addr.provinceCode ?? '', name: addr.provinceName!)
          : null;
      _regency = (addr.regencyName != null && addr.regencyName!.isNotEmpty)
          ? RegionItem(id: addr.regencyCode ?? '', name: addr.regencyName!)
          : null;
      _district = (addr.districtName != null && addr.districtName!.isNotEmpty)
          ? RegionItem(id: addr.districtCode ?? '', name: addr.districtName!)
          : null;
      _village = (addr.villageName != null && addr.villageName!.isNotEmpty)
          ? RegionItem(id: addr.villageCode ?? '', name: addr.villageName!)
          : null;
      _line1 = addr.line1;
    } else {
      _province = null;
      _regency = null;
      _district = null;
      _village = null;
      _line1 = null;
    }
  }

  void _onStoreUpdated() {
    if (_store.profile != null) {
      _applyStaffProfile(_store.profile!);
      notifyListeners();
    }
  }

  Future<void> init() async {
    await _store.fetchProfile();
  }

  Future<bool> updateField({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? birthPlace,
    String? birthDate,
    String? gender,
    String? nationalId,
  }) async {
    return _store.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      birthPlace: birthPlace,
      birthDate: birthDate,
      gender: gender,
      nationalId: nationalId,
    );
  }

  Future<bool> updateProvince(RegionItem picked) async {
    if (_province?.id == picked.id) return true;
    _province = picked;
    _regency = null;
    _district = null;
    _village = null;
    notifyListeners();
    return _saveCurrentAddress();
  }

  Future<bool> updateRegency(RegionItem picked) async {
    if (_regency?.id == picked.id) return true;
    _regency = picked;
    _district = null;
    _village = null;
    notifyListeners();
    return _saveCurrentAddress();
  }

  Future<bool> updateDistrict(RegionItem picked) async {
    if (_district?.id == picked.id) return true;
    _district = picked;
    _village = null;
    notifyListeners();
    return _saveCurrentAddress();
  }

  Future<bool> updateVillage(RegionItem picked) async {
    if (_village?.id == picked.id) return true;
    _village = picked;
    notifyListeners();
    return _saveCurrentAddress();
  }

  Future<bool> updateLine1(String newLine1) async {
    final String trimmed = newLine1.trim();
    if (trimmed == (_line1 ?? '')) return true;
    _line1 = trimmed.isNotEmpty ? trimmed : null;
    notifyListeners();
    return _saveCurrentAddress();
  }

  Future<bool> _saveCurrentAddress() async {
    final Map<String, dynamic> payload = <String, dynamic>{
      if (_province != null) ...<String, dynamic>{
        'provinceCode': _province!.id,
        'provinceName': _province!.displayName,
      },
      if (_regency != null) ...<String, dynamic>{
        'regencyCode': _regency!.id,
        'regencyName': _regency!.displayName,
      },
      if (_district != null) ...<String, dynamic>{
        'districtCode': _district!.id,
        'districtName': _district!.displayName,
      },
      if (_village != null) ...<String, dynamic>{
        'villageCode': _village!.id,
        'villageName': _village!.displayName,
      },
      if (_line1 != null && _line1!.isNotEmpty) 'line1': _line1!,
    };
    return _store.updateProfile(address: payload);
  }

  String formatBirthDateDisplay() {
    if (_birthDate == null || _birthDate!.isEmpty) return 'Belum diisi';
    final DateTime? dt = DateTime.tryParse(_birthDate!);
    if (dt == null) return _birthDate!;
    return _timeService.formatDate(dt, style: 'human_full');
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdated);
    super.dispose();
  }
}
