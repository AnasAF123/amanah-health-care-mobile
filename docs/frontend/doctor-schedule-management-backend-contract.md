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
| `GET` | `/schedules/reference/options` | Master shifts, status sesi, dan durasi interval waktu | `ADMIN`, `STAF`, `PATIENT` |

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

#### C. Referensi Opsi Konfigurasi Sesi (Shifts, Statuses, & Time Intervals):
`GET /schedules/reference/options`
- **Response `200 OK`:**
  ```json
  {
    "shifts": [
      {
        "id": "PAGI",
        "label": "Pagi",
        "shift": "morning",
        "startTime": "07:00",
        "endTime": "12:00"
      },
      {
        "id": "SIANG",
        "label": "Siang",
        "shift": "afternoon",
        "startTime": "12:00",
        "endTime": "17:00"
      },
      {
        "id": "MALAM",
        "label": "Malam",
        "shift": "night",
        "startTime": "17:00",
        "endTime": "21:00"
      }
    ],
    "statuses": [
      { "id": "open", "label": "Buka" },
      { "id": "closed", "label": "Tutup" },
      { "id": "pending", "label": "Menunggu" }
    ],
    "timeSlotIntervals": [15, 30, 45, 60]
  }
  ```
  *Memungkinkan Flutter dan Web mengeliminasi seluruh list hardcoded dan menyelaraskan validasi shift serta durasi sesi secara terpusat.*

---

## 5. Panduan Transisi untuk Flutter Mobile Developer (`AmanahScheduleStore`)

Di repository Flutter (`packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_store.dart`), data jadwal saat ini masih tersimpan dalam `Map<String, List<DoctorSchedule>> _schedulesMap` statis di memori.

### Langkah Rekomendasi Sinkronisasi:
1. **Pemanfaatan Repository yang Sudah Tersedia:**
   Class `AmanahScheduleRepository` telah siap di `packages/amanah_healthcare/lib/features/schedule/data/amanah_schedule_repository.dart`.
2. **Pada `AmanahScheduleStore`:**
   - Sambungkan method-method store ke API:
     - `fetchSchedulesForDate(DateTime date)` ➔ `GET /api/v1/schedules/my-schedules?date=YYYY-MM-DD`
     - `fetchDaySettings(DateTime date)` ➔ `GET /api/v1/schedules/day-settings?date=YYYY-MM-DD`
     - `fetchCalendarSummary(String month)` ➔ `GET /api/v1/schedules/calendar-summary?month=YYYY-MM`
     - `addSchedule(DoctorSchedule schedule)` ➔ `POST /api/v1/schedules`
     - `updateSchedule(DoctorSchedule schedule)` ➔ `PATCH /api/v1/schedules/:id`
     - `deleteSchedule(String scheduleId)` ➔ `DELETE /api/v1/schedules/:id`
     - `setDayCuti(DateTime date, bool isCuti)` ➔ `PUT /api/v1/schedules/day-settings`
3. **Penanganan Multi-Slot Saat Pembuatan Jadwal:**
   - Pada form `AmanahAddEditScheduleDrawer`, jika dokter menambahkan beberapa slot waktu sekaligus, UI dapat mengirimkan request `POST /api/v1/schedules` untuk setiap entri slot waktu secara terpisah (atau batching), karena di database setiap sesi praktek adalah satu record sesi yang independen.
4. **Tangani Error `409 Conflict`:**
   - Tangkap kode error:
     - `SCHEDULE_HAS_ACTIVE_BOOKINGS`: Tampilkan dialog "Tidak dapat menghapus jadwal karena telah ada pasien terdaftar. Silakan batalkan atau alihkan janji temu pasien terlebih dahulu."
     - `ROOM_ALREADY_OCCUPIED`: Tampilkan pesan "Ruangan telah digunakan oleh dokter lain pada jam tersebut."
     - `PRACTITIONER_ALREADY_SCHEDULED`: Tampilkan pesan "Anda sudah memiliki jadwal praktek lain pada rentang waktu ini."

---

## 6. Jawaban Resmi atas 5 Pertanyaan Terbuka Arsitektural (Open Questions Resolution)

Berdasarkan arsitektur backend terkini dan integritas data klinis, berikut adalah ketetapan resmi untuk menjawab 5 pertanyaan pada *Feature Backend Requirement Delegation Report*:

### 6.1. Multi-Slot Session Persistence
* **Pertanyaan:** Apakah backend menyimpan multiple time slots dalam satu sesi sebagai record terpisah di database, atau sebagai satu record durasi gabungan?
* **Ketetapan Backend:**
  Backend Drizzle (`practitioner_schedule_sessions`) mencatat **setiap blok waktu praktek sebagai satu entitas sesi terpisah** (`startTime` s/d `endTime`). 
  - Alasan: Setiap slot/sesi membutuhkan alokasi ruangan mandiri (`roomId`), kapasitas antrean terisolasi (`capacity`), dan relasi janji temu pasien terpisah (`appointments.scheduleSessionId`).
  - Implikasi Mobile: Ketika dokter menambahkan beberapa slot waktu pada form "Tambah Jadwal" di drawer mobile, client melakukan dispatch `POST /schedules` untuk masing-masing slot tersebut.

### 6.2. Kebijakan Penghapusan dengan Booking Aktif (Active Booking Deletion Shield)
* **Pertanyaan:** Apakah backend menyediakan *administrative override* untuk menghapus jadwal yang memiliki pasien terdaftar, ataukah penghapusan diblokir mutlak?
* **Ketetapan Backend:**
  Backend **memblokir mutlak** penghapusan langsung terhadap sesi yang memiliki janji temu berstatus aktif (`booked`, `checked_in`, `waiting`, `in_service`) dengan respons `409 Conflict` bersandi `SCHEDULE_HAS_ACTIVE_BOOKINGS`.
  - Alasan Keamanan Pasien: Pasien tidak boleh kehilangan nomor antrean atau janji temu tanpa jejak audit.
  - Prosedur Resmi Jika Dokter Berhalangan / Sakit / Cuti Mendadak:
    1. Dokter / Admin menandai hari tersebut sebagai **Cuti** melalui `PUT /schedules/day-settings` (`isCuti: true, cutiReason: '...'`).
    2. Admin klinik melalui Web Dashboard melakukan pembatalan resmi (*cancellation*) atau penjadwalan ulang (*reschedule*) janji temu pasien yang terdampak.
    3. Setelah seluruh status janji temu menjadi `cancelled` atau dipindahkan, sesi baru dapat dihapus jika memang diperlukan.

### 6.3. Sinkronisasi Pasien Terdaftar: Push vs Pull
* **Pertanyaan:** Apakah pendaftaran pasien baru via Web App / Loket Pendaftaran otomatis mendorong notifikasi push / WebSocket ke perangkat mobile dokter, ataukah mobile mengandalkan pull-to-refresh?
* **Ketetapan Backend:**
  - **Fase Saat Ini (Canonical Persistence):** Seluruh data janji temu tersimpan secara sentral di tabel `appointments` PostgreSQL. Mobile mengandalkan **Pull-to-Refresh** (`RefreshIndicator`) dan auto-refetch saat dokter membuka Overview Tab (`initState` / tab switch).
  - **Fase Berikutnya (Real-time Notification):** Backend telah menyiapkan event emitter arsitektural untuk mengalirkan WebSocket / SSE / FCM Push Notification ketika ada booking pasien baru. Kontrak payload pasien (`BookedPatientEntity`) tetap identik sehingga mobile tidak memerlukan refactor struktur data.

### 6.4. Standar Zona Waktu & Format Waktu
* **Pertanyaan:** Bagaimana format waktu standar yang disepakati antara frontend dan backend?
* **Ketetapan Backend:**
  - Format Waktu: String `HH:mm` (24-jam, contoh: `"07:00"`, `"13:30"`).
  - Format Tanggal: String `YYYY-MM-DD` (ISO-8601 Date, contoh: `"2026-08-26"`).
  - Zona Waktu Klinis: **WIB (Waktu Indonesia Barat, UTC+7)** sebagai basis waktu operasional klinik.
  - Nilai `timeRange` disediakan langsung oleh backend (contoh: `"07:00 - 11:00 WIB"`) untuk mempermudah rendering instan pada badge dan kartu jadwal di mobile & web tanpa formatting berulang.

### 6.5. Asal Target Kuota Harian (Daily Target Quota Origin)
* **Pertanyaan:** Apakah target kuota harian dihitung otomatis dari penjumlahan kapasitas seluruh sesi, atau ditentukan manual oleh dokter?
* **Ketetapan Backend:**
  Target kuota harian (`targetQuota`) dikelola secara independen di tabel `practitioner_schedule_day_settings`:
  - Nilai *default* saat dokter belum mengatur kuota harian adalah **8 pasien**.
  - Dokter dapat mengubah target kuota harian melalui `PUT /schedules/day-settings`.
  - Backend secara otomatis menghitung `sessionCount`, `bookedPatientCount`, dan `capacityPercentage` berdasarkan kalkulasi real-time terhadap seluruh sesi aktif dokter pada tanggal tersebut.

---

## 7. Panduan Sinkronisasi Lintas Platform (Mobile App & Web Dashboard)

Untuk memastikan pengembang Flutter Mobile dan pengembang Web Dashboard (Portal Admin/Pendaftaran) berjalan selaras:

1. **Konsistensi Skema Entitas:**
   Web dan Mobile mengonsumsi model data yang sama persis:
   - `ScheduleEntity`: Objek sesi praktek dokter.
   - `DayScheduleSettingEntity`: Pengaturan cuti dan target kuota harian.
   - `CalendarSummaryResponse`: Ringkasan bulanan untuk kalender.
   - `BookedPatientEntity`: Pasien janji temu.
2. **Web Portal Khusus Admin/Resepsionis:**
   - Web Dashboard menggunakan endpoint `GET /api/v1/schedules` (dengan query `poliklinikId`, `staffId`, `date`) untuk melihat jadwal seluruh dokter di klinik, sementara Flutter Mobile dokter menggunakan `GET /api/v1/schedules/my-schedules` yang secara otomatis terisolasi ke dokter yang login.
3. **Respon Error Standar:**
   Keduanya (Web & Mobile) harus menangani respons error `409 Conflict` dengan kode error yang sama:
   - `SCHEDULE_HAS_ACTIVE_BOOKINGS`
   - `ROOM_ALREADY_OCCUPIED`
   - `PRACTITIONER_ALREADY_SCHEDULED`
   - `INVALID_TIME_RANGE`
4. **Master Pilihan Dinamis:**
   Gunakan endpoint referensi berikut untuk mengisi seluruh form input di Web & Mobile:
   - `GET /api/v1/schedules/reference/polikliniks`
   - `GET /api/v1/schedules/reference/rooms`
   - `GET /api/v1/schedules/reference/options`

