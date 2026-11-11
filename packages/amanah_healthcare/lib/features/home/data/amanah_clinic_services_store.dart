import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/home/data/repositories/clinic_repository_impl.dart';
import 'package:amanah_healthcare/features/home/domain/entities/amanah_clinic_slide.dart';
import 'package:amanah_healthcare/features/home/domain/entities/clinic_service_item.dart';
import 'package:amanah_healthcare/features/home/domain/usecases/get_clinic_services_use_case.dart';

class AmanahClinicServicesStore extends ChangeNotifier {
  AmanahClinicServicesStore._({GetClinicServicesUseCase? getServicesUseCase})
      : _getServicesUseCase = getServicesUseCase ??
            GetClinicServicesUseCase(ClinicRepositoryImpl());

  static final AmanahClinicServicesStore instance =
      AmanahClinicServicesStore._();

  final GetClinicServicesUseCase _getServicesUseCase;

  List<ClinicServiceItem> _services = <ClinicServiceItem>[];
  List<AmanahClinicSlide> _slides = <AmanahClinicSlide>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<AmanahClinicSlide> get slides =>
      List<AmanahClinicSlide>.unmodifiable(_slides);
  List<ClinicServiceItem> get services =>
      List<ClinicServiceItem>.unmodifiable(_services);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchServiceCatalog({bool force = false}) async {
    if (_isLoading) return;
    if (_services.isNotEmpty && !force) return;

    _isLoading = true;
    _errorMessage = null;

    try {
      final List<ClinicServiceItem> fetched =
          await _getServicesUseCase(const NoParams());
      _services = fetched;
      _slides = fetched.map((ClinicServiceItem s) {
        final String eyebrow = (s.poliklinikName != null && s.poliklinikName!.trim().isNotEmpty)
            ? s.poliklinikName!.trim()
            : s.categoryName.trim();
        return AmanahClinicSlide(
          id: s.id,
          eyebrow: eyebrow,
          title: s.name,
          description: s.description ?? '',
          imageUrl: s.imageUrl,
        );
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
      // On failure, preserve existing state without creating fake fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
