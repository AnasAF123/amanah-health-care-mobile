# Flutter Schedule Backend Delegation Report

**Date:** 2026-09-23  
**Repository scope audited:** Flutter mobile frontend in `packages/amanah_healthcare`  
**Backend scope:** Delegation only. This document does not implement backend/database changes.  
**Web scope:** No Next.js/web source was found in this repository. Web/admin notes are consumer contract requirements only.

## 1. Purpose

This document delegates the schedule-domain requirements discovered from the Flutter mobile audit to the backend team.

The mobile app is the primary workflow producer for practitioner schedule input, but it must not become the canonical scheduling engine. The backend/database must remain authoritative for:

- effective consultation duration;
- valid practitioner schedule context;
- session or availability boundary;
- interval projection;
- appointment occupation;
- conflict handling;
- appointment-safe mutation rules;
- authorization;
- persisted status semantics.

Flutter should collect practitioner intent, submit it to backend, then render the canonical backend result.

## 2. Non-Negotiable Product Direction

The target practitioner workflow is:

```text
Choose date or applicable schedule period
Choose practitioner schedule context
Choose starting time
Review effective consultation duration
Submit availability
```

The practitioner should normally not manually calculate:

```text
end = start + duration
```

Flutter must support arbitrary valid start times such as:

```text
08:00
08:15
08:45
09:10
09:40
```

Flutter must not silently normalize or round these starts. A start of `08:45` with duration `30` must project from `08:45`, not from `09:00`.

The target primary interval statuses are:

| Domain status | Indonesian label |
|---|---|
| `OPEN` | `Buka` |
| `OCCUPIED` | `Terisi` |
| `CLOSED` | `Tutup` |

`Penuh` must not be used as the primary availability meaning. An interval containing an appointment is `OCCUPIED` / `Terisi`.

`Cuti` must not be duplicated as a top-level availability state. If leave still matters operationally, it should be represented as `CLOSED` with a backend-owned reason such as `LEAVE`, if the backend supports that structure.

## 3. Current Flutter Execution Path

Current schedule flow:

```text
AmanahScheduleTabScreen
  -> AmanahAddEditScheduleDrawer
  -> AmanahScheduleStore
  -> AmanahScheduleRepository
  -> REST API /api/v1/schedules...
  -> DoctorSchedule / DayScheduleSetting / BookedPatient DTOs
  -> schedule cards, detail drawer, patient modal
```

Observed files:

| Layer | File | Evidence |
|---|---|---|
| Schedule tab | `packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart` | Uses `AmanahScheduleStore.instance` at line 38 and loads schedules/day settings/calendar summary at lines 85-87. |
| Add/edit form | `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart` | Contains hardcoded time options at line 8, status defaults at lines 542 and 547, hardcoded initial sessions at line 598, save flow at line 742, add/remove slot handlers at lines 879 and 908, and manual `From`/`To` labels at lines 1794 and 1811. |
| State store | `packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart` | Singleton `ChangeNotifier` at lines 5 and 12, save flow at line 239, local fallbacks at lines 65, 280-281, and optimistic local retention at line 305. |
| REST client | `packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_repository.dart` | Existing API methods and manual `startTime`/`endTime` contract at lines 319-338 and 360-378. |
| DTO/model | `packages/amanah_healthcare/lib/features/schedule/domain/amanah_schedule_model.dart` | `DoctorSchedule` stores `startTime`, `endTime`, `capacity`, `availableSlots` at lines 190-327; `DayScheduleSetting` stores `targetQuota` and `isCuti` at lines 391-426. |
| Schedule rendering | `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart` | Session card derives/display start and end at lines 623-628, shows badge at line 740, detail drawer shows `Cuti` or schedule badge at line 1132, and patient detail modal begins at line 1423. |
| Repository tests | `packages/amanah_healthcare/test/features/schedule/amanah_schedule_repository_test.dart` | Tests currently assert old payload shape with `startTime`, `endTime`, capacity, statuses, and sample `timeSlot` strings. |

## 4. Current Input Model

| Field | Current Flutter behavior | Current ownership classification | Target ownership |
|---|---|---|---|
| Date | User selects a practice date. | User-entered in Flutter. | Flutter may collect, backend validates. |
| Start time / `From` | User manually selects `From`. | User-entered in Flutter. | Flutter collects arbitrary valid start. |
| End time / `To` | User manually selects `To`. | User-entered in Flutter and sent to backend. | Backend-derived or backend-validated boundary. Remove manual doctor calculation. |
| Duration | No canonical schedule duration field exists in Flutter schedule model. | Not represented. `timeSlotIntervals` exists as reference metadata/fallback, not an effective duration. | Backend-owned effective duration. Flutter consumes and displays it. |
| Session/context | Form builds hardcoded sessions such as Dini Hari, Pagi, Siang, Malam. Backend options exist but are not the authoritative form source. | Partly hardcoded, partly server-provided. | Backend-owned practitioner schedule context. |
| Weekday | Display/derived from selected date. | Derived locally. | Safe as presentation only. |
| Recurrence | No recurrence flow observed. | Not implemented. | Backend decision if recurrence is required. |
| Status | Current edit status values include `Menunggu`, `Buka`, `Cuti`; backend docs mention `open`, `closed`, `pending`. | Mixed local/backend. | `OPEN`, `OCCUPIED`, `CLOSED` canonical enum. |
| Slot count | UI derives counts from `bookedPatients.length`, `bookedPatientCount`, `capacity`, or fallbacks. | Locally derived from mixed data. | Backend projection should provide interval list and capacity. |
| Capacity/quota | `capacity` defaults to `8`; day `targetQuota` defaults to `8`; overview computes percentages locally when summary is absent. | Mixed backend/local fallback. | Backend-owned. Admin/config ownership must be clarified. |
| Room | Loaded from reference endpoint but room query can depend on date/start/end. | Server-provided reference, client-selected. | Backend should evaluate availability from projected schedule context. |
| Poliklinik/service | Loaded from reference endpoint. | Server-provided reference, client-selected. | Preserve if still part of schedule context. |
| Patient details | `BookedPatient` embeds patient name, MR number, complaint, guardian, status, time slot. | Server-provided, rendered directly. | Backend must authorize field-level visibility. Prefer appointment reference plus detail retrieval where appropriate. |

## 5. Manual `From` / `To` Dependency Audit

The current app definitely asks doctors to manually provide both `From` and `To`.

Concrete dependencies:

| Dependency | Current evidence | Migration requirement |
|---|---|---|
| Form labels | `From` label at `amanah_schedule_form_and_calendar_dialog.dart:1794`; `To` label at line 1811. | Remove `To` from practitioner-facing form only after backend no longer requires manual `endTime`. |
| Time options | `kTimeOptions` is a fixed 24-hour hourly list at line 8. | Replace with arbitrary time input/picker validated against backend context. |
| Save mapper | `_saveSchedule()` starts at line 742 and writes selected slot `from`/`to` into `DoctorSchedule`. | Submit start intent and context; backend returns projection. |
| Store update path | `saveSchedule()` passes `schedule.startTime` and `schedule.endTime` at lines 265-266. | Store must stop requiring `endTime` when backend contract changes. |
| Store create fallback | New schedule fallback uses `startTime ?? '08:00'` and `endTime ?? '12:00'` at lines 280-281. | Remove. Flutter must not invent default practice ranges. |
| Repository create | `createSchedule` requires `startTime` and `endTime` at lines 322-323 and sends both at lines 337-338. | Backend API must accept start/context without manually supplied end. |
| Repository update | `updateSchedule` accepts `startTime` and `endTime` at lines 363-364 and sends both at lines 377-378. | Update semantics must be appointment-safe and backend-owned. |
| Room reference | `fetchRooms` accepts `startTime` and `endTime` at lines 466-472. | Room availability should be checked using backend projection, not client-derived end. |
| Rendering | Session card derives `startTime`/`endTime` at `amanah_schedule_cards_and_drawers.dart:623-628`. | Rendering should consume backend projected intervals and boundaries. |

Conclusion: `endTime` is contractual today. It cannot be removed from the widget alone.

## 6. Duration Ownership Audit

Current findings:

- No authoritative `consultationDurationMinutes` field exists in the Flutter schedule model.
- No `Duration(minutes: 30)` schedule-generation rule was found in the Flutter schedule feature.
- `30` appears as:
  - `timeSlotIntervals: [15, 30, 45, 60]` fallback in `amanah_schedule_model.dart:647`;
  - fallback schedule options in `amanah_schedule_repository.dart:530`;
  - repository tests expecting `[15, 30, 45, 60]`;
  - sample booked patient `timeSlot` strings such as `08:30 - 09:00 WIB`.
- Current Flutter does not have a canonical interval projection algorithm.

Backend requirement:

The backend must expose the effective consultation duration used for projection. Flutter must not add:

```dart
const duration = Duration(minutes: 30);
```

or any equivalent hidden production business rule.

Required backend decisions:

| Decision | Required answer |
|---|---|
| Duration ownership | Is duration clinic-wide, practitioner-specific, service-specific, schedule-context-specific, or date-specific? |
| Edit authority | Can doctor edit duration, or only admin/staff? |
| Effective value resolution | If multiple configs exist, which one wins? |
| Missing config behavior | Does backend reject schedule creation, or return an explicit no-config error? |
| Projection responsibility | Does backend return only duration and boundary, or also the projected intervals? Flutter prefers backend projection where booking correctness depends on it. |

## 7. Current Status Semantics

Observed mobile statuses:

| Current value | Evidence | Problem |
|---|---|---|
| `Buka` | Default `_status = 'Buka'` at form line 542; badge rendering line 740. | Should map to canonical `OPEN`. |
| `Tutup` / `closed` | Status rendering checks `closed` / `Tutup` at form line 1098. | Should map to canonical `CLOSED`. |
| `Cuti` | Dynamic status default includes `Cuti` at line 547; form updates day cuti at lines 788-789; detail drawer shows `Cuti` at line 1132. | Should not be a top-level availability status. Use `CLOSED` plus reason if backend supports. |
| `Menunggu` | Default create status uses `Menunggu` at lines 559 and 815. | Not part of target primary availability set. Requires backend clarification or removal. |
| `Penuh` / `FULL` | Search found no primary Flutter scheduling implementation using these strings. | No mobile removal needed for this exact label, but web/backend must not introduce it as primary availability. |

Target status contract:

```text
OPEN     -> Buka
OCCUPIED -> Terisi
CLOSED   -> Tutup
```

`OCCUPIED` must be interval-level and should include an appointment reference that authorized users can inspect.

## 8. Slot And Synthetic Schedule Logic Audit

| Current mechanism | Evidence | Classification | Required action |
|---|---|---|---|
| Fixed hourly `kTimeOptions` | `amanah_schedule_form_and_calendar_dialog.dart:8` | CHANGE | Replace with arbitrary time input/picker validated against backend context. |
| Manual slot row UI | `_addTimeSlot` at line 879 and `_removeTimeSlot` at line 908 | REMOVE/MIGRATE | Target should not ask user to manually create individual ranges. |
| Multiple visual slots but only first slot saved per active session | `_saveSchedule()` uses session slots and maps first slot into schedule creation path. | REMOVE/MIGRATE | Backend projection should produce intervals. |
| Hardcoded sessions | `_buildInitialSessions()` at line 598 | MIGRATE | Backend must provide applicable practitioner contexts/boundaries. |
| Local default create range | Store uses `08:00` to `12:00` fallback at lines 280-281. | REMOVE | Flutter must not create fake domain values. |
| Local day quota fallback | Store fallback `targetQuota: 8` at line 65 and model fallback at `amanah_schedule_model.dart:403`. | REMOVE | Backend must return effective capacity/projection or explicit missing config. |
| Local schedule optimistic retention | Comment `Keep optimistic local update` at store line 305. | REMOVE | Store should refetch or replace with canonical backend response. |
| Whole-day cuti as status | Form status `Cuti`, day settings `isCuti`. | MIGRATE | Represent as `CLOSED` plus reason if supported. |

## 9. Local Persistence, Fallback, And Source-Of-Truth Risks

Current store risk areas:

| Risk | Evidence | Required migration |
|---|---|---|
| Singleton state store can preserve local truth independent of backend | `AmanahScheduleStore.instance` at `amanah_schedule_store.dart:12`. | Acceptable as cache only, not domain source. |
| Day setting fallback invents quota | `targetQuota: 8` at store line 65. | Remove fallback. |
| New schedule fallback invents time boundary | `startTime ?? '08:00'`, `endTime ?? '12:00'` at lines 280-281. | Remove fallback. |
| Save failure can keep optimistic local update | line 305. | Backend failure must be visible and local state must not masquerade as committed state. |
| `Buka Jadwal` in overview calls local `setDayCuti` | `amanah_schedule_tab_screen.dart:439`. | Must call backend mutation and refetch. |
| Loading patients enriches schedules client-side | Store `loadSchedulesForDate` starts at line 143 and fetches booked patients separately. | Backend should return interval/appointment references or a stable join contract. |

Flutter target rule:

```text
No backend data -> no fake domain schedule.
Backend rejection -> show domain error.
Backend success -> replace/refetch canonical schedule state.
```

## 10. Appointment Safety And Privacy Audit

Current mobile can display booked patient details:

- `BookedPatient` model begins at `amanah_schedule_model.dart:40`.
- It maps `fullName` / `patientName` at line 93.
- It maps `complaint` / `patientComplaint` at line 96.
- Patient detail modal begins at `amanah_schedule_cards_and_drawers.dart:1423`.
- Complaint block is rendered near `amanah_schedule_cards_and_drawers.dart:1705`.

Backend requirements:

| Topic | Requirement |
|---|---|
| Occupied interval | Return interval status `OCCUPIED` with an appointment reference. |
| Detail retrieval | Prefer dedicated appointment detail retrieval for sensitive data. |
| Field authorization | Backend must decide whether mobile user may see patient name, MR number, phone, complaint, notes, guardian data, or medical information. |
| Existing bookings | Backend must reject or safely handle schedule edits that would move, shorten, close, or delete availability containing active appointments. |
| Deletion | Existing conflict code `SCHEDULE_HAS_ACTIVE_BOOKINGS` is already represented in tests and should be preserved or evolved with structured details. |

Frontend must not implicitly move, delete, or orphan appointments by editing local schedule structures.

## 11. Current API Contract Assessment

Only existing routes observed in Flutter are listed here. New backend capabilities are described separately and are not asserted as existing routes.

| Method | Path | Current request | Current response consumer | Current meaning | Target semantic change |
|---|---|---|---|---|---|
| `GET` | `/api/v1/schedules/my-schedules` | Optional query date/range. | `DoctorSchedule.fromJson`. | Fetch doctor sessions/ranges. | Return canonical availability context/projection or data sufficient to render it without local generation. |
| `GET` | `/api/v1/schedules/calendar-summary` | `month=YYYY-MM`. | Calendar summary models. | Month indicators, cuti, quota/capacity. | Summary should align with `OPEN/OCCUPIED/CLOSED` and backend projection. |
| `GET` | `/api/v1/schedules/day-settings` | `date=YYYY-MM-DD`. | `DayScheduleSetting`. | Daily quota and `isCuti`. | Replace or evolve `isCuti`/quota semantics into backend-owned closure/config model. |
| `PUT` | `/api/v1/schedules/day-settings` | `date`, `targetQuota`, `isCuti`, `cutiReason`. | Store/day settings. | Doctor/day quota and leave mutation. | Clarify admin-only duration/config ownership; avoid `Cuti` as primary state. |
| `POST` | `/api/v1/schedules` | `date`, `specificDate`, `session`, `sessionType`, `startTime`, `endTime`, optional room/poli/service/capacity/status fields. | `DoctorSchedule`. | Create manual practice range. | Accept schedule context and arbitrary start intent; backend derives projection/end/capacity. |
| `PATCH` | `/api/v1/schedules/:id` | Optional `startTime`, `endTime`, `capacity`, `status`, `isAvailable`, room/poli/service/notes. | `DoctorSchedule`. | Update manual schedule range. | Appointment-safe update with structured conflict reasons. |
| `PATCH` | `/api/v1/schedules/:id/availability` | `{ isAvailable }`. | Store toggle. | Boolean availability toggle. | Replace/evolve into `OPEN/CLOSED` mutation with reason and conflict behavior. |
| `DELETE` | `/api/v1/schedules/:id` | Schedule ID. | Store removal. | Delete schedule. | Preserve active-booking protection; clarify close vs delete policy. |
| `GET` | `/api/v1/schedules/booked-patients` | `date` query. | `BookedPatient` list. | Fetch booked patients by date. | Prefer appointment references on occupied intervals and detail endpoint for authorized fields. |
| `GET` | `/api/v1/schedules/:id/booked-patients` | Schedule ID. | `BookedPatient` list. | Fetch booked patients for a schedule. | Same privacy/authorization requirement. |
| `GET` | `/api/v1/schedules/reference/rooms` | `date`, optional `startTime`, `endTime`. | Room selector. | Room availability for manually supplied range. | Evaluate using backend projection from date/context/start, not client-derived end. |
| `GET` | `/api/v1/schedules/reference/polikliniks` | None. | Poliklinik selector. | Active departments. | Preserve if still part of schedule context. |
| `GET` | `/api/v1/schedules/reference/options` | None. | `ClinicScheduleOptionsReference`. | Shifts, statuses, intervals. | Must include effective duration/config permissions/context boundaries or equivalent projection support. |

## 12. Backend Capabilities Flutter Needs

These are required capabilities. Backend may choose route names and DTO shape, but Flutter cannot correctly implement the target workflow without the semantics.

### 12.1 Effective duration resolution

Flutter needs:

```text
effectiveConsultationDurationMinutes
durationSource
durationEditableByCurrentUser
durationScope
```

Example semantic values:

```text
durationSource = CLINIC_CONFIG | PRACTITIONER_CONFIG | SERVICE_CONFIG | SCHEDULE_CONTEXT_CONFIG
durationScope = clinic-wide | practitioner-specific | service-specific | context-specific
durationEditableByCurrentUser = true | false
```

Flutter will use this to display duration and decide whether the duration field is read-only.

### 12.2 Schedule context and boundary

Flutter needs backend-owned schedule context data:

```text
contextId
contextLabel
date
practitionerId
boundaryStartTime
boundaryEndTime
allowedStartPrecisionMinutes or allowedStartPolicy
timezone
```

If clinic policy allows arbitrary minute input, backend should validate it. If policy restricts precision, backend must explicitly say so.

### 12.3 Projection from arbitrary start

Flutter needs backend projection for:

```text
selectedStartTime
effectiveConsultationDurationMinutes
sessionBoundaryEndTime
projectedIntervals[]
capacity
```

Required behavior:

```text
start = 08:45
duration = 30
intervals = 08:45-09:15, 09:15-09:45, 09:45-10:15, ...
```

No rounding to the nearest hour.

### 12.4 Persisted availability creation

Flutter needs create semantics like:

```text
date
scheduleContextId
startTime
optional room/service/poliklinik identifiers if still required
```

Backend response must include the canonical persisted availability and/or canonical projection.

Flutter should not send manually calculated `endTime` unless backend explicitly preserves it as a technical field while still deriving/validating it server-side.

### 12.5 Interval statuses

Each projected interval needs:

```text
intervalId or stable projection key
startTime
endTime
status: OPEN | OCCUPIED | CLOSED
displayLabel: Buka | Terisi | Tutup
appointmentRef when status = OCCUPIED and user is authorized
closedReason when status = CLOSED and reason is available
```

### 12.6 Appointment-safe mutations

Backend must define behavior for:

| Mutation | Required backend policy |
|---|---|
| Change start time | Reject if existing appointments would move without explicit backend-safe migration. |
| Change duration | Admin-only or configured authority; reject or safely handle occupied intervals. |
| Close availability | Reject or allow only unoccupied intervals, depending on clinic policy. |
| Delete schedule | Reject if active bookings exist, or provide explicit cancellation workflow outside this migration. |
| Change room/context | Validate against conflicts and active appointments. |

### 12.7 Structured conflict errors

Flutter needs structured backend errors for at least:

```text
APPOINTMENTS_ALREADY_EXIST
SCHEDULE_OVERLAP
ROOM_OVERLAP
START_OUTSIDE_BOUNDARY
DURATION_CONFIG_MISSING
DURATION_LEAVES_NO_CAPACITY
SCHEDULE_MODIFIED_CONCURRENTLY
PRACTITIONER_NOT_AUTHORIZED
DATE_CLOSED
INVALID_START_PRECISION
```

Each error should include a stable code, human-readable message, and relevant metadata such as conflicting schedule ID, boundary times, active booking count, or allowed precision.

### 12.8 Concurrency protection

Flutter needs one of:

```text
version
updatedAt precondition
ETag / If-Match
revision token
```

Without this, mobile cannot safely distinguish stale edits from current backend state.

## 13. Backend Availability Classification

| Capability | Current status from Flutter audit | Classification |
|---|---|---|
| Basic schedule list | Existing `GET /my-schedules`. | Already available, semantics need migration. |
| Basic create/update/delete | Existing `POST`, `PATCH`, `DELETE`. | Already available, contract semantically incorrect for target. |
| Active booking delete guard | Repository tests cover conflict code. | Already available or expected. Preserve. |
| Calendar summary | Existing endpoint. | Partially available. Needs target status semantics. |
| Day settings with quota/cuti | Existing endpoint. | Partially available but semantically mismatched. |
| Room/poliklinik references | Existing endpoints. | Partially available. Room query depends on manual end time. |
| Schedule options | Existing endpoint. | Partially available. Does not expose effective duration/projection contract. |
| Effective consultation duration | Not present in Flutter DTOs. | Missing. |
| Admin-controlled duration | Not represented in mobile contract. | Missing. |
| Arbitrary start projection | Not present. | Missing. |
| `OPEN/OCCUPIED/CLOSED` interval model | Not present. | Missing. |
| Appointment reference per occupied interval | Not present as interval-level contract. | Missing. |
| Privacy-scoped appointment detail retrieval | Patient details are directly modeled. | Partially available, needs authorization audit. |
| Appointment-safe update policy | Not encoded in Flutter contract. | Missing or under-specified. |
| Concurrency protection | Not observed. | Missing. |
| Removal of `Cuti` as primary state | Current mobile uses `Cuti`. | Semantically incorrect. |
| Removal of manual end-time ownership | Current mobile requires `endTime`. | Semantically incorrect. |

## 14. Frontend-Observed Database / Schema Problems

Flutter cannot prove the database schema, but the current API/DTO shape exposes these schema-level concerns:

| Observed problem | Why it matters |
|---|---|
| `endTime` appears mandatory for create/update. | Target says doctor should not manually calculate consultation end time. Backend should derive or validate it. |
| Effective consultation duration is absent. | Backend cannot produce stable projected intervals without a canonical duration source. |
| `capacity` and `targetQuota` exist but are not clearly tied to duration projection. | Capacity should derive from boundary/duration or be explicitly configured by backend. |
| `isCuti` exists as day setting and `Cuti` exists as UI status. | Leave should not duplicate primary availability state. |
| Boolean `isAvailable` is too coarse. | It cannot distinguish `OPEN`, `OCCUPIED`, and `CLOSED`. |
| Booked patient data is embedded broadly. | Occupied intervals should expose only permitted appointment references/details. |
| Room occupancy lookup depends on `startTime` and `endTime`. | If end is backend-derived, room availability should be evaluated by backend from projection/context. |
| No observed version/revision field. | Concurrent edits cannot be safely detected by Flutter. |

## 15. Required Flutter Migration After Backend Contract

Flutter should migrate only after backend provides the required contract.

### 15.1 Model layer

Modify:

- `packages/amanah_healthcare/lib/features/schedule/domain/amanah_schedule_model.dart`

Required changes:

- Add DTOs for backend schedule projection.
- Add effective duration fields returned by backend.
- Add interval model with `OPEN`, `OCCUPIED`, `CLOSED`.
- Replace primary `Cuti` status usage with `CLOSED` plus reason if backend returns it.
- Remove default domain fallbacks such as capacity `8` where backend must be authoritative.
- Avoid embedding full patient details inside every interval unless backend explicitly returns authorized fields.

### 15.2 Repository layer

Modify:

- `packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_repository.dart`

Required changes:

- Replace create/update payload shape once backend supports start-only creation.
- Stop sending client-derived `endTime` for target flow.
- Parse structured conflict metadata, not only message/code.
- Add projection/reference methods only after backend route names are finalized.
- Remove fallback `timeIntervals: [15, 30, 45, 60]` as production domain behavior.

### 15.3 Store/state layer

Modify:

- `packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart`

Required changes:

- Keep singleton `ChangeNotifier` pattern for now; do not introduce Riverpod/Bloc/GetX.
- Remove local domain fallbacks for quota/time/cuti.
- Remove optimistic committed schedule retention on failed save.
- Mutation flow must be:

```text
validate input
call API
receive canonical response
invalidate/refetch date/context schedule data
render backend result
```

### 15.4 Form layer

Modify:

- `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart`

Required changes:

- Replace manual `From`/`To` range entry with:

```text
Date
Schedule context
Start time
Effective consultation duration
Derived projection/capacity preview
Save
```

- Remove manual slot row add/remove as primary workflow.
- Allow arbitrary start time without hourly-only grid restriction unless backend policy says otherwise.
- Display duration as read-only unless backend says current user can edit it.
- Show backend projection preview if backend provides it.

### 15.5 Schedule rendering

Modify:

- `packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart`
- `packages/amanah_healthcare/lib/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart`
- `packages/amanah_healthcare/lib/features/home/presentation/components/amanah_schedule_card_stack.dart`

Required changes:

- Render projected intervals, not manually created slot ranges.
- Replace status badges with:

```text
OPEN -> Buka
OCCUPIED -> Terisi
CLOSED -> Tutup
```

- On `OCCUPIED`, allow authorized inspection through appointment reference/detail flow.
- Stop displaying synthetic capacity/slot text such as hardcoded patient counts.

### 15.6 Tests

Modify:

- `packages/amanah_healthcare/test/features/schedule/amanah_schedule_repository_test.dart`

Required tests after backend contract:

- Create availability sends date/context/start without client-calculated end.
- Arbitrary start `08:45` is preserved in request.
- No rounding from `08:45` to `09:00`.
- Backend projection response with duration `30` renders intervals anchored at start.
- `OPEN`, `OCCUPIED`, `CLOSED` map to `Buka`, `Terisi`, `Tutup`.
- Conflict errors surface backend domain code and message.
- Existing appointment conflicts do not result in local schedule mutation.
- Refetch reproduces the same schedule shown after mutation.

## 16. Web / Next.js Consumer Contract

No Next.js source was found in this repository. The web/admin frontend should consume the same backend projection contract as mobile.

Web/admin requirements:

- Do not implement a separate slot-generation algorithm in Next.js.
- Do not use `Penuh` as primary availability state.
- Render `OPEN`, `OCCUPIED`, `CLOSED` consistently with mobile.
- Admin detail sheet should render backend-projected intervals as a timeline/Gantt-style view.
- Admin duration editing should be enabled only when backend authorization says the admin can edit it.
- Web should not infer duration from hardcoded `30` or from mobile behavior.
- Web should inspect occupied interval appointments through backend-authorized references/details.

## 17. Implementation Order

No Flutter implementation should start until backend/domain decisions are settled.

Recommended order:

1. Backend defines effective duration ownership and authorization.
2. Backend defines schedule context/boundary contract.
3. Backend defines projection response for arbitrary start times.
4. Backend defines `OPEN/OCCUPIED/CLOSED` interval status contract.
5. Backend defines appointment-safe mutation and conflict errors.
6. Backend defines privacy-safe appointment reference/detail contract.
7. Flutter migrates DTO/model layer.
8. Flutter migrates repository request/response parsing.
9. Flutter migrates `AmanahScheduleStore` to canonical mutation/refetch flow.
10. Flutter redesigns schedule form around date/context/start/duration/projection.
11. Flutter migrates schedule cards/detail views to projected intervals.
12. Flutter removes obsolete manual slot/end-time/status fallbacks.
13. Flutter updates repository and widget tests.
14. Web/admin consumes the same backend projection contract.
15. Run regression tests for booking, schedule edit, deletion/closure, occupied interval display, and refresh consistency.

## 18. Acceptance Criteria

Migration is complete only when all criteria below are true:

- Doctor can enter an arbitrary valid start time.
- Doctor does not manually calculate or enter consultation end time.
- Effective consultation duration is not hardcoded in Flutter.
- Duration value comes from backend/domain configuration.
- Backend provides enough canonical data to render projected intervals.
- Flutter does not maintain a separate slot-generation truth.
- Refresh from backend reproduces exactly the same schedule.
- `Buka`, `Terisi`, and `Tutup` have unambiguous backend semantics.
- `Penuh` is not used as primary availability state.
- `Cuti` is not duplicated as top-level availability state.
- Occupied intervals expose only permitted appointment information.
- Schedule edit/delete/close actions cannot silently corrupt appointments.
- Backend conflict errors are displayed meaningfully.
- No production fallback creates fake duration, fake slots, fake quota, fake cuti, or fake schedule ranges.
- Mobile and web consume the same backend projection semantics.

## 19. Final Backend Request

Backend team should provide a v2 scheduling contract that answers these exact questions:

1. What is the authoritative source of consultation duration?
2. Who can change duration: doctor, admin, staff, or only system configuration?
3. Is duration clinic-wide, practitioner-specific, service-specific, or schedule-context-specific?
4. What schedule contexts can a practitioner choose on a given date?
5. What is the backend-owned upper boundary for each context?
6. Can practitioners start at arbitrary minutes, or is there a configured precision?
7. What endpoint or response produces projected intervals from date/context/start?
8. What persisted mutation creates availability without manual `endTime`?
9. What is the canonical interval status enum?
10. How is leave represented without top-level `Cuti` availability?
11. How does Flutter inspect an occupied interval's appointment safely?
12. What happens when existing appointments conflict with schedule edits?
13. What structured error codes and metadata will backend return?
14. What concurrency guard should Flutter send on update/delete?
15. Which old fields are backward-compatible during migration, and which must be removed?

Until these are answered, Flutter should not compensate with local calculations or fallback domain rules.
