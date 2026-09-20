# Changelog & Sync Guide: Flutter Mobile Authentication & Staff Onboarding

> **Target Audience:** Flutter Mobile Developers, Web Frontend Team, Backend Engineering  
> **Repository:** `amanah-health-care-mobile` (`packages/amanah_healthcare`)  
> **Date:** 2026-09-21  
> **Status:** Production-Ready & Verified Live in PostgreSQL  

---

## 1. Ringkasan Perubahan (Overview)

Modul autentikasi pada aplikasi Flutter Mobile (`packages/amanah_healthcare`) telah diperbarui secara menyeluruh untuk mengadopsi **Better Auth v1.7.5** dan **Staff Onboarding & Role Selection Paradigm**.

Aplikasi tidak lagi memblokir pendaftar baru yang memiliki role awal `patient` dari Google OAuth, melainkan secara mulus mengarahkan pengguna ke alur pemilihan peran klinis (**Dokter**, **Bidan**, **Staf Administrasi**) dan melengkapi profil staf pertama kali.

---

## 2. Perubahan Arsitektur & File yang Dimodifikasi

### 2.1. Dependensi & Platform Setup Android
* **[`packages/amanah_healthcare/pubspec.yaml`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/pubspec.yaml)**:
  * Menambahkan dependensi resmi `flutter_better_auth: ^0.6.5`.
* **[`android/app/build.gradle.kts`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/android/app/build.gradle.kts)**:
  * `minSdk` disetel eksplisit ke `23` (persyaratan `flutter_secure_storage` 10+).
* **[`android/app/src/main/AndroidManifest.xml`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/android/app/src/main/AndroidManifest.xml)**:
  * Menambahkan `android:taskAffinity=""` pada `MainActivity`.
  * Mendeklarasikan `com.linusu.flutter_web_auth_2.CallbackActivity` dengan `android:exported="true"`, `android:taskAffinity=""`, dan scheme `amanahhealth`.
  * Menetapkan `android:allowBackup="false"` pada `<application>` untuk mencegah error dekripsi keystore.
* **[`android/app/src/debug/AndroidManifest.xml`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/android/app/src/debug/AndroidManifest.xml)**:
  * Menambahkan `android:usesCleartextTraffic="true"` untuk komunikasi HTTP lokal development.

---

### 2.2. Domain & Model Data (`AmanahAuthUser`)
* **File:** [`lib/features/authentication/domain/amanah_auth_user.dart`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/authentication/domain/amanah_auth_user.dart)
* **Pembaruan Enum Peran:**
  ```dart
  enum AmanahUserRole { doctor, midwife, staff }
  ```
* **Mapping Role Backend:**
  * `'doctor'`, `'staff_doctor'`, `'staffDoctor'` $\rightarrow$ `AmanahUserRole.doctor`
  * `'midwife'`, `'staff_midwife'`, `'staffMidwife'` $\rightarrow$ `AmanahUserRole.midwife`
  * `'worker'`, `'staff_worker'`, `'staffWorker'`, `'staff'` $\rightarrow$ `AmanahUserRole.staff`
* **Properti Baru pada `AmanahAuthUser`:**
  * `needsOnboarding: bool` (indikator apakah pengguna perlu melengkapi profil staf).
  * `systemRole: String` (`"STAF"` / `"PATIENT"`).
  * `staff: AmanahStaffProfile?` (model profil staf terhidrasi).

---

### 2.3. Repository & Komunikasi API (`AmanahAuthRepository`)
* **File:** [`lib/features/authentication/data/amanah_auth_repository.dart`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/authentication/data/amanah_auth_repository.dart)
* **Resolusi Base URL Otomatis:**
  * Android Emulator: `http://10.0.2.2:3001`
  * iOS Simulator / Desktop: `http://localhost:3001`
* **Penyambungan Endpoint Riil:**
  1. `authenticate(email, password)` $\rightarrow$ `POST /api/auth/sign-in/email`
  2. `signUp(name, email, password)` $\rightarrow$ `POST /api/auth/sign-up/email`
  3. `signInWithGoogle(idToken)` $\rightarrow$ `POST /api/auth/sign-in/social`
  4. `getSession()` $\rightarrow$ `GET /api/auth/get-session` (Bearer token)
  5. `signOut()` $\rightarrow$ `POST /api/auth/sign-out`
  6. `requestPasswordReset(email)` $\rightarrow$ `POST /api/auth/email-otp/request-password-reset`
  7. `checkVerificationOtp(email, otp)` $\rightarrow$ `POST /api/auth/email-otp/check-verification-otp`
  8. `resetPassword(email, otp, newPassword)` $\rightarrow$ `POST /api/auth/email-otp/reset-password`
  9. **`completeStaffOnboarding(...)`** $\rightarrow$ `POST /api/v1/auth/onboarding/staff`
     * Headers: `Authorization: Bearer <access_token>`, `Content-Type: application/json`
     * Body:
       ```json
       {
         "role": "doctor",
         "fullName": "dr. Zikri Ahmad, Sp.A",
         "phoneNumber": "+6281234567890",
         "profession": "Dokter Spesialis Anak",
         "licenseNumber": "SIP.446/123/DISKES/2026",
         "staffCode": "STF-DOK-099"
       }
       ```

---

### 2.4. Layar Pemilihan Peran & Onboarding Staf
* **File Baru:** [`lib/features/authentication/presentation/screen/staff_onboarding_screen.dart`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/authentication/presentation/screen/staff_onboarding_screen.dart)
* **Fitur Layar:**
  1. **Pilihan Kartu Peran Interaktif:**
     * **Dokter** (`doctor`): Wajib memasukkan nomor STR/SIP.
     * **Bidan** (`midwife`): Wajib memasukkan nomor STR/SIP.
     * **Staf / Pegawai** (`worker`): Tidak memerlukan nomor STR/SIP.
  2. **Form Informasi Profil:**
     * Nama Lengkap dengan Gelar (pre-populated dari akun Google/registrasi).
     * Nomor WhatsApp / Telepon.
     * Profesi / Jabatan spesifik.
     * Nomor SIP / STR (kondisional sesuai peran).
     * NIP / Kode Staf (opsional, backend otomatis meng-generate jika kosong).
  3. **Tombol "Simpan & Lanjutkan ke Beranda"**: Memanggil `completeStaffOnboarding` dan langsung memindahkan state ke beranda klinik (`AmanahHomeShell`).

---

### 2.5. Observability & Logging Terpusat
* **File Baru:** [`lib/features/authentication/data/amanah_auth_logger.dart`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/lib/features/authentication/data/amanah_auth_logger.dart)
* **Fasilitas Logging:**
  * `🚀 [REQUEST]`: Method, URL, headers, dan payload (field sensitif seperti `password` dan `token` otomatis disanitasi).
  * `✅ [RESPONSE]`: Status code, latensi dalam milidetik (`ms`), URL, dan body respons.
  * `💥 [NETWORK/ERROR]`: Pesan error jaringan beserta saran diagnostik otomatis (cth: apakah host `10.0.2.2:3001` mati atau salah loopback).
  * `🔑 [STORAGE]`: Operasi baca/tulis/hapus token pada `FlutterSecureStorage`.
  * `🌐 [OAUTH]`: Setiap fase Google Sign-In SDK hingga pertukaran ID token ke Better Auth.
  * `🔄 [LIFECYCLE]`: Event siklus hidup sesi (cold restore, login, onboarding, logout).

---

## 3. Catatan Sinkronisasi untuk Tim Web & Frontend Lain

1. **Skema URL Deep Link:**
   * Scheme yang digunakan adalah **`amanahhealth`** (`amanahhealth://`).
   * Pastikan konfigurasi server `trustedOrigins` di Better Auth menyertakan `"amanahhealth://"`.
2. **Google OAuth `serverClientId`:**
   * Web Client ID: `649477011186-akbd11b8rgbbs8ipot3cf27alle6ac8v.apps.googleusercontent.com`.
   * Digunakan oleh Flutter `GoogleSignIn(serverClientId: ...)` untuk mendapatkan `idToken` yang valid diverifikasi oleh Better Auth backend.
3. **Logika `needsOnboarding`:**
   * Jika respons login atau `get-session` memiliki `needsOnboarding: true`, jangan tolak pengguna sebagai pasien. Arahkan pengguna ke form pemilihan peran/onboarding staf (`POST /api/v1/auth/onboarding/staff`).
4. **SIP/STR untuk Praktisi Medis:**
   * Khusus peran `doctor` dan `midwife`, field `licenseNumber` otomatis dipetakan backend ke tabel `practitioners`.
   * Field `staffCode` bersifat opsional; backend akan membuatkan kode unik otomatis jika dikosongkan (contoh: `STF-DOK-3089`).

---

## 4. Bukti Pengujian & Verifikasi Nyata

* **Automated Tests:** Seluruh 7 pengujian lulus (`flutter test test/features/authentication/`).
* **Static Analysis:** `flutter analyze` $\rightarrow$ 0 error.
* **Verifikasi Basis Data Live:** Pengujian live akun `zikriahmadamikom@gmail.com` berhasil tersinkronisasi ke 6 tabel PostgreSQL:
  * `user` (Better Auth)
  * `account` (Google OAuth)
  * `users` (Amanah Core)
  * `staff_profiles` (Profil Staf)
  * `practitioners` (Praktisi Medis dengan STR)
  * `user_roles` (Role `staff_doctor`)
