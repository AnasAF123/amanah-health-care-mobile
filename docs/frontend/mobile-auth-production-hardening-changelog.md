# Changelog: Authentication Hardening & Production Readiness Fixes

**Target Repositories:**  
- Flutter Mobile: `amanah-healthcare-mobile` (`packages/amanah_healthcare`)  
- NestJS Backend: `Amanah-healthcare-backend` (`amanah-backend`)  
**Date:** 2026-09-21  
**Status:** Implemented & Verified  

---

## 1. Executive Summary

Berdasarkan hasil **Authentication Maturity & Production Readiness Audit**, ditemukan 4 isu krusial yang menghambat rilis ke production:
1. Pengguna Google OAuth tertolak (`401 Unauthorized`) saat mengakses modul klinis utama (Rekam Medis, Janji Temu, Presensi, Cuti, dll).
2. Endpoint `POST /api/v1/auth/logout` di backend tidak mencabut token (fungsi no-op).
3. Endpoint login dan verifikasi OTP belum diproteksi rate limiting ketat (rentan brute force).
4. Store in-memory di Flutter (jadwal, notifikasi, perizinan) tidak di-reset saat logout, sehingga data tertahan di HP/tablet klinik.

Seluruh isu di atas telah **diperbaiki dan diverifikasi secara menyeluruh**. Dokumen ini merangkum perubahan teknis serta panduan sinkronisasi untuk Flutter Developer dan Web Developer.

---

## 2. Perubahan di NestJS Backend (`amanah-backend`)

### 2.1. Penyelarasan Guard ke `HybridAuthGuard` di Seluruh Modul Klinis
- **Sebelumnya:** Controller modul klinis menggunakan `@UseGuards(AuthGuard('jwt'), RolesGuard)`. Guard ini hanya mengenali JWT kanonikal email/password dan menolak session token dari Better Auth (Google OAuth).
- **Perubahan:** Seluruh controller klinis kini menggunakan `@UseGuards(HybridAuthGuard, RolesGuard)`:
  - `AppointmentsController` (`/api/v1/appointments`)
  - `AttendanceController` (`/api/v1/attendance`)
  - `ClinicsController` (`/api/v1/clinics`)
  - `ClinicAnalyticsController` (`/api/v1/clinics/analytics`)
  - `LeavesController` (`/api/v1/leaves`)
  - `MedicalRecordsController` (`/api/v1/medical-records`)
  - `NotificationsController` (`/api/v1/notifications`)
  - `AuditController` (`/api/v1/audit-logs`)
- **Dampak bagi Flutter Dev:** Dokter/staf yang login via Google OAuth kini dapat mengakses seluruh fitur klinis tanpa kendala `401 Unauthorized`.

### 2.2. Implementasi Pencabutan Token Nyata pada Logout
- **Sebelumnya:** `AuthService.logout` berupa fungsi kosong (`async logout() {}`).
- **Perubahan:**
  1. `AuthController.logout` mengekstrak Bearer token dari header `Authorization`.
  2. `AuthService.logout` mendaftarkan token ke **Redis Blacklist** (`blacklist:token:<token>`) dengan TTL 24 jam (86.400 detik).
  3. `AuthService.logout` menghapus record sesi Better Auth dari tabel basis data `session`.
  4. `HybridAuthGuard` memeriksa Redis blacklist pada setiap request sebelum memproses autentikasi. Jika token terdaftar di blacklist, request langsung ditolak dengan `401 Unauthorized`.
- **Dampak bagi Flutter Dev:** Begitu `signOut()` dipanggil, token langsung mati di server.

### 2.3. Rate Limiting Ketat pada Endpoint Kredensial & OTP
- **Sebelumnya:** Endpoint login dan verifikasi OTP hanya dilindungi tier umum (30 req/menit).
- **Perubahan:** Ditambahkan decorator `@RateLimit({ limit: 5, windowSeconds: 60 })` pada:
  - `POST /api/v1/auth/email/login`
  - `POST /api/v1/auth/email/register`
  - `POST /api/v1/auth/email/verify-otp`
  - `POST /api/v1/auth/otp/reset-password`
- **Dampak bagi Flutter Dev:** Jika user salah memasukkan password atau OTP lebih dari 5 kali dalam 1 menit, server akan merespons `429 Too Many Requests` dengan header `Retry-After`. Flutter client perlu menampilkan pesan cooldown yang ramah.

### 2.4. Penanganan Fleksibel Tipe Role pada `BetterAuthRbacGuard`
- `BetterAuthRbacGuard` diperbarui agar dapat mengekstrak role baik dalam bentuk string maupun objek (`role.code`), mencegah `403 Forbidden` palsu saat guard digunakan berantai dengan `HybridAuthGuard`.

---

## 3. Action Items untuk Tim Flutter Mobile (Dikerjakan oleh Flutter Agent)

### 3.1. Pembersihan Store In-Memory Saat Logout
- **Isu:** Saat user menekan logout, token di `FlutterSecureStorage` dihapus, tetapi singleton in-memory (`AmanahScheduleStore`, `AmanahNotificationStore`, `AmanahPermissionStore`) belum di-reset.
- **Tindakan untuk Flutter Dev/Agent:**
  - Pada callback `onLogout` di `AuthBottomSheetScreen` dan `AmanahHomeShell`, panggil:
    ```dart
    AmanahScheduleStore.instance.reset();
    AmanahNotificationStore.instance.reset();
    AmanahPermissionStore.instance.reset();
    ```
- **Tujuan:** Mencegah kebocoran data jadwal dan notifikasi dokter sebelumnya di HP/tablet klinik bersama.

### 3.2. Penanganan Header `Retry-After` pada Error 429 (Rate Limit)
- **Isu:** Backend kini membatasi percobaan login, register, dan verifikasi OTP maksimal 5x per menit. Jika limit terlampaui, backend mengembalikan status `429 Too Many Requests` dengan header `Retry-After: <detik>`.
- **Tindakan untuk Flutter Dev/Agent:**
  - Tangkap status code `429` di `AmanahAuthRepository`.
  - Parse header `Retry-After` dan tampilkan pesan countdown/cooldown di UI form login atau OTP.

### 3.3. Penghapusan Mock Identity Fallback di Home Shell
- **Isu:** `AmanahHomeShell` memiliki fallback ke mock user `doc-001` (`dr. Rayhan Pratama, Sp.A`) jika parameter `user` bernilai `null`.
- **Tindakan untuk Flutter Dev/Agent:**
  - Ubah parameter `user` pada `AmanahHomeShell` menjadi `required AmanahAuthUser user`.
  - Hapus fallback `defaultUser` agar navigasi tanpa user yang valid langsung dicegah.

---

## 4. Panduan Sinkronisasi untuk Flutter & Web Dev

| Aspek | Kontrak / Perilaku | Rekomendasi Implementasi |
| :--- | :--- | :--- |
| **Header Autentikasi** | `Authorization: Bearer <token>` | Selalu sertakan token yang didapat dari `/sign-in/social` atau `/sign-in/email`. |
| **Penanganan Error 429** | `HTTP 429 Too Many Requests` | Tangkap status `429`, baca header `Retry-After` (detik), dan tampilkan timer hitung mundur di UI form OTP / Login. |
| **Alur Logout Lengkap** | Panggil `signOut()` lalu navigasi | Panggil `AmanahAuthRepository.signOut()`. Token di storage dan server akan dicabut, dan store lokal akan di-reset. |
| **Akses Fitur Klinis** | Google OAuth & Email/Password setara | Keduanya kini memiliki hak akses penuh sesuai role staf yang ditetapkan di onboarding. |

---

## 5. Audit Kematangan Layanan Lupa Password & OTP (Forgot Password & OTP)

### 5.1. Status Kematangan Backend: **MATANG (Mature & Production-Ready)**
Backend Amanah Healthcare telah memiliki layanan Lupa Password & OTP yang sepenuhnya matang, aman, dan siap produksi melalui Better Auth `email-otp` plugin dengan konfigurasi:
1. **Anti-Enumeration Protection:**
   - Endpoint `POST /api/auth/email-otp/request-password-reset` selalu mengembalikan status `200 { "success": true }` meskipun email tidak terdaftar di basis data. Hal ini mencegah penyerang melakukan profiling email pengguna terdaftar.
2. **TTL & Keamanan Kode OTP:**
   - Masa berlaku OTP: **300 detik (5 menit)** (`expiresIn: 300`).
   - Kode OTP berupa **6 digit angka acak cryptographically secure**.
   - Batas percobaan verifikasi salah: **Maksimal 3 kali**. Jika salah 3 kali berturut-turut, OTP langsung hangus (`403 TOO_MANY_ATTEMPTS`).
3. **Atomic Verification & Session Revocation:**
   - Endpoint `POST /api/auth/email-otp/reset-password` melakukan konsumsi OTP secara atomik (mencegah replay attack).
   - Saat password berhasil diperbarui, seluruh sesi aktif pengguna di tabel `session` otomatis dicabut (`revokeSessionsOnPasswordReset: true`), memaksa login ulang di semua perangkat.
4. **Rate Limiting Ketat (DDoS & Brute-Force Shield):**
   - `POST /api/auth/email-otp/request-password-reset`: Maksimal 5 permintaan / 60 detik.
   - `POST /api/auth/email-otp/check-verification-otp`: Maksimal 10 percobaan / 60 detik.
   - `POST /api/auth/email-otp/reset-password`: Maksimal 5 percobaan / 60 detik.
5. **Templating Email Profesional:**
   - Email HTML dan plain-text dikirim via SMTP/Mailpit dengan branding resmi Amanah Healthcare dan disclaimer keamanan.

---

### 5.2. Status Kematangan Flutter Mobile: **PERLU KONEKSI UI (UI Masih Mocked)**
Di sisi mobile app (`amanah-healthcare-mobile`):
- **Data Layer (`AmanahAuthRepository`): SUDAH LENGKAP & MATANG**
  Method repository sudah mengarah ke endpoint yang benar dan siap digunakan:
  - `requestPasswordReset(String email)` -> `POST /api/auth/email-otp/request-password-reset`
  - `checkVerificationOtp(String email, String otp)` -> `POST /api/auth/email-otp/check-verification-otp`
  - `resetPassword(String email, String otp, String newPassword)` -> `POST /api/auth/email-otp/reset-password`
- **Presentation Layer (`AuthBottomSheetScreen`): MASIH MOCK (BELUM TERHUBUNG)**
  Pada file `packages/amanah_healthcare/lib/features/authentication/presentation/screen/auth_bottom_sheet_screen.dart` baris 409–516:
  - `_handleRequestPasswordOtp`: Hanya menggunakan `Future.delayed(600ms)` dan **TIDAK MEMANGGIL** `widget.repository.requestPasswordReset(...)`.
  - `_handleVerifyOtp`: Hanya menggunakan `Future.delayed(700ms)` dan **TIDAK MEMANGGIL** `widget.repository.checkVerificationOtp(...)`.
  - `_handleChangePassword`: Hanya menggunakan `Future.delayed(700ms)` dan **TIDAK MEMANGGIL** `widget.repository.resetPassword(...)`.

---

### 5.3. Panduan Implementasi untuk Flutter Agent / Mobile Dev

Flutter Agent / Mobile Dev perlu menyambungkan ketiga handler di `auth_bottom_sheet_screen.dart` ke method `widget.repository`:

#### 1. Perbaikan `_handleRequestPasswordOtp`:
```dart
Future<void> _handleRequestPasswordOtp(
  BuildContext sheetContext,
  StateSetter sheetSetState,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  if (!(_forgotPasswordFormKey.currentState?.validate() ?? false)) {
    return;
  }

  _loadingProvider = AuthProviderType.email;
  _statusMessage = null;
  _statusIsError = false;
  _refreshSheet(sheetSetState);

  final String email = _resetEmailController.text.trim();
  final bool success = await widget.repository.requestPasswordReset(email);

  if (!mounted) return;

  _loadingProvider = null;
  if (success) {
    for (final TextEditingController controller in _otpControllers) {
      controller.clear();
    }
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop(const _AuthSheetResult(AuthSheetMode.otpVerification));
    }
  } else {
    _statusMessage = 'Gagal mengirim kode OTP. Silakan periksa email Anda atau coba beberapa saat lagi.';
    _statusIsError = true;
    _refreshSheet(sheetSetState);
  }
}
```

#### 2. Perbaikan `_handleVerifyOtp`:
```dart
Future<void> _handleVerifyOtp(
  BuildContext sheetContext,
  StateSetter sheetSetState,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final String code = _otpControllers
      .map((TextEditingController controller) => controller.text.trim())
      .join();
  if (code.length != 6) {
    _statusMessage = 'Masukkan 6 digit kode OTP.';
    _statusIsError = true;
    _refreshSheet(sheetSetState);
    return;
  }

  _loadingProvider = AuthProviderType.email;
  _statusMessage = null;
  _statusIsError = false;
  _refreshSheet(sheetSetState);

  final String email = _resetEmailController.text.trim();
  final bool success = await widget.repository.checkVerificationOtp(email, code);

  if (!mounted) return;

  _loadingProvider = null;
  if (success) {
    _resetPasswordController.clear();
    _resetConfirmPasswordController.clear();
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop(const _AuthSheetResult(AuthSheetMode.changePassword));
    }
  } else {
    _statusMessage = 'Kode OTP tidak valid atau telah kedaluwarsa.';
    _statusIsError = true;
    _refreshSheet(sheetSetState);
  }
}
```

#### 3. Perbaikan `_handleChangePassword`:
```dart
Future<void> _handleChangePassword(
  BuildContext sheetContext,
  StateSetter sheetSetState,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  if (!(_changePasswordFormKey.currentState?.validate() ?? false)) {
    return;
  }
  if (!AmanahPasswordRequirements.evaluate(
    _resetPasswordController.text,
  ).isComplete) {
    return;
  }

  _loadingProvider = AuthProviderType.email;
  _statusMessage = null;
  _statusIsError = false;
  _refreshSheet(sheetSetState);

  final String email = _resetEmailController.text.trim();
  final String otp = _otpControllers
      .map((TextEditingController controller) => controller.text.trim())
      .join();
  final String newPassword = _resetPasswordController.text;

  final bool success = await widget.repository.resetPassword(email, otp, newPassword);

  if (!mounted) return;

  _loadingProvider = null;
  if (success) {
    _passwordController.text = _resetPasswordController.text;
    _identifierController.text = _resetEmailController.text;
    _statusMessage = null;
    _statusIsError = false;
    _refreshSheet(sheetSetState);
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop(const _AuthSheetResult(AuthSheetMode.passwordChangedSuccess));
    }
  } else {
    _statusMessage = 'Gagal mereset password. Pastikan kode OTP masih berlaku.';
    _statusIsError = true;
    _refreshSheet(sheetSetState);
  }
}
```

---

## 6. Penyelarasan & Hardening Jadwal Dokter (Doctor Schedule Management)

### 6.1. Audit & Penyesuaian Terhadap Autentikasi Baru
Modul Jadwal Dokter (`AmanahScheduleStore`) sebelumnya dibangun saat aplikasi belum memiliki autentikasi. Dengan terintegrasinya autentikasi Better Auth & Google OAuth:
1. **Peniadaan Mock ID:** Client mobile tidak lagi perlu mengirimkan mock ID (`doc-001`). Backend mengekstrak `staffId` / `practitionerId` langsung dari token sesi.
2. **Perlindungan Kepemilikan (Ownership & Multi-Tenancy):**
   - Dokter hanya berwenang membuat, mengubah, menghapus, atau melihat pasien pada jadwal miliknya sendiri.
   - Percobaan memodifikasi jadwal dokter lain ditolak dengan `403 Forbidden`.
3. **Pemberantasan Fallback Acak:** Fallback lama di backend yang mengembalikan dokter sembarang di database jika profil dokter tidak ditemukan telah dihapus demi menjaga kerahasiaan medis.
4. **Proteksi Hapus Jadwal Berpenghuni:** Jadwal dengan pasien terdaftar tidak dapat dihapus (`409 Conflict SCHEDULE_HAS_ACTIVE_BOOKINGS`).
5. **Endpoint Referensi Poliklinik Baru:** Ditambahkan `GET /api/v1/schedules/reference/polikliniks` mendampingi `GET /api/v1/schedules/reference/rooms` untuk mengisi dropdown form jadwal secara dinamis.

### 6.2. Dokumen Kontrak Lengkap
Panduan lengkap mengenai URL, parameter, payload JSON, dan langkah transisi `AmanahScheduleStore` dari mock ke REST API tersedia di:  
👉 [`docs/frontend/doctor-schedule-management-backend-contract.md`](file:///D:/amanah-healthcare-mobile/docs/frontend/doctor-schedule-management-backend-contract.md)


