# Design System — Fem-Psychmonitor "Strawberry Match: Cherry"

## 0. Relationship to `DESIGN.md` and Palette Provenance

This is a color/component variant of the same "Strawberry Match" system as `DESIGN.md`, `DESIGN-bright.md`, and `DESIGN-merlot.md` — structured here in the same section order as the Peloton reference doc (`1` Visual Theme through `9` Agent Prompt Guide) so it can be read and built from the same way. Pick one palette file per build; don't mix tokens across files.

**Seed:** `#B4182D` — HSL(352°, 76%, 40%), a vivid, highly saturated cherry-crimson. Same hue family as every other variant's primary (348–352° across the whole set), the most saturated primary seed yet. Because the seed already carries plenty of saturation, this file uses the **fixed-hue/fixed-saturation ramp method** introduced in `DESIGN-merlot.md` (vary lightness only) rather than the linear-to-white/black method in `DESIGN.md`/`DESIGN-bright.md` — that's what keeps every tint and shade reading unmistakably "Cherry" instead of fading toward gray.

The secondary (Jade, hue 145°) is color-theory-derived, not supplied: ~159° from Cherry on the hue wheel (the same split-complementary spacing the base system already uses between Rose and Matcha), matched to Cherry's saturation level so the two read as genuine co-leads rather than "bold primary, muted afterthought."

## 1. Visual Theme & Atmosphere

Fem-Psychmonitor Cherry is **an encouraging, high-energy self-care space rendered in confident color** — the boldest, most saturated variant in the "Strawberry Match" family. Where the base `DESIGN.md` reads soft-clinical and `DESIGN-merlot.md` reads warm-and-grounded, Cherry is built for the moments the product wants to feel alive: a completed streak, a positive weekly trend, a gentle nudge to check in again. The canvas is a crisp, barely-pink near-white in light mode and a deep crimson-black in dark mode — bright enough, in both cases, to let the two saturated brand ramps do the emotional work instead of competing with a busy background.

The app has two signature surfaces, mirrored from the same architecture Peloton's reference doc describes for its own product: the **history/check-in feed** — a vertically scrolling list of rounded 18dp mood check-in cards, each carrying an emotion-colored icon chip, a title, a timestamp, and a confidence percentage in tabular metric type — and the **emotion trend screen**, where a large **Emotion Trend Ring** anchors the bottom half of the screen (a thick colored arc on a `surface-3` track, the dominant emotion's confidence in 900-weight-equivalent numerals at center), flanked by a weekly summary strip and, during an active recording, a pulsing waveform capture card.

Typography is **Inter**, set with a gentler weight ladder than Peloton's 800–900-everywhere voice — this is a wellness context, not a competitive-fitness one — but confidence numbers and the ring's center value are still set heavy and tabular, because they're this app's equivalent of Peloton's "the metric is the hero" principle. Emotion labels are small uppercase whispers in their own fixed hue, exactly like Peloton's discipline eyebrow, just multiplied across six meanings instead of one brand red.

Chrome is minimal on both themes: the bottom nav has no tint pill (color alone marks the active tab, same rule Peloton uses), cards are flat rounded tiles separated by spacing and a soft shadow (light theme) or a lightness-step (dark theme), and depth never depends on Material-style drop shadows on dark surfaces.

**Key Characteristics:**
- Two co-equal, matched-saturation brand ramps — **Cherry** (primary, 352°) and **Jade** (secondary, 145°) — bold-on-bold, never bold-plus-muted
- Fixed-hue/fixed-saturation ramp generation — every tint and shade stays visibly "Cherry" or "Jade," nothing fades toward gray
- Rounded 18dp mood check-in cards, not edge-to-edge tiles — this is a personal space, not a storefront
- **Emotion Trend Ring** — the screen's hero metric, directly analogous to Peloton's output ring, just colored by dominant emotion instead of always-red
- Fixed 6-color **Emotion Palette** (happy/sad/anger/fearful/disgust/neutral) — this file's equivalent of Peloton's fixed metric colors; two of the six (Success-adjacent green, Anger-adjacent red) were deliberately re-hued away from the brand ramps to avoid collision (§2.5–2.6)
- Both themes ship from one token set; only the value axis flips
- Tabular numerals on the confidence percentage and any ticking value, so the trend ring and history list never jitter

## 2. Color Palette & Roles

### Primary (Interactive) — Cherry, hue 352°, saturation held at 76.5%

| Token | Hex | Role |
|---|---|---|
| `primary-50` | `#FCE8EB` | Tinted backgrounds, selected-row wash |
| `primary-100` | `#F9D2D7` | Chip/badge fill on light theme |
| `primary-200` | `#F4AEB7` | Hover/pressed wash, progress-track alt |
| `primary-300` | `#EE8190` | **On-dark text/icon** (chosen over `-400` for extra margin, §2.3) |
| `primary-400` | `#E64258` | Bright accent fill — energetic highlights, active-state icon |
| `primary-500` | `#B4182D` | **Seed.** Primary fills on light theme, brand mark |
| `primary-600` | `#901324` | **On-light text/links** |
| `primary-700` | `#710F1C` | Pressed state (light theme primary button) |
| `primary-800` | `#510B14` | High-emphasis text on light, rare |
| `primary-900` | `#36070E` | Reserved / deepest emphasis |

### Secondary (Co-Brand) — Jade, hue 145°, saturation held at 65%

| Token | Hex | Role |
|---|---|---|
| `secondary-50` | `#EAFBF1` | Tinted backgrounds |
| `secondary-100` | `#CDF4DD` | Chip/badge fill on light theme |
| `secondary-200` | `#A2EBC1` | Hover/pressed wash |
| `secondary-300` | `#70E19F` | On-dark text/icon |
| `secondary-400` | `#3DD67D` | Bright accent fill |
| `secondary-500` | `#25B15F` | **Seed.** Secondary fills on light theme |
| `secondary-600` | `#1D8B4B` | Mid-emphasis (not the on-light text step, §2.3) |
| `secondary-700` | `#166939` | **On-light text/links** |
| `secondary-800` | `#104C29` | High-emphasis text, rare |
| `secondary-900` | `#0B321B` | Reserved / deepest emphasis |

### Canvas & Surfaces (Both Themes)

- **Light Canvas** (`#FFF7F8`): App background — crisp, barely-pink near-white.
- **Light Surface 1 / 2 / 3** (`#FDEEF0` / `#FBE3E6` / `#F6D0D5`): Cards → nested rows/inputs → pressed/track backgrounds.
- **Light Divider** (`#F2C2C8`): 1px hairlines.
- **Dark Canvas** (`#1A0C0F`): App background — deep crimson-black, kept in the primary hue family rather than a neutral charcoal.
- **Dark Surface 1 / 2 / 3** (`#24141A` / `#301B22` / `#3D242C`): Same role ladder as light, dark register.
- **Dark Divider** (`#4A2E36`): 1px hairlines.

### Text

- **Text Primary** (`#2B0E12` light / `#F9E9EA` dark): Titles, metric values, card titles.
- **Text Secondary** (`#6E3A40` light / `#D6BCC0` dark): Body, metadata.
- **Text Tertiary** (`#A17178` light / `#A8878C` dark): Meta line, units, captions, disabled.
- **On-Primary** (`#FFFFFF` light / `#1A0C0F` dark): Text/icon on a `primary-500` fill.
- **On-Secondary** (`#1A0C0F` both themes): Text/icon on a `secondary-500` fill — **dark text in both themes**, since white fails contrast on Jade-500 (§2.3).

### Functional / Emotion Colors (fixed meaning, theme-invariant)

Fem-Psychmonitor's equivalent of Peloton's fixed in-class metric colors — each `EmotionLabelType` owns a color so a glance reads instantly. These never restyle per theme beyond the on-light/on-dark text-safe swap.

| Emotion | Base (fill/icon/chart) | On-light text-safe | On-dark text-safe | Hue rationale |
|---|---|---|---|---|
| Happy | `#FFB03C` | `#8C6121` | `#FFBC59` | Warm gold — energy, positive affect |
| Sad | `#5388C4` | `#4774A7` | `#6D9ACD` | Cool slate-blue — low-arousal-negative cue |
| Anger | `#F46325` | `#B74A1C` | `#F67A46` | Hot vermillion — re-hued from a near-red to sit ~26° clear of Cherry primary (352°); the original reused hue sat only ~13° away and risked reading as "brand red" |
| Fearful | `#946ACC` | `#7E5AAD` | `#A480D4` | Violet — unease |
| Disgust | `#A9C234` | `#5D6B1D` | `#B6CB52` | Olive — yellow-shifted green, distinct from Jade |
| Neutral | `#B09989` | `#726359` | `#BCA89B` | Warm taupe — genuinely neutral |

### Semantic

- **Success** (`#1FAD9A`): A teal-leaning green, re-hued from a near-Jade green so it sits ~27° clear of Jade secondary (145°) — the reused hue was only ~6° away and risked blurring into "one green." On-light text `#147064`, on-dark text `#41B9A9`.
- **Warning** (`#F29A18`): Low-confidence detection notice, incomplete session. On-light text `#9D6410`, on-dark text `#F4A93B`.
- **Error** (`#E04343`): Failed upload, recording error, destructive-action confirm. On-light text `#BE3939`, on-dark text `#E55F5F`.
- **Info** (`#3A82C9`): Neutral system notices, onboarding tips. On-light text `#316EAB`, on-dark text `#5895D1`.
- **Track / Empty** (`surface-3`, both themes): Unfilled portion of the Emotion Trend Ring or any progress bar.

## 3. Typography Rules

### Font Family
- **All text:** `Inter` (variable, SIL OFL) via the `google_fonts` package — an excellent UI/data face with real tabular figures, needed for confidence percentages and trend numerals.
- **Numerals:** Inter with tabular figures enabled — the confidence percentage, streak counters, and any ticking value must not jitter.
- **Fallback stack:** `Roboto, -apple-system, sans-serif`

### Hierarchy

| Role | Font | Size | Weight | Line Height | Letter Spacing | Notes |
|---|---|---|---|---|---|---|
| Display | Inter | 28sp | 700 | 1.2 | -0.3 | Screen hero — "Bagaimana perasaanmu hari ini?" |
| Screen Title | Inter | 22sp | 700 | 1.25 | -0.2 | Section titles, sheet headers |
| Card Title | Inter | 18sp | 600 | 1.3 | 0 | Mood check-in card title, list-item title |
| Confidence Metric | Inter | 32sp | 700 | 1.1 | -0.5 | Emotion Trend Ring center value, trend headline numbers (tabular) |
| Body Strong | Inter | 15sp | 600 | 1.4 | 0 | Emphasized inline copy |
| Body | Inter | 15sp | 400 | 1.5 | 0 | Default paragraph |
| Meta / Caption | Inter | 13sp | 500 | 1.35 | 0.1 | Timestamps, metadata |
| Emotion Label | Inter | 12sp | 600 | 1.2 | 0.4 (UPPERCASE) | Emotion chip labels, form field labels |
| Button | Inter | 15sp | 600 | 1.0 | 0.1 | All button text |
| Tab Label | Inter | 11sp | 600 | 1.0 | 0.1 | Bottom nav labels |
| Badge | Inter | 10sp | 700 | 1.0 | 0.5 (UPPERCASE) | Streak badge, "Recording" indicator |

### Principles
- **Gentler than Peloton's weight ladder:** titles top out at 700, not 900 — this is a wellness context asking for a moment of attention, not a competitive-fitness push.
- **The confidence number is the hero, same as Peloton's output metric:** the Emotion Trend Ring's center value is the single largest, heaviest number on screen; its label sits small and uppercase beneath it.
- **Tabular for anything that ticks:** confidence percentages, streak counts, recording timers — always tabular so the ring and history list never jitter.
- **Emotion label in its fixed hue:** the uppercase emotion chip label is the one place a small text element carries a strong, meaning-bearing color — exactly like Peloton's red discipline eyebrow, just across six meanings instead of one.
- **Color stays functional:** hierarchy comes from weight and size; color is reserved for brand fills, emotion semantics, and system states.

## 4. Component Stylings

### Buttons

**Primary Button (Save Check-in / Start Recording)**
- Shape: full pill, 999dp corner radius
- Background: `primary-500` (`#B4182D`)
- Text: `on-primary`, Inter 15sp 600
- Padding: 14dp vertical, 24dp horizontal
- Pressed: `primary-700` + scale 0.98
- Disabled: `surface-3` background, `text-tertiary` text

**Secondary Button (Jade outline — "View Trends," "Skip")**
- Background: transparent
- Border: 1.5dp `secondary-500`
- Text: `secondary-700` (light) / `secondary-300` (dark), Inter 15sp 600
- Pill, same padding as primary
- Pressed: `secondary-50`/`secondary-900`-tinted wash at 10% opacity

**Text Button ("See History," inline links)**
- Background: none
- Text: `primary-600` (light) / `primary-300` (dark), Inter 14sp 600

**Icon Button (header action)**
- 20dp glyph in 44dp hit area
- Default `text-secondary`; pressed 60% opacity
- Stroke-style line icons, 2dp stroke

### Core Atoms

**Mood Check-in Card** (the history-feed unit)
- Background: `surface-1`, 18dp corner radius, 1px `divider` border (light theme only — dark theme relies on the surface-lightness step)
- Leading: 40dp chip, filled with the detected emotion's base color at 15% opacity, icon in the emotion's on-surface text-safe variant
- Title: Inter 18sp 600 (`Card Title`), `text-primary`
- Timestamp: Inter 13sp 500 (`Meta`), `text-tertiary`
- Trailing: confidence percentage, Inter 32sp 700 tabular, colored in the emotion's text-safe variant
- 16dp internal padding

**Emotion Chip / Badge**
- Pill, `Emotion Label` typography (12sp/600, uppercase)
- Fill: emotion base color at 12–15% opacity
- Text/icon: the emotion's on-light or on-dark text-safe variant — never the raw base as text

**Emotion Trend Ring** (the screen's hero, Peloton output-ring analog)
- 96dp ring, `surface-3` track at 4dp stroke
- Progress arc: the dominant emotion's base color, 4dp stroke, round cap, starting at -90°
- Center: dominant emotion label (`Card Title` weight) over confidence % (`Confidence Metric`, tabular)
- Segmented multi-color mode: where a session carries more than one meaningful emotion, the ring splits into arc segments — one per emotion, each in its own base color — instead of forcing a single dominant arc. This is the one place all six emotion colors are allowed to appear together at once.

**Voice Capture Card** (recording-in-progress, Peloton cinematic-thumbnail analog)
- Background: `surface-1`, 18dp radius
- Center: animated waveform bars, gradient from `primary-400` to `primary-600`, height responds to input amplitude
- Record button: 64dp circle, `primary-500` fill, 3dp white/`on-primary` ring; while recording, the ring pulses opacity 1 → 0.5 → 1 on a 1.2s ease-in-out loop — this file's answer to Peloton's LIVE-dot heartbeat
- Duration timer: Inter 18sp 700 tabular, `text-primary`, centered below the waveform
- Small uppercase "MEREKAM" badge (`Badge` typography) in `primary-600`/`primary-300`, top-left, while active

**Weekly Emotion Summary Strip**
- A horizontal row of 7 equal segments (one per day), each a rounded 6dp-radius bar, 28dp tall
- Fill: that day's dominant emotion base color; empty/no-data day uses `surface-3`
- Tap a segment to jump to that day's Mood Check-in Card in the history feed

**Streak / Milestone Card**
- On hitting a streak milestone: a `Success` (`#1FAD9A`) ring pulse behind the card icon, a brief confetti burst, and "Streak 7 hari!" in `Display` typography, 1.2s duration, paired with a success haptic — direct analog to Peloton's PR burst, re-hued to this file's corrected Success color specifically so it never reads as "Jade, but muted"

### Navigation

**Bottom Tab Bar**
- Height: 56dp + safe area
- Background: `surface-1`, 0.5dp top `divider`
- Tabs: 4–5 (Home, History, Record, Trends, Profile)
- Icon: 22dp; **no tint pill** — color alone signals selection, same principle as the base system and Peloton
- Active: glyph + label in `primary-600` (light) / `primary-300` (dark)
- Inactive: `text-tertiary`
- Labels: Inter 11sp 600, always shown

**Top Header**
- Height: 44dp + safe area
- Leading: screen title (`Screen Title`, 22sp/700) or back chevron
- Trailing: 20dp stroke icons in `text-secondary`

**Section Header**
- `Screen Title` typography at 20sp, 20dp top margin, 12dp bottom
- Optional trailing text button ("Lihat Semua") in `primary-600`/`primary-300`

### Input Fields

**Text Input**
- `surface-2` fill, 12dp radius, 1px `divider` border
- Focus ring: 1.5dp `primary-500`
- Placeholder: `text-tertiary`

**Segmented Control (Week / Month / Year — trend filter)**
- Track: `surface-2`, pill shape
- Selected segment: **tonal** fill — `primary-100` (light) / a `primary-800`-tinted overlay (dark) — with `primary-600`/`primary-300` text. Deliberately *not* Peloton's stark white-chip inversion; the base system's rule is that a selected state should feel "gently lit," not "inverted"
- Inter 13sp 600

### Distinctive Components

**Emotion Trend Ring + Weekly Summary** (full screen-anchor composition)
- Card: `surface-1`, 18dp radius, 16dp padding
- Center: 96dp Emotion Trend Ring as specified above
- Below: the Weekly Emotion Summary Strip
- All values tabular, updating live as new check-ins land

**Recording Indicator Badge**
- `primary-500` fill, `on-primary` text "MEREKAM," Inter 10sp 700 uppercase, 5dp radius
- Leading 6dp dot that pulses (opacity 1 → 0.4 → 1, 1.2s loop) — this file's equivalent of Peloton's LIVE dot heartbeat, scoped to "a recording is active" rather than "a class is live"

**Multi-Emotion Segmented Ring** (see Emotion Trend Ring above for full spec)
- The one screen element allowed to show all six emotion base colors simultaneously — everywhere else, emotion color appears one-at-a-time per data point

**Streak / Milestone Burst** (see Core Atoms above for full spec)

## 5. Layout Principles

### Spacing System
- Base unit: 4dp
- Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48
- Card internal padding: 16dp
- Card-to-card gap: 16dp
- Screen side inset: 16dp

### Grid & Container
- Design canvas: 390×844 (`ScreenUtilInit` in `main.dart`) — author fixed sizes here, let ScreenUtil scale
- Phone-first; if a tablet/foldable target is ever added, content max-width ~600dp centered, history feed becomes a 2-column grid
- Trend screen: Emotion Trend Ring + Weekly Summary Strip stacked; history list scrolls below

### Whitespace Philosophy
- **Calm content, quiet chrome:** cards and the trend ring get the visual weight; UI chrome stays thin so the emotional content — not the interface — reads first
- **Gentle type, generous cards:** titles are confident but not shouting (max 700 weight); cards are spaced 16dp apart so the feed breathes
- **The ring owns the trend screen:** everything else on that screen orbits the Emotion Trend Ring, same principle as Peloton's output ring
- **No decorative empty space:** spacing is structural; warmth comes from color and rounded shapes, not from emptiness

### Border Radius Scale
| Token | Value | Use |
|---|---|---|
| `none` | 0dp | Full-bleed imagery (rare in this app) |
| `xs` | 5dp | Recording indicator badge |
| `sm` | 8dp | Small utility chips |
| `md` | 12dp | Text inputs |
| `lg` | 18dp | Mood check-in cards, trend card, voice capture card |
| `pill` | 999dp | All buttons, emotion chips, segmented control |
| `full` | 50% | Emotion Trend Ring, avatars, recording dot |

## 6. Depth & Elevation

| Level | Light Treatment | Dark Treatment | Use |
|---|---|---|---|
| Base | `canvas-light`, no shadow | `canvas-dark`, no shadow | App background |
| Raised | `surface-1` + `0 1px 3px rgba(43,14,18,0.08)` | `surface-1`, no shadow (rely on the lightness step) | Cards, list items |
| Floating | `surface-1` + `0 8px 24px rgba(43,14,18,0.14)` | `surface-2` + `0 8px 24px rgba(0,0,0,0.5)` | Bottom sheets, dialogs |
| Pressed | `surface-3` | `surface-3` | Active/pressed surfaces, track backgrounds |

**Shadow philosophy:** shadows are invisible on the dark canvas, so dark-theme depth comes entirely from the surface-lightness ladder, same as Peloton's reasoning for pure black — applied here to a warm crimson-black rather than a neutral one.

### Motion
- **Card tap:** scale 1.0 → 0.98 over 120ms, then push-transition to detail
- **Recording pulse:** the Voice Capture Card's record-button ring and the Recording Indicator's dot both pulse opacity 1 → 0.4/0.5 → 1 on a 1.2s ease-in-out loop
- **Emotion Trend Ring fill:** arc animates from 0 to value over 600ms ease-out on first load; live updates use a 300ms ease-out tween
- **Confidence tick:** values count with tabular spacing (no layout shift); a brief color flash on a changed dominant emotion
- **Streak burst:** `Success` ring pulse + confetti + "Streak N hari!" scale-in, 1.2s, success haptic
- **Segmented control select:** tonal fill cross-fades in over 150ms
- **Tab switch:** cross-fade 150ms; active glyph swaps stroke→fill instantly
- **Haptic:** light impact on chip/segment select and tab change; medium impact on "Save Check-in"; success notification on streak milestone
- **Reduce Motion:** recording pulse stays solid (no animation); ring sets final value with a 150ms crossfade; no card scale; weekly strip updates instantly

## 7. Do's and Don'ts

### Do
- Use `primary-500` (Cherry) and `secondary-500` (Jade) as genuine, matched-weight fills — bold-on-bold, never bold-plus-muted
- Generate every tint/shade with fixed hue and saturation, varying only lightness — this is what keeps the palette "segar," not "pias"
- Reserve the six emotion colors strictly for emotion data (chips, ring segments, per-emotion labels) — never repurpose one as a generic UI accent
- Keep Success (`#1FAD9A`) and Anger (`#F46325`) at their corrected hues — they were deliberately moved away from Jade and Cherry respectively to avoid visual collision
- Use `-600`/`-300` ramp steps (not `-400`) for any Cherry text/icon on a dark surface; use `-700` (not `-600`) for any Jade text/icon on a light surface — both were measured, not assumed
- Set the confidence number and ring value heavy and tabular, same "the metric is the hero" principle as Peloton's output number
- Pulse the recording indicator — it's this app's heartbeat, the direct equivalent of Peloton's LIVE dot
- Keep the bottom tab bar pill-free — active is color alone

### Don't
- Don't set body-size text directly in `primary-500` or `secondary-500` on light theme without checking §2 — use the documented text-safe step instead
- Don't let the Emotion Trend Ring's segmented multi-color mode bleed into everyday chrome — it's the one deliberately "loud" moment in an otherwise calm system
- Don't introduce a third brand hue; Success/Warning/Error/Info already cover the system-state space
- Don't reuse true black/true white for canvas or max-emphasis text — every token here carries the warm crimson undertone
- Don't set white text on a `secondary-500` fill — it fails contrast; use dark text (`on-secondary`) in both themes
- Don't hand-author a new component's dark-theme colors from scratch — derive them from the same ramp-step relationship already established here
- Don't over-animate — motion is the recording pulse, ring fill, and streak burst; quiet elsewhere

## 8. Responsive Behavior

### Device Sizes
| Device | Width | Key Changes |
|---|---|---|
| Small phone | 360dp | Emotion Trend Ring 84dp; Voice Capture waveform shorter |
| Standard phone (design canvas) | 390dp | Reference layout — all specs above assume this width |
| Large phone | 430dp | Ring and cards scale up proportionally via ScreenUtil |
| Tablet (portrait, if added) | 768dp+ | History feed → 2-column grid; trend screen gains a side rail |

### Text Scaling
- Scales with system text-size settings: Display, Screen Title, Card Title, Body, Meta
- Layout-pinned (not scaled): Confidence Metric (ring center value), Tab Label, Badge — these live in tight, live-updating layouts where reflow would break the composition
- The confidence number already dominates visually; don't additionally scale it with system text size

### Orientation
- Portrait-first throughout; this app has no equivalent of Peloton's in-class landscape mode
- If a chart-heavy trend view is ever added in landscape, keep the Emotion Trend Ring centered and let the Weekly Summary Strip move beside it rather than below

### Touch Targets
- Tab bar icon: 22dp glyph, 44dp hit area
- Mood check-in card: full-card tap, ≥ 72dp tall
- Buttons: ≥ 48dp tall
- Record button: 64dp circle, generously oversized for a primary action performed under emotional load

### Safe Area Handling
- Top: header respects safe area / status bar / notch
- Bottom: tab bar + home indicator respected; a sticky "Save Check-in" button (where present) sits above the indicator
- Sides: 16dp content inset throughout

## 9. Agent Prompt Guide

### Quick Color Reference
- Light canvas: `#FFF7F8` · Dark canvas: `#1A0C0F`
- Light surface 1/2/3: `#FDEEF0` / `#FBE3E6` / `#F6D0D5`
- Dark surface 1/2/3: `#24141A` / `#301B22` / `#3D242C`
- Primary (fill): `#B4182D` · Primary text (light/dark): `#901324` / `#EE8190`
- Secondary (fill): `#25B15F` · Secondary text (light/dark): `#166939` / `#70E19F`
- `on-secondary` text/icon: `#1A0C0F` on **both** themes (white fails contrast on Jade-500)
- Success `#1FAD9A` · Warning `#F29A18` · Error `#E04343` · Info `#3A82C9`
- Emotion — Happy `#FFB03C` · Sad `#5388C4` · Anger `#F46325` · Fearful `#946ACC` · Disgust `#A9C234` · Neutral `#B09989`
- Font: Inter. Base unit: 4dp. Design canvas: 390×844 (ScreenUtil)

### Example Component Prompts

- "Build a Fem-Psychmonitor Mood Check-in Card in Flutter, Cherry palette: `surface-1` background, 18dp radius, 1px `divider` border on light theme only, 16dp padding. Leading 40dp chip filled with the detected emotion's base color at 15% opacity, icon in that emotion's on-surface text-safe variant. Title 'Merasa Bahagia' in Card Title (Inter 18sp 600, `text-primary`). Timestamp '2 jam lalu' in Meta (Inter 13sp 500, `text-tertiary`). Trailing confidence '87%' in Confidence Metric (Inter 32sp 700 tabular), colored in the emotion's text-safe variant."

- "Create the Fem-Psychmonitor Emotion Trend Ring: a 96dp ring — `surface-3` track at 4dp stroke, a progress arc in the dominant emotion's base color at 4dp stroke, round cap, starting at -90°, animating from 0 over 600ms ease-out on first load. Centered: emotion label 'Sedih' in Card Title weight over confidence '72%' in Confidence Metric (Inter 32sp 700 tabular)."

- "Build the Fem-Psychmonitor Voice Capture Card: `surface-1` background, 18dp radius. Centered animated waveform bars gradient from `primary-400` (#E64258) to `primary-600` (#901324), bar height responding to input amplitude. A 64dp circular record button, `primary-500` fill, 3dp `on-primary` ring that pulses opacity 1→0.4→1 on a 1.2s loop while recording. Duration '00:42' in Inter 18sp 700 tabular below the waveform. Top-left 'MEREKAM' badge, `primary-500` fill, `on-primary` text, Inter 10sp 700 uppercase, 5dp radius, with a pulsing 6dp dot."

- "Render the Fem-Psychmonitor Weekly Emotion Summary Strip: 7 equal segments in a horizontal row, each a 6dp-radius bar, 28dp tall, filled with that day's dominant emotion base color (empty days use `surface-3`). Tapping a segment navigates to that day's entry in the history feed."

- "Build the Fem-Psychmonitor segmented trend filter (Minggu / Bulan / Tahun): track `surface-2`, pill shape. Selected segment gets a tonal fill — `primary-100` on light theme, a `primary-800`-tinted overlay on dark theme — with `primary-600`/`primary-300` text, Inter 13sp 600. This is a gently-lit tonal selection, not a stark inverted white chip."

- "Build the Fem-Psychmonitor primary button: full pill (999dp radius), `primary-500` background, `on-primary` Inter 15sp 600 text, 14dp × 24dp padding. Pressed: `primary-700` + scale 0.98. Provide a Jade secondary variant (transparent background, 1.5dp `secondary-500` border, `secondary-700`/`secondary-300` text) for 'Lihat Tren'."

### Iteration Guide
1. Canvas is a crisp near-white (`#FFF7F8`) in light mode or a deep crimson-black (`#1A0C0F`) in dark mode — never neutral gray or true black/white
2. Cherry (`#B4182D`) and Jade (`#25B15F`) are **co-equal** brand fills, both held at matched saturation — never treat one as "the accent" and the other as filler
3. Ramps are generated by **fixed hue/saturation, varying lightness only** — this is the "segar, tidak pias" fix; don't fall back to linear-to-white/black mixing for new tokens in this file
4. The six emotion colors are **fixed semantics** — never recolor per theme beyond the on-light/on-dark text-safe swap, and never reuse one as a generic UI accent
5. Success and Anger are **intentionally re-hued** away from Jade and Cherry — don't "simplify" them back to a more obvious green/red without re-checking the hue-collision math in §2.5–2.6
6. The **Emotion Trend Ring** is the hero, exactly like Peloton's output ring — thick colored arc, heavy tabular confidence number centered, fills from 0 on load
7. Numbers are **heavy and tabular** wherever they tick — confidence %, streak counts, recording timer
8. The **Voice Capture Card's** pulsing record-ring and the **Recording Indicator's** pulsing dot are this app's "heartbeat," the direct equivalent of Peloton's LIVE pulse
9. Selected states are **tonal** (gently lit), not inverted white chips — segmented controls and selected filter pills use a light tint fill, not a stark color-swap
10. Depth is **surface lightness + a soft shadow on light theme only**; dark theme never uses drop shadows on content