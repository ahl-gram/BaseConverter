# BaseConverterApp

Native iOS app (SwiftUI) that converts integers live across five bases at once: binary, octal, decimal, duodecimal, and hexadecimal. Ships as **"Base Convert"**, App Store `id6743086704`, Route 12B Software.

Base 12 with Dozenal-style `X` (10) and `E` (11) digits is the app's distinguishing feature, and most converters skip it entirely.

## MANDATORY: load the Liquid Glass skill before UI work

**Invoke the `liquid-glass-design` skill before writing or modifying any UI in this project.**

**Migration in flight:** this app is moving to an iOS 26 deployment target and the Liquid Glass idiom, matching its sibling PrimeFinder (issue #12, item 4). Bumping `IPHONEOS_DEPLOYMENT_TARGET` in the pbxproj is the first step and may not have landed yet, so check the pbxproj before emitting `.glassEffect`, `GlassEffectContainer`, or `.buttonStyle(.glass)`, since those require iOS 26 and will not compile against the old target.

The app currently has **no animations at all** (`withAnimation`, `.animation(`, `.transition(` appear nowhere). Glass adoption is the natural moment to add motion; treat it as a deliberate design pass, not a find-and-replace.

## Repo layout

Flattened on 2026-08-10 to mirror PrimeFinder exactly. A redundant nested `BaseConverterApp/` level used to sit between the git root and the Xcode project; it is gone. The structure is now:

```
~/CodeProjects/BaseConverter/          <- NOT the git root; project_plan.md sits here, untracked
└── BaseConverterApp/                  <- git root (README.md, CLAUDE.md, .gitignore)
    ├── BaseConverterApp.xcodeproj
    ├── BaseConverterApp/              <- Swift sources
    ├── BaseConverterAppTests/
    └── BaseConverterAppUITests/
```

Any older path reference of the form `BaseConverterApp/BaseConverterApp/BaseConverterApp.xcodeproj` predates the flattening and is stale.

`project_plan.md` is a large pre-implementation spec that lives **outside** the git root and is therefore untracked. It describes features that were planned and dropped, so do not treat it as a description of the shipped app.

## Tech stack

- Swift + SwiftUI. **Zero external dependencies**: no SPM, CocoaPods, or Carthage.
- No StoreKit, IAP, ads, analytics, networking, or persistence. Every launch starts empty.
- iPhone-only, portrait-only.
- Deployment target, Swift version, and version/build numbers live in the pbxproj. Read them there rather than trusting docs. Note the app target and the project-level default differ.
- `objectVersion = 77` (file-system-synchronized project). New Swift files need no pbxproj entry.

## Architecture

Hand-rolled MVVM. All files sit in one flat directory despite the MVVM naming.

- `BaseConverterApp.swift`: `@main`, WindowGroup
- `ContentView.swift`: root layout and keypad tap dispatch
- `BaseConverterViewModel.swift`: `ObservableObject`, Combine, one published field per base
- `BaseConverter.swift`: pure static conversion functions and the error enum
- `BaseInputField.swift`: field view plus `BaseInputStyle`, `BaseTheme`, and the `BaseField` enum
- `CustomKeyboard.swift`: the custom keypad and `KeyButton`
- `CustomKeyboardTextField.swift`: `UIViewRepresentable` wrapper that suppresses the system keyboard
- `AboutView.swift`: modal About sheet

### The custom keypad is the app's identity

The system keyboard cannot type hex `A-F` or duodecimal `X`/`E`, so every field is a `UITextField` with `inputView = UIView()`. This kills the system keyboard while keeping the caret, and the on-screen keypad drives all input. Keys recolor to the focused base's theme color and invalid digits dim to 30% and disable. Preserve this behavior in any input change.

`BaseTheme` assigns one color per base (binary blue, octal yellow, decimal green, duodecimal purple, hex orange) and it is carried consistently through the field label, the field's border and glow, and the keypad keys.

## Gotchas

- **Two visually identical `E` keys exist** (`E_DUO` and `E_HEX`), distinguished internally so each lights up only for its own base. Do not "deduplicate" them.
- **The ViewModel cleans input in `didSet` observers and re-dispatches via `DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)` to avoid infinite recursion** (`BaseConverterViewModel.swift`, two sites). This guard is timing-based rather than structural: it is fragile, and any refactor of field-update flow must account for it.
- **Error message text is never shown on screen.** Sighted users see only a red triangle icon; the message exists solely as an `accessibilityLabel`. VoiceOver users get strictly more information than sighted users.
- **No clipboard support anywhere**: `UIPasteboard` is entirely absent, so results can only leave the app by retyping. Tracked in issue #12.
- **`ContentView.handleKeyTap` is a long five-way copy-pasted switch**, one branch per base. It should collapse to a keypath or subscript.
- The layout splits the screen 50% fields / 55% keypad and compensates with a negative top padding, a hand-tuned fit that will fight you if you change proportions.
- Values are clamped to ±1,000,000,000,000; over-range digits silently refuse to type rather than showing an error.
- README claims arithmetic operations (add/subtract/multiply/divide) that **do not exist**. The only trace is a `divisionByZero` error case that is never thrown.

## Building & testing

- Open `BaseConverterApp.xcodeproj` at the git root in Xcode. Build Cmd+B, test Cmd+U, or `xcodebuild` / `xcodebuild test`.
- Run the suite from the CLI against an iOS 26 simulator: `xcodebuild test -project BaseConverterApp.xcodeproj -scheme BaseConverterApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'`.
- If `xcodebuild` ever reports `CoreSimulator is out of date`, simulator support is disabled entirely and no tests can run. The compile-only fallback is `-destination 'generic/platform=iOS' build CODE_SIGNING_ALLOWED=NO`, which verifies compilation but not behavior.
- XCTest, not Swift Testing. Logic coverage is solid; UI tests are boilerplate launch tests only.

## Related projects

Sibling app **PrimeFinder** (`~/CodeProjects/PrimeFinder`, `github.com/ahl-gram/PrimeNumberFinder`). The two ship as a Route 12B family rather than merging. The agreed cross-pollination plan and the housekeeping backlog for both apps live in **PrimeNumberFinder issue #12**.

## Conventions

- Accessibility is unusually thorough here: every key, field, and toolbar button has a label and a context-aware hint. Maintain that standard in new UI.
- Haptics on every key press (`UIImpactFeedbackGenerator`); keep them.
- Conversion math stays in `BaseConverter.swift`, out of the views.
