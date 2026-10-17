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
    this.occupation,
    this.motherName,
    this.phone,
    this.email,
    this.address,
    this.villageName,
    this.districtName,
    this.regencyName,
    this.provinceName,
    this.relationshipType,
    this.relationLabel,
    this.accountHolderName,
    this.relationshipContext,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.complaint,
    this.serviceName,
    this.poliklinikName,
    this.scheduledDate,
    this.scheduledStartTime,
    this.scheduledEndTime,
    this.etaRange,
    this.sessionName,
    this.queueNumber,
    this.doctorName,
    this.roomName,
    this.actualStartedAt,
    this.actualCompletedAt,
    this.consultationDurationFormatted,
    this.appointmentStatus,
    this.bookingCode,
  });

  final String? fullName;
  final String? medicalRecordNumber;
  final String? nik;
  final String? birthDate;
  final String? birthPlace;
  final String? gender;
  final String? bloodType;
  final String? occupation;
  final String? motherName;
  final String? phone;
  final String? email;
  final String? address;
  final String? villageName;
  final String? districtName;
  final String? regencyName;
  final String? provinceName;
  final String? relationshipType;
  final String? relationLabel;
  final String? accountHolderName;
  final String? relationshipContext;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final String? complaint;
  final String? serviceName;
  final String? poliklinikName;
  final String? scheduledDate;
  final String? scheduledStartTime;
  final String? scheduledEndTime;
  final String? etaRange;
  final String? sessionName;
  final String? queueNumber;
  final String? doctorName;
  final String? roomName;
  final String? actualStartedAt;
  final String? actualCompletedAt;
  final String? consultationDurationFormatted;
  final String? appointmentStatus;
  final String? bookingCode;

  String get practiceTimeFormatted {
    if (etaRange != null && etaRange!.trim().isNotEmpty) {
      return etaRange!;
    }
    if (scheduledStartTime != null && scheduledEndTime != null) {
      final String start = scheduledStartTime!.length >= 5
          ? scheduledStartTime!.substring(0, 5)
          : scheduledStartTime!;
      final String end = scheduledEndTime!.length >= 5
          ? scheduledEndTime!.substring(0, 5)
          : scheduledEndTime!;
      return '$start - $end WIB';
    }
    if (scheduledStartTime != null && scheduledStartTime!.trim().isNotEmpty) {
      final String start = scheduledStartTime!.length >= 5
          ? scheduledStartTime!.substring(0, 5)
          : scheduledStartTime!;
      return '$start WIB';
    }
    return '-';
  }

  String get genderDisplay {
    if (gender == null) return '-';
    final String g = gender!.trim().toLowerCase();
    if (g == 'male' || g == 'l' || g == 'laki-laki') return 'Laki-laki';
    if (g == 'female' || g == 'p' || g == 'perempuan') return 'Perempuan';
    return gender!;
  }

  String get relationshipDisplay {
    if (relationshipContext != null && relationshipContext!.trim().isNotEmpty) {
      return relationshipContext!;
    }
    if (accountHolderName != null && accountHolderName!.trim().isNotEmpty) {
      final String r = (relationshipType ?? '').trim().toLowerCase();
      if (r == 'child') return 'Anak dari $accountHolderName';
      if (r == 'spouse') return 'Pasangan dari $accountHolderName';
      if (r == 'parent') return 'Orang tua dari $accountHolderName';
      if (r == 'relative') return 'Kerabat dari $accountHolderName';
      if (r == 'self') return 'Akun Utama (Diri Sendiri)';
      if (relationLabel != null && relationLabel!.trim().isNotEmpty) {
        return '$relationLabel dari $accountHolderName';
      }
      return 'Keluarga dari $accountHolderName';
    }
    if (relationLabel != null && relationLabel!.trim().isNotEmpty) {
      return relationLabel!;
    }
    if (relationshipType == null) return '-';
    final String r = relationshipType!.trim().toLowerCase();
    switch (r) {
      case 'child':
        return 'Anak';
      case 'parent':
        return 'Orang Tua';
      case 'spouse':
        return 'Pasangan (Suami/Istri)';
      case 'self':
        return 'Akun Utama (Diri Sendiri)';
      case 'sibling':
        return 'Saudara Kandung';
      default:
        return relationshipType!;
    }
  }

  String get fullAddressFormatted {
    final List<String> parts = <String>[];
    if (address != null && address!.trim().isNotEmpty) parts.add(address!.trim());
    if (villageName != null && villageName!.trim().isNotEmpty) {
      parts.add('Desa/Kel. ${villageName!.trim()}');
    }
    if (districtName != null && districtName!.trim().isNotEmpty) {
      parts.add('Kec. ${districtName!.trim()}');
    }
    if (regencyName != null && regencyName!.trim().isNotEmpty) {
      parts.add(regencyName!.trim());
    }
    if (provinceName != null && provinceName!.trim().isNotEmpty) {
      parts.add(provinceName!.trim());
    }
    return parts.isNotEmpty ? parts.join(', ') : '-';
  }

  String get birthInfoFormatted {
    if (birthPlace != null && birthDate != null) {
      return '${birthPlace!}, ${birthDate!}';
    }
    return birthDate ?? birthPlace ?? '-';
  }
}
