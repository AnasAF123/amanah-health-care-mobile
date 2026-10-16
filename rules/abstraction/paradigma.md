# paradigma.md — Paradigma & Aturan Abstraksi (Flutter/Dart)

> Acuan untuk memecah `AmanahAuthRepository` (400+ baris, satu class mengerjakan semuanya) menjadi layer yang modular, bebas hardcode URL, dan berbasis OOP + inheritance.

**Isi dokumen**

0. Nama paradigma
1. Diagnosa kode saat ini
2. Layer & modularitas
3. Struktur direktori hasil akhir
4. Aturan abstraksi — Dart convention & clean code
5. Aturan abstraksi constant
6. API Layer tanpa hardcode URL
7. OOP & inheritance
8. Alur akhir & contoh hasil refactor
9. Checklist review & rencana migrasi

---

## 0. Nama Paradigma

Pendekatan ini bukan satu nama tunggal, melainkan susunan bertingkat:

| Tingkat | Nama | Peran |
|---|---|---|
| Paradigma pemrograman | **Object-Oriented Programming (OOP)** | Abstraction, Encapsulation, Inheritance, Polymorphism |
| Gaya arsitektur | **Clean Architecture** (Robert C. Martin), varian **Layered + Feature-First** | Kode dipisah per layer; dependency hanya menunjuk ke dalam |
| Prinsip desain | **SOLID**, DRY, KISS, Separation of Concerns | Ukuran "bersih" / "tidak bersih" |
| Pola desain | **Repository**, **Template Method** (inheritance), **Adapter/Mapper**, Strategy, Factory | Solusi konkret per masalah |
| Konvensi kode | **Effective Dart** + lint | Gaya penulisan |

**Nama singkat yang dipakai di proyek: _Feature-First Clean Architecture berbasis OOP & SOLID_.**

### Dependency Rule (aturan inti)

Dependency kode hanya boleh menunjuk ke arah dalam. Layer dalam tidak boleh tahu layer luar.

```text
 Presentation ─────▶ Domain ◀───── Data
       │                ▲            │
       └──────▶ Core ◀──┴────────────┘     (Core = teknis lintas fitur)
```

- **Domain** = Dart murni. Tidak mengimpor `flutter`, `package:http`, `dart:io`.
- **Data** meng-*implements* kontrak yang dideklarasikan Domain (Dependency Inversion).
- **Presentation** hanya bicara ke Domain (use case), tidak pernah langsung ke Data.

---

## 1. Diagnosa Kode Saat Ini

### 1.1 Temuan pelanggaran clean code

| # | Temuan | Bukti di kode | Prinsip yang dilanggar |
|---|---|---|---|
| 1 | **God Class** | Satu class mengurus: base URL, HTTP client, header, login, Google login, session, sign-out, OTP reset password, daftar klinik, onboarding staf, avatar, parsing JSON, mapping error, penyimpanan token | SRP, Separation of Concerns |
| 2 | **URL & path hardcode** | 12 literal path tersebar (`'/api/v1/auth/email/login'`, `'/api/auth/sign-out'`, `'/api/v1/clinics'`, ...) dirakit manual lewat `Uri.parse('$_baseUrl/...')` | DRY, OCP. Ganti versi API = edit belasan tempat |
| 3 | **Prefix API tidak konsisten** | `/api/v1/auth/...` (NestJS) bercampur `/api/auth/...` (sign-out, OTP) | Indikasi endpoint legacy yang belum dipisah |
| 4 | **Magic string** | `'mobile-internal'`, `'CLIENT_NOT_ALLOWED'`, `'ACCOUNT_INACTIVE'`, `'NOT_AUTHORIZED'`, `'forget-password'`, `'Authorization'`, `'Bearer'`, `'AH'`, kunci JSON `'token'`, `'user'`, `'role'` | Tidak ada literal bermakna di dalam logika |
| 5 | **Duplikasi** | Blok sukses login email identik dengan login Google. Ekstraksi `role` diulang 3x. Blok parsing error diulang 3x | DRY |
| 6 | **Aturan bisnis di Data layer** | Keputusan "pasien dilarang masuk aplikasi staf" + `signOut` ada di repository | Dependency Rule: bisnis harus di Domain |
| 7 | **Teks UI di Data layer** | Pesan Indonesia (`'Kombinasi email atau kata sandi salah...'`) di-hardcode di repository | Tidak bisa di-l10n, melanggar layering |
| 8 | **Alur exception berbelit** | `throw` di dalam `try`, lalu `catch (e) { if (e is ...) rethrow; }` (*exception as control flow*). Jika `AmanahAuthPatientRestrictedException` bukan subtype `AmanahAuthException`, error khusus itu tertelan jadi pesan generik (perlu dicek) | Error handling harus terpusat |
| 9 | **Error ditelan / perilaku berisiko** | `getSession()` menghapus token pada *semua* status non-200 (termasuk 500), sehingga user ter-logout saat server bermasalah. `catch (_)` menelan semua error. OTP/reset hanya mengembalikan `bool` | Fail loudly; hapus token hanya pada 401 |
| 10 | **Akses `dynamic` & cast tak aman** | `userMap['role']['code']`, `errorData['error']?['message']` | Effective Dart: hindari `dynamic` |
| 11 | **Dependency tersembunyi** | `AmanahHttpClient.instance` dan `AmanahAuthEnvironment.authBaseUrl` (static) dipanggil langsung, sulit di-test | Dependency Inversion |
| 12 | **Flag argument & parameter ambigu** | `uploadAvatar(useAuthAlias: true)` mengganti method *dan* path; `fileBytes` vs `filePath` sama-sama nullable | Clean Code: no flag arguments |
| 13 | **Entity memuat detail teknologi** | `AmanahAuthUser.fromBetterAuthJson`: entity domain tahu format JSON dan nama library lama, padahal backend sekarang NestJS | Domain harus bebas dari format data |
| 14 | **Cakupan fitur campur** | Clinics, avatar, onboarding, OTP ikut di "AuthRepository" | Modularitas |
| 15 | **Barrel `export` repository lain** | `export '...staff_credential_repository.dart'` dari dalam sebuah repository | Coupling tersembunyi |

### 1.2 Apakah ini spaghetti code?

Jawaban jujur: **bukan spaghetti klasik** (alur tidak melompat-lompat antar file), tetapi **God Class + duplicate code + magic string**. Efek bacanya memang mirip spaghetti: method `authenticate()` sepanjang ±70 baris dengan `if/else` dan `try/catch` bersarang 3-4 level. Untuk memahami satu kata "login", pembaca harus membaca HTTP, JSON, aturan bisnis, dan pesan UI sekaligus. Itu sebabnya terasa susah dibaca, dan penilaian itu benar.

### 1.3 Pemetaan: tanggung jawab lama → class baru → layer

| Tanggung jawab lama (di `AmanahAuthRepository`) | Class baru | Layer |
|---|---|---|
| `_baseUrl` | `AppConfig.apiBaseUrl` | `core/config` |
| `_httpClient`, `_post`, `_get` | `ApiClient`, `BaseApiClient`, `HttpApiClient` | `core/network` |
| Header `Authorization` manual di tiap method | `AuthorizedApiClient` + `ApiEndpoint.requiresAuth` | `core/network` |
| String path | `AuthEndpoints`, `ClinicEndpoints`, `UserEndpoints` | `features/*/data/endpoints` |
| `'Content-Type'`, `'application/json'`, `'Bearer'` | `HttpHeaderNames`, `MimeTypes`, `AuthSchemes` | `core/constants` |
| `'mobile-internal'` | `ClientId.mobileInternal` | `core/constants` |
| Kode error string | `ApiErrorCode` (enum) | `core/constants` |
| `jsonDecode` + cast `dynamic` | `AuthSessionDto`, `UserDto`, `ClinicDto` | `features/*/data/dto` |
| Ekstraksi `role`, default `needsOnboarding` | `AuthSessionMapper` | `features/*/data/mappers` |
| Aturan "pasien dilarang" | `PatientAccessPolicy` | `features/authentication/domain/policies` |
| Login email & Google (duplikat) | `SignInUseCase` → `SignInWithEmail`, `SignInWithGoogle` | `features/authentication/domain/usecases` |
| Pesan error Indonesia | `AuthFailure` (domain) + extension l10n | `domain/failures` + `presentation/l10n` |
| Token storage | `AuthLocalDataSource` (membungkus `AmanahAuthTokenStorage`) | `features/authentication/data` |
| Session restore, sign-out | `RestoreSession`, `SignOut` | `features/authentication/domain/usecases` |
| OTP / reset password | `PasswordRecoveryRepository` | `features/password_recovery` |
| Daftar poliklinik | `ClinicRepository` | `features/clinic` |
| Onboarding staf | `StaffOnboardingRepository` | `features/staff_onboarding` |
| Avatar upload/delete | `AvatarRepository` | `features/profile` |
| `export` repository lain | Dihapus; pakai barrel per fitur | per fitur |

---

## 2. Layer dan Modularitas

### 2.1 Nama layer

| Layer | Folder | Isi | Boleh bergantung pada |
|---|---|---|---|
| **Presentation Layer** | `presentation/` | Page, widget, state (Cubit/Bloc/Notifier), pemetaan Failure → teks l10n | Domain, Core |
| **Domain Layer** | `domain/` | Entity, Repository (abstract), UseCase, Policy, Failure | Core (hanya Dart murni) |
| **Data Layer** | `data/` | DataSource, DTO, Mapper, Endpoints, RepositoryImpl | Domain, Core |
| **Core / Infrastructure** | `core/` | **API Layer** (`core/network`), config, constants, error, storage | Tidak ke `features/` |

### 2.2 Aturan import antar layer

| Dari ↓ / Import → | presentation | domain | data | core |
|---|---|---|---|---|
| **presentation** | ✅ (fitur sama) | ✅ | ❌ | ✅ |
| **domain** | ❌ | ✅ | ❌ | ⚠️ hanya `core/error` & `core/usecase` |
| **data** | ❌ | ✅ | ✅ | ✅ |
| **core** | ❌ | ❌ | ❌ | ✅ |

Pengecualian tunggal: folder `app/di/` boleh mengimpor semuanya karena tugasnya merakit objek (wiring).

### 2.3 Aturan modularitas

1. **Satu fitur = satu modul mandiri** berisi tiga layer sendiri.
2. Fitur **tidak** mengimpor `data/` atau `presentation/` fitur lain. Hanya `domain/` (kontrak) atau `shared/`.
3. Kode yang dipakai ≥ 2 fitur naik ke `core/` (teknis) atau `shared/` (domain bersama, mis. `UserRole`).
4. Tiap fitur punya **satu barrel publik** (`authentication.dart`) yang hanya meng-export entity, repository abstract, dan use case. `data/` tidak di-export.
5. Pembuatan objek (`Impl`) hanya terjadi di `app/di/`.

---

## 3. Struktur Direktori Hasil Akhir

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── di/                                  # satu-satunya tempat yang tahu *Impl
│       ├── core_module.dart
│       └── authentication_module.dart
│
├── core/                                    # CORE: teknis, tanpa aturan bisnis fitur
│   ├── config/
│   │   ├── app_config.dart                  # abstract interface class AppConfig
│   │   ├── base_app_config.dart             # default bersama
│   │   ├── production_config.dart
│   │   └── staging_config.dart
│   ├── constants/                           # lihat §5
│   │   ├── api_prefix.dart
│   │   ├── api_error_code.dart
│   │   ├── client_id.dart
│   │   ├── auth_schemes.dart
│   │   ├── http_header_names.dart
│   │   └── mime_types.dart
│   ├── network/                             # API LAYER, lihat §6
│   │   ├── api_client.dart                  # abstract interface class
│   │   ├── base_api_client.dart             # template method
│   │   ├── http_api_client.dart             # implementasi package:http
│   │   ├── authorized_api_client.dart       # menambah Bearer token
│   │   ├── api_endpoint.dart                # HttpMethod + ApiEndpoint
│   │   ├── api_response.dart
│   │   ├── api_exception.dart               # sealed class (turunan 1 file)
│   │   └── auth_token_provider.dart         # abstract interface class
│   ├── error/
│   │   └── failure.dart                     # abstract class Failure
│   ├── usecase/
│   │   └── use_case.dart
│   └── storage/
│       └── secure_token_storage.dart        # ex AmanahAuthTokenStorage
│
├── shared/
│   └── domain/entities/user_role.dart
│
└── features/
    ├── authentication/                      # login, google, session, logout
    │   ├── authentication.dart              # barrel publik
    │   ├── data/
    │   │   ├── endpoints/auth_endpoints.dart
    │   │   ├── dto/
    │   │   │   ├── email_login_request_dto.dart
    │   │   │   ├── google_login_request_dto.dart
    │   │   │   ├── auth_session_dto.dart
    │   │   │   └── user_dto.dart
    │   │   ├── mappers/auth_session_mapper.dart
    │   │   ├── datasources/
    │   │   │   ├── auth_remote_data_source.dart
    │   │   │   └── auth_local_data_source.dart
    │   │   └── repositories/auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/{auth_user.dart, auth_session.dart}
    │   │   ├── failures/auth_failure.dart   # sealed class (turunan 1 file)
    │   │   ├── policies/patient_access_policy.dart
    │   │   ├── repositories/auth_repository.dart
    │   │   └── usecases/
    │   │       ├── sign_in_use_case.dart    # template method
    │   │       ├── sign_in_with_email.dart
    │   │       ├── sign_in_with_google.dart
    │   │       ├── restore_session.dart
    │   │       └── sign_out.dart
    │   └── presentation/
    │       ├── cubit/
    │       ├── pages/
    │       ├── widgets/
    │       └── l10n/auth_failure_message.dart
    │
    ├── password_recovery/                   # request OTP, verifikasi, reset
    │   ├── data/  (endpoints, dto, datasources, repositories)
    │   ├── domain/ (entities, failures, repositories, usecases)
    │   └── presentation/
    ├── staff_onboarding/                    # submit onboarding staf
    ├── clinic/                              # daftar poliklinik aktif
    └── profile/                             # upload & hapus avatar
```

Catatan penamaan: prefix `Amanah` pada setiap class (`AmanahAuthUser`, `AmanahHttpClient`) redundan karena nama package sudah menjadi namespace. Pertahankan hanya bila ada bentrok nama.
