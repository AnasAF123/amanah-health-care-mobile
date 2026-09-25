# Amanah Healthcare — Schedule Management API Contract Specification

> **Auto-Generated Manifest for Mobile & Frontend Engineers**  
> **Generation Timestamp:** `2026-09-25T06:25:01.024Z`  
> **Target Base URL:** `http://localhost:3001/api/v1`  
> **Environment:** Docker Production/Dev Container (`amanah-healthcare-backend-api-1`)  
> **Showcase Doctor:** `dr. Ahmadamikom Zikri` (`c518facb-372e-4f07-9766-f3eacf54221f`)  
> **Showcase Session:** `936833d1-8c2d-4f27-89bd-5f811e833859`

---

## Ringkasan Eksekutif & Prinsip Arsitektur

Dokumen ini adalah **spesifikasi kontrak API terlengkap** untuk seluruh modul **Schedule Management**, **Referensi Opsi**, **Proyeksi Slot Dinamis**, **Alur Reschedule Otomatis**, dan **Manajemen Pasien Sesi**.

### 1. Prinsip Paritas Mobile & Web Admin (Canonical Parity)
- Dokter di Mobile App dan Admin di Web App menggunakan **endpoint kanonikal bersama** di bawah rute `/api/v1/schedules/...`.
- Dokter memiliki kepemilikan penuh (*ownership guard*) terhadap jadwal praktiknya sendiri.
- Endpoint supervisi khusus `/api/v1/admin/doctor-schedules/...` juga dapat diakses oleh dokter pemilik jadwal tanpa penolakan hak akses (*Doctor Self-Supervision*).

### 2. Otomasi Kalkulasi Slot Dinamis (Dynamic Slot Derivation)
- **Tanpa Hardcoding 6 Jam:** Setiap sesi memiliki durasi per slot berbasis `practitioner.consultationDurationMinutes` (default **30 menit** dari database).
- **Rumus Kapasitas Dinamis:**
  $$\text{Kapasitas Slot} = \frac{\text{Batas Akhir Shift} - \text{Jam Mulai}}{\text{Durasi Konsultasi (30m)}}$$
  *Contoh:* Dokter memulai shift pagi jam `10:00` (batas shift `12:00`) -> Durasi $120\text{ menit} \div 30\text{ menit} = \mathbf{4\text{ slot}}$. Jam selesai otomatis diproyeksikan ke **`12:00` WIB** (bukan 16:00).
- Jika ada 2 pasien aktif, 2 pasien menempati 2 slot pertama (`10:00-10:30` dan `10:30-11:00`), menyisakan 2 slot terbuka (`availableSlots = 2`).

### 3. Autentikasi & Header Permintaan
Semua request terproteksi wajib menyertakan token JWT pada header HTTP:
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```

---

## Daftar Endpoint Kanonikal

### 1. Master & Referensi
- `GET /api/v1/schedules/reference/options` -> Shifts (4 shift 24 jam), status kanonikal (OPEN, CLOSED), interval (30m), durasi konsultasi efektif.
- `GET /api/v1/schedules/reference/rooms?date=YYYY-MM-DD&startTime=HH:mm&endTime=HH:mm` -> Ruang praktik & real-time occupancy.
- `GET /api/v1/schedules/reference/polikliniks` -> Poliklinik aktif (Poli Umum, KIA, dll).
- `GET /api/v1/clinical/practitioners?date=YYYY-MM-DD` -> Public booking dokter.

### 2. Konteks Shift & Proyeksi Slot Dinamis
- `GET /api/v1/schedules/contexts?date=YYYY-MM-DD` -> 4 siklus shift (early_morning, morning, afternoon, night) & boundary waktu.
- `GET /api/v1/schedules/projection?date=YYYY-MM-DD&startTime=HH:mm&scheduleContextId=<shift>` -> Preview proyeksi slot dinamis berbasis jam mulai arbitrer. (Wajib `scheduleContextId`).
- `GET /api/v1/schedules/occupancy-overview?date=YYYY-MM-DD` -> Anti-collision 24h occupancy grid 4 shift.

### 3. Jadwal Dokter & Kalender
- `GET /api/v1/schedules/my-schedules?date=YYYY-MM-DD` -> Sesi dinas dokter login (kapasitas, slot tersedia, pasien booked, status, isRescheduleEligible).
- `GET /api/v1/schedules/calendar-summary?month=YYYY-MM` -> Ringkasan 1 bulan kalender (dots indicator: hasSchedule, isCuti, targetQuota, bookedPatientCount, capacityPercentage, status).
- `GET /api/v1/schedules/day-settings?date=YYYY-MM-DD` -> Target kuota harian & status cuti dokter.
- `PUT /api/v1/schedules/day-settings` -> Upsert target kuota harian & status cuti (`date`, `targetQuota`, `isCuti`, `cutiReason`).
- `PATCH /api/v1/schedules/days/:date` -> Buka / Tutup seluruh jadwal harian cascading (`status: "OPEN"|"CLOSED"`, `notes`).
- `POST /api/v1/schedules/availability` -> Buat sesi instan (tanpa input jam selesai manual: `date`, `scheduleContextId`, `startTime`, `roomId`, `poliklinikId`).
- `POST /api/v1/schedules` -> Buat jadwal custom (`date`, `session`, `startTime`, `endTime`, `capacity`, `roomId`, `poliklinikId`).
- `GET /api/v1/schedules/:id` -> Detail sesi jadwal.
- `PATCH /api/v1/schedules/:id` -> Update sesi jadwal (`startTime`, `endTime`, `capacity`, `notes`, dll).
- `PATCH /api/v1/schedules/:id/availability` -> Toggle penerimaan pasien sesi (`isAvailable: true/false`).
- `DELETE /api/v1/schedules/:id` -> Hapus sesi bebas pasien.

### 4. Interaksi Pasien dalam Sesi Jadwal (Canonical Routes)
- `GET /api/v1/schedules/sessions/:sessionId/patients` -> Daftar pasien sesi terpilih (Nama, NIK, No. RM, No Antrean, Jam Slot, Keluhan, Kontak Wali, Status Kunjungan).
- `PATCH /api/v1/appointments/:appointmentId/call` -> Panggil pasien (Status: SEDANG_DIPERIKSA, update TV monitor & push notif).
- `PATCH /api/v1/appointments/:appointmentId/complete` -> Selesaikan pemeriksaan (Status: SELESAI).
- `PATCH /api/v1/appointments/:appointmentId/cancel` -> Batalkan janji temu (`reason`: string).

### 5. Reschedule Sesi & Auto-Shift Pasien (Canonical Routes)
- `GET /api/v1/schedules/sessions/:sessionId/reschedule-eligibility?targetDate=YYYY-MM-DD&targetStartTime=HH:mm&targetRoomId=...` -> Pre-check kelayakan reschedule & simulasi slot target dinamis.
- `POST /api/v1/schedules/sessions/:sessionId/reschedule` -> Eksekusi reschedule sesi & auto-shift pasien aktif:
  Body:
  ```json
  {
    "targetDate": "2026-09-27",
    "targetStartTime": "08:00",
    "targetEndTime": "11:00",
    "targetRoomId": "b77d141b-2fa5-4481-9f47-a5a040faf57a",
    "rescheduleActiveAppointments": true,
    "reason": "Dokter menghadiri konferensi medis"
  }
  ```
