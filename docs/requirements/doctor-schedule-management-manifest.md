# Feature Backend Requirement Delegation Report: Doctor Schedule Management ("Jadwal Dokter")

## 1. Feature Identification

* **Feature Name:** Doctor Schedule Management ("Jadwal Dokter" / "Jadwal Praktik Dokter")
* **Feature Scope:** End-to-end frontend schedule management including creating, reading, updating, and deleting (CRUD) doctor practice sessions, managing daily practice quota and leave (*cuti*) status, navigating monthly schedule calendars, inspecting booked patient queues, and reviewing patient complaint details.
* **Primary Frontend Platform:** Flutter Mobile Application (Android & iOS)
* **Codebase Location:** `packages/amanah_healthcare/lib/features/schedule/` and `packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart`
* **Report Purpose:** Provide the backend engineering team with an evidence-based, implementation-agnostic technical requirement delegation manifest detailing all capabilities, inputs, read dependencies, write actions, validations, UI states, and failure semantics required by the mobile frontend.

---

## 2. Executive Summary

The Doctor Schedule Management feature enables internal clinic doctors (and authorized clinic staff) to view and manage their practice schedules, track daily patient booking capacity, manage leave (*cuti*), and review patients booked for each practice session.

### Current Implementation State
* **Frontend Architecture:** The UI is structured as a dedicated tab screen (`AmanahScheduleTabScreen`) accessible from the home shell (`AmanahHomeShell`), supported by a singleton ChangeNotifier store (`AmanahScheduleStore`).
* **Existing Backend Integrations:** **None.** The mobile application currently operates entirely in-memory using mock data seeded in `AmanahScheduleStore.instance`. There are no active HTTP, REST, or GraphQL clients connected to a live schedule backend.
* **Required Backend Capabilities:** The backend must establish authoritative capabilities for:
  1. Reading doctor schedules by date and date ranges (including monthly status indicators for the calendar view).
  2. Creating new doctor practice schedules.
  3. Updating existing practice schedules (times, rooms, poli, and status).
  4. Deleting practice schedules.
  5. Reading and updating daily practice settings (target patient quota and leave / *cuti* status).
  6. Retrieving booked patient records associated with specific practice sessions.
  7. Providing selectable reference data for practice rooms, poliklinik/specializations, and available time slots with conflict detection.
* **Key Unknowns:** Authoritative timezone handling (local WIB vs UTC), multi-slot session persistence semantics, authoritative room/time conflict resolution, and patient booking lifecycle ownership.

---

## 3. User and Access Context

* **Intended Users:** Internal clinic staff only — specifically doctors (`AmanahUserRole.doctor`) and authorized clinic administrative personnel. This feature is **not patient-facing**.
* **User Journey Context:** A doctor opens the mobile application to view their assigned or created practice hours for the day/month, see how many patients have booked slots, adjust or cancel their sessions, add new practice availability, or declare leave (*cuti*).
* **Authentication Dependency:**
  * Observed in codebase: The application runs within an authenticated user context (`AmanahAuthUser`, e.g. `role: AmanahUserRole.doctor`, `id: 'doc-001'`).
  * The frontend assumes all schedule operations are scoped to the currently authenticated doctor.
* **Authorization Dependency:**
  * Frontend exposes full management actions (create, edit, delete, toggle cuti) directly on the doctor's own schedule.
  * Backend authorization capability required. Exact authorization rules, doctor tenancy, role enforcement, and permission scopes remain backend-owned / pending definition.

---

## 4. Feature User Journey

The feature comprises five primary user flows:

```
[Home Shell / Quick Access / Bottom Nav]
                   │
                   ▼
     [Overview View (AmanahScheduleTabScreen)]
       ├─► Radial Capacity Gauge (Booked vs Target Quota)
       ├─► Date Carousel Strip (25-day horizontal coverflow)
       ├─► Cuti Alert Banner (if isCuti == true)
       ├─► Booked Patients Showcase (AmanahBookedPatientCard)
       │     └─► Tap Card ──► Patient Detail Modal (AmanahPatientDetailModal)
       │
       ├─► Tap "Lihat jadwal" ──► Monthly Calendar Drawer (AmanahDocScheduleCalendarDrawer)
       │                            └─► Select Date ──► Switch to Sessions View
       │
       ├─► Tap "+" Icon ──► Add Schedule Drawer (AmanahAddEditScheduleDrawer)
       │                      └─► Save ──► Switch to Sessions View
       │
       └─► Switch View ──► [Sessions View (AmanahScheduleViewMode.sessions)]
                             ├─► Doctor Practice Session Cards (AmanahDoctorSessionCard)
                             │     ├─► Tap "Detail Sesi" ──► Session Detail Drawer (AmanahScheduleDetailDrawer)
                             │     │                           ├─► "Lihat Pasien Booking" ──► [Session Patients View]
                             │     │                           └─► "Edit Jadwal" ──► Edit Schedule Drawer
                             │     ├─► Tap "Edit" ──► Edit Schedule Drawer
                             │     └─► Tap "Delete" ──► Delete Schedule
                             └─► Empty State (if no sessions) ──► "Tambah Jadwal Dokter"
```

### Detailed Flow Steps:

1. **Entry to Overview:**
   - User navigates to the schedule screen via the bottom navigation bar "Jadwal", the home quick-access button "Jadwal Saya", or by tapping a schedule card on the home dashboard.
   - The screen initializes in `AmanahScheduleViewMode.overview` displaying the radial capacity gauge, date carousel strip, and list of booked patients across all sessions for that day.
2. **Date Navigation:**
   - User swipes the horizontal date strip to switch active dates, or taps "Lihat jadwal" to open a monthly calendar drawer (`AmanahDocScheduleCalendarDrawer`).
   - Selecting a date updates `_selectedDate` and triggers schedule/patient retrieval for that date.
3. **Inspecting Booked Patients:**
   - In overview mode or session-patient mode, user taps on any patient card (`AmanahBookedPatientCard`).
   - Opens `AmanahPatientDetailModal` showing patient identity, RM number, age, queue number, time slot, session title, room, guardian (if present), and medical complaint notes.
4. **Creating a Schedule:**
   - User taps the '+' icon button in the header or the "Tambah Jadwal" button.
   - `AmanahAddEditScheduleDrawer` opens.
   - User selects the date (via inline calendar dropdown) and activates one or more sessions (Dini Hari, Pagi, Siang, Malam).
   - For each active session, user specifies start time (`from`), end time (`to`), room (`room`), and poliklinik (`poli`).
   - User taps "Tambah Jadwal".
   - Frontend validates presence of active session, derives time and date strings, updates the store, and navigates to the sessions view for that date.
5. **Editing a Schedule:**
   - User taps "Edit Jadwal" from `AmanahScheduleDetailDrawer` or triggers edit on a session card.
   - `AmanahAddEditScheduleDrawer` opens in edit mode with pre-populated session details and status options ("Menunggu", "Buka", "Cuti").
   - User modifies fields and taps "Simpan Perubahan". If status is set to "Cuti", the date's day setting is also marked as cuti.
6. **Deleting a Schedule:**
   - User taps "Hapus" inside the edit drawer or triggers delete on the session card.
   - Schedule is removed from the store and the UI updates immediately.
7. **Toggling Leave (*Cuti*):**
   - If a date is marked as *cuti*, the overview displays a banner: *"Dokter Cuti Praktik: Seluruh jadwal dinonaktifkan."*
   - Tapping "Buka Jadwal" reverts the *cuti* status to `false`.

---

## 5. Frontend Entry Points

| Type | Component / Route / Symbol | Source Location | Description |
|---|---|---|---|
| **Tab Route** | `AmanahHomeTab.schedule` | [amanah_home_shell.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_home_shell.dart#L237-L250) | Bottom navigation item "Jadwal" routing to schedule tab |
| **Quick Action** | `AmanahQuickAction` (`id: 'jadwal-saya'`) | [amanah_home_shell.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_home_shell.dart#L120-L126) | Quick access button "Jadwal Saya" on Home dashboard |
| **Home Card Tap** | `AmanahScheduleCardStack` | [amanah_home_shell.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_home_shell.dart#L143-L150) | Tapping today's schedule card on Home dashboard |
| **Screen** | `AmanahScheduleTabScreen` | [amanah_schedule_tab_screen.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart#L15-L681) | Primary schedule feature container supporting 3 view modes |
| **Drawer / Modal** | `AmanahAddEditScheduleDrawer` | [amanah_schedule_form_and_calendar_dialog.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L511-L1344) | Bottom sheet form for creating and editing doctor schedules |
| **Drawer / Modal** | `AmanahDocScheduleCalendarDrawer` | [amanah_schedule_form_and_calendar_dialog.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L93-L395) | Monthly calendar view drawer |
| **Drawer / Modal** | `AmanahScheduleDetailDrawer` | [amanah_schedule_cards_and_drawers.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart#L1001-L1276) | Read-only session detail drawer with navigation to patient list and edit |
| **Modal** | `AmanahPatientDetailModal` | [amanah_schedule_cards_and_drawers.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart#L1423-L1491) | Detailed patient record & complaint modal |
| **State Store** | `AmanahScheduleStore` | [amanah_schedule_store.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L4-L396) | Singleton in-memory ChangeNotifier managing schedule state |
| **Tests** | `amanah_schedule_tab_screen_test.dart` | [amanah_schedule_tab_screen_test.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/test/features/home/amanah_schedule_tab_screen_test.dart#L1-L242) | Widget tests verifying all tab, drawer, modal, and empty state interactions |

---

## 6. Input Inventory

The following table documents every user-facing input collected by the feature forms (primarily within `AmanahAddEditScheduleDrawer` and related selection sheets):

| Field | Purpose | Required? | Frontend Rule | Source | Transformation | Submitted? |
|---|---|---|---|---|---|---|
| `selectedDate` | Practice date for the schedule | Yes | Must be a valid date; past dates are unselectable in calendar | Date picker / inline calendar | Formatted to `'YYYY-MM-DD'` key and localized Indonesian date string (e.g. `'Rabu, 26 Agustus 2026'`) | Yes |
| `status` | Practice session operational status (Edit mode only) | Yes (in edit mode) | Allowed values: `'Menunggu'`, `'Buka'`, `'Cuti'` | Radio pill selector | Mapped to `schedule.badge` and `AmanahBadgeVariant`. If `'Cuti'`, calls `store.setDayCuti(selectedDate, true)` | Yes |
| `sessionType` | Practice session shift category | Yes | One of: `'Dini Hari'`, `'Pagi'`, `'Siang'`, `'Malam'` | Toggle switch (`_ScheduleToggleSwitch`) | Sets `schedule.sessionType` and `schedule.title` (`'Sesi ' + sessionType`) | Yes |
| `from` | Session start time | Yes | Selected from 24 hourly options (`kTimeOptions`) or custom typed | Selection bottom sheet (`_AmanahScheduleSelectionSheet`) | Combined with `to` into `time: '$from - $to WIB'` and stored in `startTime` | Yes |
| `to` | Session end time | Yes | Selected from 24 hourly options (`kTimeOptions`) or custom typed | Selection bottom sheet (`_AmanahScheduleSelectionSheet`) | Combined with `from` into `time: '$from - $to WIB'` and stored in `endTime` | Yes |
| `room` | Assigned clinic practice room | Yes | Selected from 17 predefined rooms (`kRoomOptions`) or custom typed | Selection bottom sheet (`_AmanahScheduleSelectionSheet`) | Stored directly in `schedule.room` | Yes |
| `poli` | Poliklinik or specialization department | Yes | Selected from 18 predefined options (`kPoliOptions`) or custom typed | Selection bottom sheet (`_AmanahScheduleSelectionSheet`) | Stored directly in `schedule.poli` | Yes |
| `slots` | Additional time slots inside a session | Optional | Doctor can tap "Add More" to add multiple slot rows | Dynamic list in session panel | **Observed anomaly:** Frontend allows adding multiple slot rows, but save logic only persists `firstActive.slots.first` | Derived Need / Ambiguity |
| `isCuti` | Toggle whole-day doctor leave | Optional | Boolean flag | "Buka Jadwal" button on Cuti banner, or selecting 'Cuti' status | Updates `DayScheduleSetting.isCuti` | Yes |
| `cutiReason` | Reason for doctor leave | Optional | Text description (default: `'Dokter Cuti Praktik'`) | Passed in `setDayCuti` method | Stored in `DayScheduleSetting.cutiReason` | Yes |

---

## 7. Frontend Validation

The following validation behavior is observed in the frontend:

### Frontend-Enforced Rules:
1. **Past Date Selection Prevention:** In `AmanahDocScheduleCalendarDrawer`, any date prior to `baseToday` has its `onTap` callback disabled (`isPast ? null : ...`). Text color is dimmed (`neutral300`/`neutral500`).
2. **Occupied Room & Time Visual Disabling:** In `_AmanahScheduleSelectionSheet`, options matching `kOccupiedTimeOptions` or `kOccupiedRoomOptions` are rendered with disabled styling and cannot be tapped, unless the option is already the current value.
3. **Active Session Fallback:** In `_saveSchedule()`, if no session has `active == true`, the frontend falls back to selecting the `'pagi'` session default.
4. **Slot Fallback:** If a session's slot list is empty, frontend supplies default fallback values (`'7:00 AM' - '11:00 AM'`, `'Ruang 201'`, `'Poli Gigi & Mulut'`).

### Unenforced / Backend-Established Rules Required:
1. **Time Range Validity:** The frontend does **not** validate whether `from` is chronologically before `to`. (Backend must enforce `startTime < endTime`).
2. **Schedule Overlap:** The frontend does **not** validate whether a doctor's new session overlaps an existing session on the same date. (Backend must validate slot collisions).
3. **Room Conflict:** The frontend relies on hardcoded `kOccupiedRoomOptions` and does not query real-time room bookings across all clinic doctors. (Backend must validate room availability).
4. **Patient Quota Limits:** The frontend displays capacity percentage based on `targetQuota`, but does not enforce maximum patient caps during booking. (Backend-owned).

---

## 8. Derived and Transformed Values

| Value | Derivation Source | Transformation Logic | Where Used | Submitted? | Authoritative Role |
|---|---|---|---|---|---|
| `dateKey` | `DateTime date` | `'$y-$m-$d'` zero-padded | Key in `_schedulesMap` & `_daySettingsMap` | Yes | Client-derived; backend should accept standard ISO date |
| `dateStr` | `DateTime date` | Localized Indonesian string: `'${dayName}, ${day} ${monthName} ${year}'` | `DoctorSchedule.date` field | Yes | Presentation-only; backend should store ISO date |
| `timeStr` | `slot.from`, `slot.to` | `'${slot.from} - ${slot.to} WIB'` | `DoctorSchedule.time` field | Yes | Presentation-only; backend should store distinct start/end times |
| `capacityPercentage` | `bookedCount`, `targetQuota`, `isCuti` | If `isCuti || targetQuota <= 0` return 0; else `round(bookedCount / targetQuota * 100).clamp(0, 100)` | Radial capacity gauge on Overview | No | Derived UI metric; backend provides count and quota |
| `bookedCount` | `schedules.bookedPatients` | Sum of all `bookedPatients.length` for that date | Radial gauge & overview subtitle | No | Derived UI metric; backend provides patient records |
| `badgeVariant` | `_status` string | `'Cuti'` -> warning, `'Menunggu'` -> primary, `'Buka'` -> success | Schedule card badges | Yes | Mapped from status enum/string |
| `id` | `DateTime.now()`, `session.id`, `index` | `'ses-${now}-${sessionId}-${index}'` | `DoctorSchedule.id` | Yes | Locally generated; backend should assign authoritative ID |

---

## 9. Data Dependencies

The feature requires access to the following entities and reference datasets:

| Data Required | Why Frontend Needs It | Where It Appears | Current Source | Existing Integration? | Backend Capability Needed |
|---|---|---|---|---|---|
| **Doctor Schedules List** | Render sessions for a date | Overview & Sessions view | `AmanahScheduleStore._schedulesMap` (mock) | No | Query schedules for doctor by date or range |
| **Day Schedule Settings** | Display daily quota, cuti status, and capacity | Radial gauge & cuti alert banner | `AmanahScheduleStore._daySettingsMap` (mock) | No | Query daily settings / quota / cuti by date |
| **Monthly Schedule Indicators** | Render dots in calendar drawer (has schedule, cuti, closed) | `AmanahDocScheduleCalendarDrawer` grid | Calculated across all dates in month | No | Monthly schedule summary / calendar metadata query |
| **Booked Patients List** | Display patients booked for a date or session | `AmanahBookedPatientCard` & `AmanahPatientDetailModal` | Embedded in `DoctorSchedule.bookedPatients` | No | Query booked patients for a doctor's schedule session |
| **Reference Rooms** | Populate room selection sheet | `_AmanahScheduleSelectionSheet` | Hardcoded `kRoomOptions` (17 items) | No | Reference data capability for clinic rooms |
| **Occupied Rooms** | Disable already-booked rooms | `_AmanahScheduleSelectionSheet` | Hardcoded `kOccupiedRoomOptions` (3 items) | No | Dynamic room availability / conflict checking |
| **Reference Poliklinik** | Populate poli selection sheet | `_AmanahScheduleSelectionSheet` | Hardcoded `kPoliOptions` (18 items) | No | Reference data capability for clinic departments |
| **Reference Time Options** | Populate start/end time selection | `_AmanahScheduleSelectionSheet` | Hardcoded `kTimeOptions` (24 items) | No | Allowed time slots / scheduling increments |
| **Occupied Times** | Disable occupied time slots | `_AmanahScheduleSelectionSheet` | Hardcoded `kOccupiedTimeOptions` (7 items) | No | Dynamic doctor availability / conflict checking |

---

## 10. Read Capabilities Required

The backend team is requested to establish capabilities supporting the following read operations:

1. **Read Doctor Schedules by Date:**
   - Capability to retrieve all practice schedule sessions for the authenticated doctor on a specified date (`YYYY-MM-DD`).
   - Expected data per schedule: Unique identifier, session title/type (`Pagi`, `Siang`, `Malam`, `Dini Hari`), start time, end time, room name/code, poliklinik/department name, status (`Buka`, `Menunggu`, `Cuti`), and booked patient count.
2. **Read Doctor Schedules by Month / Range (Calendar Overview):**
   - Capability to retrieve a lightweight monthly summary for a given year/month.
   - For each date in the month, indicate: whether at least one schedule exists, whether the doctor is on leave (*cuti*), and total booked patient count.
3. **Read Day Practice Settings:**
   - Capability to retrieve target patient quota (e.g. 8) and *cuti* status (with optional reason) for a given date.
4. **Read Booked Patients for Schedule / Session:**
   - Capability to retrieve booked patient records for a specific schedule session or entire date.
   - Required patient fields: Patient ID, full name, Medical Record number (RM, e.g. `'RM-2026-0412'`), age (e.g. `'28 Thn'`), queue number (e.g. `'#01'`), assigned time slot (e.g. `'08:00 - 09:30 WIB'`), status badge text & tone, medical complaint / notes, avatar URL (optional), and guardian name & relation (optional, e.g. `'Bpk. Budi Sanjaya (Ayah)'`).
5. **Read Reference & Availability Data:**
   - List of active rooms in the clinic with real-time availability status for the requested time.
   - List of active poliklinik/specializations.

---

## 11. Write and Action Capabilities Required

The backend team is requested to establish capabilities supporting the following write/mutation operations:

1. **Create Practice Schedule Session:**
   - **Trigger:** Doctor taps "Tambah Jadwal" in `AmanahAddEditScheduleDrawer`.
   - **Frontend Data Provided:** Target date, session type (`Pagi`, `Siang`, `Malam`, `Dini Hari`), start time, end time, room, poliklinik.
   - **Expected Outcome:** New schedule session created with initial status `Menunggu` (or `Buka`), initial booking count 0, assigned unique ID.
   - **Refreshed Data:** Refreshed schedule list for that date and updated monthly calendar indicator.
2. **Update Practice Schedule Session:**
   - **Trigger:** Doctor taps "Simpan Perubahan" in `AmanahAddEditScheduleDrawer`.
   - **Frontend Data Provided:** Schedule ID, target date, session type, start time, end time, room, poliklinik, status (`Menunggu`, `Buka`, `Cuti`).
   - **Expected Outcome:** Schedule session fields updated in persistence.
   - **Side Effect:** If status is updated to `Cuti`, backend should handle whether associated bookings are cancelled, rescheduled, or flagged.
3. **Delete Practice Schedule Session:**
   - **Trigger:** Doctor taps "Hapus" in edit drawer or triggers session card deletion.
   - **Frontend Data Provided:** Schedule ID and target date.
   - **Expected Outcome:** Schedule session deleted / cancelled.
   - **Constraint:** Backend must determine business rule if schedule already has booked patients (prevent delete vs cascade cancel).
4. **Set Day Cuti / Open Schedule:**
   - **Trigger:** Doctor taps "Buka Jadwal" on the overview cuti banner, or saves a schedule with `Cuti` status.
   - **Frontend Data Provided:** Date, `isCuti` (boolean), optional `cutiReason`.
   - **Expected Outcome:** Day schedule setting updated.

---

## 12. UI States and Expected Outcomes

| State | Trigger | Frontend Behavior | Backend Information or Capability Needed |
|---|---|---|---|
| **Initial / Loading** | Screen opened or pull-to-refresh triggered | Spinner / loading indicator via `AmanahPullToRefresh` | Fast query response; support paginated or date-scoped payload |
| **Loaded (Overview)** | Schedule and patient data retrieved | Renders radial capacity gauge, date carousel, booked patient cards | Schedule list with embedded or linked patient bookings, target quota, and cuti flag |
| **Loaded (Sessions)** | User switches to sessions mode or saves schedule | Displays `AmanahDoctorSessionCard` list with booked counts | Schedule session list for selected date |
| **Loaded (Session Patients)** | User taps "Lihat Pasien Booking" in session detail drawer | Displays full-screen list of `AmanahBookedPatientCard` for that session | List of `BookedPatient` records filtered by session ID |
| **Empty (No Patients)** | Selected date has 0 booked patients | Renders `AmanahEmptyState.box` with message and "Tambah Jadwal" / "Lihat Sesi Dokter" actions | Return empty array `[]` for booked patients |
| **Empty (No Sessions)** | Selected date has 0 schedules | Renders `AmanahEmptyState.box` with message and "Tambah Jadwal Dokter" action | Return empty array `[]` for schedules |
| **Cuti Active** | Date has `isCuti == true` | Renders amber alert banner, capacity gauge shows 0% with "Cuti" badge, "Buka Jadwal" action | Return `isCuti: true` and `cutiReason` in day setting |
| **Submitting Form** | User taps "Tambah Jadwal" or "Simpan Perubahan" | Drawer awaits operation completion | Synchronous mutation response or clear error response |
| **Validation Failure** | Form inputs violate business rules | Form remains open; display distinguishable error messages | Distinguishable error response indicating which field failed (e.g. room occupied, time overlap) |
| **Conflict State** | Room or time already booked by another doctor | Reject submission with conflict notification | Conflict failure distinction (HTTP 409 / error code) |
| **Network / Server Failure** | Network timeout or 5xx response | Retains current UI state, displays toast / banner notification | Standardized error payload |

---

## 13. Error Requirements

The frontend needs to distinguish the following failure scenarios:

1. **Schedule Time Overlap / Collision:** The doctor already has an active session overlapping the requested time window.
2. **Room Occupied:** The selected room is already booked by another practitioner during the specified hours.
3. **Invalid Time Range:** End time is earlier than or equal to start time.
4. **Schedule Deletion Conflict:** The doctor attempts to delete a schedule session that already has active booked patients.
5. **Resource Not Found:** The requested schedule ID does not exist or has already been removed.
6. **Authentication / Session Expired:** The doctor's authentication token is expired or invalid.
7. **Authorization Rejection:** The authenticated user is not authorized to modify schedules for this doctor/clinic.

> *Note on Error Taxonomy:* The frontend requires distinguishable failure semantics for each of the above scenarios. The exact backend error contract, error codes, and response structures remain backend-owned / pending definition.

---

## 14. Authentication and Authorization Dependencies

* **Authentication Dependency:**
  * The feature operates exclusively within an authenticated doctor session.
  * Observed in `AmanahHomeShell`: User data is passed via `AmanahAuthUser` (`role: AmanahUserRole.doctor`, `id: 'doc-001'`).
* **Authorization Dependency:**
  * The frontend assumes that the logged-in doctor can create, edit, and delete their own schedules, as well as toggle their own cuti status.
  * Backend authorization capability required. Exact authorization contract (e.g., JWT Bearer tokens, clinic ID headers, doctor ownership checks) is backend-owned / pending definition.

---

## 15. Existing Backend Integrations

* **Observed Fact:** There are currently **no backend integrations or API clients** for doctor schedules in the mobile repository.
* The feature is powered by `AmanahScheduleStore` ([amanah_schedule_store.dart](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart)), which maintains static in-memory data for dates between August 26, 2026 and August 31, 2026.
* `pubspec.yaml` does not contain `http`, `dio`, or any REST client package. A network client must be introduced or implemented when connecting to the backend.

---

## 16. Existing vs Required vs Unknown Matrix

| Capability | Current State | Frontend Need | Evidence | Status |
|---|---|---|---|---|
| **Read Schedules by Date** | In-memory mock (`_schedulesMap`) | Query doctor schedules by date | [amanah_schedule_store.dart:27-30](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L27-L30) | **Missing** |
| **Read Monthly Calendar Overview** | In-memory mock iteration | Query month schedule/cuti indicators | [amanah_schedule_form_and_calendar_dialog.dart:256-264](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L256-L264) | **Missing** |
| **Read Day Settings (Quota & Cuti)** | In-memory mock (`_daySettingsMap`) | Query daily target quota & cuti status | [amanah_schedule_store.dart:32-39](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L32-L39) | **Missing** |
| **Read Booked Patients** | In-memory mock (`DoctorSchedule.bookedPatients`) | Query booked patients per session/date | [amanah_schedule_store.dart:41-52](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L41-L52) | **Missing** |
| **Create Schedule** | In-memory list addition (`addSchedule`) | Persist new schedule session | [amanah_schedule_store.dart:63-70](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L63-L70) | **Missing** |
| **Update Schedule** | In-memory list replacement (`updateSchedule`) | Persist updated schedule session | [amanah_schedule_store.dart:72-82](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L72-L82) | **Missing** |
| **Delete Schedule** | In-memory list removal (`deleteSchedule`) | Delete / cancel schedule session | [amanah_schedule_store.dart:84-91](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L84-L91) | **Missing** |
| **Set Day Cuti** | In-memory map update (`setDayCuti`) | Persist doctor leave status | [amanah_schedule_store.dart:93-101](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L93-L101) | **Missing** |
| **Rooms Reference & Availability** | Hardcoded constants (`kRoomOptions`, `kOccupiedRoomOptions`) | Query selectable rooms & occupied states | [amanah_schedule_form_and_calendar_dialog.dart:35-53](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L35-L53) | **Missing** |
| **Poli Reference** | Hardcoded constants (`kPoliOptions`) | Query selectable poliklinik list | [amanah_schedule_form_and_calendar_dialog.dart:55-74](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L55-L74) | **Missing** |
| **Time Conflict Detection** | Hardcoded constants (`kOccupiedTimeOptions`) | Dynamic conflict validation | [amanah_schedule_form_and_calendar_dialog.dart:76-84](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L76-L84) | **Missing** |
| **Downstream Web Patient Read** | Context only | Patient booking web application | N/A (External consumer) | **Unknown / Out of Scope** |

---

## 17. Backend Delegation Request

Based on the frontend investigation, the backend team is requested to evaluate and establish authoritative support for the following frontend requirements:

1. **Establish Read Capabilities:**
   - Endpoint / query to fetch doctor schedules for a specific date and for a month-long date range.
   - Endpoint / query to fetch day settings (quota and cuti).
   - Endpoint / query to fetch booked patients for a doctor's schedule session.
   - Reference data queries for clinic rooms, poliklinik departments, and slot availability.
2. **Establish Mutation Capabilities:**
   - Mutation to create a doctor schedule session with date, session type, start time, end time, room, and poli.
   - Mutation to update an existing schedule session (times, room, poli, status).
   - Mutation to delete an existing schedule session.
   - Mutation to toggle doctor cuti status for a date.
3. **Establish Conflict & Validation Rules:**
   - Server-side validation rejecting schedule creation/updates where room or doctor has overlapping bookings.
   - Definition of business rules when deleting a schedule that has active patient bookings.
4. **Establish Result Information:**
   - Successful creation/update should return the complete authoritative schedule entity (including assigned ID, status, and confirmed times).
5. **Establish Failure Distinctions:**
   - Provide distinguishable error codes or status codes for: room conflict, time collision, validation error, schedule not found, and unauthorized access.

---

## 18. Open Questions

The following questions cannot be resolved from codebase evidence and require backend clarification:

1. **Timezone & Date Format Standard:** The frontend currently formats times as `'07:00 - 11:00 WIB'` and `'7:00 AM'`. Will the backend accept/return standard ISO 8601 strings (e.g. `2026-08-26T07:00:00+07:00`) or 24-hour time strings (`07:00:00`)?
2. **Multi-Slot Persistence:** The frontend UI allows doctors to add multiple time slots within a single session panel via "Add More", but the local store currently only persists the first slot. Does the backend data model support multiple slots per session (e.g., breaks between slots), or is each slot an independent schedule record?
3. **Deletion Policy with Active Bookings:** What happens if a doctor deletes a schedule session that already has booked patients? Does the backend reject the deletion, auto-cancel bookings, or notify clinic administration?
4. **Authoritative Quota Configuration:** Where does the daily `targetQuota` (currently defaulting to 8 or 6) originate? Is it configured per doctor, per clinic, or per day?
5. **Downstream Web Consumer Contract:** How are patient bookings created? Since patients book through a web application, will the backend push real-time booking updates (e.g. WebSockets/SSE) or will the mobile app rely on periodic polling / pull-to-refresh?

---

## 19. Traceability Matrix

| Requirement | Frontend Evidence | User Flow | Backend Capability Needed | Status |
|---|---|---|---|---|
| **Display Daily Capacity & Quota** | [amanah_schedule_components.dart:8-156](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_components.dart#L8-L156) | Overview View | Query daily target quota & booked count | Missing |
| **Date Selection (25-Day Coverflow)** | [amanah_schedule_components.dart:226-633](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_components.dart#L226-L633) | Overview View | Query schedules for selected date | Missing |
| **Monthly Calendar Grid** | [amanah_schedule_form_and_calendar_dialog.dart:93-395](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L93-L395) | Calendar Drawer | Query monthly schedule & cuti summary | Missing |
| **View Booked Patient Records** | [amanah_schedule_cards_and_drawers.dart:136-597](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart#L136-L597) | Overview & Session Patients | Query booked patient list with complaint & RM | Missing |
| **Patient Complaint Details** | [amanah_schedule_cards_and_drawers.dart:1423-1824](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart#L1423-L1824) | Patient Detail Modal | Query detailed patient complaint & notes | Missing |
| **View Doctor Practice Sessions** | [amanah_schedule_cards_and_drawers.dart:600-997](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart#L600-L997) | Sessions View | Query doctor schedules by date | Missing |
| **Create Schedule Session** | [amanah_schedule_form_and_calendar_dialog.dart:653-734](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L653-L734) | Add Schedule Drawer | Create schedule session capability | Missing |
| **Update Schedule Session** | [amanah_schedule_form_and_calendar_dialog.dart:680-701](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L680-L701) | Edit Schedule Drawer | Update schedule session capability | Missing |
| **Delete Schedule Session** | [amanah_schedule_form_and_calendar_dialog.dart:736-744](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L736-L744) | Edit Schedule Drawer / Session Card | Delete schedule session capability | Missing |
| **Leave (*Cuti*) Management** | [amanah_schedule_store.dart:93-101](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L93-L101), [amanah_schedule_tab_screen.dart:324-364](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart#L324-L364) | Overview Cuti Banner & Edit Drawer | Set/unset cuti status capability | Missing |
| **Room & Poli Selection** | [amanah_schedule_form_and_calendar_dialog.dart:35-74](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L35-L74) | Form Selection Sheet | Reference data & conflict check capability | Missing |

---

## 20. Evidence

The following files and components were inspected in full to construct this manifest:

1. `packages/amanah_healthcare/lib/features/schedule/domain/amanah_schedule_model.dart` ([lines 1–150](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/domain/amanah_schedule_model.dart#L1-L150))
   - Defines `DoctorSchedule`, `BookedPatient`, `DayScheduleSetting`, and `AmanahBadgeVariant`.
2. `packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart` ([lines 1–397](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart#L1-L397))
   - Implements `AmanahScheduleStore`, in-memory schedule and day setting maps, date formatting, capacity calculation, CRUD methods, and initial mock data.
3. `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_components.dart` ([lines 1–634](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_components.dart#L1-L634))
   - Implements `AmanahRadialCapacityGauge` and `AmanahDateCarouselStrip`.
4. `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart` ([lines 1–2008](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart#L1-L2008))
   - Implements `AmanahBookedPatientCard`, `AmanahDoctorSessionCard`, `AmanahScheduleDetailDrawer`, `AmanahPatientDetailModal`, and queue badges.
5. `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart` ([lines 1–2194](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart#L1-L2194))
   - Implements `AmanahAddEditScheduleDrawer`, `AmanahDocScheduleCalendarDrawer`, `_AmanahScheduleSelectionSheet`, reference option lists (`kTimeOptions`, `kRoomOptions`, `kPoliOptions`, `kOccupiedTimeOptions`, `kOccupiedRoomOptions`), and form submission logic.
6. `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_queue_badge.dart` ([lines 1–351](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_queue_badge.dart#L1-L351))
   - Implements 3D queue number badge component.
7. `packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart` ([lines 1–681](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart#L1-L681))
   - Implements primary tab screen and view modes (`overview`, `sessions`, `sessionPatients`).
8. `packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_home_shell.dart` ([lines 1–481](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_home_shell.dart#L1-L481))
   - Implements navigation entry points and home dashboard schedule card stack integration.
9. `packages/amanah_healthcare/lib/features/home/presentation/components/amanah_schedule_card_stack.dart` ([lines 1–1089](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/components/amanah_schedule_card_stack.dart#L1-L1089))
   - Implements 3D home schedule cards and empty card with create schedule trigger.
10. `packages/amanah_healthcare/lib/features/home/presentation/theme/amanah_schedule_card_tokens.dart` ([lines 1–125](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/presentation/theme/amanah_schedule_card_tokens.dart#L1-L125))
    - Defines design tokens for schedule cards.
11. `packages/amanah_healthcare/lib/features/home/domain/amanah_home_data.dart` ([lines 1–248](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/home/domain/amanah_home_data.dart#L1-L248))
    - Defines doctor profile data and schedule quick action items.
12. `packages/amanah_healthcare/test/features/home/amanah_schedule_tab_screen_test.dart` ([lines 1–379](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/test/features/home/amanah_schedule_tab_screen_test.dart#L1-L379))
    - Comprehensive widget tests for all schedule tab interactions, drawers, modals, and empty states.
13. `packages/amanah_healthcare/pubspec.yaml` ([lines 1–105](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/pubspec.yaml#L1-L105))
    - Verified absence of external networking/HTTP packages.

---

## 21. Contract Boundary

This report describes frontend requirements, dependencies, and observed integration constraints. The final API contract, endpoint design, transport details, backend validation semantics, response schema, error taxonomy, authorization model, persistence strategy, and implementation remain backend-owned unless already established by an existing contract.
