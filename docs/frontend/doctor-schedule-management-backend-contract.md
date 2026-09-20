# Kontrak API & Panduan Sinkronisasi: Manajemen Jadwal Dokter (Doctor Schedule Management)

**Dokumen Referensi:** Feature Backend Requirement Delegation Report  
**Target Platform:** Flutter Mobile (`amanah-healthcare-mobile`) & NestJS Backend (`Amanah-healthcare-backend`)  
**Status:** Backend Siap & Terverifikasi (Hardened with Authentication & Ownership Shield)  
**Versi:** 1.0.0  
**Tanggal:** 2026-09-21  

---

## 1. Ringkasan Eksekutif & Penyelarasan Autentikasi

Sebelumnya, modul **Jadwal Dokter** dirancang pada saat Flutter Mobile masih beroperasi secara *offline/mock* tanpa autentikasi. Sekarang, sistem autentikasi mobile telah terhubung penuh menggunakan **Better Auth** dan **Bearer Session Token**.

### Perubahan Paradigma Utama:
1. **Peniadaan Mock ID:**
   - Flutter **tidak perlu lagi mengirimkan hardcoded `staffId: 'doc-001'`**.
   - Backend melalui [`HybridAuthGuard`](file:///D:/Amanah-healthcare-backend/src/common/auth/hybrid-auth.guard.ts) secara otomatis mengekstrak identitas dokter dari token sesi (`req.user.staff.practitionerId` dan `req.user.staff.id`).
2. **Perlindungan Kepemilikan & Multi-Tenancy (Doctor Isolation Shield):**
   - Dokter yang sedang login **hanya berhak** melihat, membuat, mengubah, menonaktifkan, menghapus, serta memeriksa pasien janji temu pada **jadwal miliknya sendiri**.
   - Percobaan memanipulasi atau membaca pasien pada jadwal dokter lain otomatis ditolak dengan `403 Forbidden` (`Akses ditolak: Anda hanya berwenang mengelola jadwal praktek Anda sendiri`).
3. **Pemberantasan Kebocoran Akun Default:**
   - Fallback lama di backend yang mengembalikan dokter acak jika profil praktisi tidak ditemukan telah **dihapus sepenuhnya**. Jika user tidak memiliki profil staf medis terdaftar, backend merespons error `403 Forbidden` atau array kosong secara aman.
4. **Perlindungan Integritas Booking (Anti-Accidental Deletion):**
   - Jadwal yang telah memiliki pasien terdaftar (`status: booked, checked_in, waiting, in_service`) **tidak dapat dihapus secara sepihak**. Backend akan menolak dengan status `409 Conflict` bersandi `SCHEDULE_HAS_ACTIVE_BOOKINGS`.

---

## 2. Base URL & Header Standar

- **Base URL:**
  - Android Emulator: `http://10.0.2.2:3001/api/v1`
  - iOS Simulator / Real Device / Web: `http://localhost:3001/api/v1` (atau domain server klinik)
- **Header Wajib untuk Seluruh Endpoint:**
  ```http
  Authorization: Bearer <better_auth_session_token>
  Content-Type: application/json
  Accept: application/json
  ```

---

## 3. Matriks Endpoint Jadwal Dokter

| Metode | Path Endpoint | Peruntukan di UI Mobile | Role yang Diizinkan |
| :--- | :--- | :--- | :--- |
| `GET` | `/schedules/my-schedules` | Tab "Jadwal", Carousel Strip harian, & Sessions View | `STAF`, `ADMIN` |
| `GET` | `/schedules/calendar-summary` | Drawer Kalender Bulanan (`AmanahDocScheduleCalendarDrawer`) | `STAF`, `ADMIN` |
| `GET` | `/schedules/day-settings` | Indikator Kapasitas Radial & Banner Cuti | `STAF`, `ADMIN` |
| `PUT` | `/schedules/day-settings` | Toggle Cuti ("Buka Jadwal") & Update Target Kuota | `STAF`, `ADMIN` |
| `POST` | `/schedules` | Drawer "Tambah Jadwal" (`AmanahAddEditScheduleDrawer`) | `STAF`, `ADMIN` |
| `PATCH` | `/schedules/:id` | Drawer "Edit Jadwal" (Ubah jam, ruangan, kuota, poli) | `STAF`, `ADMIN` |
| `DELETE` | `/schedules/:id` | Hapus Sesi Praktek (dengan validasi booking aktif) | `STAF`, `ADMIN` |
| `PATCH` | `/schedules/:id/availability` | Toggle cepat status Buka / Tutup jadwal | `STAF`, `ADMIN` |
| `GET` | `/schedules/booked-patients` | Daftar pasien terdaftar harian pada Overview Tab | `STAF`, `ADMIN` |
| `GET` | `/schedules/:id/booked-patients` | Daftar pasien spesifik per sesi praktek | `STAF`, `ADMIN` |
| `GET` | `/schedules/reference/rooms` | Pilihan Ruang Praktek & Pengecekan Okupansi Real-time | `ADMIN`, `STAF`, `PATIENT` |
| `GET` | `/schedules/reference/polikliniks` | Pilihan Unit Poliklinik aktif untuk dropdown form | `ADMIN`, `STAF`, `PATIENT` |

---

## 4. Spesifikasi Kontrak Detail & Payload

### 4.1. Mendapatkan Jadwal Dokter Login (`GET /schedules/my-schedules`)
Digunakan oleh Overview Tab dan Sessions View untuk menampilkan daftar sesi kerja dokter.

- **Query Parameters:**
  - `date` *(opsional)*: Filter tanggal spesifik (`YYYY-MM-DD`, contoh: `2026-08-26`).
  - `startDate` *(opsional)*: Tanggal awal rentang (`YYYY-MM-DD`).
  - `endDate` *(opsional)*: Tanggal akhir rentang (`YYYY-MM-DD`).
- **Response `200 OK`:**
  ```json
  [
    {
      "id": "67212c38-ca4a-45f8-b9bc-ebe2fd82b0a1",
      "staffId": "practitioner-uuid-1",
      "staffName": "dr. Sarah Jenkins, Sp.A",
      "profession": "Dokter Spesialis Anak",
      "scheduleDate": "2026-08-26",
      "specificDate": "2026-08-26",
      "poliklinikId": "cd44dd7d-07a9-4e31-9441-3e0e02ddebb1",
      "poliklinikName": "Poli Anak & Tumbuh Kembang",
      "session": "PAGI",
      "sessionLabel": "Pagi",
      "sessionShift": "morning",
      "startTime": "07:00",
      "endTime": "11:00",
      "timeRange": "07:00 - 11:00 WIB",
      "roomId": "room-uuid-201",
      "roomName": "Ruang 201",
      "capacity": 8,
      "availableSlots": 5,
      "bookedPatientCount": 3,
      "status": "Buka",
      "rawStatus": "open",
      "isAvailable": true,
      "notes": "Praktek poli reguler"
    }
  ]
  ```

---

### 4.2. Ringkasan Kalender Bulanan (`GET /schedules/calendar-summary`)
Digunakan oleh `AmanahDocScheduleCalendarDrawer` untuk me-render titik indikator (ada jadwal, sedang cuti, kapasitas) pada grid tanggal satu bulan penuh.

- **Query Parameters:**
  - `month` *(wajib)*: Format `YYYY-MM` (contoh: `2026-08`).
- **Response `200 OK`:**
  ```json
  {
    "month": "2026-08",
    "days": [
      {
        "date": "2026-08-26",
        "hasSchedule": true,
        "isCuti": false,
        "cutiReason": null,
        "sessionCount": 2,
        "targetQuota": 8,
        "bookedPatientCount": 6,
        "capacityPercentage": 75
      },
      {
        "date": "2026-08-27",
        "hasSchedule": false,
        "isCuti": true,
        "cutiReason": "Dokter Cuti Praktik: Simposium Pediatri",
        "sessionCount": 0,
        "targetQuota": 0,
        "bookedPatientCount": 0,
        "capacityPercentage": 0
      }
    ]
  }
  ```

---

### 4.3. Pengaturan Harian & Cuti Dokter (`GET` & `PUT /schedules/day-settings`)
Digunakan oleh Radial Capacity Gauge dan Alert Banner Cuti di Overview Tab.

#### A. Mengambil Pengaturan (`GET /schedules/day-settings?date=2026-08-26`)
- **Response `200 OK`:**
  ```json
  {
    "id": "setting-uuid-1",
    "practitionerId": "practitioner-uuid-1",
    "scheduleDate": "2026-08-26",
    "targetQuota": 8,
    "isCuti": false,
    "cutiReason": null,
    "totalBookedPatients": 6,
    "capacityPercentage": 75
  }
  ```

#### B. Mengubah Pengaturan / Buka Jadwal Cuti (`PUT /schedules/day-settings`)
- **Request Body:**
  ```json
  {
    "date": "2026-08-26",
    "targetQuota": 10,
    "isCuti": false,
    "cutiReason": null
  }
  ```
- **Response `200 OK`:** Mengembalikan entitas `DayScheduleSetting` yang telah diperbarui.

---

### 4.4. Menambahkan Sesi Jadwal Baru (`POST /schedules`)
Dipanggil saat dokter menekan "Tambah Jadwal" di `AmanahAddEditScheduleDrawer`.

- **Request Body:**
  ```json
  {
    "date": "2026-08-26",
    "sessionType": "Pagi",
    "startTime": "07:00",
    "endTime": "11:00",
    "roomId": "room-uuid-201",
    "poliklinikId": "cd44dd7d-07a9-4e31-9441-3e0e02ddebb1",
    "capacity": 8,
    "isAvailable": true,
    "notes": "Praktek pagi reguler"
  }
  ```
- **Response `201 Created`:** Mengembalikan objek `ScheduleEntity` lengkap dengan ID unik dari server.
- **Validasi Server:**
  - Menolak jika `startTime >= endTime` (`409 INVALID_TIME_RANGE`).
  - Menolak jika dokter sudah memiliki sesi lain yang bertubrukan pada jam tersebut (`409 PRACTITIONER_ALREADY_SCHEDULED`).
  - Menolak jika ruangan yang dipilih sudah dipesan dokter lain (`409 ROOM_ALREADY_OCCUPIED`).

---

### 4.5. Memperbarui Sesi Jadwal (`PATCH /schedules/:id`)
Dipanggil saat dokter menekan "Simpan Perubahan" di edit drawer.

- **Request Body:**
  ```json
  {
    "sessionType": "Siang",
    "startTime": "13:00",
    "endTime": "17:00",
    "roomId": "room-uuid-202",
    "capacity": 10,
    "status": "Buka",
    "notes": "Penambahan kuota konsultasi"
  }
  ```
- **Response `200 OK`:** Objek jadwal yang telah diperbarui.

---

### 4.6. Menghapus Sesi Jadwal (`DELETE /schedules/:id`)
Dipanggil saat dokter menekan tombol "Hapus" pada sesi jadwal.

- **Response `204 No Content`:** Jika jadwal berhasil dihapus.
- **Perlindungan Booking Aktif (`409 Conflict`):**
  Jika jadwal telah memiliki pasien terdaftar, backend membatalkan aksi hapus:
  ```json
  {
    "code": "SCHEDULE_HAS_ACTIVE_BOOKINGS",
    "message": "Jadwal tidak dapat dihapus karena sudah memiliki 3 pasien terdaftar. Batalkan atau jadwalkan ulang janji temu pasien terlebih dahulu."
  }
  ```

---

### 4.7. Mengambil Pasien Janji Temu (`GET /schedules/booked-patients` & `/schedules/:id/booked-patients`)
Digunakan oleh `AmanahBookedPatientCard` dan modal `AmanahPatientDetailModal`.

- **Response `200 OK`:**
  ```json
  [
    {
      "id": "patient-profile-uuid-1",
      "appointmentId": "apt-uuid-001",
      "fullName": "Ny. Siti Rahmawati",
      "medicalRecordNumber": "RM-2026-0412",
      "age": "28 Thn",
      "gender": "Perempuan",
      "queueNumber": "#01",
      "timeSlot": "08:00 - 09:30 WIB",
      "sessionTitle": "Sesi Pagi",
      "room": "Ruang 201",
      "guardian": "Bpk. Budi Sanjaya (Suami)",
      "complaint": "Demam tinggi sejak 2 hari yang lalu disertai batuk kering dan nafsu makan menurun.",
      "status": "waiting",
      "statusBadge": "Menunggu",
      "avatarUrl": null
    }
  ]
  ```

---

### 4.8. Referensi Ruangan & Poliklinik (Dropdown Pilihan)
Untuk mengisi opsi dropdown pada form tambah/edit jadwal secara dinamis:

#### A. Referensi Ruangan dengan Deteksi Okupansi Real-time:
`GET /schedules/reference/rooms?date=2026-08-26&startTime=07:00&endTime=11:00`
- **Response `200 OK`:**
  ```json
  [
    {
      "id": "room-uuid-201",
      "code": "R-201",
      "name": "Ruang 201",
      "location": "Lantai 2, Sayap Barat",
      "floor": "2",
      "isOccupied": true,
      "occupiedBy": "dr. Sarah Jenkins, Sp.A (07:00 - 11:00 WIB)"
    },
    {
      "id": "room-uuid-202",
      "code": "R-202",
      "name": "Ruang 202",
      "location": "Lantai 2, Sayap Timur",
      "floor": "2",
      "isOccupied": false,
      "occupiedBy": null
    }
  ]
  ```
  *Opsi yang memiliki `isOccupied == true` dapat langsung di-disable di UI selection sheet mobile.*

#### B. Referensi Unit Poliklinik Aktif:
`GET /schedules/reference/polikliniks`
- **Response `200 OK`:**
  ```json
  [
    {
      "id": "cd44dd7d-07a9-4e31-9441-3e0e02ddebb1",
      "code": "POLI-ANAK",
      "name": "Poli Anak & Tumbuh Kembang",
      "location": "Lantai 2"
    },
    {
      "id": "7fa1249b-993a-4b92-811c-1a2202bbebb9",
      "code": "POLI-GIGI",
      "name": "Poli Gigi & Mulut",
      "location": "Lantai 1"
    }
  ]
  ```

---

## 5. Panduan Transisi untuk Flutter Mobile Developer (`AmanahScheduleStore`)

Di repository Flutter (`packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart`), data jadwal saat ini masih tersimpan dalam `Map<String, List<DoctorSchedule>> _schedulesMap` statis di memori.

### Langkah Rekomendasi Sinkronisasi:
1. Buat class `AmanahScheduleRepository` yang menginjeksi `http.Client` dan `AmanahAuthTokenStorage`.
2. Pada `AmanahScheduleStore`:
   - Ganti inisialisasi mock data dengan pemanggilan API:
     - `fetchSchedulesForDate(DateTime date)` ➔ `GET /api/v1/schedules/my-schedules?date=YYYY-MM-DD`
     - `fetchDaySettings(DateTime date)` ➔ `GET /api/v1/schedules/day-settings?date=YYYY-MM-DD`
     - `fetchCalendarSummary(String month)` ➔ `GET /api/v1/schedules/calendar-summary?month=YYYY-MM`
     - `addSchedule(DoctorSchedule schedule)` ➔ `POST /api/v1/schedules`
     - `updateSchedule(DoctorSchedule schedule)` ➔ `PATCH /api/v1/schedules/:id`
     - `deleteSchedule(String scheduleId)` ➔ `DELETE /api/v1/schedules/:id`
     - `setDayCuti(DateTime date, bool isCuti)` ➔ `PUT /api/v1/schedules/day-settings`
3. Tangani Error `409 Conflict`:
   - Tangkap kode error `SCHEDULE_HAS_ACTIVE_BOOKINGS`, `ROOM_ALREADY_OCCUPIED`, atau `PRACTITIONER_ALREADY_SCHEDULED` untuk menampilkan dialog peringatan informatif bagi dokter.
