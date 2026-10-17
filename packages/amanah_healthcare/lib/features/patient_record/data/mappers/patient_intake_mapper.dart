import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';

class PatientIntakeMapper {
  PatientIntakeMapper._();

  static PatientIntakeRecord fromJson(
    Map<String, dynamic> json,
    String appointmentId,
  ) {
    final String flow = json['flow'] as String? ?? 'regular';
    final String type = json['type'] as String? ?? flow;
    final dynamic rawData = json['data'] ?? json;
    final Map<String, dynamic> data =
        rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};

    MaternalIntakeData? maternal;
    ImmunizationIntakeData? immunization;
    RegularIntakeData? regular;

    if (type == 'maternal' || flow == 'pregnancy') {
      maternal = _mapMaternalData(data);
    } else if (type == 'immunization' || flow == 'immunization') {
      immunization = _mapImmunizationData(data);
    } else {
      regular = _mapRegularData(data);
    }

    return PatientIntakeRecord(
      appointmentId: appointmentId,
      flow: flow,
      type: type,
      maternal: maternal,
      immunization: immunization,
      regular: regular,
    );
  }

  static MaternalIntakeData _mapMaternalData(Map<String, dynamic> data) {
    final int? g = data['gravidaCount'] as int?;
    final int? p = data['parityCount'] as int?;
    final int? a = data['abortionCount'] as int?;
    final int? ah = data['livingChildrenCount'] as int?;

    String? gpa;
    if (g != null) {
      gpa = 'G$g P${p ?? 0} A${a ?? 0} Ah${ah ?? 0}';
    }

    final List<dynamic>? prevRaw = data['previousPregnancies'] as List<dynamic>?;
    final List<PreviousPregnancyItem> previousPregnancies = <PreviousPregnancyItem>[];
    if (prevRaw != null) {
      for (final dynamic item in prevRaw) {
        if (item is Map<String, dynamic>) {
          previousPregnancies.add(
            PreviousPregnancyItem(
              orderNumber: item['orderNumber'] as int? ?? 1,
              birthYear: item['birthYear']?.toString(),
              childSex: item['childSex'] as String?,
              birthWeightGrams: item['birthWeightGrams'] as int?,
              deliveryMethod: item['deliveryMethod'] as String?,
              birthAttendant: item['birthAttendant'] as String?,
              deliveryPlace: item['deliveryPlace'] as String?,
              complications: item['complications'] as String?,
            ),
          );
        }
      }
    }

    final List<dynamic>? contraRaw =
        data['contraceptiveHistories'] as List<dynamic>?;
    final List<ContraceptiveHistoryItem> contraceptiveHistories =
        <ContraceptiveHistoryItem>[];
    if (contraRaw != null) {
      for (final dynamic item in contraRaw) {
        if (item is Map<String, dynamic>) {
          contraceptiveHistories.add(
            ContraceptiveHistoryItem(
              contraceptiveType:
                  item['contraceptiveType'] as String? ?? 'Tidak diketahui',
              durationText: item['durationText'] as String?,
              startDate: item['startDate'] as String?,
            ),
          );
        }
      }
    }

    return MaternalIntakeData(
      gpa: gpa,
      hpht: data['hpht'] as String?,
      estimatedDueDate: data['estimatedDueDate'] as String?,
      gestationalAgeFormatted: data['gestationalAgeFormatted'] as String?,
      heightCm: data['heightCm'] as int?,
      prePregnancyWeightKg: (data['prePregnancyWeightKg'] as num?)?.toDouble(),
      upperArmCircumferenceCm:
          (data['upperArmCircumferenceCm'] as num?)?.toDouble(),
      initialBmi: (data['initialBmi'] as num?)?.toDouble(),
      motherBloodType: data['motherBloodType'] as String?,
      tetanusStatus: data['tetanusStatus'] as String?,
      partnerName: data['partnerName'] as String?,
      previousPregnancies: previousPregnancies,
      contraceptiveHistories: contraceptiveHistories,
    );
  }

  static ImmunizationIntakeData _mapImmunizationData(Map<String, dynamic> data) {
    return ImmunizationIntakeData(
      childName: data['childName'] as String? ?? 'Pasien Anak',
      childNik: data['childNik'] as String?,
      childBirthDate: data['childBirthDate'] as String?,
      childAgeFormatted: data['childAgeFormatted'] as String?,
      childSex: data['childSex'] as String?,
      fatherName: data['fatherName'] as String?,
      motherName: data['motherName'] as String?,
      previousVaccineHistory: data['previousVaccineHistory'] as String?,
      childAllergyHistory: data['childAllergyHistory'] as String?,
    );
  }

  static RegularIntakeData _mapRegularData(Map<String, dynamic> data) {
    final dynamic patientRaw = data['patient'];
    final Map<String, dynamic> p =
        patientRaw is Map<String, dynamic> ? patientRaw : data;

    return RegularIntakeData(
      fullName: p['fullName'] as String? ?? p['name'] as String?,
      medicalRecordNumber: p['medicalRecordNumber'] as String? ?? p['patientRm'] as String?,
      nik: p['nik'] as String?,
      birthDate: p['birthDate'] as String?,
      birthPlace: p['birthPlace'] as String?,
      gender: p['gender'] as String?,
      bloodType: p['bloodType'] as String?,
      occupation: p['occupation'] as String?,
      motherName: p['motherName'] as String?,
      phone: p['phone'] as String?,
      email: p['email'] as String?,
      address: p['address'] as String?,
      villageName: p['villageName'] as String?,
      districtName: p['districtName'] as String?,
      regencyName: p['regencyName'] as String?,
      provinceName: p['provinceName'] as String?,
      relationshipType: p['relationshipType'] as String?,
      relationLabel: p['relationLabel'] as String?,
      accountHolderName: p['accountHolderName'] as String? ?? p['masterPatientName'] as String?,
      relationshipContext: p['relationshipContext'] as String?,
      emergencyContactName: p['emergencyContactName'] as String?,
      emergencyContactPhone: p['emergencyContactPhone'] as String?,
      emergencyContactRelationship: p['emergencyContactRelationship'] as String?,
      complaint: data['complaint'] as String?,
      serviceName: data['layananName'] as String? ?? data['serviceName'] as String?,
      poliklinikName: data['poliklinikName'] as String?,
      scheduledDate: data['appointmentDateFormatted'] as String? ??
          data['scheduledDate'] as String?,
      scheduledStartTime: data['scheduledStartTime'] as String?,
      scheduledEndTime: data['scheduledEndTime'] as String?,
      etaRange: data['etaRange'] as String?,
      sessionName: data['sessionName'] as String?,
      queueNumber: data['queueNumber']?.toString(),
      doctorName: data['doctorName'] as String?,
      roomName: data['roomName'] as String?,
      actualStartedAt: data['actualStartedAt'] as String?,
      actualCompletedAt: data['actualCompletedAt'] as String?,
      consultationDurationFormatted:
          data['consultationDurationFormatted'] as String?,
      appointmentStatus:
          data['status'] as String? ?? data['rawStatus'] as String?,
      bookingCode: data['bookingCode'] as String?,
    );
  }
}
