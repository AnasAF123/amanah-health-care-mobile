/// Domain entity representing intake clinical records across maternal, immunization, and regular workflows.
class PatientIntakeRecord {
  const PatientIntakeRecord({
    required this.appointmentId,
    required this.flow,
    required this.type,
    this.maternal,
    this.immunization,
    this.regular,
  });

  final String appointmentId;
  final String flow;
  final String type;
  final MaternalIntakeData? maternal;
  final ImmunizationIntakeData? immunization;
  final RegularIntakeData? regular;

  bool get isMaternal => type == 'maternal' || flow == 'pregnancy';
  bool get isImmunization => type == 'immunization' || flow == 'immunization';
  bool get isRegular => !isMaternal && !isImmunization;
}

/// Clinical intake data for Maternal / Pregnancy (ANC) patients.
class MaternalIntakeData {
  const MaternalIntakeData({
    this.gpa,
    this.hpht,
    this.estimatedDueDate,
    this.gestationalAgeFormatted,
    this.heightCm,
    this.prePregnancyWeightKg,
    this.upperArmCircumferenceCm,
    this.initialBmi,
    this.motherBloodType,
    this.tetanusStatus,
    this.partnerName,
    this.previousPregnancies = const <PreviousPregnancyItem>[],
    this.contraceptiveHistories = const <ContraceptiveHistoryItem>[],
  });

  final String? gpa;
  final String? hpht;
  final String? estimatedDueDate;
  final String? gestationalAgeFormatted;
  final int? heightCm;
  final double? prePregnancyWeightKg;
  final double? upperArmCircumferenceCm;
  final double? initialBmi;
  final String? motherBloodType;
  final String? tetanusStatus;
  final String? partnerName;
  final List<PreviousPregnancyItem> previousPregnancies;
  final List<ContraceptiveHistoryItem> contraceptiveHistories;
}

class PreviousPregnancyItem {
  const PreviousPregnancyItem({
    required this.orderNumber,
    this.birthYear,
    this.childSex,
    this.birthWeightGrams,
    this.deliveryMethod,
    this.birthAttendant,
    this.deliveryPlace,
    this.complications,
  });

  final int orderNumber;
  final String? birthYear;
  final String? childSex;
  final int? birthWeightGrams;
  final String? deliveryMethod;
  final String? birthAttendant;
  final String? deliveryPlace;
  final String? complications;
}

class ContraceptiveHistoryItem {
  const ContraceptiveHistoryItem({
    required this.contraceptiveType,
    this.durationText,
    this.startDate,
  });

  final String contraceptiveType;
  final String? durationText;
  final String? startDate;
}

/// Clinical intake data for Child Immunization and growth monitoring.
class ImmunizationIntakeData {
  const ImmunizationIntakeData({
    required this.childName,
    this.childNik,
    this.childBirthDate,
    this.childAgeFormatted,
    this.childSex,
    this.fatherName,
    this.motherName,
    this.previousVaccineHistory,
    this.childAllergyHistory,
  });

  final String childName;
  final String? childNik;
  final String? childBirthDate;
  final String? childAgeFormatted;
  final String? childSex;
  final String? fatherName;
  final String? motherName;
  final String? previousVaccineHistory;
  final String? childAllergyHistory;
}

/// Clinical intake data for Regular / Generic general poly appointments.
class RegularIntakeData {
  const RegularIntakeData({
    this.fullName,
    this.medicalRecordNumber,
    this.nik,
    this.birthDate,
    this.birthPlace,
    this.gender,
    this.bloodType,
    this.phone,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.complaint,
    this.serviceName,
    this.scheduledDate,
    this.scheduledStartTime,
    this.bookingCode,
  });

  final String? fullName;
  final String? medicalRecordNumber;
  final String? nik;
  final String? birthDate;
  final String? birthPlace;
  final String? gender;
  final String? bloodType;
  final String? phone;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final String? complaint;
  final String? serviceName;
  final String? scheduledDate;
  final String? scheduledStartTime;
  final String? bookingCode;
}
