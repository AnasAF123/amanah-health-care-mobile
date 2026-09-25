A. Foundational Principles
FACTORY DESIGN SYSTEM, ABSTRACTION DESIGN LAYER, DECOUPLED DESIGN, SSOT DESIGN,
SOLID Principles — five OOP rules (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion) that keep classes small, focused, and swappable.
DRY (Don't Repeat Yourself) — one authoritative implementation of any given logic; duplicates are refactored into a shared module instead of copy-pasted.
KISS (Keep It Simple, Stupid) — prefer the simplest design that solves the actual problem; resist speculative complexity.
YAGNI (You Aren't Gonna Need It) — don't build abstractions for requirements that don't exist yet.
SSOT (Single Source of Truth) — one canonical place (a schema, a config, a contract) that everything else derives from, instead of copies that drift apart over time.
Separation of Concerns (SoC) — each unit of code owns exactly one responsibility (routing, validation, business rule, persistence) and nothing else.
Composition over Inheritance — build behavior by combining small objects/functions instead of deep class hierarchies.
Law of Demeter (Principle of Least Knowledge) — an object should only talk to its immediate collaborators, never reach through them to their internals.
Tell, Don't Ask — give objects commands to act on their own state instead of pulling state out to decide for them elsewhere.
Convention over Configuration — consistent, predictable defaults (naming, folder layout) so each new module needs less boilerplate wiring.
B. Architectural Styles
Layered (N-Tier) Architecture — the classic Presentation → Application → Domain → Infrastructure stack.
Clean Architecture — dependencies point inward toward the domain; frameworks and the database are outer, replaceable "plugins."
Hexagonal Architecture (Ports & Adapters) — the domain core exposes ports (interfaces); HTTP, DB, and queues are adapters plugged into them.
Onion Architecture — a concentric-ring variant of Clean Architecture, with the domain model at the very center.
Modular Monolith — one deployable unit, internally split into strongly-bounded modules with enforced boundaries — easy to later extract into services.
Vertical Slice Architecture — organize code by feature/use-case end-to-end, instead of by technical layer.
Screaming Architecture — folder names announce the business capability ("orders", "billing"), not the technical pattern ("controllers", "services").
Event-Driven Architecture (EDA) — modules communicate by publishing/subscribing to events instead of calling each other directly, reducing coupling.
CQRS (Command Query Responsibility Segregation) — separate models/paths for writes (commands) and reads (queries), which can even use different data shapes.
Backend For Frontend (BFF) — a thin, client-specific API layer (one for mobile, one for web-admin) that both call the same shared core services underneath — the direct fix for "same behavior, different endpoint."
C. Domain-Driven Design (DDD)
Bounded Context — an explicit boundary within which a domain model and its terms have one consistent meaning.
Ubiquitous Language — the same vocabulary used by business, code, and docs inside a bounded context, preventing translation drift.
Aggregate / Aggregate Root — a cluster of related entities/value objects treated as one consistency boundary, entered only through its root — this is the "aggregation" concept you were thinking of.
Entity — a domain object with identity/lifecycle that persists across state changes (e.g. an Order).
Value Object — an immutable object defined only by its attributes, with no identity of its own (e.g. Money, Address).
Domain Service — a stateless operation that doesn't naturally belong to any single entity or value object.
Domain Event — a record that "something happened" in the domain, used to decouple side effects from the action that triggered them.
Anti-Corruption Layer (ACL) — a translation layer that isolates your domain model from a foreign or legacy model it must integrate with.
Context Mapping (Shared Kernel / Customer-Supplier / Conformist / Open Host Service) — named patterns describing how two bounded contexts relate to and exchange data with each other.
Specification Pattern — encapsulate a business rule or query predicate as a reusable, combinable object instead of scattering if conditions everywhere.
D. Data Access & Persistence
Repository Pattern — hides persistence details behind a collection-like interface (findById, save) so business logic never touches the ORM directly.
Unit of Work — tracks every change made during one business transaction and commits or rolls all of it back together, atomically.
Data Mapper — a translator between the persistence row/schema shape and the in-memory domain object, keeping the domain ignorant of the database.
Active Record (contrast pattern) — the model itself knows how to save/load; useful to name explicitly as the pattern you are moving away from for large domains.
Generic Repository — one reusable IRepository<T> implementation that every feature's specific repository extends, instead of hand-rolling CRUD each time.
Query Object / Query Builder Abstraction — encapsulate a complex, reusable query as its own object rather than duplicating raw query logic across services.
Optimistic Concurrency Control — detect conflicting concurrent writes via a version/timestamp column instead of locking rows.
Soft Delete Pattern — mark rows deletedAt instead of removing them, preserving history and referential integrity.
Outbox Pattern — write a domain event to an "outbox" table in the same database transaction as the business change, then publish it reliably afterward.
Saga / Process Manager — coordinate a multi-step transaction across several aggregates/services using a sequence of local transactions plus compensations.
E. Object Creation & Transformation
Factory Pattern — centralizes and encapsulates object/aggregate construction so callers never need to know its internal invariants.
Abstract Factory — a factory that produces families of related objects without exposing which concrete classes are used.
Builder Pattern — assembles a complex object step by step; useful for objects with many optional fields.
Mapper Pattern — a dedicated class that converts between representations (Entity ↔ DTO, DB row ↔ Domain object).
DTO (Data Transfer Object) — a plain, validated shape used to move data across a boundary (API request/response), decoupled from the internal entity shape.
Adapter Pattern — wraps an incompatible interface (e.g. a third-party SDK) so the rest of the app depends on your own interface instead.
Facade Pattern — a simplified, unified entry point placed in front of a set of complex subsystems or services.
Decorator Pattern — attaches extra behavior to an object/function dynamically without altering its class (@Injectable, @UseGuards, etc.).
Proxy Pattern — a stand-in object that controls access to another object (lazy loading, caching, permission checks).
Null Object Pattern — return a harmless "do-nothing" object instead of null, removing null-checks scattered through the codebase.
F. Behavioral & Cross-Cutting Patterns
Strategy Pattern — encapsulate interchangeable algorithms/behaviors behind one interface, selected at runtime.
Chain of Responsibility — pass a request along a chain of handlers until one of them handles it (the basis of middleware pipelines).
Template Method — define the skeleton of an algorithm in a base class, letting subclasses override only specific steps.
Observer / Pub-Sub — subscribers react to events published by a subject without the subject knowing who is listening.
Mediator Pattern — a central object coordinates communication between components instead of them referencing each other directly (the basis of command/query buses).
Command Pattern — encapsulate a request/intent as an object that can be queued, logged, validated, or routed to a dedicated handler.
Middleware / Interceptor / Guard / Pipe / Filter — the standard hook points for cross-cutting logic (logging, transformation, auth, validation, error-mapping) so it never has to be copy-pasted into every handler.
Circuit Breaker — stop calling a failing downstream dependency for a cooldown period instead of retrying it into the ground.
Retry with Backoff — automatically retry a transient failure with increasing delay instead of failing immediately.
Rate Limiting / Throttling — cap how often a client can call an endpoint, protecting shared resources from being overwhelmed.
G. Error Handling & Reliability
Result / Either Pattern — return an explicit success-or-failure value instead of throwing exceptions for expected business failures.
Railway-Oriented Programming — chain operations so a failure short-circuits the rest of the pipeline cleanly, like a railway switch.
Custom Exception Hierarchy — a tree of domain-specific exception classes instead of throwing a generic Error.
Global Exception Filter — one centralized handler that turns any thrown exception into a consistent API error shape.
Idempotency — designing an operation so repeating it (e.g. a retried request) produces the same result without duplicate side effects.
Idempotent Consumer — a message/event handler that safely ignores duplicate deliveries of the same message.
Compensating Transaction — an explicit "undo" step used to roll back a previously committed step in a saga when a later step fails.
Bulkhead Pattern — isolate resources (thread pools, DB connections) per dependency so one failing dependency can't starve the others.
Dead Letter Queue — route messages that repeatedly fail processing into a separate queue for inspection, instead of losing them or retrying forever.
Graceful Degradation — define a fallback response/behavior for when a dependency is down, instead of a hard failure.
H. Module, Folder & Dependency Structure
Package by Feature (vs. Package by Layer) — group files by business capability (orders/) rather than by technical role (controllers/, services/) scattered across the whole app.
Barrel Exports (index.ts) — one file per module that re-exports its public surface, so other modules import from a single clean path.
Module Encapsulation — a module exposes only what it explicitly exports; everything else stays private/internal to it.
Composition Root — the single place (usually app bootstrap) where all dependencies are wired together, kept separate from business logic.
Dependency Injection (DI) / Inversion of Control (IoC) — objects receive their dependencies from outside instead of constructing them, which is exactly what makes a module swappable and testable — this is the technical basis of "agnostic, plug-and-call" modules.
Dynamic Modules (forRoot / forFeature) — a pattern for configurable, reusable modules that accept options at import time.
Shared Kernel Package — a small, deliberately shared library (types, contracts, utilities) that multiple modules or apps depend on — your SSOT made physical.
Monorepo Structure — multiple apps/packages in one repository with shared tooling, enabling contract/code sharing without publishing separate packages.
Module Boundary Enforcement — lint/build rules that fail the build if one module reaches into another module's internals instead of its public interface.
God Object / God Service (anti-pattern) — a single class or file that knows and does too much. Naming this explicitly is usually the fastest way to justify splitting a 4,000-line file.
I. Multi-Client & API Consistency
Backend For Frontend (BFF), revisited — see #20; this is the concrete answer to "mobile and web-admin do the same thing but hit different endpoints."
Canonical Data Model — one agreed-upon shape for a concept (e.g. User) that every client and internal module maps to/from, instead of each client inventing its own shape.
Contract-First Design (OpenAPI/JSON Schema/Zod-schema-first) — define the API contract before implementation, then generate types/clients from it so client and server can never silently drift apart.
Shared DTO/Contract Package — a package (in a monorepo) containing request/response types consumed by both the backend and multiple frontend clients.
Transport-Agnostic Service Layer — business/application logic lives in plain services that know nothing about HTTP, so any controller — mobile, web-admin, GraphQL, CLI, cron — can call the exact same logic. This is the core "agnostic module" idea you described.
API Gateway — a single entry point that routes, authenticates, and aggregates calls to internal services, presenting one consistent surface to every client.
GraphQL Federation / Schema Stitching — compose one graph from multiple services, letting each client query exactly the fields it needs instead of maintaining parallel REST endpoints.
API Versioning Strategy — a deliberate scheme (URI, header, or media-type versioning) for evolving a contract without breaking existing clients.
Policy-Based Authorization (e.g. CASL) — express "who can do what" as declarative policies attached to the shared service layer, instead of duplicating access checks inside every client-specific endpoint.
Response Envelope Pattern — a standard wrapper ({ data, meta, error }) around every API response, so all clients parse responses identically regardless of which endpoint served them.
J. Scalability, Migration & Evolution
Strangler Fig Pattern — incrementally replace a legacy module by routing traffic to the new implementation piece by piece, until the old one can be safely deleted. This is the standard playbook for migrating a 4,000-line file without a risky big-bang rewrite.
Feature Flags / Toggles — ship code behind a runtime switch, decoupling deployment from release and enabling safe incremental rollout.
Migration-as-Code — schema changes are versioned, reviewable files generated from the schema, never manual, undocumented DB edits.
Backward-Compatible Schema Evolution — additive-first changes (a new nullable column, a new endpoint version) so old and new code can run side by side during rollout.
Blue-Green Deployment — run two identical production environments and switch traffic between them atomically, enabling instant rollback.
Canary Release — roll a new version out to a small slice of traffic first, watching for errors before a full rollout.
Read/Write Splitting — route read queries to replicas and writes to the primary, scaling read-heavy workloads horizontally.
Multi-Tenancy Pattern — a deliberate, named strategy (shared schema with tenant_id, schema-per-tenant, or database-per-tenant) for isolating each customer's data.
Stateless Service Design — services keep no in-memory session state, so any instance can serve any request — the property that makes horizontal scaling trivial.
Test Data Builder / In-Memory Fake Repository — reusable builders and in-memory repository fakes (built against the same IRepository interface as production) that make unit tests fast and independent of a real database.

# Flutter Architecture, Design System & Abstraction Layer Catalog

**Purpose:** the Flutter-side companion to `backend-architecture-paradigm-catalog.md` and Same goal, different layer: keep every file small (target **≤ 500 LOC**), keep UI decoupled from business logic, keep business logic decoupled from Flutter itself, and make the design system a pluggable, reusable package rather than scattered one-off widgets.

---

## 0. The Guiding Rule Before Anything Else

> **One class, one responsibility, one file. If a `build()` method or a class is growing past ~150–200 lines, that is the signal to extract — not to keep scrolling.**

Everything below is just this rule applied systematically to four different things: screens, widgets, business logic, and data access. A file rarely breaks the 500-LOC ceiling by accident — it breaks it because two or three of the layers below got collapsed into one file. Keeping the layers physically separate (different folders, different files) is what keeps each one small automatically.

---

## 1. Top-Level Project Layout

```
lib/
  main.dart                      # ~20 lines: picks a flavor, calls bootstrap()
  bootstrap.dart                 # env-specific setup (DI init, error reporting, runApp)

  app/
    app.dart                      # MaterialApp/CupertinoApp shell + theme + router only
    router/
      app_router.dart              # go_router root config
      routes/
        <feature>_routes.dart       # one route group file per feature — never one giant router file

  core/                           # cross-cutting, framework-adjacent — equivalent to backend's "common/"
    design_system/                 # §2
    network/
      api_client.dart               # Dio instance + base config
      interceptors/
        auth_interceptor.dart
        logging_interceptor.dart
      network_info.dart              # connectivity check abstraction
    error/
      failure.dart                   # base Failure type (§5)
      exception_mapper.dart           # raw exceptions -> Failure, at the boundary
    usecase/
      usecase.dart                    # abstract UseCase<Type, Params> base class (§5)
    di/
      injector.dart                    # composition root (get_it / riverpod)
    constants/
      app_constants.dart
      env.dart
    extensions/
      context_extensions.dart
    widgets/                         # generic, feature-agnostic building blocks: loading/error/empty states

  features/
    <feature_name>/                  # one folder per bounded context (§3)
      domain/
      data/
      presentation/

  l10n/
  gen/                                # generated code (assets, icons) — never hand-edited, never reviewed for LOC
```

If a single feature genuinely needs to be shared across **multiple apps** (not just multiple screens), see §7 — that's when this graduates from a folder to a package.

---

## 2. Design System Folder — Tokens → Atoms → Molecules → Organisms

The design system is the Flutter equivalent of the backend's `common/` base-module catalog: written once, imported everywhere, never re-implemented per screen.

```
core/design_system/
  tokens/                          # raw design values — the actual Single Source of Truth
    app_colors.dart                  # ColorScheme seed + semantic color tokens
    app_typography.dart               # TextTheme / TextStyle scale
    app_spacing.dart                   # spacing scale: xs, sm, md, lg, xl
    app_radius.dart
    app_shadows.dart
    app_breakpoints.dart                # responsive breakpoints (mobile/tablet/desktop)

  theme/
    app_theme.dart                    # ThemeData.light()/dark() built ONLY from tokens/ above
    app_theme_extension.dart           # ThemeExtension<T> for brand tokens ThemeData has no slot for

  atoms/                             # smallest units — purely presentational, zero business logic, zero state
    app_button.dart
    app_text.dart
    app_input.dart
    app_icon.dart
    app_avatar.dart
    app_badge.dart

  molecules/                         # composition of atoms — still no business logic
    app_form_field.dart                # label + input + error text
    app_card.dart
    app_list_tile.dart
    app_snackbar.dart

  organisms/                         # complex, composed, but still feature-agnostic sections
    app_bottom_nav.dart
    app_app_bar.dart
    app_empty_state.dart
    app_error_state.dart
    app_shimmer_loader.dart

  design_system.dart                  # barrel export — consumers do `import 'design_system.dart'` once
```

**Token example (`app_spacing.dart`):**

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
```

**Rule:** nothing under `atoms/`, `molecules/`, or `organisms/` ever imports anything from `features/`. Dependency only flows _from_ features _into_ the design system, never the other way — this is what makes the design system genuinely reusable/agnostic rather than accidentally coupled to one screen's needs.

---

## 3. Abstraction Layers (System Design) — Clean Architecture Per Feature

Each feature is split into three layers with a strict, one-directional dependency rule:

```
presentation  ──depends on──▶  domain  ◀──implements── data
```

`domain` is the center. It has **zero imports** of Flutter, Dio, Hive, or any package that isn't pure Dart. This is the Dependency Inversion Principle and Hexagonal Architecture applied directly to a mobile app: `domain` defines the _ports_ (interfaces), `data` supplies the _adapters_.

```
features/<feature>/
  domain/                            # pure Dart — the innermost layer
    entities/
      product.dart                     # plain immutable class, no fromJson/toJson here
    repositories/
      product_repository.dart           # ABSTRACT interface only — the "port"
    usecases/
      get_products.dart                  # one class, one public method: call()
      get_product_by_id.dart
      create_product.dart
    failures/
      product_failure.dart

  data/                                # implements domain's interfaces — the "adapter"
    models/
      product_model.dart                 # extends Entity + fromJson/toJson (this is the DTO)
    datasources/
      product_remote_datasource.dart      # talks to api_client, throws raw ServerException
      product_local_datasource.dart        # talks to Hive/Drift, throws raw CacheException
    mappers/
      product_mapper.dart                  # Model <-> Entity (Mapper pattern)
    repositories/
      product_repository_impl.dart          # implements ProductRepository, orchestrates datasources

  presentation/                          # Flutter-aware, talks to domain ONLY — never touches data/ directly
    bloc/
      product_bloc.dart                    # orchestrates use cases, emits State
      product_event.dart
      product_state.dart
    pages/
      product_list_page.dart                # route-level widget; target <150 LOC
      product_detail_page.dart
    widgets/
      product_list_item.dart                 # feature-specific, built from design_system atoms/molecules
      product_form.dart
```

### Why this specific split keeps files under 500 LOC

- A `_page.dart` file only wires a Bloc/Cubit to widgets — it never contains network calls, parsing, or business rules, so it naturally stays short.
- A `_repository_impl.dart` only orchestrates datasources and maps exceptions to `Failure` — it never contains UI or use-case logic.
- A `usecases/*.dart` file contains exactly one `call()` method — it is structurally incapable of growing large; if a use case starts needing 200 lines, that logic almost always belongs in a domain service instead (see paradigm catalog entry #26, Domain Service).

---

## 4. `core/` Catalog Table (Cross-Cutting Base Building Blocks)

| Base building block           | File                               | Purpose                                                                                                                                                      |
| ----------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Failure` (sealed base)       | `core/error/failure.dart`          | Base type for all expected error states — the Result pattern (paradigm #61).                                                                                 |
| `ExceptionMapper`             | `core/error/exception_mapper.dart` | Converts raw `DioException`/`PlatformException` into a domain `Failure`, at the repository boundary only.                                                    |
| `UseCase<Type, Params>`       | `core/usecase/usecase.dart`        | Abstract contract every use case implements — one call-site shape across the whole app.                                                                      |
| `NetworkInfo`                 | `core/network/network_info.dart`   | Abstraction over connectivity, injected wherever "online vs. offline" logic is needed.                                                                       |
| `ApiClient`                   | `core/network/api_client.dart`     | The one place Dio is configured — base URL, timeouts, interceptors.                                                                                          |
| `Injector` (composition root) | `core/di/injector.dart`            | The single place every datasource → repository → usecase → bloc binding is registered (paradigm #74, Composition Root).                                      |
| Generic UI states             | `core/widgets/`                    | `LoadingIndicator`, `ErrorStateWidget`, `EmptyStateWidget` — reused by every feature's Bloc-state `when()`/`map()` branches, instead of re-drawn per screen. |

---

## 5. Result / Failure Pattern (Code-Level Detail)

```dart
// core/error/failure.dart
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}
```

```dart
// core/usecase/usecase.dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

```dart
// domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
}
```

```dart
// data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl(this.remote, this.local, this.networkInfo);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remote.getProducts();
        await local.cacheProducts(models);
        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException {
        return const Left(ServerFailure());
      }
    }
    try {
      final cached = await local.getCachedProducts();
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
```

Notice the Bloc never sees `ServerException` or `CacheException` — only `Failure`. The UI layer only ever reasons about domain-level failure types, never transport-level ones. That is the Anti-Corruption Layer (paradigm #28) doing its job at the repository boundary.

---

## 6. State Management Layer — Keeping Bloc/Cubit Files Small

- **One Bloc/Cubit per sub-responsibility**, not per screen. If `ProductBloc` starts handling both the list and the detail screen, split it into `ProductListBloc` and `ProductDetailBloc` before it grows past ~8–10 event handlers.
- A Bloc **only calls UseCases** — never a Repository or a DataSource directly. This preserves the layering from §3 even under time pressure.
- Presentation-only mapping logic (state → widget) belongs in an extension method or a small private widget, not inline inside `BlocBuilder`'s builder callback.

```dart
// presentation/bloc/product_bloc.dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;

  ProductBloc(this.getProducts) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    final result = await getProducts(const NoParams());
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products)),
    );
  }
}
```

---

## 7. Multi-App / Shared Design System (Flutter Monorepo)

If more than one Flutter app (e.g. a customer app and an internal admin app) needs the **same** design system and/or the **same** domain logic, this is the direct analogue of the backend's "mobile vs. web-admin, same behavior, different endpoint" problem — solved the same way: extract the shared layer into its own package instead of duplicating it.

```
melos.yaml                     # Melos = the Dart/Flutter equivalent of Nx/Turborepo for monorepos
packages/
  design_system/                # §2, extracted verbatim into its own pub package
  core/                          # Failure, UseCase base, network client — shared package
  domain/                        # shared entities + repository interfaces + use cases, if truly shared
apps/
  customer_app/
    pubspec.yaml                  # depends on design_system, core, domain via path: ../../packages/...
  admin_app/
    pubspec.yaml                  # depends on the SAME packages
```

This is paradigm #77 (Shared Kernel Package) and #82 (Canonical Data Model) again — just realized as pub packages instead of npm packages. Only do this once you actually have a second app; building it speculatively for one app is YAGNI (#4).

---

## 8. Concrete Enforcement Checklist for the 500-LOC Ceiling

- **One class per file.** Never bundle two widgets, two Blocs, or a widget + its state class "for convenience" in one file.
- **Extract widgets, not methods.** If `build()` exceeds ~40–60 lines, pull the sub-tree into its own `StatelessWidget`/`StatelessConsumerWidget` in `widgets/`, not into a private `_buildXxx()` method — a private method still lives in the same file and doesn't reduce its size.
- **Split Blocs by sub-responsibility** once they pass ~8–10 event handlers (see §6).
- **Split repository implementations by responsibility** (e.g. `product_read_repository_impl.dart` / `product_write_repository_impl.dart`) if one accumulates too many query methods — CQRS (paradigm #19) applied at the repository layer.
- **Never let a `_page.dart` file contain parsing, network calls, or business rules** — if it does, that logic has leaked out of `domain`/`data` and needs to move back.
- **Wire a lint rule into CI**, e.g. `dart_code_metrics` or `custom_lint`, with a max-lines-per-file check (500) so an oversized file fails the PR automatically instead of relying on review discipline.

---

## 9. Quick Cross-Reference to the Paradigm Catalog

| Backend paradigm (catalog #1)                     | Flutter equivalent                                                                                                                                                                       |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Repository Pattern (#31)                          | `domain/repositories/*.dart` (interface) + `data/repositories/*_impl.dart`                                                                                                               |
| Unit of Work (#32)                                | Local-DB transaction wrapper (e.g. Drift's `transaction()`) when a use case must write to multiple tables atomically                                                                     |
| Mapper Pattern (#44)                              | `data/mappers/*_mapper.dart`                                                                                                                                                             |
| Factory Pattern (#41)                             | Named/factory constructors on `domain/entities/*.dart`                                                                                                                                   |
| DTO (#45)                                         | `data/models/*_model.dart`                                                                                                                                                               |
| Result/Either Pattern (#61)                       | `core/error/failure.dart` + `Either<Failure, T>` return types                                                                                                                            |
| Composition Root (#74)                            | `core/di/injector.dart`                                                                                                                                                                  |
| Shared Kernel Package (#77)                       | `packages/design_system`, `packages/core`, `packages/domain` (§7)                                                                                                                        |
| BFF / Transport-Agnostic Service Layer (#20, #85) | Not directly applicable client-side — its Flutter analogue is extracting shared `domain`/`design_system` packages so multiple apps consume identical logic instead of re-implementing it |

# Observability and Traceability Reinforcement Rules

These rules are mandatory for every new feature, endpoint, background process, integration, or infrastructure change.

The system must never become functionally capable but operationally blind.

A feature is not considered complete if it works but cannot be traced, inspected, diagnosed, or correlated when something goes wrong.

---

## 1. Observability Is Part of the Feature

Every new feature must either:

1. automatically inherit the existing observability infrastructure, or
2. explicitly mount into the existing logging/tracing layer, or
3. introduce a new observability adapter only when the existing infrastructure genuinely cannot cover the new execution path.

Never build a new feature first and "add logging later."

Observability is part of the implementation contract.

---

## 2. Never Create an Unobservable Execution Path

Before implementing a feature, ask:

```text
How will I know this feature was executed?
How will I know what input it received?
How will I know what output it produced?
How will I know why it failed?
How will I correlate the failure with the originating request?
```

If these questions cannot be answered from the existing observability system, the implementation is incomplete.

---

## 3. Prefer Existing Global Observability

Do not create random local logging mechanisms.

Before adding any logger, inspect whether the project already has:

```text
Pino
HTTP observability
requestId
correlationId
request context
structured logging
error logging
exception filters
tracing infrastructure
```

If an existing mechanism already covers the feature, use it.

Do not reinvent:

```text
console.log()
custom logger instances
feature-specific log files
ad-hoc JSON dumps
temporary debug statements
```

---

## 4. Every HTTP Endpoint Must Be Automatically Traceable

Any new HTTP endpoint must automatically inherit the global HTTP observability layer.

A newly created endpoint such as:

```ts
@Post('/appointments')
```

must immediately be observable without adding manual logging inside the controller.

The HTTP trace must expose, where safely available:

```text
requestId
timestamp
method
route
path
params
query
request metadata
request body
client metadata
authenticated actor
status code
response
duration
error
```

If a new endpoint bypasses global observability, fix the architecture.

Do not compensate by adding manual controller logging.

---

## 5. New Features Must Reuse Correlation Context

Every operation initiated by an HTTP request must preserve the request correlation context when possible.

Prefer propagation of:

```text
requestId
correlationId
traceId
```

through relevant execution boundaries.

The same logical operation should not suddenly generate unrelated logs with no way to connect them.

Desired relationship:

```text
HTTP Request
    ↓
Controller
    ↓
Service
    ↓
Repository
    ↓
External API / Queue / Worker
```

should remain traceable to the same originating operation where architecture permits.

---

## 6. Logs Must Explain State Transitions

For important operations, log meaningful state transitions rather than arbitrary prose.

Preferred:

```text
appointment.creation.started
appointment.creation.completed
appointment.creation.failed
```

Not:

```text
"masuk sini"
"test"
"jalan"
"done"
"error nih"
```

Logs should communicate what happened in system terms.

---

## 7. Generic Transport Logging and Business Logging Are Different

Do not duplicate HTTP logs inside business code.

The global HTTP layer already observes:

```text
request
response
status
duration
client
```

Feature-level logging should only exist when it provides additional domain value.

Example:

HTTP observability:

```text
POST /appointments
201
87ms
```

Feature observability:

```text
appointment.created
doctorId=...
patientId=...
scheduleId=...
```

Do not log the same thing twice.

---

## 8. Every Failure Path Must Be Observable

Do not only log success.

Whenever a feature can fail, ask whether the failure is visible.

Failures may include:

```text
validation failure
authorization failure
missing configuration
database failure
external API failure
timeout
conflict
invalid state transition
unexpected null
serialization failure
queue failure
background job failure
```

A developer should be able to determine:

```text
what failed
where it failed
which operation triggered it
which entity was involved
which request initiated it
what error category occurred
```

without inserting temporary debug statements.

---

## 9. Do Not Swallow Errors

Forbidden:

```ts
try {
  ...
} catch {
  return null;
}
```

or equivalent silent failure patterns.

If an error is intentionally transformed, preserve observability.

For example:

```text
original error category
operation
relevant identifiers
correlation ID
```

should remain discoverable.

Do not destroy diagnostic context.

---

## 10. Do Not Hide Configuration Failures Behind Fallbacks

If a feature depends on:

```text
ENV
API key
URL
storage configuration
queue configuration
database configuration
external service credentials
```

verify them first.

Do not silently replace missing configuration with dummy or fallback values merely to make execution continue.

A missing required configuration must be explicit and traceable.

Preferred:

```text
configuration.missing
key=STORAGE_BASE_URL
```

Not:

```text
fallback to localhost
```

unless fallback behavior is an intentional documented product decision.

---

## 11. No Temporary Console Debugging as Architecture

Agents must not solve observability using:

```ts
console.log();
console.error();
console.warn();
```

inside random feature files.

Temporary debugging may be used during investigation if necessary, but it must not become the permanent observability solution.

Permanent diagnostics must use the centralized logging system.

---

## 12. Logs Must Be Structured

Prefer:

```ts
logger.info({
  event: "appointment.created",
  requestId,
  appointmentId,
  doctorId,
});
```

over:

```ts
logger.info(`Appointment created ${appointmentId} doctor ${doctorId}`);
```

Structured metadata is easier to:

```text
filter
search
aggregate
correlate
export
parse
inspect
```

---

## 13. Stable Event Naming

Use stable machine-readable event names.

Preferred style:

```text
domain.action.state
```

Examples:

```text
auth.login.started
auth.login.completed
auth.login.failed

appointment.creation.started
appointment.creation.completed
appointment.creation.failed

schedule.update.started
schedule.update.completed
schedule.update.failed

storage.upload.started
storage.upload.completed
storage.upload.failed
```

Avoid changing event naming randomly between features.

---

## 14. Log Important Identifiers, Not Entire Objects

Prefer useful identifiers:

```text
userId
doctorId
patientId
scheduleId
appointmentId
requestId
```

Do not serialize an entire entity merely because it is available.

Bad:

```ts
logger.info({ user });
```

Better:

```ts
logger.info({
  userId: user.id,
  role: user.role,
});
```

This reduces noise and sensitive-data exposure.

---

## 15. Sensitive Data Must Never Be Logged Raw

Never emit:

```text
password
password hash
access token
refresh token
JWT
OTP
PIN
authorization header
cookie
session secret
API secret
private key
client secret
raw biometric data
```

Use centralized redaction.

Observability that leaks secrets is defective observability.

---

## 16. Logging Must Never Change Business Behavior

The logging layer must be passive.

It must not:

```text
change request payloads
change response payloads
change status codes
change exceptions
change transactions
change database state
change retry behavior
change authentication behavior
```

The system must behave identically whether verbose logging is enabled or disabled.

---

## 17. Logging Failure Must Not Break the Feature

If a logger, serializer, pretty printer, or telemetry sink fails, the business operation should continue whenever safely possible.

Observability infrastructure must not become a new critical failure dependency unless explicitly designed as one.

---

## 18. Do Not Log Huge or Binary Payloads Blindly

For:

```text
file uploads
images
documents
buffers
streams
binary responses
large arrays
```

log metadata instead.

Example:

```text
filename
mimeType
size
fieldName
```

Do not dump raw buffers or base64 contents into logs.

---

## 19. Preserve Request Context Across Async Boundaries

If the project uses request-scoped context or AsyncLocalStorage, respect it.

Do not create async execution paths that accidentally lose:

```text
requestId
correlationId
actor
client metadata
```

without checking whether the context must be propagated.

This is especially important for:

```text
async service operations
event handlers
queues
workers
scheduled jobs
external API calls
```

---

## 20. Background Jobs Need Their Own Trace Root

Operations without an HTTP request still require traceability.

Examples:

```text
cron jobs
queue consumers
scheduled tasks
workers
webhook processing
event handlers
```

They should create their own operation identifier such as:

```text
jobId
correlationId
traceId
```

Do not depend exclusively on HTTP request IDs.

---

## 21. External API Calls Must Be Traceable

When the backend calls another system, observe:

```text
target service
method
endpoint
duration
status
failure category
correlation ID
```

Do not log secrets or raw authorization headers.

If possible, propagate an existing correlation identifier to the downstream request.

---

## 22. Database Diagnostics Must Preserve Context

Do not spam SQL logs globally unless required.

However, important database failures should retain enough context to understand:

```text
which operation
which entity
which request
which repository action
which error
```

A database error should not appear as an isolated stack trace with no relationship to the request that caused it.

---

## 23. Feature Completion Requires Trace Verification

Before declaring a feature complete, verify at least:

```text
success path observable
validation failure observable
authorization failure observable
domain failure observable
unexpected failure observable
correlation ID present
important identifiers present
duration visible where relevant
sensitive data redacted
```

Do not assume observability works merely because Pino exists.

---

## 24. New Endpoint Checklist

For every new endpoint, ask:

```text
Does global HTTP logging see it automatically?
Does it have requestId?
Is input visible?
Is output visible?
Are errors visible?
Is duration visible?
Is actor context visible when authenticated?
Is client metadata visible when available?
Are secrets redacted?
```

If any answer is no, investigate before considering the endpoint finished.

---

## 25. New Service Checklist

For every new significant service operation:

```text
Does generic HTTP observability already provide enough information?
```

If yes:

do not add redundant logs.

If no:

add structured domain-level events at important state transitions.

---

## 26. New Integration Checklist

For every external integration:

```text
Can we see when the call starts?
Can we see which dependency was called?
Can we see how long it took?
Can we see the status/result?
Can we see the failure category?
Can we correlate it with the originating operation?
```

If not, mount it into the existing observability layer.

---

## 27. New Async Workflow Checklist

For queues, events, and workers:

```text
What identifies this job?
What triggered this job?
Can the trigger be correlated?
What input was accepted?
What state transition occurred?
What was the result?
Why did it fail?
```

Do not create invisible asynchronous workflows.

---

## 28. Do Not Create Observability Islands

Forbidden architecture:

```text
Feature A → Pino
Feature B → console.log
Feature C → custom text file
Feature D → no logging
Feature E → another logger
```

Target:

```text
Application
     ↓
Central Observability Contract
     ↓
Pino
```

with specialized adapters only where justified.

---

## 29. Single Source of Truth

There must be one authoritative configuration for:

```text
log levels
redaction
HTTP logging
pretty printing
request IDs
environment behavior
```

Do not duplicate these rules across modules.

---

## 30. Respect Existing Architecture Before Adding Files

Before creating:

```text
logger.service.ts
logging.module.ts
request-context.ts
observability.interceptor.ts
```

search the codebase first.

If equivalent infrastructure already exists, extend or reuse it.

Do not create parallel abstractions because you failed to inspect existing code.

---

## 31. Never Make Observability Feature-Specific Unless Necessary

Generic infrastructure belongs globally.

Bad:

```text
AppointmentHttpLogger
DoctorHttpLogger
PatientHttpLogger
ScheduleHttpLogger
```

for the same HTTP concerns.

Prefer:

```text
GlobalHttpObservability
```

Domain-specific event logging may remain domain-specific when it represents actual business events.

---

## 32. Observability Must Survive Future Features

The correct design should make this true:

> A developer can create a new endpoint tomorrow and receive HTTP observability automatically.

If every new endpoint requires remembering to add logging manually, the architecture is fragile.

Fix the infrastructure rather than writing another reminder.

---

## 33. Do Not Produce Noise Without Diagnostic Value

More logs do not automatically mean better observability.

Avoid:

```text
entered function
leaving function
service called
repository called
value is X
```

unless these events materially help diagnose the operation.

Prefer high-signal events.

---

## 34. Logs Must Answer Diagnostic Questions

For any feature, logs should allow an engineer to answer:

```text
What happened?
When?
Which request/job caused it?
Who initiated it?
What input mattered?
Which entity was affected?
What state changed?
How long did it take?
What result occurred?
Why did it fail?
```

If the logs cannot answer these questions, improve them.

---

## 35. Do Not Overengineer

Observability is mandatory.

Architectural ceremony is not.

Do not create:

```text
10 interfaces
15 factories
20 wrappers
```

for a simple operation.

Reuse the existing Pino infrastructure.

Introduce abstractions only when they create real boundaries.

---

## 36. Default Decision Rule

Whenever adding a new feature:

```text
1. Inspect existing observability.
2. Determine whether the new path is already covered.
3. Reuse existing tracing/logging if possible.
4. Add missing structured events only where necessary.
5. Preserve request/correlation context.
6. Verify success and failure traces.
7. Confirm sensitive data is redacted.
8. Only then consider the feature complete.
```

---

# Mandatory Agent Reinforcement

Before finishing ANY feature implementation, explicitly verify:

```text
OBSERVABILITY CHECK

[ ] New execution path is observable.
[ ] Existing global logger is reused.
[ ] No random console logging was introduced.
[ ] Request/job correlation exists.
[ ] Success path is traceable.
[ ] Failure path is traceable.
[ ] Important identifiers are included.
[ ] Sensitive information is redacted.
[ ] Logging does not change behavior.
[ ] Logging failure cannot break the feature.
[ ] No duplicate observability infrastructure was created.
```

If one of these conditions is false, the feature is NOT complete.

---

# Core Principle

Never build software that can execute but cannot explain what it did.

Functionality without observability creates invisible failure.

Every new feature must leave enough structured evidence for another engineer to reconstruct:

```text
trigger
→ input
→ execution
→ state transition
→ output
→ failure
```

without modifying the codebase merely to understand what happened.
Untuk Flutter, saya akan pakai **feature-first architecture dengan internal layering**, bukan satu folder global `screens/`, `services/`, `models/`, `widgets/` yang akhirnya jadi dumping ground.

Struktur mentalnya:

```text
App Shell
   ↓
Feature
   ├── Presentation
   ├── Application
   ├── Domain
   └── Data / Infrastructure
```

Sedangkan hal yang benar-benar lintas fitur:

```text
Core
Design System
Networking
Logging
Configuration
Storage
Navigation
```

Dan aturan `<500 lines` sebaiknya dianggap **hard review threshold**, bukan alasan untuk memotong file secara bodoh. Kalau file 480 baris tapi cohesive masih mungkin sehat; kalau 180 baris tapi punya 7 responsibility, itu sudah buruk.

Di bawah ini versi `AGENTS.md` yang bisa langsung Anda masukkan.

```md
# Flutter Architecture, Presentation Layer, Design System, and Abstraction Rules

## 0. Purpose

These rules govern the architecture of this Flutter application.

They exist to prevent:

- God Widgets
- God Screens
- God Controllers
- God Providers
- God Services
- 1,000–2,000 line Dart files
- business logic inside widgets
- HTTP calls inside UI
- persistence logic inside presentation
- feature-specific logic leaking into shared infrastructure
- random helper dumping grounds
- duplicated visual tokens
- duplicated API mapping
- hardcoded backend semantics
- tightly coupled feature modules
- unreadable state management
- untraceable asynchronous behavior
- widget trees with excessive nesting
- presentation code that cannot be tested independently
- design-system drift
- infrastructure leaking into domain logic

The architecture must optimize for:

```text
high cohesion
low coupling
clear ownership
explicit dependencies
small composable units
testability
traceability
predictable data flow
replaceable infrastructure
reusable design primitives
```

The target is not literal zero coupling.

The target is:

> Minimal, explicit, intentional coupling through stable contracts.

---

# 1. Architectural Philosophy

Use:

```text
FEATURE-FIRST
+
LAYERED INTERNALLY
```

Do NOT organize the entire project primarily as:

```text
screens/
widgets/
models/
services/
repositories/
```

because those directories eventually become global dumping grounds.

Prefer:

```text
features/
    appointment/
    schedule/
    profile/
    authentication/
```

with clear internal boundaries.

---

# 2. Recommended Top-Level Structure

Use the existing project structure where it is already coherent.

If the project does not have a mature structure, target something conceptually similar to:

```text
lib/
├── app/
│   ├── app.dart
│   ├── bootstrap/
│   ├── routing/
│   ├── dependency_injection/
│   └── configuration/
│
├── core/
│   ├── error/
│   ├── logging/
│   ├── network/
│   ├── storage/
│   ├── serialization/
│   ├── validation/
│   ├── platform/
│   ├── extensions/
│   └── constants/
│
├── design_system/
│   ├── foundations/
│   ├── primitives/
│   ├── components/
│   ├── patterns/
│   └── themes/
│
├── features/
│   ├── authentication/
│   ├── appointment/
│   ├── schedule/
│   ├── profile/
│   └── ...
│
└── main.dart
```

Do not blindly create every folder.

Every folder must have a real ownership purpose.

---

# 3. Feature Internal Structure

A feature should normally follow:

```text
features/
└── schedule/
    ├── domain/
    ├── application/
    ├── data/
    └── presentation/
```

Conceptually:

```text
Presentation
     ↓
Application
     ↓
Domain
     ↑
Data / Infrastructure
```

Dependency direction matters more than folder names.

---

# 4. Domain Layer

The domain layer contains business meaning.

It may contain:

```text
entities
value objects
domain enums
business policies
domain rules
repository contracts
domain failures
domain services
```

Example:

```text
features/
└── schedule/
    └── domain/
        ├── entities/
        │   └── doctor_schedule.dart
        ├── value_objects/
        │   └── schedule_time_range.dart
        ├── enums/
        │   └── schedule_state.dart
        ├── policies/
        │   └── schedule_edit_policy.dart
        ├── repositories/
        │   └── schedule_repository.dart
        └── failures/
            └── schedule_failure.dart
```

The domain layer must not know:

```text
Flutter widgets
BuildContext
Dio
HTTP response objects
SharedPreferences
SQLite
Hive
SecureStorage
Firebase
Riverpod
Bloc
Provider
GoRouter
Navigator
```

unless the architecture explicitly treats something as domain infrastructure, which should be exceptional.

---

# 5. Domain Must Be Framework-Independent

Forbidden:

```dart
class SchedulePolicy {
  bool canEdit(BuildContext context) {
    ...
  }
}
```

Forbidden:

```dart
class Appointment {
  final Dio dio;
}
```

Forbidden:

```dart
import 'package:flutter/material.dart';
```

inside business entities without a genuine domain reason.

Domain logic should ideally remain usable in plain Dart.

---

# 6. Domain Models Are Not API DTOs

Do not automatically use API response models as domain objects.

Example:

```text
Backend JSON
    ↓
Response DTO
    ↓
Mapper
    ↓
Domain Entity
```

Use this separation where semantics differ.

Do not add mapping ceremony when API shape and domain representation are genuinely identical and there is no architectural benefit.

---

# 7. Domain Owns Business Semantics

If the backend returns:

```text
AVAILABLE
OCCUPIED
CLOSED
UNSCHEDULED
```

and these are authoritative domain states, define them centrally.

Do not scatter:

```dart
if (status == 'available')
```

through widgets.

Prefer:

```dart
ScheduleState.available
```

or the project's equivalent typed representation.

---

# 8. Backend Remains Source of Truth

The Flutter client must not reconstruct authoritative backend state when the backend already provides it.

Bad:

```dart
status == 'Tutup'
    ? ScheduleState.closed
    : ScheduleState.available;
```

when backend already returns canonical state.

Good:

```text
API contract
    ↓
DTO parser
    ↓
typed client representation
```

Do not invent frontend truth.

---

# 9. Application Layer

The application layer coordinates use cases.

It answers:

```text
What should happen?
In what order?
Which domain capability is used?
Which repository contract is required?
```

It should not answer:

```text
How is HTTP encoded?
How does Dio work?
How does SQLite execute SQL?
How does Flutter render widgets?
```

Suggested structure:

```text
application/
├── use_cases/
├── commands/
├── queries/
├── coordinators/
└── state/
```

Adapt to the project's actual state-management architecture.

---

# 10. Use Cases

For non-trivial operations prefer explicit use-case ownership.

Examples:

```text
LoadDoctorSchedule
CreateAppointment
CancelAppointment
RescheduleAppointment
UpdateProfile
AuthenticateUser
```

A use case should orchestrate.

It should not become another God Service.

---

# 11. Use Case Example

Conceptually:

```text
RescheduleAppointment
        ↓
AppointmentRepository
        ↓
result
```

Potential orchestration:

```text
validate input
    ↓
call repository
    ↓
interpret domain result
    ↓
return application result
```

Do not include widget behavior.

---

# 12. Application Layer Must Not Know Widgets

Forbidden:

```dart
Future<void> execute(BuildContext context) {
  showDialog(...);
}
```

Forbidden:

```dart
ScaffoldMessenger.of(context).showSnackBar(...)
```

inside use cases.

UI feedback belongs to presentation.

---

# 13. Application State Is Not Widget State

Differentiate:

```text
application state
```

from:

```text
temporary widget state
```

Examples of application state:

```text
loaded schedule
current authenticated user
appointment submission state
profile update state
```

Examples of local widget state:

```text
password visible
tab expanded
animation controller
current text-field focus
hover state
temporary form interaction
```

Do not push every boolean into global state management.

---

# 14. State Management Must Remain Replaceable

Whether the project uses:

```text
Riverpod
Bloc
Cubit
Provider
GetX
another approach
```

feature business rules must not become inseparable from that library.

State-management providers/controllers should orchestrate application capabilities.

They should not contain all business logic.

---

# 15. Provider / Bloc / Controller Is Not a Service Dumping Ground

Bad:

```text
ScheduleProvider
1200 lines
```

containing:

```text
HTTP
JSON parsing
business state calculation
navigation
dialogs
date formatting
cache
authentication
logging
```

Split responsibilities.

---

# 16. Recommended State Flow

Target:

```text
Widget
   ↓
Presentation Controller / Notifier
   ↓
Use Case
   ↓
Repository Contract
   ↓
Repository Implementation
   ↓
Remote / Local Data Source
```

Result flows back upward.

---

# 17. Data Layer

The data layer handles data acquisition and representation.

Typical responsibilities:

```text
API DTOs
JSON serialization
repository implementations
remote data sources
local data sources
cache adapters
persistence adapters
API mappers
```

Example:

```text
data/
├── datasources/
│   ├── remote/
│   └── local/
├── dto/
├── mappers/
└── repositories/
```

---

# 18. Repository Contract vs Implementation

Domain/application may depend on:

```dart
abstract interface class ScheduleRepository {
  Future<ScheduleResult> getSchedule(...);
}
```

Infrastructure implements:

```text
ApiScheduleRepository
```

or:

```text
ScheduleRepositoryImpl
```

depending on project convention.

Do not let feature logic depend directly on Dio.

---

# 19. Remote Data Source Responsibility

Remote data sources may know:

```text
HTTP client
endpoint path
request body
query parameters
serialization
HTTP contract
```

They should not own presentation logic.

---

# 20. Local Data Source Responsibility

Local data sources may know:

```text
SharedPreferences
SecureStorage
SQLite
Drift
Hive
file storage
```

They should not make UI decisions.

---

# 21. Repository Implementation Responsibility

A repository implementation may:

```text
coordinate remote and local data sources
map DTOs to domain representations
apply cache policy
translate infrastructure errors
```

It must not contain widget behavior.

---

# 22. Presentation Layer

The presentation layer contains:

```text
screens/pages
feature widgets
presentation controllers/notifiers
presentation models
view state
navigation triggers
form state
visual formatting
```

It does NOT own:

```text
HTTP
database
raw persistence
business source of truth
backend contract reconstruction
```

---

# 23. Recommended Presentation Structure

Example:

```text
presentation/
├── pages/
│   └── schedule_page.dart
│
├── sections/
│   ├── schedule_header_section.dart
│   ├── schedule_calendar_section.dart
│   └── schedule_list_section.dart
│
├── widgets/
│   ├── schedule_card.dart
│   ├── schedule_status_badge.dart
│   └── schedule_empty_state.dart
│
├── state/
│   ├── schedule_state.dart
│   └── schedule_controller.dart
│
├── models/
│   └── schedule_view_model.dart
│
└── mappers/
    └── schedule_view_mapper.dart
```

Do not create all folders automatically.

Create only those justified by actual feature complexity.

---

# 24. Page Responsibility

A page/screen should mostly compose the feature.

Example:

```text
SchedulePage
    ↓
Scaffold
    ↓
ScheduleHeaderSection
    ↓
ScheduleCalendarSection
    ↓
ScheduleContentSection
```

The page should not contain 800 lines of implementation.

---

# 25. Page Is an Orchestrator, Not a God Widget

A page may decide:

```text
loading
error
empty
success
```

and compose sections.

It should not directly implement every card, dialog, mapper, HTTP call, validation rule, and formatter.

---

# 26. Section Abstraction

Use section-level widgets when a page contains meaningful visual regions.

Example:

```text
ProfilePage
├── ProfileHeaderSection
├── PersonalInformationSection
├── ContactInformationSection
└── SecuritySection
```

A section owns a coherent piece of UI.

---

# 27. Widget Extraction Rule

Extract a widget when one or more are true:

```text
it has independent semantic meaning
it is reusable
it has substantial internal layout
it owns local UI state
it can be tested independently
it reduces cognitive complexity
```

Do not extract meaningless fragments such as:

```text
_buildTop()
_buildThing()
_buildSecondThing()
```

solely to reduce line count.

---

# 28. Prefer Widget Classes Over Giant `_buildX()` Forests

A screen containing:

```dart
_buildHeader()
_buildContent()
_buildSchedule()
_buildDoctor()
_buildFooter()
_buildError()
_buildLoading()
```

may still be a God Widget.

When these pieces have semantic identity, make them real widget classes.

---

# 29. Private Builder Functions Are Not Architectural Decomposition

Moving 600 lines into twenty:

```dart
Widget _buildSomething()
```

methods inside the same file is not true decomposition.

The file still owns everything.

Extract semantic components when responsibility differs.

---

# 30. Widget File Size

The following are review thresholds:

```text
0–200 lines
generally healthy

200–350 lines
review complexity

350–500 lines
strong decomposition review required

>500 lines
normally prohibited
```

A file exceeding 500 lines requires explicit justification.

Do not split code arbitrarily just to satisfy the number.

---

# 31. Function Size

Use approximately:

```text
<40 logical lines
```

as a healthy target for most functions.

Around:

```text
40–60
```

requires review.

Above that, inspect for multiple responsibilities.

These are heuristics, not mechanical laws.

---

# 32. Widget Build Method

A `build()` method should remain readable.

Bad:

```text
build()
  300 lines
  nested Row
  nested Column
  nested Builder
  nested Consumer
  nested LayoutBuilder
```

Prefer semantic composition:

```dart
return AppointmentScreenLayout(
  header: ...,
  content: ...,
  actions: ...,
);
```

---

# 33. Avoid Excessive Widget Nesting

Deep widget nesting increases cognitive complexity.

Prefer extracting meaningful compositions.

Do not extract merely because Flutter naturally nests widgets.

Use semantic boundaries.

---

# 34. Presentation Must Not Fetch Directly

Forbidden:

```dart
FutureBuilder(
  future: Dio().get(...),
)
```

inside screens.

Forbidden:

```dart
onPressed: () async {
  await http.post(...);
}
```

inside UI.

Presentation invokes application/state abstractions.

---

# 35. Presentation Must Not Parse Raw JSON

Forbidden:

```dart
final status = json['data']['schedule']['status'];
```

inside widgets.

JSON parsing belongs to data boundaries.

---

# 36. Presentation Must Not Know Database Schema

Widgets must not know:

```text
table names
column names
SQL queries
database joins
```

---

# 37. View Models

Presentation-specific representation may use view models where useful.

Example:

```text
Schedule
    ↓
ScheduleViewMapper
    ↓
ScheduleViewModel
```

Use this when presentation requires derived display information.

Do not add view models mechanically for trivial features.

---

# 38. View Model Does Not Own Backend Truth

A ViewModel may derive presentation properties such as:

```text
formatted time
formatted date
accessibility label
localized label
icon choice
```

It must not invent domain truth already provided by backend/domain.

---

# 39. Presentation Mapping

Example:

```text
ScheduleState.closed
    ↓
ScheduleVisualState
    ↓
design-system semantic color token
```

This is acceptable.

Bad:

```text
status string
    ↓
if status == "Tutup"
    ↓
invent CLOSED backend state
```

Presentation maps canonical state to appearance.

It does not reconstruct canonical state.

---

# 40. Design System Ownership

Global visual primitives belong in:

```text
design_system/
```

not inside random features.

The design system owns:

```text
color tokens
typography
spacing
radius
elevation policy
icon sizing
motion tokens
responsive values
shared controls
shared feedback components
```

---

# 41. Design System Suggested Structure

```text
design_system/
├── foundations/
│   ├── colors/
│   ├── typography/
│   ├── spacing/
│   ├── radius/
│   ├── motion/
│   ├── breakpoints/
│   └── iconography/
│
├── primitives/
│   ├── buttons/
│   ├── text/
│   ├── icons/
│   ├── surfaces/
│   ├── inputs/
│   └── dividers/
│
├── components/
│   ├── app_button/
│   ├── app_text_field/
│   ├── status_badge/
│   ├── empty_state/
│   ├── error_state/
│   └── loading_indicator/
│
├── patterns/
│   ├── form_section/
│   ├── confirmation_dialog/
│   ├── information_card/
│   └── list_section/
│
└── themes/
    ├── light_theme.dart
    ├── dark_theme.dart
    └── theme_extensions.dart
```

Do not force Atomic Design terminology if it creates confusion.

The important hierarchy is:

```text
FOUNDATION
→ PRIMITIVE
→ COMPONENT
→ PATTERN
→ FEATURE COMPOSITION
```

---

# 42. Design-System Dependency Direction

Allowed:

```text
Feature UI
    ↓
Design System
```

Forbidden:

```text
Design System
    ↓
Appointment Feature
```

The design system must never depend on business features.

---

# 43. Foundation Tokens

Avoid raw visual magic values throughout features.

Bad:

```dart
Color(0xFF...)
fontSize: 17
borderRadius: 13
EdgeInsets.all(19)
```

repeated arbitrarily.

Prefer semantic or scale tokens.

Example:

```text
AppSpacing.sm
AppSpacing.md
AppRadius.md
AppTypography.bodyMedium
```

---

# 44. Semantic Color Tokens

Prefer semantic naming.

Good:

```text
surfacePrimary
surfaceSecondary
textPrimary
textSecondary
borderSubtle
actionPrimary
statusSuccess
statusWarning
statusError
```

Avoid feature widgets depending on arbitrary raw hexadecimal colors when the design system owns them.

---

# 45. Do Not Encode Business Semantics Into Global Colors

Bad global token:

```text
doctorClosedScheduleYellow
```

Prefer:

```text
statusWarning
```

or feature-level mapping from domain state to semantic visual token.

---

# 46. Typography

Typography rules must be centralized.

Avoid individual widgets randomly defining:

```text
fontFamily
fontWeight
fontSize
height
letterSpacing
```

unless they intentionally define a new design-system token.

---

# 47. Spacing

Use a controlled spacing scale.

Conceptually:

```text
xs
sm
md
lg
xl
2xl
```

Do not scatter:

```text
7
13
19
27
```

without design-system reasoning.

---

# 48. Radius

Use centralized radius tokens.

Do not create arbitrary:

```text
BorderRadius.circular(17)
```

across different widgets.

---

# 49. Shadows and Elevation

Respect the project design policy.

If the product design avoids shadows, feature code must not independently introduce them.

Surface treatment belongs to design-system policy.

---

# 50. Motion

Animations must use shared duration and curve tokens where reasonable.

Example:

```text
AppMotion.fast
AppMotion.standard
AppMotion.slow
```

Avoid random:

```dart
Duration(milliseconds: 237)
```

throughout features.

---

# 51. Reusable Components

A component belongs in the global design system only when it is genuinely reusable across domains.

Example:

```text
AppButton
AppTextField
StatusBadge
EmptyState
ErrorState
LoadingIndicator
```

Not:

```text
DoctorScheduleClosedCard
```

which likely belongs to the schedule feature.

---

# 52. Feature-Specific Components Stay in Feature

Example:

```text
features/
└── appointment/
    └── presentation/
        └── widgets/
            └── appointment_card.dart
```

Do not pollute the global design system with domain-specific widgets.

---

# 53. Promotion Rule

Start local.

Promote to the design system only after the component demonstrates genuine cross-feature reuse and stable semantics.

Do not globalize components prematurely.

---

# 54. Atomic Composition

Where useful, think:

```text
Foundation
    ↓
Primitive
    ↓
Component
    ↓
Feature Widget
    ↓
Section
    ↓
Page
```

Example:

```text
Typography Token
    ↓
AppText
    ↓
StatusBadge
    ↓
ScheduleCard
    ↓
ScheduleListSection
    ↓
SchedulePage
```

---

# 55. Do Not Over-Atomize

Avoid:

```text
DoctorNameText
DoctorSpecialtyText
DoctorTimeText
DoctorAvatarCircle
DoctorCardPadding
```

as separate global files unless they represent reusable abstractions.

Atomic design is not permission to create meaningless micro-files.

---

# 56. Component API Must Be Narrow

Bad:

```dart
AppointmentCard(
  color1,
  color2,
  radius,
  shadow,
  titleFont,
  subtitleFont,
  buttonRadius,
  buttonColor,
  iconColor,
  ...
)
```

This exposes internal design-system details.

Prefer semantic inputs:

```text
appointment
state
onDetails
onReschedule
```

and let the component/design system own presentation rules.

---

# 57. Avoid Prop Drilling

If data passes through multiple intermediate widgets that do not consume it, reconsider composition.

Use the project's state/context mechanism appropriately.

Do not immediately make everything global.

---

# 58. Local State First

Prefer local state for local concerns.

Examples:

```text
selected tab
expanded card
text visibility
animation state
local input focus
```

Do not create global providers for trivial local interaction state.

---

# 59. Feature State for Feature Concerns

Use feature-level state management for:

```text
remote loading
feature data
submission
domain failure
refresh
pagination
```

---

# 60. Global State Is Expensive

Global state should be limited to truly application-wide concerns such as:

```text
authentication session
application configuration
global user context
theme
locale
```

Do not move feature state globally for convenience.

---

# 61. State Must Be Explicit

Avoid ambiguous booleans:

```dart
isLoading
hasData
hasError
isDone
```

that can form impossible combinations.

Prefer explicit state models where complexity warrants it.

Example:

```text
initial
loading
success
empty
failure
```

or sealed classes/unions depending on project conventions.

---

# 62. Impossible States Should Be Difficult to Represent

Bad:

```text
isLoading = true
hasError = true
data != null
```

simultaneously.

Prefer a state representation that makes invalid combinations impossible or obvious.

---

# 63. Async State

Remote operations should expose meaningful async lifecycle.

Example:

```text
idle
submitting
success
failure
```

Do not infer asynchronous state from unrelated booleans.

---

# 64. Separate Read State and Mutation State Where Necessary

A screen may have:

```text
scheduleQueryState
scheduleUpdateState
```

instead of one enormous state object controlling every operation.

Use this separation only when it improves clarity.

---

# 65. Form Architecture

Large forms should not store every responsibility inside the screen.

Potential separation:

```text
Form Widget
    ↓
Form Controller
    ↓
Form Value / Input Model
    ↓
Use Case
```

Validation ownership must be explicit.

---

# 66. Client Validation vs Backend Validation

Client validation improves UX.

Backend validation remains authoritative.

Do not encode backend business rules twice unless required for UX.

When duplicated intentionally, ensure server remains source of truth.

---

# 67. Navigation

Navigation should be centralized according to existing project conventions.

Avoid random:

```text
Navigator.push(...)
```

scattered through repositories/services.

Navigation is presentation/application-shell responsibility.

---

# 68. Business Logic Must Not Navigate

Forbidden:

```dart
class AppointmentRepository {
  void create() {
    Navigator.push(...);
  }
}
```

Repositories return results.

Presentation decides navigation.

---

# 69. Dialogs and Snackbars

Dialogs, sheets, snackbars, and UI notifications belong to presentation.

A repository should never call:

```text
showDialog
showModalBottomSheet
ScaffoldMessenger
```

---

# 70. Side Effects

Explicitly separate:

```text
state transition
```

from:

```text
UI side effect
```

Example:

```text
appointment creation succeeds
    ↓
controller state becomes success
    ↓
presentation reacts
    ↓
navigate / show message
```

Do not hide UI side effects deep inside data services.

---

# 71. Networking

Networking belongs in centralized infrastructure.

Suggested:

```text
core/
└── network/
    ├── client/
    ├── interceptors/
    ├── configuration/
    ├── errors/
    └── observability/
```

Features may provide endpoint-specific data sources.

---

# 72. One HTTP Client Ownership Model

Do not create:

```dart
Dio()
```

inside arbitrary repositories.

Use the centrally configured HTTP client.

This preserves:

```text
authentication
timeouts
observability
correlation
base URL
error handling
```

---

# 73. HTTP DTOs Stay at Data Boundary

Example:

```text
ScheduleResponseDto
```

should normally remain inside schedule data infrastructure.

Do not expose HTTP-specific DTOs throughout presentation.

---

# 74. API Error Translation

Raw Dio exceptions should not normally reach widgets.

Target:

```text
DioException
    ↓
Data Error Mapper
    ↓
Application/Domain Failure
    ↓
Presentation State
```

Do not display raw infrastructure exception strings to users.

---

# 75. Observability

Every feature must inherit existing logging/HTTP observability.

Do not add:

```dart
print()
debugPrint()
```

as permanent observability.

Use the application logging abstraction.

---

# 76. Feature-Level Logs

Generic request/response logging belongs to network infrastructure.

Feature code should only emit meaningful application events when necessary.

Example:

```text
appointment.creation.started
appointment.creation.failed
appointment.creation.completed
```

Do not duplicate full HTTP payload logs inside feature controllers.

---

# 77. Correlation

If HTTP infrastructure provides:

```text
requestId
correlationId
```

preserve it where possible.

Debugging should allow:

```text
Flutter action
    ↓
HTTP request
    ↓
NestJS request
```

to be correlated.

---

# 78. Local Persistence

Treat persistent storage as infrastructure.

Define capability-oriented interfaces when justified.

Examples:

```text
SessionStorage
SecureTokenStorage
ProfileCache
```

Do not let domain logic depend directly on SharedPreferences keys.

---

# 79. Storage Keys

Do not scatter:

```dart
prefs.getString('foo')
```

across the project.

Keys and storage ownership must be centralized.

---

# 80. Secure Data

Credentials/tokens must use the approved secure-storage mechanism.

Never hide security-sensitive state inside generic preferences for convenience.

---

# 81. Mappers

Mappers should be pure where possible.

Examples:

```text
DTO → Domain
Domain → Persistence
Domain → View Model
```

Mappers should not fetch data.

---

# 82. Formatter

Formatting should be explicit.

Examples:

```text
DateFormatter
TimeFormatter
PhoneFormatter
```

But do not create generic formatter classes containing unrelated methods.

---

# 83. Extensions

Dart extensions are appropriate for small, semantically obvious transformations.

Do not use extensions to hide:

```text
database calls
network calls
global state
large business logic
```

Extensions should remain predictable.

---

# 84. Utility Folder Rule

Never create a giant:

```text
utils.dart
helpers.dart
common.dart
```

containing unrelated behavior.

Utility ownership must be semantic.

Example:

```text
core/
└── formatting/
    ├── date_formatter.dart
    └── file_size_formatter.dart
```

---

# 85. Feature-Local Utility Rule

If only one feature uses a helper, keep it inside that feature.

Do not immediately promote it into `core`.

---

# 86. Shared Code Promotion

Promote code to `core` only when:

```text
multiple features genuinely require it
semantics are identical
ownership is domain-independent
behavior is stable
```

---

# 87. Dependency Direction

Desired:

```text
Presentation
    ↓
Application
    ↓
Domain
```

Infrastructure/data implements capabilities required inward.

Avoid:

```text
Domain
    ↓
Presentation
```

or:

```text
Domain
    ↓
Dio
```

---

# 88. Cross-Feature Dependencies

Features must not casually import each other's internal files.

Bad:

```text
appointment
    ↓
schedule/data/internal/schedule_repository_impl.dart
```

Prefer:

```text
public feature contract
```

or move genuinely shared semantics to an appropriate shared domain/module.

---

# 89. No Feature Internals Leakage

Feature internal files should remain private by convention.

Expose only deliberate public APIs.

---

# 90. Barrel Files

Use barrel files only where they make module boundaries clearer.

Do not create barrel exports that:

```text
export every internal file
hide circular dependencies
destroy ownership
```

---

# 91. Circular Dependencies

Circular feature dependencies are architectural warnings.

Do not solve them with import hacks.

Reassess ownership.

---

# 92. Dependency Injection

Use the existing project DI approach.

Do not instantiate infrastructure manually inside presentation.

Bad:

```dart
final repository = ScheduleRepositoryImpl(Dio());
```

inside widget code.

---

# 93. Composition Root

Dependency wiring belongs at the composition root.

Conceptually:

```text
App Bootstrap
    ↓
HTTP Client
    ↓
Repositories
    ↓
Use Cases
    ↓
Controllers / Providers
```

Feature widgets consume configured capabilities.

---

# 94. Environment Configuration

Environment values must be centralized.

Do not scatter:

```dart
const apiUrl = 'http://...';
```

through feature files.

Use typed configuration.

---

# 95. No Silent ENV Fallback

If required configuration is missing, fail explicitly according to environment policy.

Do not silently point to random localhost URLs.

---

# 96. Constants

Constants should live near their owner.

Examples:

```text
design tokens
→ design system

API paths
→ network/data feature

domain states
→ domain

storage keys
→ storage infrastructure
```

Do not create one giant global `constants.dart`.

---

# 97. Strings

User-facing strings should follow the project's localization strategy.

Do not scatter duplicated UI copy where localization infrastructure exists.

---

# 98. Error UI

Reusable presentation states may include:

```text
LoadingState
ErrorState
EmptyState
```

as design-system or shared presentation components.

Feature-specific failures still belong to the feature.

---

# 99. Skeletons and Loading

Do not hardcode arbitrary loading behavior in every screen.

Use existing presentation patterns where appropriate.

---

# 100. Responsive Design

Responsive logic should be centralized where possible.

Do not scatter arbitrary:

```dart
if (width > 721)
```

through unrelated widgets.

Use design-system breakpoints or layout abstractions.

---

# 101. Platform Adaptation

Platform-specific behavior should be isolated.

Example:

```text
core/platform/
```

or local feature adapters.

Do not litter:

```dart
Platform.isAndroid
```

through every widget.

---

# 102. Device Capability

Camera, biometrics, files, sensors, notifications, etc. are infrastructure/platform capabilities.

Use adapters where appropriate.

Example:

```text
CameraPort
    ↑
FlutterCameraAdapter
```

when business/application code genuinely needs abstraction.

---

# 103. Widget Rebuild Awareness

Avoid making large screens listen to broad state objects unnecessarily.

Prefer selecting only relevant state where the chosen state-management framework supports it.

Do not prematurely optimize trivial widgets.

---

# 104. Expensive Computation

Do not perform expensive transformation repeatedly inside `build()`.

Move deterministic heavy work to:

```text
controller
memoized/selective state
mapper
domain calculation
```

depending on ownership.

---

# 105. Build Must Remain Side-Effect Free

Do not initiate uncontrolled:

```text
HTTP calls
database writes
navigation
analytics mutations
```

inside `build()`.

---

# 106. Lifecycle

Async work tied to widget lifecycle must respect:

```text
mounted state
cancellation
disposal
controller ownership
```

Do not leak resources.

---

# 107. Controllers Must Be Disposed

Any manually created:

```text
AnimationController
TextEditingController
FocusNode
ScrollController
StreamSubscription
```

must have explicit ownership and disposal.

---

# 108. Avoid StatefulWidget by Default

Do not treat StatefulWidget as bad.

Use local state where local state is appropriate.

The rule is:

```text
local interaction state
→ widget state

feature/application state
→ feature state mechanism
```

---

# 109. Avoid Global State by Default

Do not elevate state because passing it explicitly feels inconvenient.

Global state increases coupling.

---

# 110. Presentation Component Inputs

Widgets should accept narrow semantic inputs.

Bad:

```dart
ScheduleCard({
  required Map<String, dynamic> rawData,
});
```

Better:

```dart
ScheduleCard({
  required ScheduleViewModel schedule,
});
```

or domain model if presentation mapping is unnecessary.

---

# 111. Avoid `Map<String, dynamic>` Across Layers

Raw dynamic maps belong near serialization boundaries.

Convert them to typed structures early.

---

# 112. Avoid `dynamic`

Use explicit types.

`dynamic` is not architectural flexibility.

It removes contracts.

---

# 113. Nullability Must Have Meaning

Do not make fields nullable merely to avoid initialization problems.

Ask:

```text
Can this value actually be absent?
```

If not, require it.

---

# 114. Avoid Boolean Parameter Explosion

Bad:

```dart
ScheduleCard(
  true,
  false,
  true,
  false,
)
```

Prefer semantic configuration or typed state.

---

# 115. Avoid Constructor Explosion

If a widget requires 20 unrelated parameters, it may represent multiple responsibilities.

Review decomposition.

---

# 116. Avoid Widget Configuration Explosion

Do not expose internal styling excessively.

A shared component should own its design.

Consumers should provide semantics, not reconstruct the component visually.

---

# 117. Business State vs Visual State

Keep distinction:

```text
ScheduleState.closed
```

is business/domain state.

```text
StatusAppearance.warning
```

is presentation state.

Map them deliberately.

Do not merge them into one ambiguous string.

---

# 118. Design System Must Not Know Backend Enums

A global `StatusBadge` should not necessarily import:

```text
ScheduleState
AppointmentStatus
PaymentStatus
```

It should accept semantic appearance inputs.

Feature owns mapping:

```text
ScheduleState
    ↓
StatusBadgeVariant
```

This keeps the design system domain-agnostic.

---

# 119. Theme Extensions

Use ThemeExtension where it provides meaningful typed semantic tokens.

Do not create giant theme classes carrying every feature-specific value.

---

# 120. No Direct Theme Magic

Avoid repeatedly doing complex:

```dart
Theme.of(context).colorScheme....
```

mapping differently across features when a design-system component should own it.

---

# 121. Icons

Centralize iconography rules where the design system specifies them.

Avoid mixing random icon packs without intention.

---

# 122. Assets

Asset ownership should be clear.

Example:

```text
assets/
├── images/
├── icons/
└── illustrations/
```

Feature-specific assets may use feature namespaces if needed.

---

# 123. Asset Paths

Do not scatter raw asset paths everywhere.

Use generated assets or centralized references if the project already supports them.

---

# 124. Feature Folder Example

A mature feature may look like:

```text
features/
└── appointment/
    ├── domain/
    │   ├── entities/
    │   │   └── appointment.dart
    │   ├── enums/
    │   │   └── appointment_status.dart
    │   ├── repositories/
    │   │   └── appointment_repository.dart
    │   └── failures/
    │       └── appointment_failure.dart
    │
    ├── application/
    │   ├── use_cases/
    │   │   ├── create_appointment.dart
    │   │   ├── cancel_appointment.dart
    │   │   └── reschedule_appointment.dart
    │   └── results/
    │
    ├── data/
    │   ├── datasources/
    │   │   └── appointment_remote_data_source.dart
    │   ├── dto/
    │   │   ├── appointment_response_dto.dart
    │   │   └── create_appointment_request_dto.dart
    │   ├── mappers/
    │   │   └── appointment_mapper.dart
    │   └── repositories/
    │       └── appointment_repository_impl.dart
    │
    └── presentation/
        ├── pages/
        │   ├── appointment_list_page.dart
        │   └── appointment_detail_page.dart
        │
        ├── sections/
        │   ├── upcoming_appointment_section.dart
        │   └── appointment_history_section.dart
        │
        ├── widgets/
        │   ├── appointment_card.dart
        │   ├── appointment_status_badge.dart
        │   └── appointment_action_bar.dart
        │
        ├── state/
        │   ├── appointment_state.dart
        │   └── appointment_controller.dart
        │
        └── mappers/
            └── appointment_view_mapper.dart
```

This is a reference model.

Do not mechanically create empty directories.

---

# 125. Small Feature Structure

A small feature does not need ceremony.

Example:

```text
features/
└── settings/
    ├── domain/
    ├── data/
    └── presentation/
```

If application use cases provide no value yet, do not add empty layers.

Architecture must scale with complexity.

---

# 126. Complexity Trigger

Introduce additional abstraction when complexity emerges.

Examples:

```text
simple
Repository → Page

medium
Repository → Controller → Page

complex
Repository → Use Case → Controller → Page
```

Do not force maximum architecture onto trivial features.

---

# 127. 500-Line Enforcement

No new Dart file should casually exceed 500 lines.

When approaching 350–400 lines, perform a decomposition review.

Before crossing 500 lines, explicitly answer:

```text
Why is this file still cohesive?

Which responsibilities does it own?

Why would extraction make architecture worse?

Can the file be split by semantic ownership?

Is this generated code?
```

Generated files are exempt.

---

# 128. Generated Code Exception

Files generated by:

```text
Freezed
json_serializable
Drift
Retrofit
build_runner
code generators
```

may exceed file-size limits.

Do not manually refactor generated code.

---

# 129. Screen Decomposition Trigger

A screen should be reviewed if it simultaneously owns:

```text
routing
HTTP fetching
state
forms
validation
multiple sections
dialog behavior
domain calculation
response mapping
animations
```

This is almost certainly a God Screen.

---

# 130. Controller Decomposition Trigger

Review a controller/notifier when it contains:

```text
many unrelated operations
10+ mutable state fields
many external dependencies
HTTP parsing
navigation
database knowledge
UI formatting
business policies
```

---

# 131. Repository Decomposition Trigger

Review a repository when it contains:

```text
presentation mapping
UI decisions
navigation
widget state
unrelated domains
```

---

# 132. Design-System Decomposition Trigger

Review a shared component when it contains multiple unrelated visual variants controlled by dozens of flags.

Bad:

```text
UniversalCard(
  isAppointment,
  isDoctor,
  isSchedule,
  isPatient,
  isAdmin,
  ...
)
```

Prefer separate semantic components sharing lower-level primitives.

---

# 133. Composition Over Configuration Explosion

Prefer:

```text
Base surface primitive
    ↓
AppointmentCard
ScheduleCard
DoctorCard
```

over:

```text
OneUniversalCardWith37Booleans
```

---

# 134. No Mega Component

A reusable component should not attempt to represent the entire application.

Generalization has limits.

---

# 135. Error Boundaries

Feature failures should map into explicit presentation states.

Do not let widgets depend on random string messages from infrastructure.

---

# 136. Retry Behavior

Retry belongs to the appropriate layer.

Network retry policy:

```text
network infrastructure
```

User-triggered retry button:

```text
presentation
```

Business retry semantics:

```text
application/domain
```

Do not mix them.

---

# 137. Caching

Cache strategy belongs to data/infrastructure.

Presentation should not decide:

```text
cache TTL
cache key
remote/local precedence
```

---

# 138. Pagination

Pagination mechanics may span application/data state.

Widgets should express:

```text
load next page
refresh
```

not manually manage raw page parameters everywhere.

---

# 139. Optimistic Updates

If used, optimistic state must have:

```text
clear rollback
error behavior
authoritative backend reconciliation
```

Do not silently let frontend truth diverge from backend.

---

# 140. Realtime / WebSocket

Realtime transport belongs to infrastructure/data.

Feature state consumes typed events.

Widgets should not parse raw websocket JSON.

---

# 141. Background Tasks

Background operations should use application capabilities, not presentation widgets.

Keep platform scheduling adapter separate.

---

# 142. Notifications

Push notification infrastructure should translate raw platform payloads into application-level events.

Do not spread Firebase-specific payload parsing across screens.

---

# 143. Analytics

Analytics is a cross-cutting concern.

Use an abstraction if required.

Do not couple every feature directly to vendor-specific analytics APIs.

---

# 144. Logging

Use one centralized logging contract.

Potential architecture:

```text
AppLogger
    ↑
Talker/Pino/other adapter
```

depending on current stack.

Features should not instantiate logging engines.

---

# 145. Security

Never log:

```text
tokens
passwords
OTP
authorization headers
personal confidential payloads
raw biometric information
```

Observability must use central redaction.

---

# 146. Testing Strategy

Match tests to architectural boundaries.

```text
Domain
→ unit tests

Use Cases
→ unit tests with mocked ports

Repository
→ repository/integration tests

Data Source
→ transport tests

Presentation Controller
→ state tests

Widgets
→ widget tests

Critical flows
→ integration tests
```

Do not test implementation details unnecessarily.

---

# 147. Pure Domain Tests

Domain policies should ideally be testable without:

```text
FlutterBinding
Dio
database
router
device
```

---

# 148. Widget Tests

Widgets should receive typed state/dependencies.

Do not require real network access merely to render a card.

---

# 149. Golden Tests

Use golden tests where visual regression value justifies them.

Do not golden-test every trivial widget merely for coverage numbers.

---

# 150. Contract Tests

Where API stability is important, verify DTO serialization against backend contract examples.

Do not rely only on widget tests.

---

# 151. Refactoring Rule

Refactoring should preserve behavior unless behavior change is explicitly requested.

Do not silently combine:

```text
architecture refactor
+
API contract change
+
UI redesign
```

unless the task explicitly requires all three.

---

# 152. Read-Only First

Before refactoring:

```text
inspect feature
inspect imports
inspect state management
inspect networking
inspect design system
inspect existing widgets
inspect tests
inspect generated code
```

Do not invent parallel architecture.

---

# 153. Reuse Existing Abstractions

Before creating:

```text
AppButton
AppLogger
ApiClient
BaseState
Result
Failure
```

search the codebase first.

Duplicate foundational abstractions are forbidden.

---

# 154. No Architecture by Copy-Paste

Do not copy an old feature's architecture blindly.

Existing features may contain technical debt.

Reuse concepts only after verifying they are sound.

---

# 155. Presentation Read-Only Inspection

Before editing a screen, identify:

```text
page responsibility
sections
reusable widgets
local state
feature state
domain values
view formatting
navigation
side effects
```

Then determine the correct extraction boundaries.

---

# 156. Presentation Decomposition Pattern

Example:

```text
BAD

SchedulePage
  1100 lines

GOOD

SchedulePage
   ↓
ScheduleHeaderSection
ScheduleCalendarSection
ScheduleListSection
ScheduleBottomActions
```

Then:

```text
ScheduleListSection
   ↓
ScheduleCard
```

Then:

```text
ScheduleCard
   ↓
AppSurface
StatusBadge
AppButton
```

Each layer has semantic ownership.

---

# 157. Keep One Readable Composition Root Per Screen

Do not decompose until nobody can understand the page hierarchy.

The screen file should remain a readable map of the UI.

Good:

```dart
return Scaffold(
  appBar: const ScheduleAppBar(),
  body: ScheduleBody(...),
  bottomNavigationBar: ScheduleActions(...),
);
```

The page remains understandable.

---

# 158. Avoid Helper Chain Hell

Bad:

```text
Page
→ helper
→ helper
→ helper
→ helper
→ helper
```

with no semantic names.

Every extracted component must improve comprehension.

---

# 159. Avoid Indirection Without Value

If a class only forwards calls:

```dart
class AppointmentManager {
  Future<void> create() {
    return service.create();
  }
}
```

and adds no boundary or semantics, remove it.

---

# 160. Do Not Worship Clean Architecture

Architecture exists to manage complexity.

Do not create:

```text
Entity
DTO
Model
ViewModel
StateModel
UiModel
PresenterModel
```

for a two-field static feature.

Use abstraction proportionally.

---

# 161. Clean Architecture Boundary Test

A layer is justified when it protects the application from a meaningful source of change.

Examples:

```text
HTTP schema changes
database changes
state-management changes
UI changes
vendor SDK changes
business-rule changes
```

If it protects nothing, reconsider it.

---

# 162. Feature Public API

If another feature needs functionality, expose a deliberate contract.

Do not import deeply:

```text
../../schedule/data/repositories/impl/...
```

---

# 163. Imports

Prefer stable project aliases/package imports if configured.

Avoid extremely deep relative imports such as:

```dart
../../../../../../core/...
```

Do not introduce a new import strategy without checking existing configuration.

---

# 164. Dependency Cycle Prevention

Before adding cross-feature imports, inspect whether it creates:

```text
A → B → A
```

If yes, stop.

Resolve ownership first.

---

# 165. Shared Domain

If two features genuinely share one business concept, place that concept at an appropriate shared domain boundary.

Do not duplicate it.

Do not move unrelated feature logic into shared.

---

# 166. Mapping Ownership

Use:

```text
API DTO → Domain Mapper
```

inside data.

Use:

```text
Domain → View Mapper
```

inside presentation.

Do not create one universal mapper knowing every layer.

---

# 167. Serialization Ownership

JSON serialization belongs to data/infrastructure.

The domain must not care about JSON field names.

---

# 168. No HTTP Key Strings in Widgets

Forbidden:

```dart
data['doctor_name']
```

inside presentation.

Typed models must exist before data reaches widgets.

---

# 169. API Paths

Endpoint strings must not be scattered.

Use existing endpoint/config conventions.

---

# 170. HTTP Method Ownership

Remote data sources own transport calls.

Repositories expose semantic operations.

Example:

```text
Repository:
getDoctorSchedule()

Data Source:
GET /api/v1/...
```

---

# 171. Repository Names Must Be Semantic

Prefer:

```text
ScheduleRepository
AppointmentRepository
```

not:

```text
ApiService
NetworkService
DataService
```

when representing domain capabilities.

---

# 172. Service Names Must Be Specific

Avoid:

```text
CommonService
HelperService
ManagerService
UtilsService
```

unless the name genuinely represents a bounded capability.

---

# 173. Failure Types

Failures should carry semantic meaning where useful.

Examples:

```text
NetworkFailure
UnauthorizedFailure
ScheduleUnavailableFailure
ValidationFailure
```

Do not expose raw stack traces to UI.

---

# 174. Do Not Over-Type Errors

Do not create a unique class for every possible error if simple typed categories are sufficient.

Balance explicitness and complexity.

---

# 175. UI Error Copy

User-facing error copy belongs to presentation/localization.

Domain failure should describe semantics, not necessarily final human wording.

---

# 176. Loading Copy

Same rule:

```text
application knows operation state
presentation knows how to communicate it
```

---

# 177. Formatting Dates

Do not store display-formatted dates as source of truth.

Keep structured date/time representation.

Format at presentation boundary.

---

# 178. Time Zones

Time-zone conversion policy must be explicit.

Do not arbitrarily format backend timestamps differently across screens.

---

# 179. Image URLs

One source of truth must exist.

Do not introduce:

```text
profile.avatar
user.image
fallbackAvatar
cachedAvatarUrl
```

without explicit ownership.

---

# 180. Fallback Policy

Fallbacks must be intentional.

If backend data is absent:

```text
empty state
explicit placeholder
documented fallback
```

should be deliberate.

Do not fabricate real-looking data.

---

# 181. No Dummy Data in Production Paths

Mock/demo/showcase data must not silently execute in normal production feature flow.

Development fixtures must be explicitly isolated.

---

# 182. Fixture Ownership

Use:

```text
test fixtures
storybook/widgetbook fixtures
development mocks
```

separately from runtime repositories.

---

# 183. Design Preview

If using Widgetbook or equivalent, preview fixtures must not leak into runtime feature logic.

---

# 184. Accessibility

Reusable UI should expose:

```text
semantic labels
sufficient tap targets
text scaling support
focus behavior
```

where appropriate.

Accessibility is part of presentation quality.

---

# 185. Responsive Text

Do not disable text scaling globally just to preserve pixel layout.

Fix the layout.

---

# 186. Scroll Ownership

Avoid nested scroll views without understanding constraints.

Separate sections appropriately.

---

# 187. List Performance

Use lazy list construction for large collections.

Avoid constructing hundreds of expensive widgets eagerly.

---

# 188. Keys

Use keys when widget identity matters.

Do not add random keys everywhere.

---

# 189. Const

Use `const` where semantically possible.

Do not distort architecture merely to maximize const usage.

---

# 190. Async Cancellation

For search, autocomplete, repeated network operations, or stale screen requests, consider cancellation/debouncing where appropriate.

Avoid race conditions.

---

# 191. Stale Response Protection

When multiple requests can overlap, ensure an older response cannot incorrectly replace newer state.

This belongs in state/application logic, not arbitrary widget checks.

---

# 192. Debounce Ownership

Search-field debounce generally belongs near presentation/application state.

Network infrastructure should not universally debounce requests.

---

# 193. Authentication

Authentication concerns should have explicit ownership.

Example:

```text
auth feature
+
network auth interceptor
+
secure token storage
```

Do not duplicate token handling across repositories.

---

# 194. Token Refresh

Token refresh belongs in centralized auth/network infrastructure.

Feature repositories must not individually implement refresh logic.

---

# 195. Authorization

Frontend authorization controls UI availability.

Backend remains authoritative.

Do not treat hidden buttons as security.

---

# 196. Route Guards

Route access logic belongs to application/router boundary.

Do not duplicate authentication redirects throughout screens.

---

# 197. Deep Links

Deep-link parsing belongs at navigation boundary.

Features receive typed route arguments where possible.

---

# 198. Route Arguments

Avoid passing arbitrary `Map<String, dynamic>` through navigation.

Use typed route contracts where project routing supports it.

---

# 199. Forms and DTOs

Form input model and API request DTO may differ.

Do not couple widget text controllers directly to API serialization everywhere.

---

# 200. TextEditingController

Do not let application/domain layers know `TextEditingController`.

Convert UI values before leaving presentation.

---

# 201. FocusNode

Same rule.

Focus belongs to presentation.

---

# 202. AnimationController

Animation belongs to presentation.

Never let application/domain coordinate frame-level animation.

---

# 203. UI Animation State

Keep animation state near the widget that owns it.

Do not place hover/spinner progress in global feature state unless genuinely shared.

---

# 204. Long-Running Computation

CPU-heavy work should not block the UI thread.

Evaluate isolate/compute or backend ownership when appropriate.

Do not prematurely move trivial work to isolates.

---

# 205. Image Processing

Keep expensive image processing outside widget build methods.

Use appropriate infrastructure/platform abstraction.

---

# 206. File Upload

Suggested flow:

```text
Presentation
    ↓
Select File
    ↓
Application
    ↓
Repository
    ↓
Remote Data Source
    ↓
HTTP Client
```

Do not let widgets manually build multipart transport when data infrastructure already owns networking.

---

# 207. Permission Handling

Device permissions should have centralized platform handling when complex.

UI should request a semantic capability.

---

# 208. Permission UI

Presentation decides how permission denial is communicated.

Platform adapter decides how permission state is read/requested.

---

# 209. Connectivity

Do not treat connectivity status alone as proof that API requests will succeed.

Actual network errors remain authoritative.

---

# 210. Offline Mode

If offline behavior exists, its synchronization strategy must be explicit.

Do not introduce hidden local fallback data that mimics server truth.

---

# 211. Mutation Queue

Offline mutations require deliberate queue/reconciliation architecture.

Do not implement them as random local persistence hacks.

---

# 212. Design System API Stability

Changing a global design-system primitive can affect many features.

Before modifying it:

```text
search consumers
evaluate visual impact
avoid breaking semantic contract
```

---

# 213. Component Variants

Variants should represent meaningful visual semantics.

Example:

```text
primary
secondary
ghost
destructive
```

not arbitrary feature-specific combinations.

---

# 214. Status Component

A global status component may expose:

```text
success
warning
error
neutral
info
```

Feature maps business state into these variants.

---

# 215. Button Responsibility

Global button handles:

```text
visual style
interaction state
disabled state
loading visual
accessibility
```

Feature decides:

```text
what action happens
```

---

# 216. Input Responsibility

Global input handles visual/input shell.

Form/business validation remains at appropriate layers.

---

# 217. No Business Rules in Design System

Forbidden:

```dart
if (appointment.status == ...)
```

inside `AppButton`.

Design system must remain domain-independent.

---

# 218. Presentation Dependency Rule

Presentation may depend on:

```text
application
domain
design system
core presentation-safe utilities
```

It should not depend directly on:

```text
concrete database adapters
raw HTTP client
environment parsing
storage implementation
```

---

# 219. Application Dependency Rule

Application may depend on:

```text
domain
ports/interfaces
```

It should not depend on:

```text
widgets
router UI
Dio response classes
SQLite row objects
```

---

# 220. Domain Dependency Rule

Domain should be the most stable layer.

Keep dependencies minimal.

---

# 221. Data Dependency Rule

Data may depend on:

```text
domain contracts
network infrastructure
storage infrastructure
serialization
```

It may know external representations.

---

# 222. Core Rule

`core/` is not a dumping ground.

Only put code there if it is:

```text
cross-feature
domain-neutral
stable
infrastructure-oriented
```

---

# 223. Core Anti-Pattern

Do not place:

```text
AppointmentHelper
DoctorScheduleUtils
PatientFormatter
```

inside global core merely because they are reusable inside one feature.

---

# 224. App Layer

`app/` owns application shell concerns:

```text
bootstrap
DI
routing
theme composition
global configuration
```

It should not contain feature business logic.

---

# 225. Bootstrap

`main.dart` should remain extremely small.

Conceptually:

```dart
void main() async {
  await bootstrap();
}
```

Complex initialization belongs in bootstrap/application composition.

---

# 226. Bootstrap Responsibility

Bootstrap may configure:

```text
Flutter binding
environment
dependency injection
logging
HTTP client
storage
crash reporting
runApp
```

Keep initialization ordered and observable.

---

# 227. Initialization Errors

Startup failures must be explicit and observable.

Do not silently ignore failed initialization.

---

# 228. Generated Routing

If using generated routing, respect generated boundaries.

Do not manually edit generated route files.

---

# 229. Dependency Registration

Keep dependency registration organized by ownership.

Avoid one 2,000-line service locator file.

Potential grouping:

```text
core dependencies
feature dependencies
platform dependencies
```

depending on current DI library.

---

# 230. Lazy Registration

Use lazy construction where appropriate.

Do not optimize DI prematurely.

---

# 231. Singleton Scope

Use singletons only where lifecycle semantics justify them.

Do not make every service singleton by default.

---

# 232. Repository Lifecycle

Repositories are often long-lived/stateless, but respect architecture and data ownership.

---

# 233. Controller Lifecycle

Feature controllers should follow feature/page lifecycle unless state intentionally persists.

Avoid accidental immortal state.

---

# 234. Cache Lifecycle

Cache ownership must be explicit.

Do not let presentation accidentally become cache.

---

# 235. Naming Convention

Prefer semantic names.

Good:

```text
schedule_page.dart
schedule_card.dart
schedule_controller.dart
schedule_repository.dart
schedule_repository_impl.dart
schedule_remote_data_source.dart
schedule_response_dto.dart
schedule_mapper.dart
```

Avoid:

```text
schedule_helper2.dart
schedule_new.dart
schedule_final.dart
common_schedule.dart
temp_service.dart
```

---

# 236. Suffix Convention

Use suffixes that communicate architectural responsibility:

```text
_page
_section
_card
_dialog
_sheet
_controller
_notifier
_state
_repository
_repository_impl
_data_source
_dto
_mapper
_policy
_validator
_formatter
_adapter
```

Do not suffix everything with `service`.

---

# 237. Import Boundary Review

Every new import should be questioned.

Ask:

```text
Why does this layer know this dependency?
```

If the answer is unclear, boundary may be wrong.

---

# 238. File Review Rule

For every modified file approaching 500 lines:

```text
identify responsibilities
identify extraction candidates
check local helpers
check state ownership
check side effects
check duplicated code
```

---

# 239. No Cosmetic Splitting

This is forbidden:

```text
screen.dart
screen_part_1.dart
screen_part_2.dart
screen_part_3.dart
```

with arbitrary line-based splitting.

Split by semantic component.

---

# 240. No `part` Abuse

Do not use Dart `part` files merely to hide a giant class across multiple files.

`part` does not create architectural decoupling.

Use real classes/modules unless generated code requires `part`.

---

# 241. God Widget Detection

A widget is probably a God Widget if it knows:

```text
HTTP
storage
navigation
domain calculation
formatting
form validation
multiple feature states
logging
animation
business permissions
```

Split responsibilities.

---

# 242. God Controller Detection

A controller is probably too large if it owns:

```text
multiple unrelated use cases
large mapping logic
transport
navigation
UI rendering concerns
cache
storage
logging infrastructure
```

---

# 243. God Repository Detection

A repository is probably too large if it handles:

```text
many unrelated domains
presentation state
widget concerns
routing
arbitrary utility functions
```

---

# 244. God Design-System Component Detection

A shared component is probably too generic if its public constructor requires dozens of unrelated configuration flags.

---

# 245. Complexity Review Threshold

If a class has approximately:

```text
>8 meaningful dependencies
>15 public methods
>400 lines
many independent reasons to change
```

perform decomposition review.

These are heuristics, not universal laws.

---

# 246. Reuse vs Duplication

Do not abstract merely because two widgets visually resemble each other.

Ask:

```text
Do they share the same semantic responsibility?
```

If not, keep them separate.

---

# 247. Premature Abstraction

Avoid:

```text
UniversalScreen
UniversalController
GenericCrudRepository<T>
BaseEverythingWidget
```

unless real repeated behavior justifies them.

---

# 248. Generic CRUD Warning

Business features often have different invariants.

Do not erase domain meaning behind generic CRUD merely to reduce files.

---

# 249. Base Widget Warning

Do not create giant inheritance trees:

```text
BaseScreen
→ AuthenticatedScreen
→ FormScreen
→ AppointmentScreen
```

Prefer composition.

---

# 250. Composition Over Inheritance

Flutter is naturally compositional.

Use it.

Prefer:

```text
Page
+ Layout
+ Section
+ Component
```

instead of large inheritance trees.

---

# 251. Mixins

Use mixins sparingly.

Do not use mixins to inject unrelated hidden dependencies.

---

# 252. Extension Methods

Keep extensions small and predictable.

Do not make extensions another hidden service locator.

---

# 253. Static Globals

Avoid mutable global singleton variables.

Use DI/state ownership.

---

# 254. Context Extensions

Context extensions may expose design-system conveniences.

Example:

```text
context.colors
context.textStyles
```

if consistent with project design.

Do not let them perform business operations.

---

# 255. Navigation Extensions

Be cautious.

Extensions should not hide significant application behavior.

---

# 256. BuildContext

`BuildContext` must remain presentation-related.

Do not pass it into domain/data layers.

---

# 257. Responsive Context

Layout decisions may use `BuildContext`.

Business policies may not.

---

# 258. Localization Context

Presentation may use context localization.

Domain logic should use semantic values.

---

# 259. Backend Contract Versioning

Client data layer must respect backend contract versioning.

Do not silently support multiple old shapes forever unless compatibility is intentional.

---

# 260. Changelog Awareness

When backend changelog announces a client-visible API change:

```text
inspect contract
update DTO
update mapper
update domain representation if needed
update presentation mapping if needed
```

Do not blindly rewrite UI.

---

# 261. Backend Changelog Boundary

Backend changelog says what changed.

Flutter decides how to implement it.

Do not expect backend documentation to prescribe Flutter architecture.

---

# 262. API Contract Change Isolation

A response field rename should ideally impact:

```text
DTO
mapper
possibly domain
```

and not require editing 20 widgets.

If it does, abstraction boundaries are leaking.

---

# 263. Design Change Isolation

Changing global radius should ideally affect design-system tokens/components.

It should not require manually editing 80 feature widgets.

---

# 264. State Management Change Isolation

If state library changes, domain/data layers should remain mostly unaffected.

This is a practical measure of decoupling.

---

# 265. HTTP Client Change Isolation

Replacing Dio should primarily affect networking/data infrastructure.

Domain/presentation should not require broad rewrite.

---

# 266. Storage Change Isolation

Replacing SharedPreferences/Hive/SQLite should not rewrite feature presentation.

---

# 267. Router Change Isolation

Changing router implementation should not modify repositories.

---

# 268. Design System Change Isolation

Design-system implementation changes should not modify business logic.

---

# 269. Feature Removal

A well-isolated feature should be removable without breaking unrelated features except explicit dependencies.

---

# 270. Feature Addition

A new feature should mostly add files under its own feature namespace plus explicit DI/navigation registration.

If it requires modifying dozens of unrelated features, inspect architecture.

---

# 271. Refactoring Workflow

Before refactoring a complex feature:

```text
1. map current data flow
2. map dependencies
3. identify side effects
4. identify domain rules
5. identify UI composition
6. identify duplicated state
7. identify infrastructure leakage
8. extract pure logic
9. extract semantic widgets
10. establish explicit boundaries
11. verify behavior
12. remove obsolete paths
```

---

# 272. Do Not Rewrite Everything

Prefer incremental decomposition.

A risky full rewrite is not automatically superior to controlled refactoring.

---

# 273. Preserve Behavior

Architecture refactoring must not unintentionally alter:

```text
API behavior
screen behavior
state transitions
navigation
validation
backend semantics
```

unless explicitly requested.

---

# 274. Remove Dead Code

After migration, remove obsolete:

```text
fallback
old service
legacy helper
duplicate mapper
temporary adapter
```

unless compatibility requires it.

---

# 275. One Canonical Path

Do not leave:

```text
old repository
new repository
fallback repository
```

all active indefinitely.

Choose one canonical path after migration.

---

# 276. Documentation

Complex architectural decisions should be documented near the relevant module.

Do not write comments explaining obvious syntax.

Explain WHY.

---

# 277. Architecture Decision

When introducing a substantial abstraction, record:

```text
problem
chosen boundary
reason
alternatives considered
tradeoff
```

briefly where project conventions support ADRs.

---

# 278. Agent Mandatory Read-Only Phase

Before creating files, the agent MUST inspect:

```text
existing folder structure
state management
HTTP client
DI mechanism
router
design system
shared widgets
logging
error handling
storage
existing feature patterns
```

No assumptions.

---

# 279. Agent Must Search Before Creating

Before creating:

```text
AppButton
AppText
AppCard
AppLogger
ApiClient
Result
Failure
BaseState
LoadingWidget
ErrorWidget
EmptyState
```

search the repository.

Reuse existing abstractions when semantically correct.

---

# 280. Agent Must Not Create Parallel Architecture

Forbidden:

```text
existing:
core/network/

agent creates:
shared/http/

existing:
design_system/components/

agent creates:
common/widgets/
```

without explicit architectural reason.

---

# 281. Agent Presentation Checklist

For every feature UI change verify:

```text
[ ] Page remains composition-focused.
[ ] No HTTP logic in widgets.
[ ] No raw JSON in presentation.
[ ] Business rules are not duplicated.
[ ] Backend canonical state is respected.
[ ] Feature widgets remain local unless truly shared.
[ ] Global components reuse design system.
[ ] No random raw colors.
[ ] No random typography.
[ ] No arbitrary spacing proliferation.
[ ] No new God Widget.
```

---

# 282. Agent Application Checklist

```text
[ ] Use case has one coherent responsibility.
[ ] No widget dependency.
[ ] No BuildContext.
[ ] No raw Dio dependency.
[ ] Repository contracts are respected.
[ ] State transitions are explicit.
[ ] Async failures remain observable.
```

---

# 283. Agent Domain Checklist

```text
[ ] Domain is framework-independent where practical.
[ ] Business semantics have one source of truth.
[ ] No presentation concepts leaked in.
[ ] No API DTO dependency without justification.
[ ] No duplicate domain constants.
```

---

# 284. Agent Data Checklist

```text
[ ] HTTP calls stay in remote data source/network boundary.
[ ] JSON parsing stays in data boundary.
[ ] DTO mapping is explicit.
[ ] Raw infrastructure exceptions are translated.
[ ] Repository implementation respects domain contract.
[ ] No UI concerns exist here.
```

---

# 285. Agent Design-System Checklist

```text
[ ] Shared component is genuinely cross-feature.
[ ] Component is domain-agnostic.
[ ] Visual tokens are centralized.
[ ] Constructor is semantically narrow.
[ ] No feature-specific business enum is imported.
[ ] Existing primitive/component was checked first.
```

---

# 286. Agent File Complexity Checklist

For every modified Dart file:

```text
[ ] <500 lines or explicitly justified.
[ ] One coherent responsibility.
[ ] No arbitrary helper dumping.
[ ] No unrelated side effects.
[ ] No large nested branching.
[ ] No duplicated business logic.
```

---

# 287. Agent Dependency Checklist

```text
[ ] Dependency direction is intentional.
[ ] No presentation → concrete infrastructure shortcut.
[ ] No domain → Flutter framework dependency without reason.
[ ] No cross-feature internal import.
[ ] No circular dependency.
[ ] No random global singleton.
```

---

# 288. Agent Observability Checklist

```text
[ ] Network requests remain covered by global observability.
[ ] New execution path can be traced.
[ ] No permanent print/debugPrint introduced.
[ ] Errors preserve diagnostic context.
[ ] Sensitive values remain redacted.
```

---

# 289. Agent Completion Report

After substantial implementation/refactor, report:

```text
FLUTTER ARCHITECTURE CHECK

Feature:
...

Presentation changes:
...

Application changes:
...

Domain changes:
...

Data changes:
...

Design-system changes:
...

New abstractions:
...

Reused abstractions:
...

Largest modified Dart file:
... lines

Files over 500 lines:
NONE / explain

God Widget introduced:
NO

God Service/Controller introduced:
NO

Cross-feature coupling introduced:
NO / explain

Raw HTTP inside presentation:
NO

Raw JSON inside presentation:
NO

Backend state re-derived on client:
NO

Design tokens bypassed:
NO

Observability preserved:
YES

Tests executed:
...
```

Do not merely state:

```text
Implementation completed.
```

---

# 290. Definition of Done

A Flutter feature is not complete merely because:

```text
it renders
it compiles
the endpoint responds
```

It must also satisfy:

```text
[ ] Clear domain ownership.
[ ] Clear application orchestration.
[ ] Data/infrastructure isolated.
[ ] Presentation remains presentation.
[ ] State ownership is explicit.
[ ] UI composition is readable.
[ ] No God Widget.
[ ] No God Controller.
[ ] No God Repository.
[ ] No accidental cross-feature dependency.
[ ] No raw API semantics scattered in UI.
[ ] Existing design system is respected.
[ ] Shared components remain domain-agnostic.
[ ] No arbitrary visual hardcoding.
[ ] Backend remains source of truth.
[ ] Networking remains centrally observable.
[ ] No file casually exceeds 500 lines.
[ ] Tests match the architectural boundary.
```

---

# 291. Golden Architecture Rule

The intended flow is:

```text
USER INTERACTION
        ↓
PRESENTATION
Widget / Page / Section
        ↓
Presentation State Controller
        ↓
APPLICATION
Use Case / Coordinator
        ↓
DOMAIN
Entity / Policy / Contract
        ↓
DATA
Repository Implementation
        ↓
INFRASTRUCTURE
HTTP / Storage / Platform
        ↓
BACKEND
```

Then:

```text
BACKEND RESPONSE
        ↓
DTO
        ↓
Mapper
        ↓
Domain/Application Result
        ↓
Presentation State
        ↓
View Mapping
        ↓
Design System Components
        ↓
SCREEN
```

Never collapse this into:

```text
Widget
  ↓
Dio
  ↓
JSON
  ↓
if/else
  ↓
Widget
```

for a non-trivial production feature.

---

# 292. Final Reinforcement

Do not solve a 1,000-line Flutter screen by creating:

```text
screen_helpers.dart
```

with another 800 lines.

Do not solve business complexity by hiding it inside a provider.

Do not solve design inconsistency by adding more hardcoded colors.

Do not solve backend contract changes by reconstructing backend semantics on the client.

Do not solve coupling by creating meaningless interfaces.

Do not solve architecture with dozens of forwarding classes.

Instead:

```text
identify ownership
        ↓
identify the domain
        ↓
separate application orchestration
        ↓
isolate data/infrastructure
        ↓
make presentation state explicit
        ↓
compose semantic UI pieces
        ↓
reuse design-system primitives
        ↓
keep feature-specific widgets local
        ↓
preserve one-way dependency flow
        ↓
preserve observability
```

The architecture should make this statement true:

> A developer should be able to modify how a screen looks without understanding HTTP internals, modify HTTP transport without rewriting widgets, modify business rules without editing visual components, and replace infrastructure without rewriting the domain.

The final goal is not the maximum number of layers.

The final goal is:

> The smallest number of clear, cohesive, independently understandable abstractions required to keep change local.
```

Untuk project Anda, saya paling menyarankan **jangan pakai `core/widgets/` sebagai tempat semua UI**. Pisahkan tegas:

```text
design_system/
    foundations/
    primitives/
    components/
    patterns/

features/
    schedule/
        presentation/
            pages/
            sections/
            widgets/
```

Jadi misalnya:

```text
AppButton
StatusBadge
AppTextField
```

masuk design system.

Tetapi:

```text
DoctorScheduleCard
AppointmentCard
DoctorProfileHeader
```

tetap tinggal di feature masing-masing.

Dan mental model dependency-nya cukup diingat sebagai:

```text
                    APP
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
 DESIGN SYSTEM                  FEATURES
                                  │
                    ┌─────────────┼─────────────┐
                    ▼             ▼             ▼
             PRESENTATION   APPLICATION      DOMAIN
                    │             │             ▲
                    │             └─────────────┘
                    │
                    ▼
                 DATA
                    │
                    ▼
          CORE INFRASTRUCTURE
       HTTP / STORAGE / PLATFORM
```

Yang paling keras untuk agent adalah: **Presentation tidak boleh tahu transport, Domain tidak boleh tahu Flutter, Data tidak boleh tahu UI, dan Design System tidak boleh tahu business domain.** Itu empat boundary yang kalau benar-benar Anda enforce, Flutter codebase jauh lebih sulit berubah menjadi spaghetti.