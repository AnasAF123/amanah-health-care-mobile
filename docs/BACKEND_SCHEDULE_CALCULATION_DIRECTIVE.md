# ARCHITECTURAL DIRECTIVE & TECHNICAL REPRIMAND

**TO:** Core Backend Engineering Team (API & Scheduling Services)  
**FROM:** Mobile Engineering & Client Platform Team  
**DATE:** September 24, 2026  
**STATUS:** CRITICAL / NON-NEGOTIABLE  
**SUBJECT:** Immediate Migration of Schedule Time-Interval Calculations, Capacity Slicing, and Shift Boundary Validation from Client to Backend (Single Source of Truth)

---

## 1. Executive Summary & Root Cause

The frontend team is issuing this formal engineering reprimand regarding the current scheduling implementation. 

Forcing client applications (Mobile and Web) to perform time-interval calculations (e.g., projecting `01:00 -> 01:30`, `01:30 -> 02:00`, calculating shift capacity, and enforcing session boundary clamps) is a **severe architectural violation**.

The frontend is strictly a **consumer and presentation layer**. The client does not own domain policies, database configurations, or operational boundaries. Any arithmetic regarding consultation durations, interval slicing, and shift constraints **belongs exclusively to the backend service**.

---

## 2. Architectural Violations

The current expectation that client applications should compute schedule intervals violates fundamental software engineering principles:

1. **Violation of Single Source of Truth (SSOT):**
   - The consultation duration policy lives in PostgreSQL (`practitioners.consultation_duration_minutes`, default `30`, configurable by clinic admins).
   - The shift boundaries (`00:00-06:00`, `06:00-12:00`, `12:00-17:00`, `17:00-21:00`) reside in the database.
   - Forcing clients to mirror these variables and calculate intervals locally results in split-brain domain logic.

2. **Violation of Don't Repeat Yourself (DRY):**
   - Duplicating time-slicing arithmetic across Flutter Mobile (Android/iOS), React Web Admin, and Patient Web Portals guarantees desynchronization bugs, timezone discrepancies, and booking collisions.

3. **Violation of Separation of Concerns (SoC) & Security:**
   - Client-side calculation allows malicious or malformed client payloads to bypass capacity limits, overlap existing sessions, or write invalid time ranges directly into persistence.
   - All validation and projections must be authoritative and server-enforced.

---

## 3. Authoritative Domain Formula (Backend Responsibility)

The backend service **MUST** perform all scheduling projections using the practitioner's active database policy and shift definitions:

$$\text{Available Minutes} = \text{Shift Boundary End Time} - \text{Selected Start Time}$$

$$\text{Total Capacity (Slots)} = \left\lfloor \frac{\text{Available Minutes}}{\text{Consultation Duration Minutes}} \right\rfloor$$

$$\text{Projected End Time} = \text{Selected Start Time} + (\text{Total Capacity} \times \text{Consultation Duration Minutes})$$

### Concrete Example:
- **Practitioner Consultation Duration:** `30 minutes` (from DB)
- **Session:** Shift Pagi (Boundary: `06:00 - 12:00 WIB`)
- **Doctor inputs Start Time:** `08:45`

The backend must calculate:
1. Available duration: `12:00 - 08:45` = `195 minutes`
2. Total valid slots: $\lfloor 195 / 30 \rfloor = 6\text{ slots}$
3. Calculated End Time: $08:45 + (6 \times 30\text{ min}) = 11:45\text{ WIB}$ (remaining 15 minutes discarded, not forced)
4. Discrete Interval Array:
   - Slot 1: `08:45 - 09:15`
   - Slot 2: `09:15 - 09:45`
   - Slot 3: `09:45 - 10:15`
   - Slot 4: `10:15 - 10:45`
   - Slot 5: `10:45 - 11:15`
   - Slot 6: `11:15 - 11:45`

---

## 4. Required API Specifications & Contracts

### A. Real-Time Schedule Projection Endpoint
The client will send **ONLY** what the doctor specifies. The backend returns the computed projection and interval list.

`GET /api/v1/schedules/projection`

#### Query Parameters:
```http
GET /api/v1/schedules/projection?date=2026-09-24&scheduleContextId=ctx-morning&startTime=08:45&roomId=room-101&poliklinikId=poli-umum
```

#### Authoritative Backend Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "date": "2026-09-24",
    "scheduleContextId": "ctx-morning",
    "contextLabel": "Sesi Pagi",
    "selectedStartTime": "08:45",
    "projectedEndTime": "11:45",
    "effectiveConsultationDurationMinutes": 30,
    "capacity": 6,
    "shiftBoundary": {
      "startTime": "06:00",
      "endTime": "12:00"
    },
    "intervals": [
      {
        "intervalIndex": 1,
        "startTime": "08:45",
        "endTime": "09:15",
        "status": "OPEN",
        "displayLabel": "08:45 - 09:15 WIB",
        "isOccupied": false
      },
      {
        "intervalIndex": 2,
        "startTime": "09:15",
        "endTime": "09:45",
        "status": "OPEN",
        "displayLabel": "09:15 - 09:45 WIB",
        "isOccupied": false
      },
      {
        "intervalIndex": 3,
        "startTime": "09:45",
        "endTime": "10:15",
        "status": "OPEN",
        "displayLabel": "09:45 - 10:15 WIB",
        "isOccupied": false
      },
      {
        "intervalIndex": 4,
        "startTime": "10:15",
        "endTime": "10:45",
        "status": "OPEN",
        "displayLabel": "10:15 - 10:45 WIB",
        "isOccupied": false
      },
      {
        "intervalIndex": 5,
        "startTime": "10:45",
        "endTime": "11:15",
        "status": "OPEN",
        "displayLabel": "10:45 - 11:15 WIB",
        "isOccupied": false
      },
      {
        "intervalIndex": 6,
        "startTime": "11:15",
        "endTime": "11:45",
        "status": "OPEN",
        "displayLabel": "11:15 - 11:45 WIB",
        "isOccupied": false
      }
    ]
  }
}
```

---

### B. Standardized Boundary & Validation Error Codes
If a doctor attempts to submit a start time that exceeds the shift boundary or does not leave room for at least one full consultation slot:

`HTTP 409 CONFLICT` or `HTTP 422 UNPROCESSABLE ENTITY`

```json
{
  "statusCode": 409,
  "code": "START_OUTSIDE_BOUNDARY",
  "message": "Jam mulai berada di luar batas waktu shift yang dipilih (06:00 - 12:00 WIB).",
  "details": {
    "boundaryStartTime": "06:00",
    "boundaryEndTime": "12:00",
    "minimumRequiredDurationMinutes": 30
  }
}
```

---

### C. Create Schedule Availability Endpoint
`POST /api/v1/schedules/availability`

#### Request Payload (Client):
```json
{
  "date": "2026-09-24",
  "scheduleContextId": "ctx-morning",
  "startTime": "08:45",
  "roomId": "room-101",
  "poliklinikId": "poli-umum"
}
```

Notice that the client **does not submit `endTime` or `capacity`**. The backend derives both authoritatively and persists the record.

#### Backend Response (`201 CREATED`):
```json
{
  "id": "sched-20260924-001",
  "scheduleDate": "2026-09-24",
  "sessionShift": "morning",
  "sessionLabel": "Sesi Pagi",
  "startTime": "08:45",
  "endTime": "11:45",
  "timeRange": "08:45 - 11:45 WIB",
  "poliklinikId": "poli-umum",
  "poliklinikName": "Poli Umum",
  "roomId": "room-101",
  "roomName": "Ruang 101",
  "capacity": 6,
  "bookedPatientCount": 0,
  "isAvailable": true,
  "status": "Buka"
}
```

---

## 5. Mandatory Action Items for Backend

1. **Implement Server-Side Interval Calculator:**
   Remove all reliance on client-submitted `endTime` or slot slicing.
2. **Expose `GET /api/v1/schedules/projection`:**
   Ensure this endpoint dynamically computes the interval projection on the fly given `date`, `scheduleContextId`, and `startTime`.
3. **Enforce Database Policy Dynamic Lookup:**
   Always query `practitioners.consultation_duration_minutes` for the authenticated doctor. Do not hardcode 30 minutes in SQL or server code.
4. **Boundary Validation:**
   Reject any schedule creation where `startTime + duration > shift.endTime`.

---
*Signed,*  
**Mobile Engineering & Architecture Team**  
*Amanah Healthcare Platform*
