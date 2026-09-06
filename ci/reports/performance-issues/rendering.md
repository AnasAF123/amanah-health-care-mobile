i am facing speed rendering performance animation issue on mobile android, 
give me best practing rendering speed on flutter mobile, caching state or what ever best practice speed, including if there is threejs webview inside it, so user can see the webview componetn speed and already been there, from initial booting, , give the  fully paradigm concept just concept on flutter mobile development, give inside markdown hyper detail contentsekarang perhatikan pada kartu id di situ kita punya webview isinya itu komponen three.JS nah di situ kita menghadapi tantangan rendering ya itu mendapatkan performa yang paling cepat baik itu Dia semu Luruh animasi Nggak cuman dia saja nah permasalahan yang sekarang itu adalah ketika user menekan tombol kartu ID dari homepage itu user melihat lag parah dan bahkan pernah tercatat itu 10 detik baru muncul kartu id-nya Jadi gimana caranya supaya dia itu dari awal booting itu sudah ada jadi dia di cache jadi Udah ready nggak ada performa yang patah atau apapun itu lah harusnya cepat secepat kilat gitu sama juga ketika user perform sliding up sliding down sliding slide pokoknya semuanya lah gitu semuanya itu harusnya mulus beranimasi mulus banget Gimana kamu supaya isu rendering ini itu jadi lebih terstruktur dan tidak ada overheadding yang terjadi mungkin dari sisi kode itu salah implementasinya atau mungkin ada semacam Prof drilling atau dan seterusnya atau mungkin state yang tidak teratur atau gimana saya nggak ngerti yang penting dicek dulu dan silahkan anda implementasi plan dulu planningnya dulu planning dulu secara mendalam baru kemudian ada eksekusi tapi begini ya hasilnya nanti ketika selesai ya itu user nggak melihat error ya harusnya ini# Flutter Mobile Rendering Performance, Animation Smoothness, and Zero-Lag WebView Architecture
# Flutter Android Performance Paradigm
### Rendering speed, state/cache strategy, cold-boot, and embedded Three.js WebView — a full conceptual playbook

> **Core idea in one sentence:** a fast Flutter app is the result of five compounding habits — *rebuild small, paint less, compute off the main thread, cache in layers, and warm up everything expensive before the user asks for it.* Everything below is a detailed expansion of those five habits, applied specifically to Android and to the hardest case: an embedded WebView running a Three.js scene.

---

## Part 0 — How to use this document

Each part below is a **paradigm**, not just a tip list: a mental model for *why* the problem happens, followed by the concrete practices that follow from that model. Read Part 1 first even if you only care about the WebView section (Part 8) — the WebView problems only make sense once you understand how Flutter composites frames in the first place.

---

## Part 1 — The rendering pipeline paradigm: how a frame actually happens

Flutter does not draw "widgets." It draws **pixels derived from three parallel trees**, on a strict time budget, across multiple threads. Every optimization in this guide is really just "reduce work in one of these stages."

### 1.1 The three trees

| Tree | What it holds | Lifespan |
|---|---|---|
| **Widget tree** | Immutable configuration objects (`Widget`) you write in `build()` | Recreated constantly, cheap to allocate |
| **Element tree** | Mutable "instances" that manage the widget's position in the tree and diffing | Persists across rebuilds, reused when `widget.runtimeType`/`key` match |
| **RenderObject tree** | Actual layout/paint logic (box constraints, offsets, painting) | Persists, only touched when layout/paint actually needs to change |

When you call `setState()`, you are **not** repainting the screen — you are asking Flutter to rebuild a `Widget` subtree, which Flutter then *diffs* against the existing `Element` tree. If the new widget is `==`-equivalent (same runtimeType + same `key`, and for `const` widgets, identical), Flutter can skip work entirely. This is the single most important fact in this whole document: **`setState` triggers a diff, not a redraw — but you control how expensive that diff is.**

### 1.2 The frame lifecycle

```
Build → Layout → Paint → Compositing → Rasterization → GPU present
```

- **Build**: your `build()` methods run, producing new Widget objects.
- **Layout**: RenderObjects compute size/position (single pass, parent-to-child constraints, child-to-parent sizes).
- **Paint**: RenderObjects record drawing instructions into `Layer`s (not pixels yet).
- **Compositing**: layers are merged into a final scene graph.
- **Rasterization**: the GPU actually turns the scene graph into pixels.

### 1.3 Threads

- **Platform thread** — Android's main UI thread; handles OS events, plugin/method-channel calls, and (historically) platform views.
- **UI thread** — runs your Dart `build`/`layout`/`paint` recording (the "Build → Paint" part above).
- **Raster thread** — takes the recorded layers and rasterizes them via the engine (Impeller/Skia).
- **IO thread** — decodes images and other async I/O off the hot path.

On modern Android with Impeller, some of this threading has been further merged/optimized for platform views specifically (see Part 8) — but the general model (don't block the UI thread, don't block the raster thread) still governs everything.

### 1.4 The budget

- 60 fps → **16.67 ms** per frame for the *entire* pipeline above.
- 120 fps (common on modern Android panels) → **8.33 ms** per frame.
- If Build+Layout+Paint+Raster exceeds this, you drop a frame → visible **jank**.

### 1.5 Skia → Impeller: the paradigm shift you should know about

Historically, Flutter's Skia renderer compiled GPU shaders **just-in-time**, the first time a given visual effect (a blur, a certain blend mode, a shadow) was encountered at runtime. That caused the infamous "shader compilation jank" — visible stutter the *first* time an animation or effect ran, especially right after app launch. Impeller replaces this with **ahead-of-time shader compilation** at build time, so the GPU never has to pause to compile mid-animation.

As of recent stable Flutter releases, Impeller is the **default renderer on both iOS and Android**, and the newest stable releases have gone further, removing the legacy Skia backend for Android 10+ entirely. Practical implication for you:

- Make sure you're on a current stable Flutter version — a large share of "random first-run jank" reports historically were pure Skia shader-compilation jank that simply disappears on Impeller.
- If you must support very old/low-end Android devices, verify Impeller isn't silently falling back to Skia (check logs for the active renderer) since some very old GPUs/driver combos are excluded.

---

## Part 2 — Jank taxonomy: know which problem you actually have

"It's laggy" is not a diagnosis. Route every symptom into one of these buckets before reaching for a fix:

| Symptom | Root cause | Where to look |
|---|---|---|
| Stutter only on first run of an animation/effect | Shader compilation jank | Confirm Impeller is active |
| Stutter during scroll/typing/list updates | **UI-thread jank** — expensive `build()`, heavy business logic, huge widget subtree rebuilding | DevTools CPU profiler, widget rebuild profiler |
| Stutter during blur/opacity/shadow-heavy animations, smooth otherwise | **Raster-thread jank** — expensive paint ops (`saveLayer`, `BackdropFilter`, clips) | DevTools "Raster" timeline track |
| Stutter specifically around a WebView/Map/native view | **Platform-view compositing jank** | See Part 8 |
| Gradual slowdown over a session | Memory pressure / leaks → GC pauses | DevTools Memory tab, look for retained images/controllers |
| Slow app open, fast afterward | Cold-start cost, not runtime rendering cost | See Part 7 |

---

## Part 3 — The "rebuild small, paint less" widget paradigm

### 3.1 `const` everything you can

A `const` widget is not just "immutable" — Flutter can skip *allocating a new instance at all* and skip the diff entirely, because the identical object reference is reused. This is free performance with zero runtime cost:

```dart
// Bad: new Text instance every rebuild, always diffed
Text('Loading...')

// Good: same instance, comparison short-circuits
const Text('Loading...')
```

Enable `prefer_const_constructors` and `prefer_const_literals_to_create_immutables` lints and treat warnings as build failures for release branches.

### 3.2 Split `build()` into small widgets — don't just inline

The **blast radius** of a rebuild is scoped to the widget whose `build()` you re-invoke. A single 300-line `build()` method means *any* state change inside that screen rebuilds all 300 lines' worth of widgets. Extract subtrees into their own `StatelessWidget`/`StatefulWidget` classes so that Flutter can skip rebuilding branches that don't depend on the changed state.

```dart
// Bad: header re-diffed every time the counter changes
Column(children: [ExpensiveHeader(), Text('$counter')])

// Good: ExpensiveHeader is const/extracted → never re-diffed on counter change
const Column(children: [ExpensiveHeader(), CounterText()])
```

### 3.3 `RepaintBoundary`: isolate paint, not just build

Even if a widget doesn't rebuild, its **paint layer** can still be forced to re-composite if a sibling changes. Wrap frequently-animating or expensive-to-paint widgets (custom painters, video players, WebViews, Lottie/Rive animations, complex gradients) in `RepaintBoundary` so their layer is cached independently and doesn't force neighboring content to re-rasterize.

```dart
RepaintBoundary(
  child: ExpensiveCustomPaintWidget(),
)
```

Rule of thumb: put a `RepaintBoundary` around anything that (a) animates continuously, or (b) is expensive to paint but visually static most of the time (a chart, a map, a WebView).

### 3.4 Avoid the "expensive widget" list — or box it

These widgets are individually cheap to *write* but expensive to **paint**, because they force `saveLayer` calls (an offscreen buffer allocation + composite) on the GPU:

- `Opacity` (animated) → prefer `AnimatedOpacity`/`FadeTransition`, or wrap the *result* in a single `RepaintBoundary` if opacity must be applied to a complex subtree.
- `BackdropFilter` / `ImageFilter.blur` → the most expensive common widget in Flutter; blurs the entire layer beneath it every frame. Cache a blurred snapshot instead of blurring live content when possible, and never stack multiple blurs.
- `ClipPath` / `ClipRRect` (complex paths) → prefer pre-clipped image assets or simple shapes (`ClipRRect` with a fixed small radius is fine; arbitrary bezier `ClipPath` on scrolling content is not).
- `ShaderMask` → similar cost profile to `BackdropFilter`.

### 3.5 Lists: never build what isn't visible

- Always use `ListView.builder`/`GridView.builder` (lazy) — never `ListView(children: [...huge list...])`.
- Give a fixed `itemExtent` (or `prototypeItem`) whenever row height is uniform — this lets Flutter skip a full layout pass to measure every item and jump straight to the right scroll offset.
- Use `Sliver`-based scrolling (`CustomScrollView` + `SliverList`/`SliverGrid`) when mixing headers, grids, and lists in one scrollable — one scroll physics/one viewport instead of nested scrollables fighting each other.
- Set `addAutomaticKeepAlives: false` / `addRepaintBoundaries: false` on `ListView.builder` when list items are simple and don't need state preservation — the defaults add safety overhead you may not need.
- Tune `cacheExtent` deliberately: too small causes visible pop-in during fast flings; too large wastes memory building off-screen items.

### 3.6 Scope `MediaQuery` reads

`MediaQuery.of(context)` rebuilds the calling widget on **any** metrics change (rotation, keyboard opening, text-scale change) even if you only used `.size`. Use the granular accessors instead so your widget only rebuilds for the dimension it actually depends on:

```dart
// Rebuilds on rotation, keyboard open/close, text scale change, brightness change...
final size = MediaQuery.of(context).size;

// Rebuilds ONLY when size changes
final size = MediaQuery.sizeOf(context);
```

### 3.7 Animate the cheap way

For `AnimatedBuilder`, pass unchanging content through the `child` parameter rather than rebuilding it inside the `builder` callback — this lets Flutter reuse that subtree across every animation tick instead of rebuilding it 60 times a second:

```dart
AnimatedBuilder(
  animation: controller,
  // Rebuilt every tick — keep tiny (just the transform/paint)
  builder: (context, child) => Transform.rotate(angle: controller.value * 6.28, child: child),
  // Built once, reused every tick
  child: const ExpensiveLogo(),
)
```

Always `dispose()` `AnimationController`/`Ticker` objects in `dispose()` — a leaked, still-ticking controller silently burns a frame budget forever.

---

## Part 4 — Off-main-thread computation paradigm

The UI thread must stay free for build/layout/paint. Anything CPU-heavy — JSON parsing of a large payload, image manipulation, encryption/hashing, complex sorting/filtering of large lists — belongs on a separate isolate:

```dart
final parsed = await compute(parseLargeJson, rawJsonString);
// or, more ergonomic:
final parsed = await Isolate.run(() => parseLargeJson(rawJsonString));
```

For images specifically, decode at the size you'll actually display, not full resolution — a 4000×3000 photo decoded to fill a 200×200 thumbnail wastes both CPU (decode time) and memory (the decoded bitmap is held in full size unless you tell Flutter otherwise):

```dart
Image.network(
  url,
  cacheWidth: 200, // decode at target size, not full resolution
)
```

Defer non-critical work (analytics pings, prefetching the *next* screen's data) with `WidgetsBinding.instance.addPostFrameCallback` so it runs after the current frame is safely on screen, not competing with it.

---

## Part 5 — State-management paradigm for speed

### 5.1 Three layers of state, three different lifetimes

1. **Ephemeral / local UI state** (a text field's focus, a tab index) → `setState` on the smallest possible `StatefulWidget`, or `ValueNotifier` + `ValueListenableBuilder`.
2. **App/shared state** (auth session, cart contents, theme) → a state-management library.
3. **Persisted state** (needs to survive app restarts) → see Part 6, the caching paradigm.

### 5.2 The one idea that matters: minimize rebuild "blast radius"

Every mainstream state-management library exists to solve one problem: *when data changes, rebuild only the widgets that actually read that specific slice of data* — not the whole screen. The mechanism differs, but the goal is identical:

| Library | Selective-rebuild mechanism |
|---|---|
| **Provider** | `Selector<T, R>`, or `context.select<T, R>(...)` |
| **Riverpod** | `ref.watch(provider.select((s) => s.field))` |
| **Bloc/Cubit** | `BlocSelector`, or `buildWhen:` on `BlocBuilder` |
| **GetX** | `.obs` reactive fields + `Obx(() => ...)` around the smallest possible widget |
| **setState (vanilla)** | Manual — push `setState` down into the smallest subtree, use `ValueListenableBuilder` for leaf values |

Anti-pattern to actively avoid: one giant `setState()`/`notifyListeners()` at the top of a screen that forces the *entire* screen (including static headers, images, nav bars) to rebuild for a one-line data change. Push state — and the widgets that watch it — as close to the leaf as possible.

### 5.3 `FutureBuilder`'s classic trap

If you construct the `Future` **inside** `build()`, it is recreated on *every* rebuild, silently re-triggering the async work (a network call, a DB query) each time an unrelated ancestor rebuilds:

```dart
// Bad: new network call on every rebuild of this widget
FutureBuilder(future: fetchUser(), builder: ...)

// Good: future created once, stored, reused across rebuilds
late final Future<User> _userFuture = fetchUser(); // in State, initialized once
...
FutureBuilder(future: _userFuture, builder: ...)
```

---

## Part 6 — The layered caching paradigm

Think of caching as a strict hierarchy, each layer faster and more limited than the one below it. A well-built repository always checks top-down and only falls through when the faster layer misses:

```
L1  In-memory (RAM)        →  nanoseconds  →  ValueNotifier / Riverpod provider / plain Map cache
L2  Local disk              →  milliseconds →  Hive / drift(sqflite) / SharedPreferences
L3  Network (source of truth) → 100s of ms  →  REST/GraphQL API
```

### 6.1 Repository pattern: centralize the strategy, don't scatter it

Never let a widget decide whether to hit the network. Put that decision in a repository, and choose one of these documented strategies deliberately per data type:

- **Cache-first**: return cached data immediately if present; only hit network if empty/expired. Good for rarely-changing data (user profile, config).
- **Network-first, cache-fallback**: try network, fall back to cache on failure. Good for data that must be fresh when possible (prices, availability).
- **Stale-while-revalidate**: return cached data instantly *and* kick off a background refresh, updating the UI when the fresh data arrives. Best perceived-performance option for most feeds/lists — the user never sees a spinner for data you already have.

### 6.2 Tools per layer

- **In-memory**: plain singleton maps, or your state-management library's own provider container acting as a cache (Riverpod providers are memoized by default — reading the same provider twice without invalidation returns the cached value for free).
- **Structured local persistence**: `drift` (SQL, type-safe, best for relational/query-heavy data) or `Hive`/`Isar`-style key-value/object stores (best for simple fast key→object caching). `SharedPreferences` only for small primitives (flags, tokens), never as a general object cache.
- **Image caching**: Flutter has a built-in in-memory `ImageCache` (`PaintingBinding.instance.imageCache`, tune `maximumSize`/`maximumSizeBytes` if you're memory constrained); add `cached_network_image` or `flutter_cache_manager` for a **disk-persisted** image cache so images survive app restarts and don't get re-downloaded.
- **HTTP-level caching**: `dio` + `dio_cache_interceptor` to respect `Cache-Control`/`ETag` headers transparently, so repeat requests for unchanged data cost a disk read instead of a round trip.

### 6.3 Memoize derived data

If a screen computes something expensive from raw data (sorting, grouping, aggregating), cache the *result* keyed by the inputs, not just the raw source — recomputing a sort/filter on every rebuild is a very common, very invisible performance leak.

---

## Part 7 — Cold-boot paradigm: be fast *before* the first frame, and stay warm after it

Two metrics matter, and they are not the same thing:

- **TTID** (Time To Initial Display) — time to the very first frame.
- **TTFD** (Time To Full Display) — time until the app is actually *usable* (data loaded, interactive).

### 7.1 Mask the unavoidable with a native splash

Use `flutter_native_splash` (or the platform splash-screen APIs directly) so the OS shows a native splash **immediately**, before the Flutter engine and Dart VM have even finished initializing — this covers the otherwise-unavoidable engine boot latency with something the user perceives as instant, rather than a blank/white flash.

### 7.2 Keep `main()` almost empty

```dart
void main() {
  runApp(const MyApp()); // as close to this as possible
}
```

Defer everything that isn't required for the very first frame: analytics SDK init, crash-reporter init, remote-config fetch, feature-flag evaluation. Kick these off **after** `runApp` (e.g., in the root widget's `initState` via `addPostFrameCallback`, or fired-and-forgotten with `unawaited(...)`) so they don't block first paint.

### 7.3 Lazy dependency injection

Whether you use `GetIt`, Riverpod, or a hand-rolled service locator: register services as **lazy singletons** (constructed on first use) rather than eagerly instantiating your entire dependency graph at boot. A database connection or an HTTP client you don't need until the user opens screen 3 shouldn't cost you milliseconds on screen 1.

### 7.4 Deferred loading for rarely-used heavy features

Dart supports deferred imports for splitting rarely-used, heavy code (a PDF viewer, an admin panel, a huge charting library) out of the initial load:

```dart
import 'package:heavy_feature/heavy_feature.dart' deferred as heavy;

Future<void> openHeavyFeature() async {
  await heavy.loadLibrary();
  heavy.launch();
}
```

### 7.5 Smaller binary → faster install and cold start

- Build with `--split-per-abi` so users download only the native code for their CPU architecture, not a universal fat binary.
- Ensure R8/ProGuard shrinking + resource shrinking is enabled for release Android builds — less code to load/verify at startup.
- Audit bundled fonts/assets; unused font weights and unused localized asset variants are pure dead weight at install and (for some resources) at boot scan time.

### 7.6 Ahead-of-time compilation / Baseline Profiles (Android's general PGO mechanism)

This is Android-platform-level, not Flutter-specific, but it stacks with everything above: Android Runtime (ART) can be given a **Baseline Profile** — a list of hot classes/methods — so that on install, ART ahead-of-time-compiles exactly those code paths instead of interpreting/JIT-compiling them on first use. Industry reports on native Android apps commonly cite meaningful (double-digit percentage) cold-start improvements from this mechanism, generated and verified via Android's Jetpack **Macrobenchmark** library. Flutter's own Dart AOT snapshot already gives you a similar benefit for your Dart code specifically; layering an Android Baseline Profile on top targets the surrounding Android/plugin/embedding layer. Tooling maturity for *generating* Flutter-specific baseline profiles has been evolving — check current `flutter.dev` documentation for the up-to-date recommended workflow before investing engineering time here, but the underlying ART mechanism is stable and worth knowing about conceptually.

### 7.7 Pre-warm expensive singletons off the UI thread

If a component is genuinely expensive to construct (a database with migrations, a crypto key derivation, **or — see Part 8 — a WebView with a Three.js scene**), start constructing it during the splash/boot window, on a background isolate where possible, rather than lazily on first navigation to the screen that needs it. This is the general version of the "already been there" pattern — apply it to *any* expensive component, not just WebViews.

---

## Part 8 — The WebView + Three.js paradigm: making embedded 3D feel instant and smooth

This is the hardest performance case in Flutter because you are compositing **two completely separate rendering worlds** every frame: Flutter's own Impeller-rendered layer, and a native Android `WebView` (Chromium) running its own independent browser rendering/compositing/JS engine underneath. The overhead of stitching these two together — not Three.js itself — is usually the first thing to diagnose.

### 8.1 Why WebView is a fundamentally different performance case

A `WebView` inside Flutter is a **platform view**: real estate handed off to native Android view hierarchy, not something Flutter paints itself. Every frame, the system has to decide how to merge "pixels Flutter rendered" with "pixels the native WebView rendered" without tearing. This composition tax is real and well documented in the Flutter project's own issue tracker (WebGL content specifically has a long history of running dramatically slower inside an embedded WebView than the exact same page does in a standalone Chrome tab) — so don't assume a slow embedded 3D scene is a Three.js problem before ruling out the compositing layer itself.

### 8.2 Choosing the right Android platform-view mode

Flutter offers three strategies for compositing a platform view like a WebView on Android. Picking the right one is often the single biggest lever you have:

| Mode | How it works | Pros | Cons | Availability |
|---|---|---|---|---|
| **Texture layer** (default) | WebView renders to a texture that Flutter composites like any other layer | Good Flutter FPS elsewhere on screen; full Flutter transforms (opacity, clip, rotation) work on it | Can look janky during very fast scrolling/animation of the WebView content itself | Default, all versions |
| **Hybrid Composition (HC)** | WebView renders as a real native Android view, composited by the OS (SurfaceFlinger) alongside Flutter's own surface | Full native fidelity, correct accessibility/text-selection/`SurfaceView` behavior | Historically merges the platform and raster threads, which can *reduce overall Flutter frame rate* app-wide while the WebView is on screen | Since Flutter 1.20 |
| **Hybrid Composition++ (HCPP)** | Native `SurfaceControl`-based compositing via Vulkan — the platform view and Flutter's Impeller output are composited directly by the Android OS without the older synchronization overhead | Native fidelity **and** performance — designed specifically to fix the HC/texture-layer trade-off above; benefits scrolling and touch accuracy for exactly this WebView/video/maps use case | Opt-in, requires **Android API 34+, a Vulkan-capable device, and Impeller** — automatically falls back to the previous mode when unsupported | Experimental as of Flutter 3.44 |

**Practical recommendation:** if your minimum supported Android version and device fleet allow it, opt in to HCPP for the screen hosting your Three.js WebView (it's designed for exactly this scenario), and confirm you're using **Texture layer** mode (Flutter's default) rather than legacy HC on devices that fall back, since HC's thread-merging cost is usually worse for a continuously-animating WebGL scene than texture-layer's occasional scroll jank.

### 8.3 Package choice: `webview_flutter` vs `flutter_inappwebview`

The official `webview_flutter` covers basic embedding well. For the specific pattern this guide is about — **pre-warming a WebView at boot and keeping it alive across navigation** — `flutter_inappwebview` currently offers more of the primitives you need out of the box:

- A first-class **`InAppWebViewKeepAlive`** token: multiple `InAppWebView` widgets that reference the same token render the *same underlying native WebView* — its JS engine state, loaded scene, scroll position, and WebGL context survive being removed and re-added to the widget tree.
- **`HeadlessInAppWebView`** — construct and load a WebView with no visible widget at all, ideal for warming it up during splash before any UI needs to show it.
- **`pause()`/`resume()`** and **`pauseTimers()`/`resumeTimers()`** on the controller — pause animations/timers/media without destroying the WebView (and therefore without losing the WebGL context), then resume instantly when the screen becomes visible again.
- Built-in support for loading bundled local assets (so your Three.js bundle can be shipped inside the app and loaded from disk, not fetched over the network).

Regardless of package, confirm `android:hardwareAccelerated="true"` in `AndroidManifest.xml` (default since very old API levels, but verify nothing has disabled it at the Activity level).

### 8.4 The "already been there" pre-warm pattern — step by step

This directly answers the "user should see it as already been there from initial booting" requirement:

```
Boot sequence
─────────────
1. Native splash shown instantly (masks engine boot)
2. runApp() — first Flutter frame renders (home screen skeleton)
3. In parallel / on a post-frame callback:
   → construct HeadlessInAppWebView (or an Offstage InAppWebView)
   → keepAlive: InAppWebViewKeepAlive()  ← the survival token
   → load Three.js bundle from LOCAL ASSETS (not network)
   → JS scene initializes, renderer.setAnimationLoop starts, first WebGL frame renders — off-screen
4. User taps into the "3D screen"
   → the SAME native WebView (same keepAlive token) is attached to a visible InAppWebView
   → no reload, no JS re-execution, no new WebGL context creation
   → scene is already mid-loop → feels instant, "already been there"
5. User navigates away
   → controller.pause() (and optionally a JS bridge call to stop the render loop)
   → WebView stays resident (not disposed) — GL context preserved
6. User returns
   → controller.resume() → instant, no reload
```

Key implementation rules that make this actually work:

1. **Never** put the `InAppWebView` behind a `Navigator.push()` route that constructs it fresh each time — a pushed route's widget subtree is disposed on pop, which (without a `keepAlive` token) destroys the WebView and its GL context, forcing a full reload next time. Keep the WebView instance alive at a stable point in the tree (app root `Stack`/`IndexedStack`) and simply toggle *visibility*, or rely on the `keepAlive` token if it must live inside a route.
2. **Load from local assets, not the network.** Bundle the Three.js library and your scene's HTML/JS/model files as Flutter assets, and serve them to the WebView via a local asset loader or an embedded localhost server. This removes network latency and DNS/TLS handshake time from your "already loaded" promise, and keeps it working offline.
3. **Fix the WebView's size before first load.** Resizing a WebView after the page has laid out forces Chromium to relayout the DOM and can force the browser to resize/recreate the WebGL drawing buffer — a visible hitch. Size the container once (e.g., from a `LayoutBuilder` at the parent screen) rather than animating it.
4. **Throttle the JS↔Dart bridge.** `JavascriptChannel`/`addJavaScriptHandler` calls are serialized messages across a channel boundary, not free function calls. Never call them on every `requestAnimationFrame` tick (e.g., to stream camera coordinates back to Dart); batch or throttle to a few times per second, or only on discrete user actions. Let the Three.js scene run its own loop autonomously inside the WebView, and use the bridge as a coarse remote control (load model, change material, capture screenshot) rather than a per-frame data pipe.

### 8.5 Tuning Three.js itself for a mobile-embedded GPU

Even with a perfect WebView setup, the scene itself needs to respect a much smaller GPU/thermal/battery budget than a desktop browser tab:

- **Cap the device pixel ratio** — this is usually the single biggest win: `renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5))` (or `2` at most). Rendering at an uncapped DPR on a high-density Android panel can mean pushing 4–9× the actual visible pixel count through the GPU for no visible benefit.
- Request the performant GPU path: `new THREE.WebGLRenderer({ powerPreference: 'high-performance' })`.
- Prefer **no MSAA / FXAA** over real multisample antialiasing on mid/low-tier Android GPUs — MSAA's bandwidth cost is much more punishing on mobile tile-based GPUs than on desktop.
- Reduce draw calls: merge static geometries, use `InstancedMesh` for repeated objects, and atlas your textures instead of binding many small ones.
- Compress assets: **Draco**-compressed glTF geometry and **KTX2/Basis Universal** compressed textures instead of raw PNG/JPEG — smaller to download *and* smaller/faster once resident in GPU memory.
- Use `THREE.LOD` and frustum culling for anything beyond a trivially simple scene.
- Explicitly `dispose()` geometries, materials, textures, and render targets when swapping models — a mobile WebView's WebGL context has a much tighter memory ceiling than desktop Chrome, and undisposed resources compound into jank or an outright context loss over a longer session (which, notably, would break the whole "already been there" promise, since a lost context has to be fully re-initialized).
- Don't run a full render loop for an idle/paused scene — stop `renderer.setAnimationLoop(null)` when off-screen (paired with the Dart-side `pause()` call above) and restart it on resume, rather than rendering an unseen scene 60 times a second in the background.

### 8.6 When to skip WebView entirely

If, after every optimization above, the WebView compositing tax is still the bottleneck — or 3D rendering is core to your product rather than a supporting feature — the alternative paradigm is to render 3D content into a native Flutter `Texture` instead of a platform view, bypassing the browser compositing layer entirely: packages like `flutter_gl` (raw OpenGL/ANGLE texture streaming), Filament-based renderers, `model_viewer_plus` for simple glTF display, or native AR plugins (`ARCore`/`ARKit` bridges) for AR-specific cases. This trades away the Three.js ecosystem's huge library of examples/tooling and cross-platform web reuse for genuinely native GPU integration — worth it only once you've confirmed WebView-based compositing, not your 3D content itself, is the ceiling.

---

## Part 9 — Profiling paradigm: measure, don't guess

Every recommendation above is a hypothesis until you've confirmed it against a real trace, on a real device:

- **Flutter DevTools → Performance tab**: the frame chart shows UI-thread vs raster-thread time per frame; "Enhance tracing" breaks a frame down into build/layout/paint durations so you can see exactly which stage is over budget.
- **Widget rebuild profiler** (Android Studio/IntelliJ Flutter plugin): shows *which* widgets rebuilt on a given frame and how many times — the fastest way to catch an overly-broad `setState`/`notifyListeners` blast radius from Part 5.
- **CPU Profiler**: for UI-thread jank caused by heavy Dart computation (Part 4's candidates for `compute()`/isolates).
- **Memory tab**: catches retained images, undisposed controllers, and — critically for Part 8 — leaked WebView/texture resources that cause a session to slow down over time.
- **`PerformanceOverlay`** widget: a live on-device bar chart of UI/raster thread time, useful for a quick "is it currently bad" check without attaching DevTools.
- **Debug flags** for visual diagnosis: `debugRepaintRainbowEnabled` (flashes a color over every repainted layer — instantly reveals over-repainting), `debugPaintSizeEnabled` (visualizes layout boxes/overflow).
- **Always profile in `--profile` or release mode, on a real mid/low-tier physical Android device.** Debug mode carries JIT/assertion overhead that doesn't reflect production performance, and emulators share GPU/CPU resources with the host machine in ways that make their numbers unrepresentative — this is doubly true for WebView/WebGL content, where emulator GPU passthrough behavior can differ substantially from a real device's driver.

---

## Part 10 — The one-page cheat sheet

**Rendering**
- `const` everywhere; split big `build()` methods into small widgets.
- `RepaintBoundary` around anything that animates continuously or paints expensively (custom painters, WebViews, video).
- Avoid/limit `Opacity`, `BackdropFilter`, `ClipPath`, `ShaderMask` on scrolling or frequently-rebuilt content.
- `ListView.builder` + `itemExtent`/`prototypeItem`; use Slivers for mixed scroll content.
- `MediaQuery.sizeOf(context)`, not `MediaQuery.of(context).size`.
- Confirm Impeller is active; keep Flutter SDK current.

**Compute & memory**
- `compute()`/`Isolate.run()` for anything CPU-heavy.
- `cacheWidth`/`cacheHeight` on images sized to their display size.

**State**
- Push state, and the widgets that watch it, as close to the leaf as possible.
- Use `.select()`/`Selector`/`buildWhen`/`Obx` — never one giant top-level rebuild.
- Store `Future`s once (not inline in `build()`), or you'll silently re-fetch on every rebuild.

**Caching**
- Layer it: memory → disk (Hive/drift/SharedPreferences) → network.
- Repository pattern owns the strategy (cache-first / network-first / stale-while-revalidate) — widgets never decide.
- Disk-persist images (`cached_network_image`) and HTTP responses (`dio_cache_interceptor`) where appropriate.

**Cold boot**
- Native splash to mask engine init; near-empty `main()`.
- Lazy DI; defer non-critical SDK init until after first frame.
- Deferred imports for rarely-used heavy features; `--split-per-abi`; shrink/minify release builds.
- Pre-warm genuinely expensive components (databases, WebViews) during the splash window, not on first navigation.

**WebView + Three.js**
- Prefer `flutter_inappwebview` for `keepAlive`/`pause()`/`resume()`/headless pre-warming primitives.
- Opt into HCPP where the device supports it (API 34+, Vulkan, Impeller); otherwise stick with the default texture-layer mode over legacy Hybrid Composition for continuously-animating content.
- Pre-warm off-screen at boot, load from bundled local assets, and **never** rebuild the WebView on navigation — toggle visibility / reuse the `keepAlive` token instead.
- Fix WebView size before load; throttle the JS↔Dart bridge; `pause()`/`resume()` rather than dispose/recreate.
- In Three.js: cap `devicePixelRatio`, use `powerPreference: 'high-performance'`, compress assets (Draco/KTX2), dispose GPU resources on model swap, stop the render loop when hidden.

**Verify**
- DevTools Performance + widget rebuild profiler + Memory tab, on a real mid-tier Android device, in profile/release mode — never trust a debug-mode or emulator reading.

---

## Further reading (official sources)

- Flutter rendering pipeline & performance overview — `docs.flutter.dev/perf/ui-performance`
- Android Platform Views modes (Texture layer / Hybrid Composition / HCPP) — `docs.flutter.dev/platform-integration/android/platform-views`
- `flutter_inappwebview` Keep-Alive feature — `inappwebview.dev/docs/webview/keep-alive`
- Android Baseline Profiles overview — `developer.android.com/topic/performance/baselineprofiles/overview`
- Impeller rendering engine — Flutter release notes for 3.29 and 3.44 on `flutter.dev/blog` (Impeller becoming Android default, HCPP introduction)
## Core Mission

We are currently facing a serious rendering and performance problem in the Flutter Android application.

The objective is not simply to make one screen slightly faster. The objective is to establish a complete **high-performance rendering paradigm** for the entire Flutter mobile application so that navigation, gestures, scrolling, sliding interactions, animations, state transitions, and embedded rendering components all feel smooth, immediate, and stable.

One of the most critical cases is the **ID Card feature**.

Inside the ID Card, we currently have a `WebView` that renders a **Three.js component**. At the moment, opening the ID Card from the homepage can produce severe lag. In the worst recorded case, the user had to wait approximately **10 seconds** before the ID Card became visible.

This is unacceptable for the intended user experience.

The target behavior is fundamentally different:

> When the user taps the ID Card button, the ID Card should feel as though it was already there.

The user should not experience WebView initialization, Three.js startup, asset loading, JavaScript execution, GPU warm-up, or rendering preparation at the moment they request the feature.

Those expensive operations should, where technically appropriate and safe, happen earlier in the application lifecycle.

The interaction itself should only reveal an already-prepared experience.

The guiding principle is:

> **Do expensive work before the user needs it, but never block the user while preparing it.**

---

# 1. Performance Philosophy

The application must follow a **Performance by Architecture** philosophy rather than relying on random micro-optimizations.

Do not start by adding arbitrary caches, unnecessary isolates, `RepaintBoundary` widgets everywhere, or aggressive preloading.

Performance problems must first be understood.

The correct approach is:

```text
Observe
    ↓
Measure
    ↓
Identify Bottlenecks
    ↓
Map Rendering and State Flow
    ↓
Create Performance Plan
    ↓
Implement Incrementally
    ↓
Profile Again
    ↓
Validate User Experience
```

Do not optimize based on assumptions.

Do not assume that the lag comes from Flutter itself.

Do not assume that the lag comes from Three.js.

Do not assume that the WebView is the only bottleneck.

The actual issue may come from multiple systems interacting at the same time.

For example:

```text
User taps ID Card
        ↓
Navigation starts
        ↓
Widget tree rebuilds
        ↓
State changes propagate
        ↓
WebView is created
        ↓
Android platform view initializes
        ↓
WebView engine initializes
        ↓
HTML loads
        ↓
JavaScript starts
        ↓
Three.js initializes
        ↓
Assets load
        ↓
Textures/models load
        ↓
GPU pipeline warms up
        ↓
First frame becomes visible
```

If all of this happens **after the user taps the button**, a severe delay is expected.

The architecture must prevent this expensive chain from occurring synchronously at interaction time.

---

# 2. The First Rule: Measure Before Changing Architecture

Before implementing performance fixes, perform a complete profiling and investigation phase.

The first phase is not execution.

The first phase is **performance reconnaissance**.

You must investigate the application systematically.

The investigation should identify:

* Which screens rebuild excessively.
* Which widgets rebuild unnecessarily.
* Which animations drop frames.
* Which state updates trigger large widget-tree rebuilds.
* Whether navigation causes expensive synchronous work.
* Whether image decoding blocks rendering.
* Whether network calls are triggered during navigation.
* Whether WebView initialization is the primary bottleneck.
* Whether Three.js initialization causes the delay.
* Whether JavaScript assets are loaded repeatedly.
* Whether heavy work occurs on the Flutter UI thread.
* Whether excessive widget nesting exists.
* Whether unnecessary layout calculations occur.
* Whether unnecessary painting occurs.
* Whether platform views are affecting frame performance.
* Whether the application has memory pressure or garbage collection spikes.
* Whether state architecture causes cascading rebuilds.
* Whether prop drilling or poorly scoped state is causing unnecessary updates.

The objective is to build a factual performance map.

Do not modify the architecture blindly.

---

# 3. Establish a Rendering Performance Map

The application should be analyzed through four major layers.

```text
┌─────────────────────────────────────┐
│         USER INTERACTION            │
│ Tap • Drag • Scroll • Slide         │
└──────────────────┬──────────────────┘
                   ↓
┌─────────────────────────────────────┐
│          FLUTTER UI LAYER           │
│ Widgets • Layout • Paint • Animate  │
└──────────────────┬──────────────────┘
                   ↓
┌─────────────────────────────────────┐
│           STATE LAYER               │
│ Events • State • Selective Updates  │
└──────────────────┬──────────────────┘
                   ↓
┌─────────────────────────────────────┐
│        PLATFORM / RENDER LAYER      │
│ WebView • Three.js • GPU • Android  │
└─────────────────────────────────────┘
```

Every performance issue should be traced through this pipeline.

The question should always be:

> Where is the actual cost introduced?

For example:

```text
Slow Interaction
      ↓
Is Flutter rebuilding?
      ↓
If no
      ↓
Is layout expensive?
      ↓
If no
      ↓
Is painting expensive?
      ↓
If no
      ↓
Is WebView initializing?
      ↓
If yes
      ↓
Investigate WebView lifecycle
      ↓
Investigate Three.js initialization
```

This prevents random optimization.

---

# 4. Flutter Frame Performance Model

Flutter performance must be understood as a frame pipeline.

Conceptually:

```text
State Change
     ↓
Build
     ↓
Layout
     ↓
Paint
     ↓
Compositing
     ↓
Rasterization
     ↓
GPU Frame
```

If any stage becomes too expensive, animation smoothness suffers.

For smooth interaction, the system should avoid long work on the critical rendering path.

The critical rule is:

> Never allow expensive initialization or computation to compete with a user interaction frame unless absolutely necessary.

For example, during a slide gesture:

```text
BAD FLOW

User drags
    ↓
Gesture callback
    ↓
Heavy calculation
    ↓
Network processing
    ↓
Large state update
    ↓
Entire screen rebuilds
    ↓
Animation continues
```

Instead:

```text
GOOD FLOW

User drags
    ↓
Minimal gesture update
    ↓
Only affected visual state changes
    ↓
Animation frame renders
    ↓
Heavy work is separated from the interaction path
```

The gesture path must remain lightweight.

---

# 5. Global Performance Principle: Keep the UI Thread Free

The Flutter UI rendering path must be protected.

Do not place unnecessary expensive operations directly inside:

* `build()`
* gesture callbacks
* animation callbacks
* navigation callbacks
* scroll listeners
* synchronous initialization paths

The UI should primarily be responsible for:

```text
Input
↓
State Selection
↓
Visual Update
↓
Rendering
```

Heavy work should not continuously compete with rendering.

Examples of potentially expensive work include:

* large JSON parsing
* heavy transformations
* image processing
* large list processing
* complex calculations
* repeated serialization/deserialization
* unnecessary database processing
* repeated object construction
* expensive Three.js startup logic

The principle is:

> **Rendering work should remain rendering work. Business processing and heavy computation should not unnecessarily occupy the frame-critical path.**

---

# 6. Build Method Discipline

The Flutter `build()` method must be treated as a potentially repeatable rendering declaration.

It must not be treated as a place for expensive execution.

Avoid putting expensive operations inside `build()`.

The build process should not repeatedly perform:

* network requests
* expensive filtering
* large sorting operations
* complex parsing
* WebView creation logic
* repeated controller initialization
* repeated object creation when avoidable
* unnecessary state synchronization

The conceptual rule is:

```text
build()

SHOULD DO:
✓ Describe UI
✓ Read state
✓ Compose widgets

SHOULD NOT DO:
✗ Fetch data
✗ Perform heavy calculations
✗ Initialize expensive systems repeatedly
✗ Trigger side effects
```

---

# 7. Rebuild Isolation

One of the most important Flutter performance strategies is preventing a small state change from rebuilding an unnecessarily large part of the widget tree.

Bad architecture:

```text
Page State Changes
        ↓
Entire Page Rebuilds
        ↓
Header Rebuilds
List Rebuilds
Animations Rebuild
WebView Parent Rebuilds
Unrelated Components Rebuild
```

Preferred architecture:

```text
Specific State Changes
        ↓
Only Relevant Component Rebuilds
```

The application should use **selective rendering boundaries**.

Conceptually:

```text
Page
├── Static Header
├── Dynamic User Section
├── Animated Interaction Layer
├── Independent Content Section
└── Persistent WebView Layer
```

Each section should have an appropriate rendering responsibility.

A change in one area should not automatically invalidate everything else.

---

# 8. State Management Must Be Rendering-Aware

State management is not only about organizing business logic.

Poorly structured state management can directly cause rendering problems.

The architecture should avoid:

```text
Global State Change
        ↓
Large Dependency Tree Notified
        ↓
Many Widgets Rebuild
        ↓
Frame Cost Increases
```

Instead:

```text
Small State Change
        ↓
Precise State Consumer
        ↓
Only Required UI Rebuilds
```

The important principle is:

> **State ownership should be as local as possible and as global as necessary.**

Do not make everything global.

Do not make everything local.

State should live at the correct ownership boundary.

---

# 9. Avoid State Cascades

A dangerous pattern is:

```text
User Interaction
    ↓
State A Changes
    ↓
State B Reacts
    ↓
State C Updates
    ↓
State D Rebuilds
    ↓
Navigation State Changes
    ↓
Entire Page Rebuilds
```

This creates cascading work.

Instead, use a predictable flow:

```text
User Event
    ↓
Single Intent
    ↓
Controlled State Transition
    ↓
Selective UI Update
```

State transitions should be observable and predictable.

The goal is to eliminate accidental rebuild chains.

---

# 10. Prop Drilling Investigation

Prop drilling itself is not automatically a rendering problem.

However, excessive prop drilling can indicate poor component boundaries.

For example:

```text
Root
 ↓
Screen
 ↓
Section
 ↓
Container
 ↓
Card
 ↓
Button
```

If a state value is passed through multiple layers only to be consumed at the bottom, it may create unnecessary coupling.

The investigation should determine whether:

* state is being passed through unrelated widgets
* parent widgets rebuild only to pass unchanged values
* deeply nested components are unnecessarily coupled
* state boundaries are incorrectly positioned

The solution is not automatically to introduce global state.

Instead, use appropriate boundaries:

```text
Local State
↓
Component State

Feature State
↓
Feature Scope

Application State
↓
Application Scope
```

---

# 11. Animation Architecture

All animations should follow a performance-first philosophy.

The objective is:

```text
Interaction
      ↓
Immediate Visual Response
      ↓
Stable Frame Delivery
      ↓
No Perceived Stutter
```

Avoid animations that trigger unnecessary:

* layout recalculation
* widget-tree reconstruction
* state cascades
* expensive painting

Prefer animation architectures that isolate visual changes.

The key question for every animation is:

> Does this animation require rebuilding the entire surrounding UI?

If the answer is yes, investigate whether the animation boundary is incorrectly designed.

---

# 12. Sliding, Dragging, and Gesture Performance

The application must specifically optimize:

* slide up
* slide down
* horizontal sliding
* drag gestures
* transitions
* scrolling
* interactive animations

The gesture pipeline should be lightweight.

Bad conceptual pattern:

```text
Pointer Move
      ↓
Heavy State Update
      ↓
Large Widget Rebuild
      ↓
Layout Recalculation
      ↓
Animation Frame
```

Preferred pattern:

```text
Pointer Move
      ↓
Minimal Interaction State
      ↓
Affected Visual Layer Updates
      ↓
Next Frame
```

Continuous gestures must never repeatedly trigger unnecessary business logic.

The user should experience:

```text
Finger Movement ≈ Visual Response
```

The visual response should feel directly connected to the user's input.

---

# 13. WebView Is a Separate Performance Domain

The ID Card WebView must not be treated as an ordinary Flutter widget.

It represents a separate rendering environment.

Conceptually:

```text
Flutter Engine
       │
       ├── Flutter UI Rendering
       │
       └── Native WebView
                │
                └── Browser Rendering Engine
                         │
                         └── Three.js
                                  │
                                  └── WebGL / GPU
```

Therefore, opening the ID Card may involve multiple rendering systems.

The performance architecture must consider:

* Flutter rendering
* Android platform view lifecycle
* WebView lifecycle
* HTML loading
* JavaScript parsing
* Three.js initialization
* WebGL initialization
* asset loading
* texture loading
* model loading
* GPU warm-up

The goal is to prevent all of these stages from starting only when the user presses the ID Card button.

---

# 14. The ID Card Must Follow a Warm Lifecycle

The ID Card should conceptually follow this lifecycle:

```text
APPLICATION BOOT
       ↓
Critical UI becomes available
       ↓
Application reaches usable state
       ↓
ID Card preparation begins safely
       ↓
WebView initializes
       ↓
Web content loads
       ↓
Three.js initializes
       ↓
Assets are prepared
       ↓
First stable frame is rendered
       ↓
ID Card enters READY state
       ↓
User taps ID Card
       ↓
READY component is revealed
```

The user interaction should ideally be:

```text
Tap
↓
Reveal
```

Not:

```text
Tap
↓
Initialize Everything
↓
Wait
↓
Render
```

This is the central paradigm for the ID Card performance issue.

---

# 15. Do Not Block Initial Boot

Preloading must not create a different problem.

The application must not become slow during initial boot simply because everything is initialized immediately.

The correct philosophy is:

```text
Boot Critical Path
        ↓
Show Application Quickly
        ↓
Application Becomes Interactive
        ↓
Background Preparation Begins
```

Therefore:

```text
CRITICAL BOOT WORK
        │
        ├── Required application initialization
        ├── Required authentication state
        ├── Required first-screen resources
        │
        ↓
APP INTERACTIVE
        │
        ↓
NON-CRITICAL PREPARATION
        │
        ├── ID Card WebView warm-up
        ├── Three.js preparation
        ├── Optional asset preparation
        └── Future screen readiness
```

The application should prioritize **Time to Interactive**, not merely initialization completion.

---

# 16. Persistent WebView Paradigm

If the WebView is destroyed every time the user leaves the ID Card, the application may repeatedly pay the initialization cost.

This creates:

```text
Open ID Card
↓
Create WebView
↓
Initialize Three.js
↓
Close ID Card
↓
Destroy WebView
↓
Open Again
↓
Initialize Everything Again
```

The architecture should investigate whether a persistent lifecycle is more appropriate:

```text
Initialize Once
       ↓
Warm and Ready
       ↓
Hide When Not Needed
       ↓
Reveal When Requested
       ↓
Reuse Existing Runtime
```

Conceptually:

> **Do not recreate an expensive rendering environment unless there is a real reason to destroy it.**

However, persistence must be implemented responsibly.

The system must also investigate:

* memory usage
* lifecycle safety
* background behavior
* WebView resource consumption
* GPU usage
* Android lifecycle
* whether hidden rendering continues unnecessarily

A cached component must not become an uncontrolled background resource.

---

# 17. WebView Readiness State

The ID Card should have an explicit readiness model.

Conceptually:

```text
UNINITIALIZED
      ↓
PREPARING
      ↓
LOADING
      ↓
INITIALIZING THREE.JS
      ↓
RENDERING FIRST FRAME
      ↓
READY
```

The Flutter application should understand this state.

The UI should never pretend that the component is ready when it is not.

Likewise, navigation should not accidentally trigger multiple initialization requests.

The architecture should prevent:

```text
Tap 1 → Initialize
Tap 2 → Initialize Again
Rebuild → Initialize Again
Navigation → Initialize Again
```

There should be one controlled lifecycle.

---

# 18. First Frame Readiness

Loading completion is not always the same as visual readiness.

For Three.js, this distinction is important.

Conceptually:

```text
HTML Loaded
≠
JavaScript Ready
≠
Three.js Initialized
≠
Assets Ready
≠
First Frame Rendered
```

The application should define readiness based on the actual desired user experience.

The strongest readiness condition is:

> The visual component has completed initialization and can display a stable frame immediately.

Therefore, Flutter and the WebView layer should conceptually synchronize around meaningful readiness rather than only network completion.

---

# 19. Three.js Performance Must Also Be Optimized

Even if Flutter caches the WebView perfectly, a poorly optimized Three.js scene can still produce poor performance.

The Three.js component should therefore be investigated independently.

Potential areas include:

* unnecessary render loops
* excessive scene complexity
* too many draw calls
* unnecessarily high polygon counts
* oversized textures
* expensive shaders
* unnecessary post-processing
* continuous rendering when nothing changes
* repeated asset loading
* excessive device pixel ratio
* poor WebGL resource management

The WebView may be ready, but the Three.js scene must also be capable of maintaining smooth rendering.

---

# 20. Render Only When Necessary

A Three.js scene does not always need to consume GPU resources continuously.

The architecture should determine whether the scene actually requires:

```text
Continuous Animation
```

or whether it can follow:

```text
Render on Change
```

For static or mostly static content, continuous rendering may create unnecessary overhead.

For animated content, rendering should remain intentional.

The question is:

> Is the GPU doing useful visual work right now?

If not, unnecessary rendering should be investigated.

---

# 21. Asset Caching Strategy

Caching should be layered.

Do not think of caching as only one thing.

The application may have several cache domains:

```text
Application State Cache
        ↓
Flutter Widget / Screen Persistence
        ↓
Image Cache
        ↓
Data Cache
        ↓
WebView Runtime Cache
        ↓
Browser Asset Cache
        ↓
Three.js Asset Cache
```

Each layer solves a different problem.

The architecture should identify which resource is expensive to recreate.

For example:

```text
Expensive Widget Rebuild
→ Widget / State Strategy

Expensive Image Decode
→ Image Caching Strategy

Expensive API Response
→ Data Cache

Expensive WebView Startup
→ Persistent WebView Lifecycle

Expensive Three.js Assets
→ Browser / Three.js Asset Reuse
```

Do not add caches blindly.

Cache the actual bottleneck.

---

# 22. Screen Lifecycle Should Be Intentional

Every important screen should have a lifecycle strategy.

Conceptually:

```text
COLD
↓
INITIALIZING
↓
READY
↓
VISIBLE
↓
BACKGROUND / HIDDEN
↓
RESUMED
↓
DISPOSED
```

Not every screen needs to remain alive.

The architecture should classify screens according to cost.

For example:

### Cheap Screens

```text
Create → Display → Dispose
```

### Expensive Screens

```text
Prepare → Keep Ready → Reveal → Reuse
```

The ID Card WebView is a strong candidate for investigation as an expensive rendering environment.

---

# 23. Avoid Premature Optimization Everywhere

The objective is not:

> Put `RepaintBoundary` around everything.

The objective is not:

> Cache every widget.

The objective is not:

> Keep every screen alive forever.

The objective is:

> Understand the rendering cost and apply the correct optimization at the correct layer.

Over-optimization can introduce:

* memory problems
* lifecycle bugs
* stale state
* hidden background rendering
* difficult debugging
* fragile architecture

Performance architecture must remain maintainable.

---

# 24. Repaint Isolation

Repainting should be investigated separately from rebuilding.

A widget rebuilding does not always mean the entire screen paints in the same way.

Likewise, a small visual change should not necessarily cause unrelated expensive painting.

The application should identify expensive visual regions and determine whether they should be isolated.

Conceptually:

```text
Static Background
────────────────────────

Animated Card
────────────────────────

Static Content
```

The animated region should ideally not force unrelated static regions to repaint unnecessarily.

However, repaint isolation should only be used where profiling demonstrates value.

---

# 25. Image Rendering Performance

Images can contribute significantly to perceived lag.

The application should investigate:

* oversized source images
* unnecessary decoding resolution
* repeated image loading
* large transparent assets
* expensive image transformations
* synchronous image preparation
* images that exceed their display requirements

The rendering pipeline should avoid processing more image data than the screen actually needs.

---

# 26. List Performance

Any long or dynamic list should avoid constructing unnecessary off-screen content.

The conceptual rule is:

```text
Visible Content
        +
Small Preparation Window
        =
Efficient Rendering
```

Not:

```text
Entire Dataset
        ↓
Build Everything
        ↓
Hope Scrolling Remains Smooth
```

Scrolling must remain independent from unnecessary background work.

---

# 27. Navigation Must Not Become a Loading Pipeline

Navigation should primarily represent a transition between experiences.

Bad flow:

```text
Tap
↓
Navigation
↓
Start Data Loading
↓
Start Controller Initialization
↓
Start Heavy Processing
↓
Start WebView
↓
Wait
```

Preferred flow:

```text
Preparation
↓
Ready State
↓
Tap
↓
Navigation / Reveal
↓
Immediate Experience
```

Where preparation is not possible, loading must still be intentional and non-blocking.

But for predictable and frequently used features such as the ID Card, proactive preparation should be investigated.

---

# 28. Avoid Heavy Work During Transitions

Animations and transitions represent sensitive frame periods.

The application should avoid simultaneously performing:

```text
Route Transition
+
Heavy State Update
+
WebView Initialization
+
Large Image Decode
+
Complex Calculation
```

This creates contention.

The architecture should sequence expensive work intelligently.

---

# 29. Performance Budget Thinking

Every interaction should conceptually have a performance budget.

Ask:

* What happens immediately after the user taps?
* What work is required before the next visual response?
* What can be deferred?
* What can be prepared earlier?
* What can be reused?
* What does not need to happen at all?

The fastest operation is often:

> The operation that was never executed unnecessarily.

---

# 30. Memory Performance and Rendering Performance Must Be Balanced

Keeping the WebView permanently alive may improve responsiveness.

However, it may increase memory consumption.

Therefore, performance must be evaluated as a balance:

```text
FAST STARTUP
      ↕
LOW MEMORY
      ↕
FAST FEATURE ACCESS
```

The architecture must find the correct lifecycle strategy for the actual application.

Do not sacrifice system stability merely to make one interaction faster.

---

# 31. Garbage Collection Awareness

Excessive short-lived object creation can create memory churn.

During animations and frequently repeated interactions, unnecessary allocations should be investigated.

The architecture should avoid repeatedly creating expensive objects in hot paths.

Hot paths include:

* animation frames
* scrolling
* dragging
* frequent state updates
* repeatedly rebuilt complex widgets

The question is:

> Is this object being recreated hundreds or thousands of times without a real reason?

---

# 32. Separate Business Logic From Rendering

Rendering components should not become containers for unrelated business complexity.

A healthy structure is:

```text
Business Logic
        ↓
State / View Model
        ↓
Presentation State
        ↓
Flutter UI
```

The UI should consume a clear presentation state.

Avoid:

```text
Widget
↓
Database Logic
↓
Network Logic
↓
Transformation Logic
↓
Rendering Logic
```

This makes performance behavior difficult to predict and optimize.

---

# 33. Establish Performance Ownership

Each performance domain should have clear ownership.

For example:

```text
Flutter UI
→ Widget composition and animation

State Layer
→ Controlled state transitions

Navigation
→ Route lifecycle

WebView Layer
→ Browser lifecycle

Three.js Layer
→ WebGL rendering

Asset Layer
→ Resource preparation and reuse
```

When ownership is unclear, performance problems become difficult to diagnose.

---

# 34. Create a Performance Investigation Report First

Before implementation, create a structured performance report.

The report should map:

```text
PERFORMANCE AREA
│
├── Problem
├── Evidence
├── Suspected Cause
├── Actual Cause
├── Current Behavior
├── Desired Behavior
├── Proposed Solution
├── Risk
└── Validation Method
```

Example:

```text
ID CARD WEBVIEW

Problem:
10-second delay before visible content.

Current Behavior:
WebView and Three.js initialize after user interaction.

Investigation:
Determine initialization timeline.

Desired Behavior:
ID Card is ready before user requests it.

Proposed Direction:
Warm lifecycle and controlled persistence.

Risk:
Memory consumption and hidden rendering.

Validation:
Profile cold start, warm navigation, repeated navigation,
memory usage, and frame stability.
```

---

# 35. Required Planning Phase Before Execution

Do not immediately refactor the application.

The work must follow a formal plan.

## Phase 1 — Codebase Crawling

Inspect:

* application lifecycle
* homepage
* ID Card trigger
* navigation flow
* WebView implementation
* Three.js loading mechanism
* state management
* controllers
* animations
* gesture handling
* expensive screens
* rebuild boundaries

---

## Phase 2 — Performance Mapping

Create a dependency and rendering map:

```text
Homepage
    ↓
ID Card Trigger
    ↓
State Transition
    ↓
Navigation
    ↓
ID Card Screen
    ↓
WebView Lifecycle
    ↓
Three.js Runtime
```

Determine where the delay occurs.

---

## Phase 3 — Profiling

Measure actual performance.

Identify:

* startup timing
* tap-to-first-frame timing
* WebView initialization timing
* Three.js readiness timing
* frame drops
* rebuild frequency
* memory usage

---

## Phase 4 — Architecture Plan

Only after evidence is collected, define:

* state improvements
* rebuild isolation
* animation improvements
* screen lifecycle strategy
* WebView warm-up strategy
* Three.js optimization strategy
* caching strategy

---

## Phase 5 — Risk Review

Before implementation, identify possible risks:

* broken navigation
* duplicate WebViews
* memory leaks
* stale state
* lifecycle crashes
* hidden background rendering
* Android lifecycle issues
* WebView recreation loops

---

## Phase 6 — Controlled Implementation

Implement changes incrementally.

Do not rewrite the entire application unnecessarily.

After every significant architectural change:

```text
Implement
↓
Run
↓
Profile
↓
Validate
↓
Continue
```

---

# 36. Required Final User Experience

The final experience should feel immediate.

### Homepage

```text
Application Ready
↓
User Interacts
↓
Immediate Response
```

### ID Card

```text
Application Boot
↓
App Becomes Interactive
↓
ID Card Prepares in Background
↓
WebView Ready
↓
Three.js Ready
↓
User Taps ID Card
↓
Immediate Reveal
```

### Gestures

```text
Slide Up
↓
Smooth

Slide Down
↓
Smooth

Horizontal Slide
↓
Smooth

Animations
↓
Stable

Scrolling
↓
Stable
```

The user should not experience:

* severe lag
* long freezes
* delayed interactions
* sudden rendering jumps
* repeated initialization
* visible WebView startup delays
* broken transitions
* unexplained loading states

---

# 37. Definition of Success

Success is not defined merely by removing one 10-second delay.

Success means the application has a structured and maintainable performance architecture.

The final system should demonstrate:

```text
✓ Fast Time to Interactive
✓ Controlled State Updates
✓ Minimal Unnecessary Rebuilds
✓ Smooth Animations
✓ Responsive Gestures
✓ Stable Navigation
✓ Efficient Screen Lifecycles
✓ Warm WebView Strategy Where Appropriate
✓ Three.js Readiness Before User Demand
✓ Controlled Memory Usage
✓ No Repeated Expensive Initialization
✓ Evidence-Based Optimization
✓ No User-Facing Errors
✓ No Fragile Performance Hacks
```

---

# Final Engineering Directive

Approach this as a **Flutter Rendering Performance Hunter, Mobile Runtime Architect, and Non-Fragile System Flow Designer**.

Do not guess.

Do not randomly add caches.

Do not randomly wrap widgets with optimization tools.

Do not immediately rewrite the architecture.

First, crawl the codebase.

Understand the rendering flow.

Map the state flow.

Trace the ID Card lifecycle.

Profile the actual bottlenecks.

Create the implementation plan.

Review risks.

Only then begin execution.

The final paradigm must be:

```text
EXPENSIVE WORK
        ↓
IDENTIFIED
        ↓
MEASURED
        ↓
MOVED OUT OF CRITICAL INTERACTION PATHS
        ↓
PREPARED EARLY WHEN APPROPRIATE
        ↓
REUSED WHEN SAFE
        ↓
RENDERED SELECTIVELY
        ↓
VALIDATED THROUGH PROFILING
```

The ultimate objective is simple:

> **The application must feel fast because the architecture prevents unnecessary work from reaching the user interaction and rendering path.**

The ID Card should not make the user wait for a WebView and Three.js environment to wake up after they tap the button.

The system should intelligently prepare expensive experiences before they are requested, while keeping the initial application boot responsive and lightweight.

At the same time, every animation, slide, drag, scroll, transition, and interaction must be investigated through the same performance philosophy:

> **Minimal work per interaction. Minimal unnecessary rebuilds. Minimal rendering overhead. Clear state ownership. Controlled lifecycles. Evidence-based optimization. Smooth visual output.**
 