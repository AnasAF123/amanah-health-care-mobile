class ReplacementStaffFacet {
  const ReplacementStaffFacet({
    required this.staffProfileId,
    required this.fullName,
    this.roleCode,
    this.roleName,
    this.avatarUrl,
    required this.opportunityCount,
    required this.earliestDate,
    required this.availableDates,
  });

  final String staffProfileId;
  final String fullName;
  final String? roleCode;
  final String? roleName;
  final String? avatarUrl;
  final int opportunityCount;
  final String earliestDate;
  final List<String> availableDates;
}

class ReplacementDateFacet {
  const ReplacementDateFacet({required this.workDate, required this.count});

  final String workDate;
  final int count;
}

class ReplacementFacets {
  const ReplacementFacets({
    required this.distinctStaff,
    required this.availableDates,
    required this.totalOpenOpportunities,
  });

  final List<ReplacementStaffFacet> distinctStaff;
  final List<ReplacementDateFacet> availableDates;
  final int totalOpenOpportunities;

  static const ReplacementFacets empty = ReplacementFacets(
    distinctStaff: <ReplacementStaffFacet>[],
    availableDates: <ReplacementDateFacet>[],
    totalOpenOpportunities: 0,
  );
}
