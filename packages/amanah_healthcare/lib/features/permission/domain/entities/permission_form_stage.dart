/// Sequential stages of the staff leave permission application flow.
enum PermissionFormStage {
  /// Stage 1: Select leave type (Cuti Tahunan, Izin Sakit, Izin Khusus, etc.)
  type,

  /// Stage 2: Select date mode (Horizontal grid: Hari Ini vs Rentang Tanggal)
  dateMode,

  /// Stage 2b: Select custom date range (Side-by-side start & end date panels)
  dateCustom,

  /// Stage 3: Select scope (1 Hari Penuh vs Sesi Tertentu with roster sessions)
  scope,

  /// Stage 4: Enter reason and review application summary
  reason,
}
