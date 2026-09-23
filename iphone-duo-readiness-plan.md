# GamebookEngine — iPhone Duo Readiness Plan

Date: September 19, 2026
Status: Plan / proposal — not yet implemented

## 1. Context

### What the iPhone Duo is

Apple announced the **iPhone Duo** on September 9, 2026 — its first foldable iPhone. It ships on **iOS 27.1**, with pre-orders on **October 16** and availability on **October 23**.

Hardware that affects us:

| Feature | Detail |
|---|---|
| Outer display | 5.4" Super Retina XDR, ≈ **466 × 678 pt** (portrait) — compact-width, behaves like a standard iPhone |
| Inner display | 7.6" Super Retina XDR (folding/nano-texture), ≈ **669 × 951 pt** portrait / **951 × 669 pt** landscape — **regular width in both dimensions**, i.e. "iPad-shaped" |
| Poses | Closed / open-flat / partially folded like a book / propped in tent mode; the app is resized live as the device opens and closes |
| Multitasking | Split View for the first time on iPhone; apps run side-by-side and resize on the fly |
| Biometrics | Touch ID in the side button only (no Face ID) — not currently used by the app, no action |
| Input | Apple Pencil (USB-C) support coming later this year — not in core scope |

Behaviors that matter to developers:

- The app **resizes at runtime** — there is no longer a single fixed geometry per device.
- **`UIScreen.main` is being deprecated** — there are two displays, and the reference is ambiguous.
- **Safe area insets are asymmetric** — left/right insets frequently differ (camera, Split View halves, vertical bars).
- System navigation/toolbar controls lay out **vertically under the status bar** when the app is built against the iOS 27.1 SDK.
- New APIs: reserved regions (hinge fold + under-display camera), arrangement views (split/overlay layouts), hinge-angle interaction.

### Compatibility tiers (why "rebuild" is step zero)

| Built with | Inner-display behavior |
|---|---|
| Older SDK (no rebuild) | Runs, but **letterboxed** — old aspect ratio with bars each side |
| iOS 27 SDK | Extends full width, avoids camera area |
| **iOS 27.1 SDK** | **Full edge-to-edge**, standard nav/toolbar buttons lay out vertically |

Rebuilding with Xcode 27.1 / the iOS 27.1 SDK alone moves the app from "obviously not updated" to "fine." The rest of this plan is the difference between "fine" and "good."

### References — Apple sources

- Press release: [Apple unveils iPhone Duo](https://www.apple.com/newsroom/2026/09/apple-unveils-iphone-duo)
- [iPhone Duo technical specifications](https://www.apple.com/iphone-duo/specs)
- [Get ready for iPhone Duo (developer page)](https://developer.apple.com/iphone-duo)
- HIG: [Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)
- Dev doc: [Preparing your app for iPhone Duo](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo)
- [iOS & iPadOS 27 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes)
- Tech talks:
  - [Prepare your app for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111461)
  - [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466)
  - [Strike a pose with adaptive layouts on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463)
  - [Leverage multiple displays and scenes on iPhone Duo](https://iphoneduo.dev/) (full session list indexed here)

### References — community analysis

- [iPhone Duo Developer Hub](https://iphoneduo.dev/) — written notes for every official session
- [Prepare Your App for iPhone Duo — notes](https://iphoneduo.dev/blog/01-prepare-your-app-for-iphone-duo)
- [blakecrosley.com: iPhone Duo for Developers](https://blakecrosley.com/blog/iphone-duo-for-developers)
- [dev.to: What Actually Changes in Your Swift Code (checklist)](https://dev.to/arshtechpro/iphone-duo-for-ios-developers-what-actually-changes-in-your-swift-code-5gc5)

## 2. Scope and decisions

Agreed scope for this effort:

1. **Render correctly** on both displays and across all poses (closed portrait, closed landscape, open vertical, open horizontal, Split View halves).
2. **Adapt layouts** to the wide (regular-width) inner display — two-column/split layouts where content benefits.
3. **Keep the deployment target at iOS 13.6** and gate all new APIs behind `#available(iOS 27.1, *)`.
4. Core readiness only — explicitly **excluded** from this pass: Apple Pencil support, lock-screen widget, App Store Connect Duo screenshots/assets, webplayer changes.

## 3. Current-state findings

| Area | Current behavior | File reference | Duo implication |
|---|---|---|---|
| Window lifecycle | `AppDelegate` builds `UIWindow(frame: UIScreen.main.bounds)`, no scene lifecycle, no `UIApplicationSceneManifest` | `GamebookEngine/AppDelegate.swift:26-31` | Screen reference ambiguous/deprecated; window won't track scene geometry on resize/Split View |
| SpriteKit canvas | `view = SKView(frame: UIScreen.main.bounds)` created once in `viewDidLoad`, scene `scaleMode = .aspectFill` | `GamebookEngine/Views/Editing/Game Overview/GameOverviewViewController.swift:24-27` | Frame taken at load; not rebuilt when the viewport changes (open/close/rotate/Split View) |
| Rasterization | `ContainerView` rasterizes at `UIScreen.main.scale` | `ContainerView.swift` | `UIScreen.main` deprecated; must use trait display scale |
| Orientation | iPhone **portrait only** in Info.plist; iPad all four | `GamebookEngine/Info.plist:63-73` | Inner display is iPad-shaped; portrait-only feels wrong when open and conflicts with split-view habits |
| Size classes | No size-class branching in code; only 4 size-class constraints in PlayViewController.xib | `GamebookEngine/Views/Playing/PlayViewController.xib:133-147` | No mechanism to take advantage of regular width on the inner display |
| Content columns | Game list and play screens center at max-width ~600 pt | `Game list` XIBs (constraints `width <= 600`), Play XIB (600/575) | Wastes the ~669 pt-wide inner display; no wide/regular layout |
| Fixed cell heights | GameList 337, DecisionEditorRule 168, PageTableViewCell 186, Attribute 90, etc. | Various XIBs | Fixed heights look sparse/unbalanced at regular width |
| Custom overlay control | Search button pinned to top safe area (top-right) | `GameOverviewViewController.swift:62-67` | On Duo, system bars lay out vertically; uncovered button can collide with system controls |
| Safe area / notch | Content inside XIB safe areas; no hardcoded notch constants | n/a | Insets become asymmetric on Duo (only the "iPad-shaped" constraints exist) |
| Device checks | Only `UIDevice.current.userInterfaceIdiom == .phone` checks in IntroductionView | `GamebookEngine/Views/Introduction/IntroductionView.swift:78,129` | `interfaceOrientation`/`UIDevice.orientation` are unreliable on Duo; prefer size classes |
| Preview extension | QuickLook extension, portrait-oriented storyboard, device family 1,2 | `GamebookPreviewExtension/` | Verify on both displays; likely no code change needed |

## 4. Phased change plan

### Phase 0 — Tooling and test baseline

1. Install **Xcode 27.1 beta** (first beta expected late September 2026) and its bundled **iOS 27.1 SDK**.
2. Add the **iPhone Duo Simulator** runtime and use **Device Hub** (in Xcode 27.1) to preview the app in every pose — open, close, rotate, fold controls.
3. Define a test matrix using the point shapes implied by App Store Connect dimensions, plus Split View halving:
   - 466 × 678 — outer display, portrait (compact)
   - 669 × 951 — inner display, portrait (regular)
   - 951 × 669 — inner display, landscape (regular)
   - ~half-width split panes on the inner display (asymmetric insets)
4. Confirm Swift toolchain: project is Swift 5.0 language mode (keep it; do not absorb the Swift 6 migration into this work).

### Phase 1 — Resizability fundamentals (all screens)

1. **Eliminate `UIScreen.main` across the project** (grep `UIScreen`):
   - `AppDelegate.swift` — obtain screen/bounds from the scene or view geometry instead.
   - `GameOverviewViewController.swift:24` — create `SKView` from `view.bounds` and rebuild on size/trait changes (see Phase 2).
   - `ContainerView.swift` — use `traitCollection.displayScale` for rasterization.
2. **Replace orientation-based logic with size-class logic** everywhere:
   - UIKit: `traitCollection.horizontalSizeClass` via `traitCollectionDidChange(_:)`.
   - SwiftUI: `@Environment(\.horizontalSizeClass)` / `verticalSizeClass`.
   - Avoid `UIDevice.orientation` / `interfaceOrientation` for layout decisions (it lies on Duo).
3. **Treat safe-area insets per-edge** — never assume left == right (e.g. replace `usableWidth = width - insets.left * 2` with `bounds.inset(by: safeAreaInsets)`).
4. **Review fixed cell heights** (GameList 337, DecisionEditorRule 168, PageTableViewCell 186, Attribute 90) — prefer self-sizing or size-class variants so rows feel appropriate at regular width.
5. **Validate every XIB screen + LaunchScreen.storyboard** in all four poses; fix anything that overflows, underfills, or jumps on resize.

Guide: dev.to checklist ([Change 1–4](https://dev.to/arshtechpro/iphone-duo-for-ios-developers-what-actually-changes-in-your-swift-code-5gc5)), [Prepare your app tech talk](https://developer.apple.com/videos/play/tech-talks/111461).

### Phase 2 — Scene-based lifecycle

1. Add `UIApplicationSceneManifest` to `Info.plist` and introduce a `UIWindowSceneDelegate` (
   SceneDelegate) that:
   - Creates the window from `windowScene.windows.first` geometry rather than `UIScreen.main.bounds`.
   - Sizes the layout from `window.width` / the scene's bounds.
2. In `GameOverviewViewController`, rebuild the SpriteKit `SKView`/scene on size changes (`viewWillTransition(to:with:)`, trait changes, or scene `didUpdate`), so the map canvas tracks the live viewport.
3. Benefit: correct resizing on open/close, Split View halving, and the future path to multiple scenes/windows (new windows only creatable on the inner display).

Guide: [Leverage multiple displays and scenes on iPhone Duo](https://iphoneduo.dev/); avoid `interfaceOrientation` and main-screen references.

### Phase 3 — Adaptive wide layouts (regular size class)

Goal: on `horizontalSizeClass == .regular`, use the extra room; on compact width, keep today's behavior. Keep everything behind `#available(iOS 27.1, *)` with sensible fallbacks on older devices / compact width.

1. **Game list** — switch from a single centered 600pt table to a **two-column layout** of game cards on regular width (collection or multi-column table). Keep the compact single-column for the outer display.
2. **Play screen (reader)** — on regular width, present **story text and decisions side-by-side** (split arrangement) instead of a single vertical scroll; keep the vertical stacked layout on compact width. Use `ArrangementView` (SwiftUI) / `UIArrangementViewController` (UIKit) with a `.split` style, constrained to horizontal axis (`axes(.horizontal)`).
   - This is a main/detail relationship → **split style**, not overlay.
   - The existing 4 size-class constraints in `PlayViewController.xib` are the starting point; extend from there.
3. **Editor** — on regular width, show **page list + SpriteKit canvas** (or canvas + inspector) in a split arrangement, mirroring the iPad feel; keep today's push-navigation flow on compact.
4. **Center max-width caps** — raise the 600pt caps on regular width (e.g. keep readability-focused constraints but let them scale) so text edge-to-edge isn't required and columns don't over-extend.

Guide: [Strike a pose with adaptive layouts on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463) (arrangement views), [HIG: Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo).

### Phase 4 — Fold / hinge safety (reserved regions)

1. Query **reserved regions** for custom, hand-placed controls:
   - UIKit: `view.reservedRegions(kind: .division)` (the fold) and `.occlusion` (under-display camera).
   - SwiftUI: `proxy.reservedRegions(kind:)` on the geometry proxy.
   - Reposition the SpriteKit overlay **search button** (`GameOverviewViewController.swift:62-67`) and any custom decision controls so they never sit on the hinge or collide with the vertical system controls.
2. **Do not displace continuously-scrolling content** (the reader's scroll of story text) to avoid the fold — displacement is for discrete controls only.
3. Standard containers (nav stack, split view, tab, list, scroll, sheets, alerts, menus, popovers) already adapt to the fold automatically — no work needed there.

Guide: [Reserved regions and fold avoidance](https://iphoneduo.dev/blog/01-prepare-your-app-for-iphone-duo) and the dev.to [Change #4](https://dev.to/arshtechpro/iphone-duo-for-ios-developers-what-actually-changes-in-your-swift-code-5gc5).

### Phase 5 — Orientation and launch experience

1. **Orientations:** keep the Info.plist iPhone default of portrait (applies to the closed/outer display and classic iPhones), but override at runtime via `supportedInterfaceOrientations` on view controllers to allow **all orientations when `traitCollection.horizontalSizeClass == .regular`** (i.e. the open inner display / Split View halves), so reading and editing work in landscape when open.
   - Rebuild with the iOS 27.1 SDK so the inner display is edge-to-edge with vertical system bars (Info.plist alone can't distinguish Duo-open from a classic iPhone).
   - `UIRequiresFullScreen` continues to be honored by Duo, but the app will still resize on open/close.
2. **LaunchScreen.storyboard** — build/verify at all target sizes and orientations; it currently carries the whole launch experience.

## 5. Test plan

| Check | Detail |
|---|---|
| Pose × orientation matrix | Outer 466×678 · Inner 669×951 · Inner 951×669 · all four rotate/pose states via Device Hub |
| Split View | App at half-width on the inner display, verify vertical bars + asymmetric insets |
| Live resize | Open/close the device mid-session while reading and while editing; no jump, no clipped content |
| Screens | Game list, Play reader, all editors (text/markdown/attribute/decision/page/meta), game overview SpriteKit canvas |
| QuickLook extension | Verify `GamebookPreviewExtension` renders on both displays |
| Custom controls | Search button + decision controls avoid hinge/vertical system controls (Phase 4) |
| Regression | Existing iPhones (all supported) and iPads unchanged on compact-width paths |

## 6. Risks and open questions

- **Xcode 27.1 beta timing**: Apple's own "Preparing your app for iPhone Duo" guide and the Xcode 27.1 beta were marked "coming later this month" as of the Sept 9 announcement. Phase 0 should not block Phase 1 (most of Phase 1 is SDK-agnostic hygiene).
- **API verification**: the exact shapes of `reservedRegions` / `UIReservedRegion`, `ArrangementView` / `UIArrangementViewController`, and their `#available` signatures must be confirmed against the real iOS 27.1 SDK before coding Phase 3/4.
- **Editing-flow orientation**: the editors are currently tuned to portrait scrolling flows; opening them on the regular-width inner display may need more than resize — budget time for layout round-trips.
- **Device detection**: prefer size classes over device checks (e.g. `introductionView` phone checks) so behavior is driven by available space, not ambiguity about which display is active.

## 7. Reference links

Apple:
- [HIG: Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)
- [Preparing your app for iPhone Duo (dev doc)](https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo)
- [Get ready for iPhone Duo](https://developer.apple.com/iphone-duo)
- [iOS & iPadOS 27 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes)
- Tech talks: [Prepare your app](https://developer.apple.com/videos/play/tech-talks/111461) · [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466) · [Strike a pose: adaptive layouts](https://developer.apple.com/videos/play/tech-talks/111463) — full session index at [iphoneduo.dev](https://iphoneduo.dev/)
- Apple pages: [iPhone Duo announcement](https://www.apple.com/newsroom/2026/09/apple-unveils-iphone-duo) · [Technical specifications](https://www.apple.com/iphone-duo/specs)

Community:
- [iPhone Duo Developer Hub](https://iphoneduo.dev/)
- [Prepare Your App for iPhone Duo — notes](https://iphoneduo.dev/blog/01-prepare-your-app-for-iphone-duo)
- [blakecrosley.com: iPhone Duo for Developers](https://blakecrosley.com/blog/iphone-duo-for-developers)
- [dev.to: What Actually Changes in Your Swift Code](https://dev.to/arshtechpro/iphone-duo-for-ios-developers-what-actually-changes-in-your-swift-code-5gc5)