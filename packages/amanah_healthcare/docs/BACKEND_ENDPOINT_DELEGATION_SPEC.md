# BACKEND ENDPOINT DELEGATION SPECIFICATION
## Zero-Client-Calculation & SSOT Schedule Architecture

**Dokumen Kebutuhan Endpoint Backend untuk Mobile Client (Flutter)**  
**Versi:** 1.0.0  
**Tanggal:** 25 September 2026  
**Target Backend:** NestJS / Drizzle ORM (`Amanah-healthcare-backend`)  
**Target Client:** Flutter Mobile (`amanah-healthcare-mobile`)

---

## 1. Executive Summary & Root Cause Analysis

### Masalah Arsitektural Saat Ini (Client Overengineering)
Saat ini, Flutter mobile menampung **364 baris logika kalkulasi bentrok** (`ScheduleSlotCollisionHelper`), 4 pemanggilan HTTP paralel (`loadPolikliniks`, `loadRooms`, `loadScheduleContexts`, `loadOccupancyOverview`), serta kalkulasi aritmatika waktu lokal (`parseTimeToMinutes`, penambahan interval 30 menit).

Hal ini menimbulkan masalah fatal di lapangan:
1. **Blind Room Fallback**: Jika slot belum memilih ruangan atau ruangan berganti secara asynchronous, client fallback ke `_rooms.first.id` (`Ruang KIA 1`). Padahal dokter sedang membuat jadwal di `Ruang Poli Umum 1`.
2. **Desinkronisasi Grid (Non-WYSIWYG)**: Slot 21:30 - 23:30 di `Ruang KIA 1` kosong (tampil polos), tetapi di `Ruang Poli Umum 1` sudah ada `dr. Ahmad Santoso`. Dokter merasa slot kosong, memilih 21:30, lalu terkena **409 Conflict** saat submit.
3. **Pelanggaran Prinsip SSOT & Trust Backend**: Frontend bertindak sebagai validator bentrok jadwal, padahal inventaris ruangan dan praktisi medis adalah hak prerogatif backend/database.

### Solusi Arsitektural: Backend Delegation
Frontend **TIDAK BOLEH** menghitung bentrok, menit, atau menebak ketersediaan slot.  
Backend harus menyediakan **2 Endpoint Siap Pakai (Presentation-Ready)** sehingga Flutter murni bertindak sebagai *dumb UI renderer*:
1. `GET /api/v1/schedules/form-bootstrap`: 1 roundtrip untuk memuat semua referensi form & default dokter.
2. `GET /api/v1/schedules/slot-availability`: Mengembalikan array slot 100% siap render (mana yang disabled, label teks bentroknya apa, dan alasan detailnya).

---

## 2. Spesifikasi Endpoint 1: Form Bootstrap (1 Roundtrip)

Menggantikan 4 request terpisah (`/options`, `/rooms`, `/polikliniks`, `/contexts`) menjadi **satu panggilan terpadu** saat drawer Tambah/Edit Jadwal dibuka.

### Endpoint Definition
- **Method:** `GET`
- **Path:** `/api/v1/schedules/form-bootstrap`
- **Query Parameters:**
  - `date` (`string`, required): Format `YYYY-MM-DD` (contoh: `2026-09-25`)
  - `scheduleId` (`string`, optional): UUID jadwal jika dalam mode Edit Jadwal.

### Response Contract (`200 OK`)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Form bootstrap data berhasil dimuat",
  "data": {
    "doctor": {
      "id": "3cb62e10-450b-43e5-aba9-49ec37079ebb",
      "name": "dr. Fadhiilah Ahmad Zikri, Sp.A",
      "defaultRoomId": "b77d141b-2fa5-4481-9f47-a5a040faf57a",
      "defaultRoomName": "Ruang Poli Umum 1",
      "defaultPoliklinikId": "a11d141b-1fa5-4481-9f47-a5a040faf11a",
      "defaultPoliklinikName": "Poli Umum",
      "consultationDurationMinutes": 30
    },
    "rooms": [
      {
        "id": "b77d141b-2fa5-4481-9f47-a5a040faf57a",
        "name": "Ruang Poli Umum 1",
        "code": "RPU-01",
        "isOccupied": true,
        "occupiedBy": "dr. Ahmad Santoso"
      },
      {
        "id": "590be133-107b-476e-bab3-a3ccd2d875dd",
        "name": "Ruang KIA 1",
        "code": "KIA-01",
        "isOccupied": false,
        "occupiedBy": null
      }
    ],
    "polikliniks": [
      {
        "id": "a11d141b-1fa5-4481-9f47-a5a040faf11a",
        "name": "Poli Umum",
        "code": "POLI-UMUM"
      }
    ],
    "shifts": [
      {
        "id": "dini_hari",
        "code": "early_morning",
        "name": "Sesi Dini Hari",
        "startTime": "00:00",
        "endTime": "06:00",
        "isPast": true,
        "existingSchedule": null
      },
      {
        "id": "pagi",
        "code": "morning",
        "name": "Sesi Pagi",
        "startTime": "06:00",
        "endTime": "12:00",
        "isPast": true,
        "existingSchedule": null
      },
      {
        "id": "siang",
        "code": "afternoon",
        "name": "Sesi Siang",
        "startTime": "12:00",
        "endTime": "18:00",
        "isPast": true,
        "existingSchedule": null
      },
      {
        "id": "malam",
        "code": "night",
        "name": "Sesi Malam",
        "startTime": "18:00",
        "endTime": "24:00",
        "isPast": false,
        "existingSchedule": null
      }
    ]
  }
}
```

---

## 3. Spesifikasi Endpoint 2: Slot Availability & Conflict Matrix (SSOT Grid)

**Ini adalah endpoint inti pemecah masalah.**  
Ketika user menekan tombol **"Pilih Jam"** pada sesi manapun, Flutter **HANYA** memanggil endpoint ini dengan membawa `roomId`.

### Endpoint Definition
- **Method:** `GET`
- **Path:** `/api/v1/schedules/slot-availability`
- **Query Parameters:**
  - `date` (`string`, required): Format `YYYY-MM-DD` (contoh: `2026-09-25`)
  - `shift` (`string`, required): `early_morning` | `morning` | `afternoon` | `night` (atau `dini_hari` | `pagi` | `siang` | `malam`)
  - `roomId` (`string`, required): UUID ruangan yang dipilih (contoh: `b77d141b-2fa5-4481-9f47-a5a040faf57a`)
  - `excludeScheduleId` (`string`, optional): UUID jadwal dokter saat ini jika sedang mengedit jadwal sendiri (agar slot dokter sendiri tidak terhitung bentrok).

### Aturan Bisnis di Backend (Backend Rule Engine):
1. **Pemeriksaan Temporal**: Slot yang jamnya sudah lewat dari `NOW()` pada tanggal tersebut otomatis berstatus `PAST`.
2. **Pemeriksaan Bentrok Ruangan**: Jika ada dokter lain yang menempati `roomId` tersebut pada interval jam tertentu, slot berstatus `OCCUPIED_BY_OTHER`, `displayLabel` berisi nama dokter yang bentrok (misal: `"dr. Ahmad Santoso"`), dan `isAvailable: false`.
3. **Pemeriksaan Bentrok Dokter Sendiri**: Jika dokter yang sedang login sudah memiliki jadwal di ruangan lain pada jam tersebut, slot berstatus `OCCUPIED_BY_SELF`, `displayLabel: "Jadwal Anda"`, dan `isAvailable: false`.
4. **Slot Bebas**: Jika tidak ada satupun bentrok, slot berstatus `AVAILABLE`, `displayLabel: "Tersedia"`, dan `isAvailable: true`.

### Response Contract (`200 OK`)
Contoh riil saat user membuka Sesi Malam di `Ruang Poli Umum 1` pada jam 21:30 WIB:
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Ketersediaan slot berhasil dihitung",
  "data": {
    "date": "2026-09-25",
    "shift": "night",
    "shiftLabel": "Sesi Malam",
    "roomId": "b77d141b-2fa5-4481-9f47-a5a040faf57a",
    "roomName": "Ruang Poli Umum 1",
    "boundary": {
      "startTime": "18:00",
      "endTime": "24:00"
    },
    "intervalMinutes": 30,
    "summary": {
      "totalSlots": 12,
      "availableSlots": 0,
      "occupiedSlots": 12
    },
    "slots": [
      {
        "slotIndex": 0,
        "time": "18:00",
        "endTime": "18:30",
        "isAvailable": false,
        "status": "PAST",
        "displayLabel": "Sudah Selesai",
        "conflict": {
          "type": "TEMPORAL_PAST",
          "occupantName": null,
          "reason": "Slot waktu ini telah melewati jam operasional saat ini."
        }
      },
      {
        "slotIndex": 1,
        "time": "18:30",
        "endTime": "19:00",
        "isAvailable": false,
        "status": "PAST",
        "displayLabel": "Sudah Selesai",
        "conflict": {
          "type": "TEMPORAL_PAST",
          "occupantName": null,
          "reason": "Slot waktu ini telah melewati jam operasional saat ini."
        }
      },
      {
        "slotIndex": 2,
        "time": "19:00",
        "endTime": "19:30",
        "isAvailable": false,
        "status": "PAST",
        "displayLabel": "Sudah Selesai",
        "conflict": {
          "type": "TEMPORAL_PAST",
          "occupantName": null,
          "reason": "Slot waktu ini telah melewati jam operasional saat ini."
        }
      },
      {
        "slotIndex": 3,
        "time": "19:30",
        "endTime": "20:00",
        "isAvailable": false,
        "status": "PAST",
        "displayLabel": "Sudah Selesai",
        "conflict": {
          "type": "TEMPORAL_PAST",
          "occupantName": null,
          "reason": "Slot waktu ini telah melewati jam operasional saat ini."
        }
      },
      {
        "slotIndex": 4,
        "time": "20:00",
        "endTime": "20:30",
        "isAvailable": false,
        "status": "PAST",
        "displayLabel": "Sudah Selesai",
        "conflict": {
          "type": "TEMPORAL_PAST",
          "occupantName": null,
          "reason": "Slot waktu ini telah melewati jam operasional saat ini."
        }
      },
      {
        "slotIndex": 5,
        "time": "20:30",
        "endTime": "21:00",
        "isAvailable": false,
        "status": "PAST",
        "displayLabel": "Sudah Selesai",
        "conflict": {
          "type": "TEMPORAL_PAST",
          "occupantName": null,
          "reason": "Slot waktu ini telah melewati jam operasional saat ini."
        }
      },
      {
        "slotIndex": 6,
        "time": "21:00",
        "endTime": "21:30",
        "isAvailable": false,
        "status": "PAST",
        "displayLabel": "Sudah Selesai",
        "conflict": {
          "type": "TEMPORAL_PAST",
          "occupantName": null,
          "reason": "Slot waktu ini telah melewati jam operasional saat ini."
        }
      },
      {
        "slotIndex": 7,
        "time": "21:30",
        "endTime": "22:00",
        "isAvailable": false,
        "status": "OCCUPIED_BY_OTHER",
        "displayLabel": "dr. Ahmad Santoso",
        "conflict": {
          "type": "ROOM_OCCUPIED",
          "occupantName": "dr. Ahmad Santoso",
          "reason": "Ruang Poli Umum 1 sudah dialokasikan untuk dr. Ahmad Santoso pada jam 18:00 - 24:00 WIB."
        }
      },
      {
        "slotIndex": 8,
        "time": "22:00",
        "endTime": "22:30",
        "isAvailable": false,
        "status": "OCCUPIED_BY_OTHER",
        "displayLabel": "dr. Ahmad Santoso",
        "conflict": {
          "type": "ROOM_OCCUPIED",
          "occupantName": "dr. Ahmad Santoso",
          "reason": "Ruang Poli Umum 1 sudah dialokasikan untuk dr. Ahmad Santoso pada jam 18:00 - 24:00 WIB."
        }
      },
      {
        "slotIndex": 9,
        "time": "22:30",
        "endTime": "23:00",
        "isAvailable": false,
        "status": "OCCUPIED_BY_OTHER",
        "displayLabel": "dr. Ahmad Santoso",
        "conflict": {
          "type": "ROOM_OCCUPIED",
          "occupantName": "dr. Ahmad Santoso",
          "reason": "Ruang Poli Umum 1 sudah dialokasikan untuk dr. Ahmad Santoso pada jam 18:00 - 24:00 WIB."
        }
      },
      {
        "slotIndex": 10,
        "time": "23:00",
        "endTime": "23:30",
        "isAvailable": false,
        "status": "OCCUPIED_BY_OTHER",
        "displayLabel": "dr. Ahmad Santoso",
        "conflict": {
          "type": "ROOM_OCCUPIED",
          "occupantName": "dr. Ahmad Santoso",
          "reason": "Ruang Poli Umum 1 sudah dialokasikan untuk dr. Ahmad Santoso pada jam 18:00 - 24:00 WIB."
        }
      },
      {
        "slotIndex": 11,
        "time": "23:30",
        "endTime": "24:00",
        "isAvailable": false,
        "status": "OCCUPIED_BY_OTHER",
        "displayLabel": "dr. Ahmad Santoso",
        "conflict": {
          "type": "ROOM_OCCUPIED",
          "occupantName": "dr. Ahmad Santoso",
          "reason": "Ruang Poli Umum 1 sudah dialokasikan untuk dr. Ahmad Santoso pada jam 18:00 - 24:00 WIB."
        }
      }
    ]
  }
}
```

---

## 4. Keuntungan Drastis Setelah Endpoint Ini Dipasang di Backend

| Aspek | Sebelum (Client Calculation) | Sesudah (Backend Delegation) |
|---|---|---|
| **Jumlah Roundtrip Saat Buka Form** | 4 HTTP Requests | **1 HTTP Request** (`/form-bootstrap`) |
| **Logika Bentrok Jadwal di Flutter** | 364 baris kode rentan bug (`ScheduleSlotCollisionHelper`) | **0 baris kode** (Flutter tinggal `map` array `slots`) |
| **Kalkulasi Menit Waktu (00:00 - 24:00)** | Dilakukan di Dart (`parseTimeToMinutes`, loops) | **0 kalkulasi** (Waktu & boundary disediakan backend) |
| **Tampilan Grid (WYSIWYG)** | Rentan bias karena cache ruangan salah (`Ruang KIA 1`) | **100% WYSIWYG**: Data grid sama persis dengan validator submit |
| **Blind Fallback** | Fallback sembarangan ke `_rooms.first.id` | **Tidak ada fallback**: Room ID dikirim eksplisit |
| **Potensi Error 409 Conflict Tak Terduga** | Sering terjadi karena tampilan grid menipu user | **Nol**: Slot bentrok langsung `disabled: true` sejak awal |

---

## 5. Checklist Integrasi untuk Backend Engineer
- [ ] Buat handler controller `GET /api/v1/schedules/form-bootstrap`.
- [ ] Buat handler controller `GET /api/v1/schedules/slot-availability`.
- [ ] Implementasikan query Drizzle untuk menggabungkan `staff_schedules`, `clinic_rooms`, dan temporal check `NOW()`.
- [ ] Tambahkan unit test di NestJS:
  - Kasus 1: Sesi malam di ruangan yang sudah ditempati dokter lain menghasilkan `isAvailable: false` dan `displayLabel: "<Nama Dokter>"`.
  - Kasus 2: Sesi di ruangan kosong menghasilkan seluruh slot `isAvailable: true` dan `displayLabel: "Tersedia"`.
  - Kasus 3: Jam yang sudah lewat menghasilkan `status: "PAST"` dan `displayLabel: "Sudah Selesai"`.
- [ ] Berikan Changelog endpoint baru beserta URL Swagger kepada tim Mobile.
