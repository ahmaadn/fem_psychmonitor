# AGENTS.md

## Layout

- **Root** = Flutter app (`fem_psychmonitor`, product title **Fem-Psychmonitor**).
- **`server/`** = git submodule (`ahmaadn/fem-psychmonitor-backend`). Own git history, lockfile, CI — treat as a separate package.
- Planning/contracts (not runtime code): `PLAN.md` (SER pipeline), `DESIGN.md` (UI tokens). Prefer code + scripts when they disagree with prose.

## Flutter (root)

### Commands

```bash
flutter pub get
flutter gen-l10n          # also runs via `flutter: generate: true`
flutter analyze
flutter test
flutter test test/path/to_test.dart
flutter run
```

### Architecture

- Stack: **Provider** + **go_router** + **ScreenUtil** design size `390×844`.
- Layers: `lib/features/*` (UI) → `lib/data/viewmodels/*` → `lib/data/repositories/*` → local SQLite / API scaffolds.
- **Local-first**: `main.dart` wires `Sqlite*Repository`. `Api*Repository` / `SqliteSyncService` are no-ops until `baseUrl` is non-empty (currently unset).
- Dummy repos under `lib/data/repositories/dummy/` are for tests/scaffolds — do not use them as the app default.
- SQLite: `DatabaseHelper` (`fem_psychmonitor.db` v2). Desktop needs `DatabaseHelper.initPlatform()` (sqflite FFI) before open — already done in `main`.
- Routes/auth gates: `lib/app/routes/app_routes.dart` (assessment required before shell routes).
- Theme: prefer `context.palette` (`AppPalette`) over raw `AppColors`. Tokens live in `lib/app/config/*`; design source `DESIGN.md` — "Strawberry Match" system: Strawberry Rose `#C66F80` (primary) + Matcha Green `#4a6644` (secondary) as co-equal brand fills, generated as 10-step tonal ramps, with a fixed 6-color emotion palette (happy/sad/anger/fearful/disgust/neutral) as the app's real functional-color system. Ships **both** light and dark themes (`AppPalette.light()` / `AppPalette.dark()`), not dark-only.
- i18n: `lib/l10n` (`app_en.arb` template, `app_id.arb`). Locales: `en_US`, `id_ID`. Edit ARB → regenerate.

### UI / Widget Conventions (read `DESIGN.md` before writing any widget)

- **Never hardcode color.** No raw `Color(0x...)` or hex literal in a feature widget — everything comes from `context.palette`. If a token you need doesn't exist yet, add it to `AppPalette` (both `.light()` and `.dark()`) rather than inlining a one-off value.
- **Never hardcode size.** Padding, radius, icon size, font size all go through ScreenUtil (`.w`/`.h`/`.r`/`.sp`) against the `390×844` design canvas from `DESIGN.md` §5 — no raw pixel literals in new/edited widgets.
- **Reuse the shared component library before writing a new widget.** Buttons, cards, chips, the emotion badge, the emotion trend ring, bottom nav, inputs, and the segmented control are specified once in `DESIGN.md` §4 and must live as shared widgets (not redefined per screen). If a screen needs a variant, extend the shared widget's parameters — don't fork a near-duplicate.
- **Ramp-step rule (brand colors):** fills use the `-500` step; text/icons rendered directly in a brand color use `-600` on light theme and `-400` on dark theme — never render small text in the raw `-500` seed. (Check `DESIGN.md` §2.3 per-file — Bloom's secondary uses `-700` on light, not `-600`; the step isn't guaranteed identical across the two palette files.)
- **Emotion colors are for emotion data only** (`EmotionLabelType`-keyed chips, chart/ring segments, per-emotion labels) — never reused as a generic UI accent, and brand colors are never substituted for an emotion. Text set directly in an emotion color must use the on-light/on-dark text-safe variant from `DESIGN.md` §2.6, not the raw base hex.
- **Every new screen/widget supports both themes before it's considered done** — verify against `AppPalette.light()` and `.dark()`, not just whichever theme is active in the emulator by default.
- Full rebuild scope, execution order, and the do-not-touch list (routing, viewmodels/repositories, `EmotionLabelType` order, SER pipeline) for a system-wide UI refactor are captured in `REFACTOR_PROMPT.md` — reuse it rather than re-deriving refactor scope ad hoc.


### Emotion detection (easy to break)

- Pipeline contract: **`PLAN.md`** — order and constants are part of the training contract, not style choices.
- Fixed params: `SR=16000`, `DURATION=3s` → `48000` samples, `N_MFCC=40`, `N_FFT=2048`, `HOP=512`, `MAX_PAD_LEN=128`, `FEATURE_DIM=121`, input tensor `(1,128,121)`, 6-class softmax.
- Feature stack order: **MFCC → Δ → ΔΔ → ZCR**. Global z-score uses **`assets/models/norm_female_model.json`** (do not hardcode mean/std).
- Model asset: `assets/models/female_model.tflite`. Input tensor name: `serving_default_female_model_input:0`.
- C++ MFCC FFI: `android/app/src/main/cpp/mfcc_extractor.*` ↔ `lib/detection/services/mfcc_ffi.dart`. **Android/iOS only** — other platforms throw `UnsupportedError`.
- **Web (dev UI only):** `EmotionDetector` is a conditional export (`emotion_detector.dart` → `emotion_detector_stub.dart` when `dart.library.io` is absent). SER/TFLite/MFCC/FFmpeg do not run on web; recording flows stay not-ready with a clear error. SQLite uses `sqflite_common_ffi_web` via `db_factory_*.dart`. Prefer `flutter run -d chrome` for UI; full SER remains Android (release target).
- **Web SQLite binaries** (required once per machine/clone): `web/sqlite3.wasm` + `web/sqflite_sw.js`. Prefer `dart run sqflite_common_ffi_web:setup` (needs working `webdev`). If that hangs, compile from the package workdir and fetch wasm:
  - `dart compile js .dart_tool/sqflite_common_ffi_web/setup/<ver>/web/sqflite_sw.dart -O2 -o web/sqflite_sw.js` (after a partial setup has copied package sources), and download `sqlite3.wasm` from the URL in that package’s `sqlite3_wasm_version.dart`.
- Label index = `EmotionLabelType.values` order: happy, sad, **anger**, fearful, disgust, neutral. Do not reorder the enum.
- Inference runs in a background isolate (`inference_isolate.dart`); UI uses `EmotionDetector`.

### Flutter gotchas

- Do not reverse SER preprocess steps or change pad/norm order without retraining alignment.
- Uploaded compressed audio is transcoded via FFmpeg (`ffmpeg_kit_flutter_new_min`).
- Question seed data: `assets/questions/*.json` via `QuestionSeeder`.
- Root README is still the Flutter template — ignore it for product context.

## Server (`server/`)

Work from `server/` with **pnpm** (Corepack). Copy `.env.example` → `.env`; **`DATABASE_URL` is required** (throws on boot). `PORT` default `3000`.

```bash
pnpm install
pnpm dev              # tsx watch src/index.ts
pnpm start
pnpm typecheck
pnpm lint             # biome check
pnpm lint:fix
pnpm test             # vitest
pnpm test:coverage
pnpm db:generate      # drizzle-kit generate → drizzle/
pnpm db:migrate
pnpm build
```

CI order (PR/main): **typecheck → lint → test:coverage**. After schema edits: `db:generate` then `db:migrate`.

- Stack: Express 5 + Drizzle ORM + PostgreSQL (`src/db/schema.ts`, `drizzle.config.ts`).
- Currently thin: `/`, `/health` (DB ping). Auth/JWT/mail env keys in `.env.example` are forward-looking — not all wired yet.
- Format/lint: Biome (single quotes, no semicolons, 2-space). Conventional commits for semantic-release.
- Never commit `server/.env`. Keep `pnpm-lock.yaml` in sync (`--frozen-lockfile` in CI).

## Cross-cutting

- Submodule: change backend → commit inside `server/`, then update submodule pointer in the parent repo.
- Parent app sync/API clients are scaffolds; implement server routes and set `baseUrl` together.
- No monorepo tooling at root — Flutter and server are independent install/test surfaces.