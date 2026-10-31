import 'package:amanah_healthcare/features/permission/domain/entities/replacement_facets.dart';

class ReplacementFacetsDto {
  const ReplacementFacetsDto({
    required this.distinctStaff,
    required this.availableDates,
    required this.totalOpenOpportunities,
  });

  factory ReplacementFacetsDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawStaff = json['distinctStaff'] as List<dynamic>? ?? <dynamic>[];
    final List<ReplacementStaffFacet> staffList = rawStaff.map((dynamic item) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      final List<dynamic> rawDates = map['availableDates'] as List<dynamic>? ?? <dynamic>[];
      return ReplacementStaffFacet(
        staffProfileId: map['staffProfileId']?.toString() ?? '',
        fullName: map['fullName']?.toString() ?? '',
        roleCode: map['roleCode']?.toString(),
        roleName: map['roleName']?.toString(),
        avatarUrl: map['avatarUrl']?.toString(),
        opportunityCount: (map['opportunityCount'] as num?)?.toInt() ?? 0,
        earliestDate: map['earliestDate']?.toString() ?? '',
        availableDates: rawDates.map((dynamic d) => d.toString()).toList(),
      );
    }).toList();

    final List<dynamic> rawDates = json['availableDates'] as List<dynamic>? ?? <dynamic>[];
    final List<ReplacementDateFacet> dateList = rawDates.map((dynamic item) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      return ReplacementDateFacet(
        workDate: map['workDate']?.toString() ?? '',
        count: (map['count'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return ReplacementFacetsDto(
      distinctStaff: staffList,
      availableDates: dateList,
      totalOpenOpportunities: (json['totalOpenOpportunities'] as num?)?.toInt() ?? 0,
    );
  }

  final List<ReplacementStaffFacet> distinctStaff;
  final List<ReplacementDateFacet> availableDates;
  final int totalOpenOpportunities;

  ReplacementFacets toEntity() {
    return ReplacementFacets(
      distinctStaff: distinctStaff,
      availableDates: availableDates,
      totalOpenOpportunities: totalOpenOpportunities,
    );
  }
}
