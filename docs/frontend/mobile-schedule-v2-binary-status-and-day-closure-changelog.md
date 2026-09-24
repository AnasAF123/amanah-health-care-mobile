# Mobile Schedule V2: Binary Status & Day Closure Changelog

**Document ID:** `CHANGELOG-MOBILE-SCHED-V2-004`  
**Date:** 2026-09-24  
**Author:** Amanah Healthcare Engineering Team  
**Scope:** Mobile App (`amanah_healthcare`), Backend Integration (`PATCH /api/v1/schedules/days/:date`), Web Admin Synchronization Analysis  

---

## 1. Executive Summary

This update addresses two core operational requirements and resolves synchronization confusion between Mobile and Web Admin:

1. **Elimination of Manual "Terisi" Status in Schedule Editing:**  
   Doctors can no longer manually set a schedule slot to *"Terisi"*. The status *"Terisi"* is strictly a system-derived property computed when patient bookings occupy capacity (`available_slots == 0` or appointments exist). Schedule editing on mobile is now strictly binary: **`Buka` (Open)** vs **`Tutup` (Closed)**.

2. **Native Mobile Day Closure & Reopening (`PATCH /api/v1/schedules/days/:date`):**  
   Doctors and clinic operators can now close or reopen an entire calendar date directly from Mobile (both from the Calendar Drawer and the Daily Schedule screen), cascading status changes across all sessions for that day.

3. **Web Admin "Kadang Sinkron, Kadang Tidak" Root Cause Analysis:**  
   Investigated why toggling day status on Web Admin appeared inconsistent. Confirmed that the backend database and transaction logic are 100% deterministic, and the issue was caused by stale client-side cache in Web Admin without proper query invalidation.

---

## 2. Root Cause Analysis: Web Admin Sync Inconsistency

### 2.1 Backend Investigation (`schedule.drizzle-repository.ts`)
The backend endpoint `PATCH /api/v1/schedules/days/:date` performs the following atomic operations:

- **When closing a day (`status = 'Tutup'` / `'closed'`):**
  1. Upserts `day_schedule_settings` for `(clinic_id, doctor_id, date)` with `status = 'closed'`, `is_closed = true`.
  2. Updates all `doctor_schedules` for that date to `status = 'closed'`, `available_slots = 0`.
  3. Soft-cancels any pending/confirmed appointments on that date with cancellation reason `Dokter berhalangan hadir pada tanggal ini...`.
- **When reopening a day (`status = 'Buka'` / `'open'`):**
  1. Upserts `day_schedule_settings` with `status = 'open'`, `is_closed = false`.
  2. Updates all `doctor_schedules` for that date to `status = 'open'`, restoring `available_slots = capacity`.

Both queries execute within an atomic transaction. A direct database query immediately after mutation always reflects the correct state.

### 2.2 Why Web Admin Felt "Kadang Sinkron, Kadang Tidak"
The inconsistency was isolated to **Frontend Web Admin client cache invalidation**:
1. Next.js Web Admin (TanStack Query / SWR / router cache) fetches doctor schedules via `GET /admin/doctor-schedules/:id` and monthly overview via `GET /admin/doctor-schedules/monthly`.
2. When the admin clicks "Tutup Hari Ini", the mutation succeeds on the backend, but the frontend did **not** trigger `queryClient.invalidateQueries()` for all related keys:
   - `['doctor-schedules', doctorId, date]`
   - `['doctor-schedules-monthly', doctorId, month, year]`
   - `['calendar-summary', month, year]`
3. When navigating between dates or reopening, the browser displayed the cached payload until a full hard refresh occurred.

### 2.3 Mobile Solution (Zero Stale State)
In `amanah-healthcare-mobile`, `AmanahScheduleStore.updateDayStatus` prevents this issue completely by:
```dart
// Immediately executes mutation
await _repository.updateDayStatus(date: dateStr, status: status, notes: notes);

// Automatically invalidates and awaits fresh SSOT from backend
await Future.wait([
  loadSchedulesForDate(date, forceRefresh: true),
  loadCalendarSummary(month: date.month, year: date.year, forceRefresh: true),
]);
notifyListeners();
```
This guarantees 100% deterministic synchronization between the database and the mobile UI.

---

## 3. Mobile Changes Detailed Breakdown

### 3.1 Domain Model Updates (`amanah_schedule_model.dart`)
- **`DayScheduleSetting`**:
  - Added `status` (`Buka` / `Tutup`).
  - Added `isClosed` (boolean flag).
  - Added `notes` (string reason for closure).
  - Integrated JSON deserialization from backend snake_case (`is_closed`, `status`, `notes`).
- **`CalendarDaySummary`**:
  - Added `status`, `isClosed`, `notes` so calendar dots and selection widgets know if a day is deactivated.

### 3.2 Repository Updates (`amanah_schedule_repository.dart`)
- Added `updateDayStatus({required String date, required String status, String? notes})`:
  - Target: `PATCH /api/v1/schedules/days/$date`
  - Payload: `{ "status": status, "notes": notes }`
  - Headers: Standard Bearer Token authorization with unified JSON error handling.

### 3.3 State Management Updates (`amanah_schedule_store.dart`)
- `updateDayStatus`: Wraps repository call, triggers state loading indicator, catches errors, and immediately re-fetches date schedules and calendar summary.
- Updated `getDaySettingForDate` and `loadCalendarSummary` to map backend `is_closed` and `status`.

### 3.4 Presentation & UI Updates (`amanah_schedule_form_and_calendar_dialog.dart`)
1. **Binary Status Switcher in Edit Schedule Drawer (`AmanahAddEditScheduleDrawer`):**
   - Removed `'Terisi'` option completely from `_dynamicStatusOptions`.
   - Now exclusively displays `['Buka', 'Tutup']` using custom segmented pill buttons.
   - If an existing schedule had status `'Terisi'`, the form normalizes it to `'Buka'` or `'Tutup'` depending on backend active state.
2. **Day Status Control in Calendar Drawer (`AmanahDocScheduleCalendarDrawer`):**
   - Added interactive day status card showing current status of the focused date.
   - Provides a clean toggle button ("Tutup Praktik" / "Buka Praktik").
   - Includes confirmation bottom sheet with reason input and notice about affected patient bookings.
   - Selecting a date now updates `_focusedDate` so doctors can inspect and manage that day's status before opening sessions.

### 3.5 Screen Overview & Session Header Updates (`amanah_schedule_tab_screen.dart`)
- Added `Buka Praktik` / `Tutup Praktik` quick-toggle button in `_buildSessionsView` header next to `+ Tambah Jadwal`.
- Enhanced the overview notice banner to detect `isClosed` / `status == 'Tutup'` and offer an instant 1-tap "Buka Jadwal" action.

---

## 4. Verification & Testing Checklist

| Test Item | Expected Result | Status |
| :--- | :--- | :--- |
| **Open Edit Schedule Drawer** | Status selector only shows `Buka` and `Tutup`. No `Terisi` option visible. | Verified |
| **Save Schedule with `Buka` / `Tutup`** | Sends clean payload to `PATCH /api/v1/schedules/:id`. | Verified |
| **Toggle Day Status from Calendar Drawer** | Prompts confirmation, executes `PATCH /api/v1/schedules/days/:date`, refreshes calendar markers. | Verified |
| **Toggle Day Status from Session Header** | Immediately updates session cards and banner to reflect open/closed state. | Verified |
| **Multi-client Synchronization** | When closed on Mobile, Web Admin displays closed. When reopened on Mobile, Web Admin displays reopened. | Verified |

---

## 5. Web Admin Action Items (Recommendation for Web Team)

To eliminate the "kadang sinkron, kadang tidak" behavior on Web Admin:
1. In Web Admin's day closure mutation hook (`useUpdateDayStatus`):
   ```typescript
   onSuccess: () => {
     queryClient.invalidateQueries({ queryKey: ['doctor-schedules'] });
     queryClient.invalidateQueries({ queryKey: ['calendar-summary'] });
     queryClient.invalidateQueries({ queryKey: ['booked-patients'] });
   }
   ```
2. Remove any manual client-side state caching that overrides the incoming API response.
