# Frontend Authentication Compatibility Report: Flutter Mobile vs. Better Auth Backend

> **Scope:** Verification of the existing Flutter Authentication Module against the verified Backend Authentication Contract  
> **Auditor:** Senior Flutter Frontend Engineer  
> **Verification Date:** 2026-09-20  
> **Target Package:** `packages/amanah_healthcare`  
> **Backend Contract Version:** 1.0.0 (`/api/auth/*` & `/api/v1/*`, NestJS 11 + Better Auth v1.7.5)  
> **Artifact Path:** `docs/frontend/authentication-mobile-compatibility-report.md`  
> **Status:** ⚠️ **Partially Compatible** (Frontend UI/UX flows present; networking, persistence, and role mapping adjustments required)

---

## 1. Executive Summary & Compatibility Overview

### 1.1 Summary
The Flutter mobile application (`packages/amanah_healthcare`) was audited against the authoritative **Backend Authentication Contract (v1.0.0)** produced by the backend reality verification process. 

The existing Flutter authentication presentation layer demonstrates high architectural maturity, featuring complete UI organisms for sign-in, registration, OTP verification, password change, and logout confirmation, alongside security-conscious UX (OWASP-compliant generic error messaging and simultaneous field error highlighting).

However, the **data layer, networking, session lifecycle, and authorization mechanisms are currently entirely mock-based**. The repository uses an in-memory state orchestrator and loads static credentials from a local JSON asset (`assets/amanah/auth/auth_credentials.json`). There is currently no HTTP client (`http`, `dio`), no secure storage (`flutter_secure_storage`), no session restoration on launch (`GET /api/auth/get-session`), and no role mapping for Better Auth's `'staffDoctor'`, `'staffMidwife'`, `'staffWorker'`, `'admin'`, or rejection of `'patient'`.

### 1.2 Overall Classification: ⚠️ Partially Compatible
- **UI & UX Layer:** ✅ **Compatible** (All required screens, form fields, validation rules, and password strength requirements match backend expectations).
- **Network & Data Layer:** ❌ **Not Compatible** (Pure mock simulation; requires HTTP client integration and endpoint wiring).
- **Session Lifecycle:** ❌ **Not Compatible** (Ephemeral in-memory state; requires `flutter_secure_storage` and splash restoration).
- **Staff-Only Authorization:** ⚠️ **Partially Compatible** (Supports `doctor` and `staff` enums, but lacks Better Auth role mapping and patient denial).

**Conclusion:** Minimal, targeted adjustments to the data/repository layer, storage, and role mapping are required before the Flutter application can consume the verified backend contract. No UI redesign or component rewrite is needed.

---

## 2. Existing Flutter Authentication Inventory

| Component / Layer | Existing Implementation Path | Type / Mechanism | Evidence & Notes |
| :--- | :--- | :--- | :--- |
| **Auth Screen Orchestrator** | `lib/features/authentication/presentation/screen/auth_bottom_sheet_screen.dart` | `StatefulWidget` (`_AuthBottomSheetScreenState`) | Lines 1–689. Manages sheet modes, controllers, loading states, and shell switching. |
| **Sign In Organism** | `lib/features/authentication/presentation/organisms/sign_in_content.dart` | `StatelessWidget` | Lines 1–130. Accepts email/phone and password, displays generic error message. |
| **Sign Up Organism** | `lib/features/authentication/presentation/organisms/sign_up_content.dart` | `StatelessWidget` | Lines 1–169. Collects name, email, phone, password, confirm password. |
| **Forgot Password Organism** | `lib/features/authentication/presentation/organisms/forgot_password_content.dart` | `StatelessWidget` | Lines 1–61. Email input for OTP request. |
| **OTP Verification Organism** | `lib/features/authentication/presentation/organisms/otp_verification_content.dart` | `StatefulWidget` | Lines 1–84. 6-box OTP entry with countdown mockup (`00:43`). |
| **Change Password Organism** | `lib/features/authentication/presentation/organisms/change_password_content.dart` | `StatelessWidget` | Lines 1–87. New password, confirm password, password strength meter. |
| **Success Organism** | `lib/features/authentication/presentation/organisms/password_changed_success_content.dart` | `StatefulWidget` | Lines 1–355. 72-particle confetti canvas and checkmark badge. |
| **Social Button Molecule** | `lib/features/authentication/presentation/components/social_auth_button.dart` | `StatelessWidget` | Lines 1–76. Google OAuth button with SVG asset. |
| **Auth Repository** | `lib/features/authentication/data/amanah_auth_repository.dart` | Mock Asset Reader | Lines 1–46. Loads `auth_credentials.json`, 650ms artificial delay. |
| **Auth User Model** | `lib/features/authentication/domain/amanah_auth_user.dart` | Immutable Model | Lines 1–43. Holds `id`, `role`, `fullName`, `email`, `phone`, `password`, `isEmailVerified`. |
| **Password Rules Evaluator** | `lib/features/authentication/presentation/state/password_requirements.dart` | Helper / Evaluator | Lines 1–88. Evaluates length, uppercase/lowercase, numbers, symbols. |
| **API / HTTP Client** | `packages/amanah_healthcare/pubspec.yaml` | **None** | No `http`, `dio`, or `flutter_better_auth` in dependencies. |
| **Local / Secure Storage** | `packages/amanah_healthcare/pubspec.yaml` | **None** | No `flutter_secure_storage` or `shared_preferences` for auth state. |
| **State Management** | Pure `setState` | In-memory | Held in `_AuthBottomSheetScreenState._authenticatedUser`. |
| **Routing / Guards** | Conditional widget tree | In-widget check | `if (_authenticatedUser != null) AmanahHomeShell(...) else Scaffold(...)`. |
| **Logout Handler** | `lib/features/home/presentation/screen/amanah_home_shell.dart`<br>`amanah_account_tab_screen.dart` | Dialog + Callback | Lines 94–113 (home shell), lines 1674–1696 (account tab). |
| **Existing Unit Tests** | `test/features/authentication/auth_sign_in_content_test.dart` | Widget Tests | Lines 1–163. Tests initial state, error states, and credential changes. |

---

## 3. Backend-to-Flutter Contract Matrix

| Backend Contract Requirement | Existing Flutter Implementation | Status | Evidence | Identified Gap |
| :--- | :--- | :---: | :--- | :--- |
| **1. Sign In (Email/Password)**<br>`POST /api/auth/sign-in/email`<br>Body: `{ email, password }` | `SignInContent`<br>`_handleEmailAuth()` | ⚠️ Partial | `auth_bottom_sheet_screen.dart:212-243`<br>`sign_in_content.dart:1-130` | UI and validation exist. However, calls mock `AmanahAuthRepository` instead of HTTP endpoint. Does not store session token. |
| **2. Google OAuth Native**<br>`POST /api/auth/sign-in/social`<br>Body: `{ provider: "google", idToken: { token: "..." } }` | `SocialAuthButton`<br>`_handleGoogleAuth()` | ⚠️ Partial | `auth_bottom_sheet_screen.dart:245-256`<br>`social_auth_button.dart:8-52` | UI button exists. Logic is purely simulated (700ms delay toast). `google_sign_in` plugin not yet integrated. |
| **3. Request Password Reset OTP**<br>`POST /api/auth/email-otp/request-password-reset`<br>Body: `{ email }` | `ForgotPasswordContent`<br>`_handleForgotPassword()` | ⚠️ Partial | `auth_bottom_sheet_screen.dart:272-288`<br>`forgot_password_content.dart:1-61` | UI exists and validates email format. Does not call backend endpoint; triggers local mode switch after 650ms. |
| **4. Check Verification OTP**<br>`POST /api/auth/email-otp/check-verification-otp`<br>Body: `{ email, type: "forget-password", otp }` | `OtpVerificationContent`<br>`_handleVerifyOtp()` | ⚠️ Partial | `auth_bottom_sheet_screen.dart:290-307`<br>`otp_verification_content.dart:1-84` | 6-digit input UI exists. Does not dispatch OTP verification to backend; switches mode locally after 650ms. |
| **5. Reset Password**<br>`POST /api/auth/email-otp/reset-password`<br>Body: `{ email, otp, password }` | `ChangePasswordContent`<br>`_handleChangePassword()` | ⚠️ Partial | `auth_bottom_sheet_screen.dart:309-335`<br>`change_password_content.dart:1-87` | UI, password meter, and confirmation matching exist. Does not send new password to backend endpoint. |
| **6. Session Restoration**<br>`GET /api/auth/get-session`<br>Header: `Authorization: Bearer <token>` | **None** | ❌ Not Compatible | `auth_bottom_sheet_screen.dart:45, 676` | On cold start, `_authenticatedUser` is always `null`. No check to backend `get-session` exists. |
| **7. Sign Out / Logout**<br>`POST /api/auth/sign-out`<br>Header: `Authorization: Bearer <token>` | `AmanahHomeShell._handleLogout()` | ⚠️ Partial | `amanah_home_shell.dart:94-113`<br>`auth_bottom_sheet_screen.dart:680-684` | Confirmation dialog and local state reset exist. Does not call backend `sign-out` endpoint or clear storage. |
| **8. Bearer Token Transport**<br>`Authorization: Bearer <session_token>` | **None** | ❌ Not Compatible | `pubspec.yaml` (no HTTP client) | No HTTP client configured with auth headers or interceptors. |
| **9. Staff-Only RBAC Enforcement**<br>Allow: `staffDoctor`, `staffMidwife`, `staffWorker`, `admin`<br>Reject: `patient` (403/logout) | `AmanahUserRole` (`doctor`, `staff`) | ⚠️ Partial | `amanah_auth_user.dart:21-43` | Model has `doctor` and `staff` enums, but does not recognize Better Auth role strings or reject `'patient'`. |
| **10. Local Session Storage**<br>Key: `'amanah_auth_token'` in secure storage | **None** | ❌ Not Compatible | `pubspec.yaml` (no secure storage) | Tokens are not stored; session is lost upon app process termination. |

---

## 4. Authentication Flow Traces (Current vs. Contract)

### 4.1 Sign In Flow
- **Current Flow:**
  ```text
  SignInContent (masuk)
  → _handleEmailAuth() [auth_bottom_sheet_screen.dart:212]
  → AmanahAuthRepository.authenticate() [amanah_auth_repository.dart:15]
  → rootBundle.loadString('assets/amanah/auth/auth_credentials.json')
  → returns AmanahAuthUser
  → setState(_authenticatedUser = user)
  → switches to AmanahHomeShell
  ```
- **Contract Target Flow:**
  ```text
  SignInContent (masuk)
  → AuthRepository.signIn(email, password)
  → HTTP POST /api/auth/sign-in/email
  → Better Auth returns { token, user }
  → Validate user.role != 'patient'
  → flutter_secure_storage.write(key: 'amanah_auth_token', value: token)
  → Update auth state with AmanahAuthUser
  → switches to AmanahHomeShell
  ```

### 4.2 Sign Up Flow
- **Current Flow:**
  `SignUpContent` collects fields $\rightarrow$ validates password requirements $\rightarrow$ `_handleSignUp()` simulates 700ms delay $\rightarrow$ shows toast $\rightarrow$ switches back to `AuthSheetMode.signIn`.
- **Contract Finding:** The Backend Authentication Contract explicitly notes that the mobile application is **strictly staff-oriented** (`staffDoctor`, `staffMidwife`, `staffWorker`, `admin`). Self-registration of medical staff via mobile is not exposed by the backend; staff accounts are provisioned via administrative channels. The frontend sign-up button can either route to an administrative inquiry or consume `/api/auth/sign-up/email` if enabled.

### 4.3 Google OAuth Flow
- **Current Flow:**
  `SocialAuthButton` $\rightarrow$ `_handleGoogleAuth()` $\rightarrow$ 700ms delay $\rightarrow$ displays demo toast.
- **Contract Target Flow:**
  `SocialAuthButton` $\rightarrow$ `GoogleSignIn.signIn(serverClientId: WEB_CLIENT_ID)` $\rightarrow$ get `idToken` $\rightarrow$ HTTP POST `/api/auth/sign-in/social` with `{ provider: "google", idToken: { token: idToken } }` $\rightarrow$ Better Auth returns session token $\rightarrow$ write to secure storage $\rightarrow$ launch `AmanahHomeShell`.

### 4.4 Password Recovery Flow (OTP)
- **Current Flow:**
  `ForgotPasswordContent` (email) $\rightarrow$ 650ms delay $\rightarrow$ `OtpVerificationContent` (6 digits) $\rightarrow$ 650ms delay $\rightarrow$ `ChangePasswordContent` (new password) $\rightarrow$ 700ms delay $\rightarrow$ `PasswordChangedSuccessContent` $\rightarrow$ Sign In.
- **Contract Target Flow:**
  1. `ForgotPasswordContent`: `POST /api/auth/email-otp/request-password-reset` with `{ email }`.
  2. `OtpVerificationContent`: `POST /api/auth/email-otp/check-verification-otp` with `{ email, type: "forget-password", otp }`.
  3. `ChangePasswordContent`: `POST /api/auth/email-otp/reset-password` with `{ email, otp, password }`.
  4. `PasswordChangedSuccessContent`: Displays celebration animation $\rightarrow$ redirects to Sign In.

### 4.5 Logout Flow
- **Current Flow:**
  `AmanahAccountTabScreen` $\rightarrow$ `_LogoutButton` $\rightarrow$ `AmanahHomeShell._handleLogout()` $\rightarrow$ `showAmanahConfirmationDialog` $\rightarrow$ `widget.onLogout()` $\rightarrow$ `setState(_authenticatedUser = null)` $\rightarrow$ landing screen.
- **Contract Target Flow:**
  User confirms logout $\rightarrow$ `HTTP POST /api/auth/sign-out` with `Authorization: Bearer <token>` $\rightarrow$ `flutter_secure_storage.delete(key: 'amanah_auth_token')` $\rightarrow$ `googleSignIn.signOut()` $\rightarrow$ `setState(_authenticatedUser = null)` $\rightarrow$ landing screen.

---

## 5. Session Lifecycle Contract Audit

```text
App Cold Launch
    ↓
Auth Initialization (Splash / App Start)
    ↓
Check flutter_secure_storage ('amanah_auth_token')
    ├─ Token Found → HTTP GET /api/auth/get-session (Authorization: Bearer <token>)
    │                  ├─ 200 OK with User → Map to AmanahAuthUser → Render AmanahHomeShell
    │                  └─ 200 with null / 401 → Delete token → Render AuthBottomSheetScreen (SignIn)
    └─ No Token → Render AuthBottomSheetScreen (Initial Landing)
```

- **Current Repository Reality:** No session restoration exists. The app launches unconditionally into `AuthBottomSheetScreen` with `_authenticatedUser = null`.
- **Session Expiration Reality:** If a clinical API request returns 401 Unauthorized, there is currently no global interceptor to catch the error, purge the local session, and navigate back to the sign-in modal.

---

## 6. API Contract Compatibility Matrix

| Operation | Backend Contract Endpoint & Method | Backend Request Payload | Backend Response Payload | Current Flutter Request & Model | Compatibility | Evidence |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **Sign In** | `POST /api/auth/sign-in/email` | `{"email": "...", "password": "..."}` | `{"token": "...", "user": {"id": "...", "name": "...", "email": "...", "role": "staffDoctor", ...}}` | `identifierController.text`, `passwordController.text` via `AmanahAuthRepository` | ⚠️ Partial | `sign_in_content.dart:28`<br>`amanah_auth_repository.dart:15` |
| **Google Sign-In** | `POST /api/auth/sign-in/social` | `{"provider": "google", "idToken": {"token": "..."}}` | `{"token": "...", "user": {...}}` | None (Mocked toast) | ❌ Not Compatible | `auth_bottom_sheet_screen.dart:245` |
| **Request Reset OTP** | `POST /api/auth/email-otp/request-password-reset` | `{"email": "..."}` | `{"success": true}` | None (Local mode switch) | ⚠️ Partial | `auth_bottom_sheet_screen.dart:272` |
| **Verify Reset OTP** | `POST /api/auth/email-otp/check-verification-otp` | `{"email": "...", "type": "forget-password", "otp": "..."}` | `{"success": true}` | None (Local mode switch) | ⚠️ Partial | `auth_bottom_sheet_screen.dart:290` |
| **Reset Password** | `POST /api/auth/email-otp/reset-password` | `{"email": "...", "otp": "...", "password": "..."}` | `{"success": true}` | None (Local mode switch) | ⚠️ Partial | `auth_bottom_sheet_screen.dart:309` |
| **Get Session** | `GET /api/auth/get-session` | None (Bearer header) | `{"session": {...}, "user": {...}}` | None | ❌ Not Compatible | Not implemented |
| **Sign Out** | `POST /api/auth/sign-out` | None (Bearer header) | `{"success": true}` | None (Local nullification) | ⚠️ Partial | `amanah_home_shell.dart:94` |

---

## 7. Staff Authorization & Role Mapping Compatibility

### 7.1 Backend Role Taxonomy vs. Flutter Models
The backend contract defines exact user roles:
- `'staffDoctor'`: Medical doctor
- `'staffMidwife'`: Midwife / clinical nurse
- `'staffWorker'`: General clinic staff
- `'admin'`: System administrator
- `'patient'`: External patient (must be rejected on mobile)

### 7.2 Existing Flutter Role Model (`AmanahAuthUser`)
`packages/amanah_healthcare/lib/features/authentication/domain/amanah_auth_user.dart`:
```dart
enum AmanahUserRole { doctor, staff }
```
- **Mapping Compatibility:**
  - `'staffDoctor'` $\rightarrow$ `AmanahUserRole.doctor`
  - `'staffMidwife'` $\rightarrow$ `AmanahUserRole.staff`
  - `'staffWorker'` $\rightarrow$ `AmanahUserRole.staff`
  - `'admin'` $\rightarrow$ `AmanahUserRole.staff`
  - `'patient'` $\rightarrow$ **Explicit Denial & Sign-out** (Must display: *"Akun Anda terdaftar sebagai pasien. Aplikasi ini khusus staf medis klinik."*)
- **Identified Gap:** Flutter does not currently inspect or parse these specific backend strings, nor does it enforce the rejection of the `'patient'` role.

---

## 8. Android Platform & Network Security Audit (Skill Alignment)

Per the `flutter-better-auth-android` skill guidelines:
1. **Cleartext Traffic for Android Emulator (`10.0.2.2`)**:
   - Existing: [`packages/amanah_healthcare/android/app/src/main/res/xml/amanah_network_security_config.xml`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/android/app/src/main/res/xml/amanah_network_security_config.xml#L4) only permits `127.0.0.1`.
   - **Gap:** Android emulator accessing host backend `http://10.0.2.2:3001` will fail unless `10.0.2.2` is added to `amanah_network_security_config.xml` (or debug manifest).
2. **Keystore Backup Vulnerability**:
   - Existing: [`AndroidManifest.xml:25`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/android/app/src/main/AndroidManifest.xml#L25) sets `android:allowBackup="true"`.
   - **Recommendation:** Set `android:allowBackup="false"` to prevent Android Auto Backup from restoring encrypted storage without the Keystore key (`InvalidKeyException: Failed to unwrap key`).
3. **Internet Permission**:
   - [`AndroidManifest.xml:5`](file:///D:/amanah-healthcare-mobile/packages/amanah_healthcare/android/app/src/main/AndroidManifest.xml#L5) already includes `<uses-permission android:name="android.permission.INTERNET"/>` in the main manifest. ✅

---

## 9. Conclusion & Decision

The existing Flutter Authentication Module is **Partially Compatible (⚠️)** with the Backend Authentication Contract. 

Because concrete gaps exist (mock repository, absent HTTP client, absent secure storage, missing session restoration, and unmapped roles), an **Adjustment Plan** has been produced in [`docs/frontend/authentication-mobile-adjustment-plan.md`](file:///D:/amanah-healthcare-mobile/docs/frontend/authentication-mobile-adjustment-plan.md). No implementation changes have been made during this verification phase.
