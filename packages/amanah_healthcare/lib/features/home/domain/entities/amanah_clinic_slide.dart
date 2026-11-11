/// Presentation-ready slide model for the Master 3D Carousel Section
class AmanahClinicSlide {
  const AmanahClinicSlide({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  final String id;
  final String eyebrow;
  final String title;
  final String description;
  final String? imageUrl;
}
