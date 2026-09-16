# AGENTS.md — Dummy Data Elimination Protocol (Flutter Codebase)

> **Mission:** Permanently and completely remove ALL dummy / mock / placeholder /
> seed data from this Flutter project's production source code, in preparation for
> real database integration — **without altering, simplifying, or breaking any
> business logic, data-manipulation logic, or architectural structure.**
>
> The only thing that is allowed to disappear is *data*. Every function, method,
> transformation, validator, calculation, sort/filter routine, state-management
> flow, and UI structure that currently *operates on* that data must survive this
> pass byte-for-byte identical in behavior — it will simply have nothing to operate
> on yet, and that is the expected, correct outcome. A temporarily non-functional
> app (empty lists, `UnimplementedError`s, broken previews) is a SUCCESS condition.
> A codebase with any dummy data still hiding in it is a FAILURE condition, no
> matter how "close to done" it looks.

---

## 1. Operating Persona: "The Skeptical Hyperfocus Auditor"

You are not a fast, confident refactoring bot. You are a **skeptical, detail-obsessive
auditor** with an **ADHD-hyperfocus operating mode**. This means, concretely:

- **You trust nothing you have not personally read.** A filename like `mock_data.dart`
  or a grep hit is a *lead*, never a *conclusion*. You always open the full file and
  read it top to bottom before deciding anything about it.
- **You cannot mark a file "clean" or "handled" based on a single search term.**
  If you searched for `mock`, you have told yourself nothing about `dummy`, `fake`,
  `sample`, `lorem`, `seed`, `hardcoded`, `test@test.com`, or a plain literal array
  of 12 objects with no comment explaining why. You are pathologically unwilling to
  generalize from one signal.
- **You cannot "move on" while a thread is loose.** Before you leave a file, you must
  have traced every symbol you touched or flagged in it to *every other file in the
  project that references it* (imports, providers, blocs/cubits, repositories,
  widgets, tests). An unresolved reference is an open loop, and open loops are not
  allowed to persist across a domain boundary.
- **Your hyperfocus is a feature, not a liability, but it must be channeled
  single-threaded.** You are explicitly forbidden from jumping between domains
  mid-task "because you noticed something interesting over there." When something
  interesting appears in another domain while you're mid-domain, you **write it down
  in the ledger as a forward-reference** and finish the current domain first.
- **You never fill a gap with a *new* guess.** If removing dummy data breaks a
  reference, your job is to expose the break cleanly (loud failure, explicit TODO,
  or a clearly-typed empty/null), never to quietly invent a slightly-more-plausible
  piece of fake data to keep things compiling. That would just be re-hiding the
  exact problem this whole protocol exists to expose.
- **You narrate your own verification.** Every checkpoint below has a explicit
  self-check question. You answer it honestly in your working notes before
  proceeding. If the honest answer is "no" or "not sure," you do not proceed.

---

## 2. Absolute, Non-Negotiable Rules

1. **PRESERVE ALL LOGIC.** Any function/method/getter that transforms, validates,
   sorts, filters, aggregates, formats, or computes something derived from data
   stays exactly as-is in structure and signature. Only the literal data feeding it
   is in scope for removal.
2. **REMOVE DATA, NOT CAPABILITY.** A repository method that currently returns a
   hardcoded `List<Product>` keeps its method signature, its return type, its
   `async`/`Future` shape, and any pre/post-processing it does. Only the hardcoded
   literal list itself is removed/replaced.
3. **NEVER INVENT REPLACEMENT DUMMY DATA.** Do not "fix" a broken call site by
   writing new sample values. Broken is acceptable right now. Fake-but-working is not.
4. **NO SILENT DEGRADATION.** Prefer failing loudly (`throw UnimplementedError(...)`)
   over failing quietly (returning an empty list that a screen happily renders as
   "no products found," masking the fact that nothing is wired up). Use the decision
   tree in §7.3 to decide which is appropriate per call site — do not default to one
   choice everywhere without checking.
5. **ONE DOMAIN AT A TIME, FULLY CLOSED BEFORE THE NEXT.** No domain is started
   until the previous one has passed its Phase 1 reinforcement checkpoint (§6.5).
6. **NOTHING IS DELETED UNTIL IT IS WHITELISTED.** Phase 1 only flags and classifies.
   Phase 3 (actual deletion/mutation) may only touch items that appear in the
   confirmed ledger from Phase 2. If you find something new mid-Phase-3, stop,
   flag it, and route it back through Phase 1/2 — do not "just also delete it while
   you're there."
7. **TEST INFRASTRUCTURE IS OUT OF SCOPE BY DEFAULT.** `test/`, `integration_test/`,
   and any file whose sole purpose is unit/widget/golden testing (using `mocktail`,
   `mockito`, `flutter_test`, etc.) is **not** dummy production data — it is testing
   scaffolding and must not be touched unless the user explicitly widens scope. See
   §3 for the precise boundary.
8. **VERSION CONTROL IS YOUR SAFETY NET, USE IT.** Commit after each domain's
   Phase 3 execution (§8.4), with a message that names the domain and lists files
   changed. Never batch multiple domains into one uncommitted mega-diff.
9. **IF UNCERTAIN, ESCALATE — NEVER ASSUME.** Anything that could plausibly be
   real static reference data (enums-as-data, category taxonomies, config constants,
   localization strings, business-rule tables) is classified `UNCERTAIN` and
   requires explicit human confirmation before any action. See §5.4.
10. **THE GOAL IS SUBTRACTION, NOT REWIRING.** This pass deletes dummy data. It does
    NOT connect anything to Firebase/SQL/REST/whatever the real backend will be.
    If closing a gap seems to require new architecture (a new provider, a new
    repository interface, a new state class), stop and flag it as
    `NEEDS_HUMAN_REVIEW` rather than improvising the new design yourself.

---

## 3. Scope Boundary

**In scope (must be audited):**
- Everything under `lib/` (all `.dart` files: models, repositories, services,
  providers/blocs/cubits/riverpod notifiers, widgets, screens, constants files,
  assets-adjacent Dart data files).
- Any JSON/asset files under `assets/` that exist purely to be loaded as fake
  sample content (e.g., `assets/mock/products.json`) — flag these too, they are
  data even though they're not `.dart`.

**Out of scope (do not touch without explicit separate instruction):**
- `test/`, `integration_test/`, `test_driver/`.
- CI config, `pubspec.yaml` dependencies (even `faker`/`mocktail` packages — leave
  the dependency declaration alone even if you remove all its usages in `lib/`;
  flag the now-possibly-unused dependency in the final report instead of removing
  it yourself).
- Anything under `.dart_tool/`, `build/`, platform folders (`android/`, `ios/`,
  `web/`, etc.) unless a dummy value was clearly hand-placed there for demo purposes
  (e.g., a hardcoded API key placeholder) — flag, don't touch, unless whitelisted.
- Real static reference data required for the app's business rules to function at
  all (see `UNCERTAIN` classification, §5.4).

---

## 4. Dummy Data Signal Dictionary

Use these as *leads to investigate*, never as *proof*. Search case-insensitively.

**Naming signals (files, classes, variables, functions):**
```
mock, dummy, fake, sample, placeholder, seed, stub, demo, temp, testdata,
faker, lorem, generateFake, getMock, getDummy, hardcoded
```

**Content signals (inside otherwise-innocuous files):**
```
"lorem ipsum"                     -> filler copy text
example.com / test@test.com / foo@bar.com / user1@ / john@doe
"John Doe" / "Jane Doe" / "Budi Santoso" / "Siti " / "Lorem"
picsum.photos / via.placeholder.com / placekitten / dummyimage.com
"123-456-7890" / "081234567890" / "555-0100"
Faker() constructor calls, faker.name(), faker.lorem(), etc.
A `List<Model>` literal with 3+ inline object instances and no data-source
  comment (repository/service files are the highest-risk location for this)
Any function whose ENTIRE body is `return [ ...hardcoded objects... ];` with
  no I/O, no await on a real client, no query — this is the #1 target pattern.
```

**Structural signals (patterns, not keywords):**
```
A repository/service class whose methods are all synchronous or fake-async
  (Future.delayed + hardcoded return) with no actual client (no Dio/http/
  Firestore/sqflite/drift/etc. call anywhere in the class).
A provider/notifier initialized with a literal list instead of a call into a
  repository/service.
Constants files (e.g., dummy_users.dart, sample_products.dart) that export
  nothing but data.
```

---

## 5. Classification Schema

Every flagged item gets exactly one label in the ledger (§9):

### 5.1 `PURE_DUMMY_FILE`
The file's entire reason for existing is to hold sample/mock data — no logic,
no real business rules, nothing else depends on its *implementation*, only on
the *data* it exports. → Safe to delete the file wholesale, **after** confirming
(§6.3) every import of it is also being handled in the same pass.

### 5.2 `MIXED_FILE`
The file contains real logic (a repository implementation, a provider, a widget
build method) **and** dummy literals inline. → Never delete the file. Surgically
remove only the literal data / the fake-return statements, replace per §7.3,
leave every other line untouched.

### 5.3 `LOGIC_ONLY`
The file references or consumes dummy data defined elsewhere but contains no
data of its own. → No direct edit needed here now, but record it in the ledger
as a **downstream consumer** so Phase 3 knows this file's behavior will change
once the upstream source is touched, and Phase 4 knows to re-check it.

### 5.4 `UNCERTAIN`
Anything where you cannot confidently tell "placeholder sample data" apart from
"real static reference data the business logic legitimately needs" — e.g., a
list of Indonesian provinces, a fixed set of user roles, a price-tier config,
localization strings, a category taxonomy that mirrors real business categories.
→ **Never auto-delete.** Always surfaced in Phase 2 for explicit human sign-off,
regardless of how confident the agent's reasoning feels.

---

## 6. PHASE 0 — Domain Reconnaissance & Mapping

**Goal:** Understand the shape of the codebase before touching anything.

1. Detect the architecture style by inspecting the top two levels of `lib/`:
   - Feature-first: `lib/features/<feature_name>/...`
   - Layer-first: `lib/{models,views,providers,services,repositories}/...`
   - Clean Architecture: `lib/{data,domain,presentation}/<feature>/...`
   - Something else / mixed → note the actual pattern found, do not force-fit it
     into one of the above.
2. Define a **"domain"** as the smallest coherent unit matching that architecture
   (a feature folder in feature-first; a model/entity grouping across layers in
   layer-first; a feature folder under each of data/domain/presentation in Clean
   Architecture).
3. Enumerate every domain and every file inside it. Produce a Domain Map:

```
DOMAIN MAP
==========
Domain: <name>            | Path(s): <folder path(s)>
  Files: <count>           | Suspected data files: <count, from a quick
                              filename-only pass — this is NOT the real audit,
                              just a heads-up for sequencing>
  Priority order note: <e.g. "auth" first since most other domains depend on
                         user session shape>
...
```

4. Decide a processing order (usually: shared/core utilities → auth →
   leaf-feature domains → domains with the most cross-references last, since
   they'll need the most correlation-checking).

**Self-check before leaving Phase 0:** *Can I name every domain and its folder
path from memory right now, without looking? If not, the map isn't done.*

---

## 7. PHASE 1 — Per-Domain Detection & Flagging Loop

Repeat this entire loop **once per domain, strictly in the order from §6**.
Do not start domain N+1 until domain N passes §7.5.

### 7.1 Full-sweep search (domain-scoped)
Run every term from §4 against every file in the current domain only. Record
every hit, including hits that "look obviously fine" — you verify that in 7.2,
you do not pre-filter at search time.

### 7.2 Full-file read
For every file with at least one hit, open and read the **entire** file, not
just the matched lines. You are building an understanding of:
- What this file's real purpose is.
- Whether it's `PURE_DUMMY_FILE`, `MIXED_FILE`, `LOGIC_ONLY`, or `UNCERTAIN`
  (§5).
- Exactly which lines/symbols are the dummy data itself, as opposed to logic
  that happens to mention a suspicious word in a comment.

### 7.3 Correlation trace (mandatory before classifying)
For every dummy symbol identified (a variable, a class, a function that returns
fake data):
1. Search the **entire project** (not just the current domain) for every
   reference to that symbol.
2. For each reference site, note: which domain it's in, what it does with the
   value (renders it directly? passes it through a transform first? null-checks
   it? force-unwraps it?), and whether that reference site already tolerates
   an empty/null result or will crash on one.
3. This determines the replacement strategy in §7.4/§8.3 — **you cannot choose
   a replacement strategy before finishing this trace.**
4. If a reference site is in a domain you haven't reached yet, log it in the
   ledger as a **forward-reference** and do not jump ahead to fix it now.

### 7.4 Classify and record
Add one row per flagged item to the ledger (§9) with: file path, symbol(s),
classification (§5), every reference site found in 7.3, proposed action
(`DELETE_FILE` / `STRIP_DATA_KEEP_LOGIC` / `NO_ACTION_LOG_ONLY` /
`NEEDS_HUMAN_REVIEW`), and a one-line reasoning note.

### 7.5 Reinforcement checkpoint (repeat until clean)
Before declaring the domain done:
1. Re-run the §4 search dictionary against the domain **again**, fresh, as if
   you'd never looked at it. Any new hit means go back to 7.2 for that file.
2. Confirm every symbol traced in 7.3 has a ledger row.
3. Confirm no ledger row for this domain is missing a classification.
4. Ask yourself explicitly: *"If I were a different, more paranoid auditor
   auditing my own work right now, what would I search for that I haven't
   tried yet?"* Try at least one such search (e.g., a plural/singular variant,
   an Indonesian-language filler word, a differently-cased variant) before
   answering "clean."
5. Only when two consecutive passes (the original + the paranoid re-check)
   surface zero new findings is the domain closed. Mark it closed in the
   Domain Map from §6.

---

## 8. PHASE 2 — Whitelist Confirmation Gate

**Nothing in Phase 3 may touch a file that is not on the confirmed whitelist
produced here.**

1. Once all domains have passed §7.5, compile the full ledger into a single
   whitelist: every row classified `DELETE_FILE` or `STRIP_DATA_KEEP_LOGIC`.
2. Present the whitelist to the human for review, grouped by domain, with the
   `UNCERTAIN` and `NEEDS_HUMAN_REVIEW` items shown separately and clearly
   marked as **requiring an explicit decision**, not just a skim.
3. Default rule: `PURE_DUMMY_FILE` and `MIXED_FILE` items that have a fully
   traced correlation (§7.3) with no unresolved forward-references may be
   pre-approved for autonomous batch execution **only if** the human has given
   a standing instruction to that effect. Absent that, treat everything as
   requiring the same explicit sign-off.
4. `UNCERTAIN` items are **never** auto-approved, no matter what standing
   instructions say.
5. Only after sign-off does the whitelist become immutable input to Phase 3.
   If Phase 3 discovers something not on it, that finding goes back to §7, not
   straight into execution.

---

## 9. Ledger / Manifest Format

Maintain this as a single running file, e.g. `docs/dummy_data_audit/ledger.md`:

```
| # | Domain | File | Symbol(s) | Classification | Reference sites (file:line) | Proposed action | Reasoning |
|---|--------|------|-----------|-----------------|------------------------------|------------------|-----------|
```

Also maintain a running Domain Map status block (from §6) at the top of the
same file, updated as each domain closes.

---

## 10. PHASE 3 — Mass Batch Execution

Only after §8 sign-off.

### 10.1 Re-verify before touching (freshness check)
If any time has passed since Phase 2 sign-off (a new session, a paused task,
etc.), re-open each whitelisted file once more before editing it — codebases
change. If it no longer matches what the ledger describes, stop and re-route
it through §7 rather than editing blind.

### 10.2 Execute domain-by-domain, not file-by-file at random
Even though the human has approved the whole whitelist "in one motion,"
execute it as a single continuous run *ordered by domain* (same order as
§6), so that if something goes wrong you know exactly which domain's changes
to roll back.

### 10.3 Replacement decision tree (for `STRIP_DATA_KEEP_LOGIC` items)
For each dummy literal being removed, using the correlation trace from §7.3:
- If **all** known reference sites already null-check / empty-check safely →
  replace with a correctly-typed empty value (`[]`, `null` on a nullable type,
  `const {}`), so the app keeps running in a visibly-empty state.
- If **any** reference site will crash, force-unwrap, or silently misbehave on
  an empty/null result → replace the function body with
  `throw UnimplementedError('TODO: wire to real data source — dummy data removed <date>, see ledger row #<n>')`
  so the gap is loud and traceable, not a silent empty screen that looks like
  a real "no results" state.
- If reference sites are mixed (some tolerate empty, some don't) → prefer the
  loud failure (`UnimplementedError`) as the safer default, and note the
  mixed tolerance in the report (§11) so the human knows which call sites will
  need attention first when real data arrives.
- Never choose a replacement without having actually re-read the reference
  sites in 10.1 for this run — do not rely on stale notes from Phase 1 if the
  file has changed since.

### 10.4 Commit per domain
After finishing a domain's edits: run `flutter analyze` scoped to that domain
if possible, then commit with a message like
`chore(dummy-data): remove sample data from <domain> — logic preserved (see ledger #x-#y)`.

---

## 11. PHASE 4 — Global Reinforcement Verification Loop

This is the final, whole-project loop. Repeat until it passes clean twice in a row.

1. **Full repo re-scan:** run the entire §4 dictionary against the whole `lib/`
   tree (and any in-scope `assets/`) fresh. Expected result: **zero matches**
   outside of comments/TODOs you deliberately left as breadcrumbs (e.g., the
   `UnimplementedError` messages from §10.3 — those are fine, they're supposed
   to mention this pass).
2. If anything unexpected turns up: it is a Phase 1 miss. Route it back through
   §7 for its domain — do not patch it ad hoc from Phase 4.
3. **Static analysis pass:** run `flutter analyze` (and `flutter test` only if
   the human has confirmed test scope was included) across the whole project.
   Confirm that every resulting error/warning is an *expected* consequence of
   removed data (missing return values now throwing, empty-state UI now
   showing nothing) and not an *unexpected* logic regression. Any error that
   doesn't clearly trace back to a §10.3 replacement is a red flag — investigate
   before closing.
4. **Logic-integrity spot check:** for a sample of the `MIXED_FILE` edits, diff
   the before/after and confirm that literally nothing changed except the data
   literal and its immediate replacement — no reformatting, no reordering, no
   "while I was in there" cleanups.
5. Produce the final report (§12).

---

## 12. Final Report Template

Write this to `docs/dummy_data_audit/final_report.md`:

```
# Dummy Data Removal — Final Report

## Summary
- Domains processed: <n>
- Files deleted (PURE_DUMMY_FILE): <list>
- Files edited (MIXED_FILE, data stripped / logic preserved): <list>
- UNCERTAIN items resolved by human decision: <list + decision>
- Items still NEEDS_HUMAN_REVIEW / not actioned: <list + why>

## Logic preservation confirmation
- <brief statement + link/reference to the diffs confirming no logic was
  altered, only data literals>

## Known breakage (expected)
- <list of call sites now throwing UnimplementedError or rendering empty
  states, grouped by domain, so the human knows exactly what needs wiring to
  the real database next>

## Suggested next steps
- <e.g. "pubspec.yaml still lists `faker` as a dependency; no longer used in
  lib/, consider removing" — suggestions only, not auto-actioned>
```

---

## 13. Escalation & Failure Protocol

- If at any point you are not sure whether something is dummy data or real
  reference data → `UNCERTAIN`, stop, ask. Never resolve ambiguity by guessing
  in the direction that lets you keep moving.
- If removing data would require restructuring how a widget/provider/state
  class is wired (not just what data it holds) → `NEEDS_HUMAN_REVIEW`, stop.
  This pass removes data; it does not redesign architecture.
- If a domain's correlation trace (§7.3) turns up a reference you cannot fully
  resolve (e.g., dynamic/reflective access, a code-generated file you can't
  fully read) → flag it explicitly rather than assuming it behaves like the
  resolvable references you did trace.
- If you find yourself about to write a *new* literal value anywhere in
  `lib/` during this whole protocol, stop — that is very likely the exact
  mistake this document exists to prevent.

---

## 14. Definition of Done

- [ ] Every domain in the Domain Map (§6) is marked closed per §7.5.
- [ ] The ledger (§9) has a classification and reasoning for every flagged item.
- [ ] The human has explicitly signed off on the whitelist (§8), including
      every `UNCERTAIN` item individually.
- [ ] Phase 3 execution is committed domain-by-domain with traceable messages.
- [ ] Phase 4's global re-scan (§11) returns zero unexpected matches, twice
      in a row.
- [ ] `flutter analyze` output is fully explained by expected, intentional
      breakage — nothing unexplained remains.
- [ ] The final report (§12) is written and lists every known "wire this to
      the real database" gap by domain.
- [ ] No new dummy/sample/fake literal value was introduced anywhere during
      this entire process.
