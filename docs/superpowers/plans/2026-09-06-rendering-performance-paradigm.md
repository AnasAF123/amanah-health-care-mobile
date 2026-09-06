# Flutter Mobile Rendering Performance & Zero-Lag Three.js ID Card Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a permanent high-performance rendering architecture across the Amanah Healthcare Flutter app that eliminates the 10-second ID Card freeze via background pre-warming and local asset bundling, isolates widget rebuilds, and ensures 60/120 FPS gesture/animation smoothness.

**Architecture:** 
1. Create a singleton `AmanahLocalAssetServer` with persistent HTTP caching to serve WebGL/WASM assets over localhost without per-visit overhead.
2. Build an `AmanahDoctorIdCardWarmService` that pre-warms the Chromium WebView and Three.js scene off-screen post-boot, decoupling initialization from user interaction (Tap → Instant Reveal).
3. Vendor Three.js, GLTFLoader, and Rapier WASM locally inside `assets/amanah/id_card/web/vendor/`, eradicating unpkg/jsdelivr CDN network latency.
4. Optimize the Three.js runtime with DPR capping (`Math.min(devicePixelRatio, 1.5)`), pause/resume hooks, and GPU resource disposal.
5. Apply rebuild isolation, `RepaintBoundary` barriers, and granular `MediaQuery.sizeOf` across HomeShell and high-velocity gesture surfaces.

**Tech Stack:** Flutter 3.29+, Dart 3.10+, `webview_flutter` 4.13+, Three.js r160, Rapier3D WASM, Impeller/Vulkan.

**Spec:** `ci/reports/performance-issues/rendering.md`

---

## Global Constraints

- Never block the initial application boot or time-to-interactive (`runApp` and splash dismissal must remain instantaneous).
- All WebView assets (HTML, JS, CSS, WASM, 3D GLB models) must resolve 100% locally with zero internet/CDN dependencies.
- The warm WebView lifecycle must be memory-safe and leak-free: pause render loops and timers when hidden to consume 0% GPU in the background.
- Preserve existing theme tokens (`AmanahColorTokens`, `AmanahTypographyTokens`) and design system contracts.
- Maintain full test coverage; all existing and new tests must pass (`flutter test` exit code 0).

---

## Architecture Blueprint: The Warm WebView Flow

```
┌────────────────────────────────────────────────────────────────────────┐
│                        APPLICATION BOOT PHASE                          │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Native Splash displays immediately (masks engine start)              │
│ 2. runApp(AmanahApp) → HomeShell first frame mounts instantly           │
│ 3. Native Splash dismisses → User is interactive on Dashboard          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ post-frame callback (idle)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   BACKGROUND PRE-WARM SERVICE                          │
├────────────────────────────────────────────────────────────────────────┤
│ • AmanahLocalAssetServer binds once to 127.0.0.1:cached_port          │
│ • Local assets (Three.js, Rapier WASM, card.glb) served with immutable │
│   HTTP cache headers (zero CDN round-trips, zero network latency)      │
│ • Off-screen WebViewController initializes & loads index.html          │
│ • Three.js scene compiles shaders & renders first stable frame         │
│ • JS bridge emits 'WEBVIEW_READY' → AmanahDoctorIdCardWarmService.ready│
│ • Three.js render loop pauses (0% GPU consumed in background)          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ User taps "Kartu ID"
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        USER INTERACTION PHASE                          │
├────────────────────────────────────────────────────────────────────────┤
│ • Navigation to AmanahDoctorIdCardScreen is instantaneous (0ms wait)   │
│ • Pre-warmed WebView attached directly to view                         │
│ • JS bridge emits 'RESUME_ANIMATION' → 3D card spins smoothly         │
│ • On Back navigation: 'PAUSE_ANIMATION' emitted, controller retained   │
│ • Subsequent visits: Instant (already in memory)                       │
└────────────────────────────────────────────────────────────────────────┘
```

---

## File Map & Responsibilities

| File Path | Action | Responsibility |
|---|---|---|
| `lib/features/home/services/amanah_local_asset_server.dart` | `[NEW]` | Singleton HTTP asset server with immutable caching headers for WebGL/WASM assets |
| `lib/features/home/services/amanah_doctor_id_card_warm_service.dart` | `[NEW]` | Headless/warm lifecycle manager for the Doctor ID Card WebView & readiness state |
| `assets/amanah/id_card/web/vendor/three.module.js` | `[NEW]` | Local Three.js r160 ES module (eliminates unpkg.com dependency) |
| `assets/amanah/id_card/web/vendor/GLTFLoader.js` | `[NEW]` | Local GLTFLoader addon module (eliminates unpkg.com dependency) |
| `assets/amanah/id_card/web/vendor/rapier.es.min.js` | `[NEW]` | Local Rapier3D physics module (eliminates jsdelivr.net dependency) |
| `assets/amanah/id_card/web/index.html` | `[MODIFY]` | Switch importmap to local vendor scripts, remove Google Fonts, cap DPR to 1.5, add pause/resume hooks |
| `lib/features/home/presentation/components/amanah_doctor_id_card_components.dart` | `[MODIFY]` | Refactor `AmanahDoctorIdCardStage` to consume warm service instead of spawning ad-hoc server |
| `lib/features/home/presentation/screen/amanah_doctor_id_card_screen.dart` | `[MODIFY]` | Seamless instant mounting, graceful fallback placeholder while warming |
| `lib/features/home/presentation/screen/amanah_home_shell.dart` | `[MODIFY]` | Trigger background pre-warm in post-frame idle window |
| `pubspec.yaml` | `[MODIFY]` | Ensure `assets/amanah/id_card/web/vendor/` is registered in asset bundle |
| `test/features/home/amanah_doctor_id_card_warm_service_test.dart` | `[NEW]` | Unit & integration tests for warm service, local server, and readiness lifecycle |

---

## Tasks

### Task 1: Vendor Three.js, GLTFLoader, and Rapier Locally
**Files:**
- Create: `packages/amanah_healthcare/assets/amanah/id_card/web/vendor/three.module.js`
- Create: `packages/amanah_healthcare/assets/amanah/id_card/web/vendor/GLTFLoader.js`
- Create: `packages/amanah_healthcare/assets/amanah/id_card/web/vendor/rapier.es.min.js`
- Modify: `packages/amanah_healthcare/pubspec.yaml`
- Modify: `packages/amanah_healthcare/assets/amanah/id_card/web/index.html`

- [ ] **Step 1: Copy/vendor scripts into local vendor directory**
  Place local versions of Three.js r160, GLTFLoader, and Rapier3D inside `assets/amanah/id_card/web/vendor/`.
- [ ] **Step 2: Register vendor directory in `pubspec.yaml`**
  Add `- assets/amanah/id_card/web/vendor/` to flutter assets list.
- [ ] **Step 3: Update `index.html` importmap to local paths**
  ```html
  <script type="importmap">
    {
      "imports": {
        "three": "./vendor/three.module.js",
        "three/addons/loaders/GLTFLoader.js": "./vendor/GLTFLoader.js",
        "@dimforge/rapier3d-compat": "./vendor/rapier.es.min.js"
      }
    }
  </script>
  ```
- [ ] **Step 4: Remove external font requests from `index.html`**
  Replace `fonts.googleapis.com` with local system sans-serif font stack.
- [ ] **Step 5: Cap DPR and add pause/resume hooks in `index.html`**
  ```javascript
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
  let isAnimationActive = true;
  window.addEventListener('message', (event) => {
    if (event.data?.type === 'PAUSE_ANIMATION') isAnimationActive = false;
    if (event.data?.type === 'RESUME_ANIMATION') {
      isAnimationActive = true;
      requestAnimationFrame(animate);
    }
  });
  ```
- [ ] **Step 6: Commit changes**
  `git commit -m "perf(id-card): vendor 3D web assets locally and cap renderer DPR"`

---

### Task 2: Persistent Local Asset Server (`AmanahLocalAssetServer`)
**Files:**
- Create: `packages/amanah_healthcare/lib/features/home/services/amanah_local_asset_server.dart`
- Test: `packages/amanah_healthcare/test/features/home/amanah_local_asset_server_test.dart`

- [ ] **Step 1: Write unit test for `AmanahLocalAssetServer`**
  Verify server binds once, serves bundle assets with correct MIME types, and adds `Cache-Control: public, max-age=31536000, immutable`.
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement `AmanahLocalAssetServer`**
  - Singleton pattern (`AmanahLocalAssetServer.instance`).
  - Idempotent `start()` method returning port.
  - Streaming from `rootBundle` with appropriate `ContentType` mapping (`.wasm`, `.glb`, `.js`, `.html`, `.png`, `.svg`).
  - Immutable caching headers to enable Chromium disk cache.
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit changes**
  `git commit -m "feat(server): implement persistent local asset server with immutable caching"`

---

### Task 3: Background Pre-Warm Service (`AmanahDoctorIdCardWarmService`)
**Files:**
- Create: `packages/amanah_healthcare/lib/features/home/services/amanah_doctor_id_card_warm_service.dart`
- Test: `packages/amanah_healthcare/test/features/home/amanah_doctor_id_card_warm_service_test.dart`

- [ ] **Step 1: Write unit test for `AmanahDoctorIdCardWarmService`**
  Verify state transitions: `uninitialized` → `warming` → `ready`. Verify pause and resume calls.
- [ ] **Step 2: Run test to verify it fails**
- [ ] **Step 3: Implement `AmanahDoctorIdCardWarmService`**
  - Singleton instance holding `WebViewController?`.
  - `Future<void> warmUp(AmanahDoctorProfile profile)`:
    - Binds `AmanahLocalAssetServer`.
    - Creates headless `WebViewController` with `JavaScriptMode.unrestricted`.
    - Registers JavaScript channel `DoctorIdCardBridge` for `'WEBVIEW_READY'` signal.
    - Loads `_webRuntimeUri()`.
  - Methods: `pauseAnimation()`, `resumeAnimation()`, `updateProfile(profile)`.
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit changes**
  `git commit -m "feat(warm-service): create background pre-warm service for ID card WebView"`

---

### Task 4: Refactor `AmanahDoctorIdCardStage` & `AmanahDoctorIdCardScreen`
**Files:**
- Modify: `packages/amanah_healthcare/lib/features/home/presentation/components/amanah_doctor_id_card_components.dart`
- Modify: `packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_doctor_id_card_screen.dart`
- Test: `packages/amanah_healthcare/test/features/home/amanah_doctor_id_card_screen_test.dart`

- [ ] **Step 1: Update `AmanahDoctorIdCardStage`**
  - Connect to `AmanahDoctorIdCardWarmService.instance`.
  - If warm controller is ready, attach immediately.
  - If still warming, show sleek native fallback card (`_DoctorIdCardFace`) without blank lag.
  - Notify `resumeAnimation()` on mount and `pauseAnimation()` on unmount.
- [ ] **Step 2: Update `AmanahDoctorIdCardScreen`**
  - Instant transition without heavy synchronous init.
- [ ] **Step 3: Run existing and new screen tests**
- [ ] **Step 4: Commit changes**
  `git commit -m "refactor(id-card): integrate pre-warmed stage into doctor ID card screen"`

---

### Task 5: Boot Choreography in `AmanahHomeShell`
**Files:**
- Modify: `packages/amanah_healthcare/lib/features/home/presentation/screen/amanah_home_shell.dart`

- [ ] **Step 1: Schedule ID Card warm-up during idle post-frame window**
  ```dart
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmanahDoctorIdCardWarmService.instance.warmUp(
        amanahHomeDashboardData.profile,
      );
    });
  }
  ```
- [ ] **Step 2: Verify `AmanahHomeShell` rebuild isolation**
  Audit `_selectedTab` and store listeners so tab switching doesn't invalidate unrelated subtrees.
- [ ] **Step 3: Run test suite**
- [ ] **Step 4: Commit changes**
  `git commit -m "chore(boot): schedule non-blocking ID card pre-warming on home shell init"`

---

### Task 6: App-Wide Gesture & Rebuild Boundary Audit
**Files:**
- Audit & Modify:
  - `lib/features/home/presentation/screen/amanah_schedule_tab_screen.dart`
  - `lib/features/home/presentation/components/amanah_pull_to_refresh.dart`
  - `lib/features/presence/presentation/screen/amanah_presence_history_screen.dart`

- [ ] **Step 1: Ensure all continuous gesture callbacks operate without triggering full-screen rebuilds**
- [ ] **Step 2: Add `RepaintBoundary` around high-frequency animated layers**
- [ ] **Step 3: Verify all `MediaQuery` calls use `MediaQuery.sizeOf(context)`**
- [ ] **Step 4: Run full analyzer and test suite**
- [ ] **Step 5: Commit changes**
  `git commit -m "perf(rendering): apply repaint boundaries and rebuild isolation on gesture surfaces"`

---

## Verification Plan

### Automated Tests
```bash
# 1. Analyze entire package
cd packages/amanah_healthcare
flutter analyze lib/features/home/services/ lib/features/home/presentation/screen/ lib/features/home/presentation/components/

# 2. Run targeted ID card & warm service tests
flutter test test/features/home/amanah_doctor_id_card_screen_test.dart test/features/home/amanah_doctor_id_card_warm_service_test.dart

# 3. Run complete test suite
flutter test
```

### Manual Verification
1. **Cold Boot Test**: Launch app. Verify home dashboard displays immediately with zero splash freeze.
2. **ID Card Instant Reveal Test**: Tap "Kartu ID" from Home dashboard. The 3D card with lanyard appears immediately without a 10-second wait or blank screen.
3. **Repeated Navigation Test**: Tap Back, then tap "Kartu ID" again. Card is already resident, interactive, and responsive.
4. **Gesture Smoothness**: Drag lanyard and flip card in 3D; pull-to-refresh on schedule tab; verify fluid 60/120 FPS motion without frame drops.
5. **Offline Mode**: Enable Airplane mode. Open ID Card. Verify 100% functionality without internet connection.
