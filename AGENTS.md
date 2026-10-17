# AGENTS.md — Mobile Architecture & Abstraction Standing Rules

> **Primary Source of Truth**: `rules/abstraction/paradigma.md`  
> **Reference Implementation**: `packages/amanah_healthcare/lib/features/authentication/`  
> **Paradigm**: Feature-First Clean Architecture berbasis OOP & SOLID

---

## 1. Core Engineering Principle: Feature-First Clean Architecture

Setiap kali mengintegrasikan fitur baru atau memodifikasi fitur yang sudah ada di repositori mobile ini, tiru cara penulisan dan struktur direktori dari modul `authentication`.

### 1.1 Dependency Rule (Aturan Inti & Non-Negotiable)
Dependency kode hanya boleh menunjuk ke arah dalam. Layer dalam tidak boleh tahu layer luar.

```text
 Presentation ─────▶ Domain ◀───── Data
       │                ▲            │
       └──────▶ Core ◀──┴────────────┘     (Core = teknis lintas fitur)
```

1. **Domain Layer (`domain/`)**:
   - **Pure Dart**: DILARANG KERAS mengimpor `package:flutter`, `package:http`, atau `dart:io`.
   - Berisi: `entities/`, `repositories/` (abstract interface), `usecases/`, `policies/`, `failures/`.
2. **Data Layer (`data/`)**:
   - Mengimplementasikan kontrak yang dideklarasikan oleh Domain Layer.
   - Berisi: `datasources/`, `dto/`, `mappers/`, `endpoints/`, `repositories/` (`*RepositoryImpl`).
3. **Presentation Layer (`presentation/`)**:
   - Hanya berkomunikasi dengan Domain Layer (use case atau cubit/notifier/state).
   - DILARANG KERAS mengakses atau mengimpor Data Layer (`*Dto`, `*RemoteDataSource`, `*Impl`).
4. **Core Layer (`core/`)**:
   - Teknis lintas fitur (`core/network`, `core/constants`, `core/error`, `core/config`, `core/storage`).
   - DILARANG bergantung atau mengimpor kode dari `features/`.

---

## 2. Struktur Direktori Standar Per Fitur

```text
lib/features/<nama_fitur>/
├── <nama_fitur>.dart                   # Barrel export publik (hanya entity, abstract repo, usecase)
├── data/
│   ├── endpoints/<nama_fitur>_endpoints.dart
│   ├── dto/                            # Data Transfer Objects (*_dto.dart)
│   ├── mappers/                        # Pure mappers DTO -> Domain Entity (*_mapper.dart)
│   ├── datasources/                    # Remote & Local datasources
│   └── repositories/<nama_fitur>_repository_impl.dart
├── domain/
│   ├── entities/                       # Plain immutable Dart classes
│   ├── failures/                       # Domain specific failures
│   ├── policies/                       # Business validation rules / policies
│   ├── repositories/                   # Abstract interface class
│   └── usecases/                       # Single-responsibility use cases
└── presentation/
    ├── components/                     # Reusable atomic UI widgets
    ├── state/                          # Controllers / Cubits / Notifiers
    └── screens/                        # Page-level widgets
```

---

## 3. Aturan Abstraksi API & Zero Hardcoding

1. **Dilarang Keras Hardcode URL/Path**:
   - Dilarang merakit `Uri.parse('$_baseUrl/...')` secara manual di repository atau datasource.
   - Semua path API wajib dideklarasikan di class `*Endpoints` (misal `AuthEndpoints`, `QueueEndpoints`, `ScheduleEndpoints`).
2. **Dilarang Menggunakan Magic String**:
   - Header HTTP, auth scheme, mime type, client ID, dan error code wajib menggunakan konstanta terpusat dari `core/constants/`.
3. **Parsing JSON & Type Safety**:
   - Hindari akses `dynamic` mentah seperti `json['user']['name']`.
   - Gunakan `Dto.fromJson` yang aman dengan fallback terukur, lalu konversikan ke Domain Entity melalui class `Mapper`.
4. **Authorized Client**:
   - Endpoint terautentikasi wajib menggunakan `AuthorizedApiClient` (atau parameter `requiresAuth: true`), bukan menyusun header Bearer secara manual di datasource/repository.

---

## 4. UI Design System & Component Discipline

1. **Pills / Status Badges**:
   - Gunakan shell atom yang seragam (`AmanahStatusBadge`) yang didukung oleh `AmanahPillStyleService`.
   - Dilarang meng-inline style duplikat untuk status indikator; semua varian warna dan tone diatur terpusat.
2. **Modal & Bottom Sheet**:
   - Semua modal dan bottom sheet harus mendukung dismissibilitas luar (`isDismissible: true`, outside-tap dismissal) dan mengikuti signature design token Amanah.
3. **Skeleton & Empty State**:
   - Hindari menampilkan klaim "data kosong" secara prematur. Gunakan shimmer/skeleton saat fetching data berlangsung.
4. **Batas Ukuran File**:
   - Pertahankan batas maksimal 500 baris per file. Jika melebihi, pisahkan layer komponen/delegates ke file terpisah.
