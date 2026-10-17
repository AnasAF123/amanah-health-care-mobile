enum DoctorQueueStatus {
  waiting('waiting'),
  called('called'),
  inConsultation('in_consultation'),
  completed('completed'),
  noShow('no_show'),
  cancelled('cancelled'),
  rescheduled('rescheduled');

  final String value;
  const DoctorQueueStatus(this.value);

  static DoctorQueueStatus fromString(String? raw) {
    for (final status in DoctorQueueStatus.values) {
      if (status.value == raw) {
        return status;
      }
    }
    return DoctorQueueStatus.waiting;
  }
}
