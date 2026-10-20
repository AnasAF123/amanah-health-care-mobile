import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/gender_constants.dart';
import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/dto/staff_onboarding_dto.dart';
import 'package:amanah_healthcare/features/authentication/data/region_api_service.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/delete_avatar.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/fetch_staff_onboarding_polikliniks.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/submit_staff_onboarding.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/upload_avatar.dart';

class StaffOnboardingController extends ChangeNotifier {
  StaffOnboardingController({
    required this.user,
    AuthRepository? repository,
    FetchStaffOnboardingPolikliniksUseCase? fetchPolikliniksUseCase,
    SubmitStaffOnboardingUseCase? submitUseCase,
    UploadAvatarUseCase? uploadAvatarUseCase,
    DeleteAvatarUseCase? deleteAvatarUseCase,
    RegionApiService? regionService,
  })  : _fetchPolikliniksUseCase = fetchPolikliniksUseCase ??
            FetchStaffOnboardingPolikliniksUseCase(
              repository ?? const AmanahAuthRepository(),
            ),
        _submitUseCase = submitUseCase ??
            SubmitStaffOnboardingUseCase(
              repository ?? const AmanahAuthRepository(),
            ),
        _uploadAvatarUseCase = uploadAvatarUseCase ??
            UploadAvatarUseCase(
              repository ?? const AmanahAuthRepository(),
            ),
        _deleteAvatarUseCase = deleteAvatarUseCase ??
            DeleteAvatarUseCase(
              repository ?? const AmanahAuthRepository(),
            ),
        _regionService = regionService ?? RegionApiService() {
    _initFields();
  }

  final AmanahAuthUser user;
  final FetchStaffOnboardingPolikliniksUseCase _fetchPolikliniksUseCase;
  final SubmitStaffOnboardingUseCase _submitUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final DeleteAvatarUseCase _deleteAvatarUseCase;
  final RegionApiService _regionService;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController fullNameController;
  late final TextEditingController nikController;
  late final TextEditingController birthPlaceController;
  late final TextEditingController phoneController;
  late final TextEditingController professionController;
  late final TextEditingController addressController;
  late final TextEditingController licenseController;

  DateTime? birthDate;
  String gender = GenderConstants.male;

  // Region State (Kemendagri)
  List<RegionItem> provinces = const <RegionItem>[];
  List<RegionItem> regencies = const <RegionItem>[];
  List<RegionItem> districts = const <RegionItem>[];
  List<RegionItem> villages = const <RegionItem>[];

  RegionItem? selectedProvince;
  RegionItem? selectedRegency;
  RegionItem? selectedDistrict;
  RegionItem? selectedVillage;

  bool isLoadingProvinces = false;
  bool isLoadingRegencies = false;
  bool isLoadingDistricts = false;
  bool isLoadingVillages = false;
  String? regionErrorMessage;

  // Clinical Poliklinik State
  List<StaffOnboardingPoliOption> poliklinikOptions =
      const <StaffOnboardingPoliOption>[];
  StaffOnboardingPoliOption? selectedPoliklinik;
  bool isLoadingPolikliniks = false;
  String? poliklinikErrorMessage;

  // Avatar & Submission State
  late UserAvatar avatar;
  bool isAvatarUploading = false;
  bool isSubmitting = false;
  String? submitErrorMessage;

  bool get isClinical => user.isDoctor || user.isMidwife;

  void _initFields() {
    fullNameController = TextEditingController(text: user.fullName);
    nikController =
        TextEditingController(text: user.staff?.nationalId ?? '');
    birthPlaceController = TextEditingController();
    phoneController = TextEditingController(text: user.phone);

    // Fixed profession based on admin invitation role
    final String assignedProfession =
        user.staff?.profession?.trim().isNotEmpty == true
            ? user.staff!.profession!.trim()
            : (user.isDoctor
                ? 'Dokter'
                : (user.isMidwife ? 'Bidan' : 'Staf Operasional'));
    professionController = TextEditingController(text: assignedProfession);

    addressController = TextEditingController();
    licenseController = TextEditingController();
    avatar = user.avatar;
  }

  Future<void> init() async {
    await loadProvinces();
    if (isClinical) {
      await loadPolikliniks();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nikController.dispose();
    birthPlaceController.dispose();
    phoneController.dispose();
    professionController.dispose();
    addressController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  void setGender(String value) {
    if (gender == value) return;
    gender = value;
    notifyListeners();
  }

  void setBirthDate(DateTime date) {
    birthDate = date;
    notifyListeners();
  }

  void setAvatar(UserAvatar newAvatar) {
    avatar = newAvatar;
    notifyListeners();
  }

  void setAvatarUploading(bool uploading) {
    isAvatarUploading = uploading;
    notifyListeners();
  }

  Future<void> deleteAvatarPhoto() async {
    isAvatarUploading = true;
    notifyListeners();
    try {
      await _deleteAvatarUseCase(const NoParams());
      avatar = UserAvatar.fromFallback(
        userId: user.id,
        name: user.fullName,
      );
    } finally {
      isAvatarUploading = false;
      notifyListeners();
    }
  }

  Future<UserAvatar> uploadAvatarPhoto({
    List<int>? fileBytes,
    String? filePath,
    String fileName = 'avatar.jpg',
    bool useAuthAlias = true,
  }) async {
    isAvatarUploading = true;
    notifyListeners();
    try {
      final UserAvatar updated = await _uploadAvatarUseCase(
        UploadAvatarParams(
          fileBytes: fileBytes,
          filePath: filePath,
          fileName: fileName,
          useAuthAlias: useAuthAlias,
        ),
      );
      avatar = updated;
      return updated;
    } finally {
      isAvatarUploading = false;
      notifyListeners();
    }
  }

  Future<void> loadProvinces() async {
    isLoadingProvinces = true;
    regionErrorMessage = null;
    notifyListeners();

    try {
      final List<RegionItem> result = await _regionService.getProvinces();
      provinces = result;
      isLoadingProvinces = false;
      notifyListeners();
    } catch (e) {
      isLoadingProvinces = false;
      regionErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> onProvinceChanged(RegionItem? province) async {
    selectedProvince = province;
    selectedRegency = null;
    selectedDistrict = null;
    selectedVillage = null;
    regencies = const <RegionItem>[];
    districts = const <RegionItem>[];
    villages = const <RegionItem>[];
    notifyListeners();

    if (province == null) return;

    isLoadingRegencies = true;
    regionErrorMessage = null;
    notifyListeners();

    try {
      regencies = await _regionService.getRegencies(province.id);
      isLoadingRegencies = false;
      notifyListeners();
    } catch (e) {
      isLoadingRegencies = false;
      regionErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> onRegencyChanged(RegionItem? regency) async {
    selectedRegency = regency;
    selectedDistrict = null;
    selectedVillage = null;
    districts = const <RegionItem>[];
    villages = const <RegionItem>[];
    notifyListeners();

    if (regency == null) return;

    isLoadingDistricts = true;
    regionErrorMessage = null;
    notifyListeners();

    try {
      districts = await _regionService.getDistricts(regency.id);
      isLoadingDistricts = false;
      notifyListeners();
    } catch (e) {
      isLoadingDistricts = false;
      regionErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> onDistrictChanged(RegionItem? district) async {
    selectedDistrict = district;
    selectedVillage = null;
    villages = const <RegionItem>[];
    notifyListeners();

    if (district == null) return;

    isLoadingVillages = true;
    regionErrorMessage = null;
    notifyListeners();

    try {
      villages = await _regionService.getVillages(district.id);
      isLoadingVillages = false;
      notifyListeners();
    } catch (e) {
      isLoadingVillages = false;
      regionErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void onVillageChanged(RegionItem? village) {
    selectedVillage = village;
    notifyListeners();
  }

  Future<void> loadPolikliniks() async {
    isLoadingPolikliniks = true;
    poliklinikErrorMessage = null;
    notifyListeners();

    try {
      final List<StaffOnboardingPoliOption> options =
          await _fetchPolikliniksUseCase(const NoParams());
      poliklinikOptions = options;
      if (options.isNotEmpty) {
        final String? assignedPoliId = user.staff?.poliklinikId;
        if (assignedPoliId != null && assignedPoliId.isNotEmpty) {
          selectedPoliklinik = options.firstWhere(
            (StaffOnboardingPoliOption p) => p.id == assignedPoliId,
            orElse: () => options.first,
          );
        } else if (selectedPoliklinik == null) {
          selectedPoliklinik = options.first;
        }
      }
      isLoadingPolikliniks = false;
      notifyListeners();
    } catch (e) {
      isLoadingPolikliniks = false;
      poliklinikErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void onPoliklinikChanged(StaffOnboardingPoliOption? poli) {
    selectedPoliklinik = poli;
    notifyListeners();
  }

  Future<AmanahAuthUser?> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return null;
    }

    if (birthDate == null) {
      submitErrorMessage = 'Pilih tanggal lahir terlebih dahulu.';
      notifyListeners();
      return null;
    }

    if (isClinical && (selectedPoliklinik == null || selectedPoliklinik!.id.isEmpty)) {
      submitErrorMessage = 'Pilih unit poliklinik penugasan.';
      notifyListeners();
      return null;
    }

    isSubmitting = true;
    submitErrorMessage = null;
    notifyListeners();

    final String birthDateFormatted =
        '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}';

    final StaffOnboardingDto dto = StaffOnboardingDto(
      fullName: fullNameController.text.trim(),
      nationalId: nikController.text.trim(),
      birthPlace: birthPlaceController.text.trim(),
      birthDate: birthDateFormatted,
      gender: gender,
      phoneNumber: phoneController.text.trim(),
      profession: professionController.text.trim(),
      provinsi: selectedProvince?.name,
      provinsiId: selectedProvince?.id,
      kabupaten: selectedRegency?.name,
      kabupatenId: selectedRegency?.id,
      kecamatan: selectedDistrict?.name,
      kecamatanId: selectedDistrict?.id,
      kelurahan: selectedVillage?.name,
      kelurahanId: selectedVillage?.id,
      alamatDetail: addressController.text.trim(),
      poliklinikId: isClinical ? selectedPoliklinik?.id : null,
      licenseNumber: isClinical && licenseController.text.trim().isNotEmpty
          ? licenseController.text.trim()
          : null,
    );

    AmanahAuthLogger.logLifecycle(
      'Submitting staff onboarding DTO',
      details: <String, dynamic>{
        'fullName': dto.fullName,
        'nationalId': dto.nationalId,
        'profession': dto.profession,
        'poliklinikId': dto.poliklinikId,
        'licenseNumber': dto.licenseNumber,
      },
    );

    try {
      final AmanahAuthUser? updatedUser =
          await _submitUseCase(dto);

      isSubmitting = false;
      notifyListeners();

      if (updatedUser != null) {
        return updatedUser.copyWith(
          avatar: avatar.hasCustomAvatar ? avatar : updatedUser.avatar,
          needsOnboarding: false,
        );
      } else {
        submitErrorMessage = 'Gagal menyimpan profil staf. Silakan periksa data.';
        notifyListeners();
        return null;
      }
    } catch (e) {
      isSubmitting = false;
      submitErrorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}
