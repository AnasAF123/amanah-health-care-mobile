import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';

class PatientIntakeMapper {
  PatientIntakeMapper._();

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final String trimmed = value.trim();
      final int? direct = int.tryParse(trimmed);
      if (direct != null) return direct;
      final double? d = double.tryParse(trimmed);
      return d?.toInt();
    }
    return null;
  }

  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  static int? _parseInt(dynamic value) => parseInt(value);
  static double? _parseDouble(dynamic value) => parseDouble(value);

  static PatientIntakeRecord fromJson(Map<String, dynamic> json, String appointmentId) {
    final String flow = json['flow'] as String? ?? 'regular';
    final String type = json['type'] as String? ?? flow;
    final dynamic rawData = json['data'] ?? json;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? rawData
        : <String, dynamic>{};

    // Always map regular demographic & appointment intake data so no patient lacks core data
    final RegularIntakeData regular = _mapRegularData(data);

    MaternalIntakeData? maternal;
    if (type == 'maternal' ||
        flow == 'pregnancy' ||
        data.containsKey('hpht') ||
        data.containsKey('gestationalAgeFormatted')) {
      maternal = _mapMaternalData(data);
    }

    ImmunizationIntakeData? immunization;
    if (type == 'immunization' ||
        flow == 'immunization' ||
        (data.containsKey('childName') && data['childName'] != null)) {
      immunization = _mapImmunizationData(data);
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

  static List<MaternalDiseaseHistoryItem> _mapDiseaseHistory(dynamic rawHistory) {
    if (rawHistory is! Map<String, dynamic>) return const <MaternalDiseaseHistoryItem>[];

    final List<Map<String, String>> definitions = <Map<String, String>>[
      <String, String>{
        'has': 'hasDiabetesHistory',
        'notes': 'diabetesHistoryNotes',
        'label': 'Diabetes Melitus',
      },
      <String, String>{
        'has': 'hasHypertensionHistory',
        'notes': 'hypertensionHistoryNotes',
        'label': 'Hipertensi / Tekanan Darah Tinggi',
      },
      <String, String>{
        'has': 'hasHepatitisBHistory',
        'notes': 'hepatitisBHistoryNotes',
        'label': 'Hepatitis B',
      },
      <String, String>{
        'has': 'hasThyroidDiseaseHistory',
        'notes': 'thyroidDiseaseHistoryNotes',
        'label': 'Penyakit Tiroid',
      },
      <String, String>{
        'has': 'hasSurgeryHistory',
        'notes': 'surgeryHistoryNotes',
        'label': 'Riwayat Operasi',
      },
      <String, String>{
        'has': 'hasTwinPregnancyHistory',
        'notes': 'twinPregnancyHistoryNotes',
        'label': 'Riwayat Kehamilan Kembar',
      },
      <String, String>{'has': 'hasAsthmaHistory', 'notes': 'asthmaHistoryNotes', 'label': 'Asma'},
      <String, String>{
        'has': 'hasHeartDiseaseHistory',
        'notes': 'heartDiseaseHistoryNotes',
        'label': 'Penyakit Jantung',
      },
      <String, String>{
        'has': 'hasAutoimmuneHistory',
        'notes': 'autoimmuneHistoryNotes',
        'label': 'Autoimun (SLE/Lupus)',
      },
      <String, String>{
        'has': 'hasTuberculosisHistory',
        'notes': 'tuberculosisHistoryNotes',
        'label': 'Tuberkulosis (TBC)',
      },
      <String, String>{
        'has': 'hasHivOrSyphilisHistory',
        'notes': 'hivOrSyphilisHistoryNotes',
        'label': 'HIV / Sifilis',
      },
      <String, String>{
        'has': 'hasCystMyomaTumorHistory',
        'notes': 'cystMyomaTumorHistoryNotes',
        'label': 'Kista / Miom / Tumor',
      },
      <String, String>{
        'has': 'hasMentalHealthHistory',
        'notes': 'mentalHealthHistoryNotes',
        'label': 'Kesehatan Mental',
      },
      <String, String>{
        'has': 'hasOtherDiseaseHistory',
        'notes': 'otherDiseaseHistoryNotes',
        'label': 'Penyakit Lainnya',
      },
    ];

    final List<MaternalDiseaseHistoryItem> result = <MaternalDiseaseHistoryItem>[];
    for (final Map<String, String> def in definitions) {
      final dynamic rawHas = rawHistory[def['has']];
      final bool has =
          rawHas == true ||
          (rawHas is String &&
              (rawHas.trim().toLowerCase() == 'ya' ||
                  rawHas.trim().toLowerCase() == 'ada' ||
                  rawHas.trim().toLowerCase() == 'true'));
      final dynamic rawNotes = rawHistory[def['notes']];
      final String? notes = rawNotes?.toString().trim();

      result.add(
        MaternalDiseaseHistoryItem(
          diseaseName: def['label']!,
          hasDisease: has,
          yearOrNotes: (notes != null && notes.isNotEmpty) ? notes : null,
        ),
      );
    }
    return result;
  }

  static List<VaccineEntryItem> _mapVaccineEntries(dynamic entriesRaw) {
    if (entriesRaw is! List<dynamic>) return const <VaccineEntryItem>[];
    final List<VaccineEntryItem> list = <VaccineEntryItem>[];
    for (final dynamic item in entriesRaw) {
      if (item is Map<String, dynamic>) {
        final String code =
            item['vaccineCode'] as String? ?? item['vaccine_code'] as String? ?? '-';
        final String status = item['status'] as String? ?? 'NOT_GIVEN';
        final String? givenDate = item['givenDate'] as String? ?? item['given_date'] as String?;
        final String? notes = item['notes'] as String?;
        list.add(
          VaccineEntryItem(vaccineCode: code, status: status, givenDate: givenDate, notes: notes),
        );
      }
    }
    return list;
  }

  static MaternalIntakeData _mapMaternalData(Map<String, dynamic> data) {
    final int? g = _parseInt(data['gravidaCount']);
    final int? p = _parseInt(data['parityCount']);
    final int? a = _parseInt(data['abortionCount']);
    final int? ah = _parseInt(data['livingChildrenCount']);

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
              orderNumber: _parseInt(item['orderNumber']) ?? 1,
              birthYear: item['birthYear']?.toString(),
              childSex: item['childSex'] as String?,
              birthWeightGrams: _parseInt(item['birthWeightGrams']),
              deliveryMethod: item['deliveryMethod'] as String?,
              birthAttendant: item['birthAttendant'] as String?,
              deliveryPlace: item['deliveryPlace'] as String?,
              complications: item['complications'] as String?,
            ),
          );
        }
      }
    }

    final List<dynamic>? contraRaw = data['contraceptiveHistories'] as List<dynamic>?;
    final List<ContraceptiveHistoryItem> contraceptiveHistories = <ContraceptiveHistoryItem>[];
    if (contraRaw != null) {
      for (final dynamic item in contraRaw) {
        if (item is Map<String, dynamic>) {
          contraceptiveHistories.add(
            ContraceptiveHistoryItem(
              contraceptiveType: item['contraceptiveType'] as String? ?? 'Tidak diketahui',
              durationText: item['durationText'] as String?,
              startDate: item['startDate'] as String?,
            ),
          );
        }
      }
    }

    final String? husbandName = (data['partnerName'] ?? data['husbandName']) as String?;
    MaternalHusbandData? husband;
    if (husbandName != null && husbandName.trim().isNotEmpty) {
      husband = MaternalHusbandData(
        name: husbandName.trim(),
        nik: (data['partnerNik'] ?? data['husbandNik'])?.toString(),
        birthDate: (data['partnerBirthDate'] ?? data['husbandBirthDate']) as String?,
        age: _parseInt(data['partnerAge'] ?? data['husbandAge']),
        job: (data['partnerJob'] ?? data['husbandJob']) as String?,
        education: (data['partnerEducation'] ?? data['husbandEducation']) as String?,
        bloodType: (data['partnerBloodType'] ?? data['husbandBloodType']) as String?,
      );
    }

    final dynamic rawDisease = data['diseaseHistory'] ?? data['answers'];
    final List<MaternalDiseaseHistoryItem> diseaseHistoryList = _mapDiseaseHistory(rawDisease);

    return MaternalIntakeData(
      gpa: gpa,
      hpht: data['hpht'] as String?,
      estimatedDueDate: data['estimatedDueDate'] as String?,
      gestationalAgeFormatted: data['gestationalAgeFormatted'] as String?,
      heightCm: _parseInt(data['heightCm']),
      prePregnancyWeightKg: _parseDouble(data['prePregnancyWeightKg']),
      upperArmCircumferenceCm: _parseDouble(data['upperArmCircumferenceCm']),
      initialBmi: _parseDouble(data['initialBmi']),
      motherBloodType: data['motherBloodType'] as String?,
      tetanusStatus: data['tetanusStatus'] as String?,
      partnerName: husbandName,
      husband: husband,
      diseaseHistoryList: diseaseHistoryList,
      puskesmas: data['puskesmas'] as String?,
      posyandu: data['posyandu'] as String?,
      dasawisma: data['dasawisma'] as String?,
      concerningEnvironmentNotes: data['concerningEnvironmentNotes'] as String?,
      allergyInfo: data['allergyInfo'] as String?,
      otherNotes: data['otherNotes'] as String?,
      previousPregnancies: previousPregnancies,
      contraceptiveHistories: contraceptiveHistories,
    );
  }

  static ImmunizationIntakeData _mapImmunizationData(Map<String, dynamic> data) {
    return ImmunizationIntakeData(
      childName: data['childName'] as String? ?? 'Pasien Anak',
      childNik: data['childNik']?.toString(),
      childBirthDate: data['childBirthDate'] as String?,
      childAgeFormatted: data['childAgeFormatted'] as String?,
      childSex: data['childSex'] as String?,
      fatherName: data['fatherName'] as String?,
      motherName: data['motherName'] as String?,
      previousVaccineHistory: data['previousVaccineHistory'] as String?,
      childAllergyHistory: data['childAllergyHistory'] as String?,
      vaccineEntries: _mapVaccineEntries(data['entries']),
    );
  }

  static RegularIntakeData _mapRegularData(Map<String, dynamic> data) {
    final dynamic patientRaw = data['patient'];
    final Map<String, dynamic> p = patientRaw is Map<String, dynamic> ? patientRaw : data;

    return RegularIntakeData(
      patientId: p['id'] as String? ?? data['patientId'] as String?,
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
      scheduledDate:
          data['appointmentDateFormatted'] as String? ?? data['scheduledDate'] as String?,
      scheduledStartTime: data['scheduledStartTime'] as String?,
      scheduledEndTime: data['scheduledEndTime'] as String?,
      etaRange: data['etaRange'] as String?,
      sessionName: data['sessionName'] as String?,
      queueNumber: data['queueNumber']?.toString(),
      doctorName: data['doctorName'] as String?,
      roomName: data['roomName'] as String?,
      actualStartedAt: data['actualStartedAt'] as String?,
      actualCompletedAt: data['actualCompletedAt'] as String?,
      consultationDurationFormatted: data['consultationDurationFormatted'] as String?,
      appointmentStatus: data['status'] as String? ?? data['rawStatus'] as String?,
      bookingCode: data['bookingCode'] as String?,
    );
  }
}
