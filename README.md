# Quotey

An iOS app for capturing quotes with their context and learning them by heart.

## Capture

- Type or paste a quote directly.
- Scan text from a printed page with VisionKit's `DataScannerViewController`.
- Bulk-import a library from CSV or JSON.
- Share text from any app (Safari, Books, Notes, …) into Quotey via the Share Extension.

## Learn

Four practice modes, all driven off the same SwiftData store:

- **Spaced repetition** — SM-2 scheduler with an "easy / good / hard / again" grader.
- **Self-quiz** — the context is shown as a prompt; tap to reveal the quote.
- **Fill-in-the-blank** — random words are masked; tap a blank to reveal.
- **Recitation** — type the quote from memory; the app diffs your attempt against the original and scores it.

## Sync

SwiftData persistence with CloudKit sync over the user's private database, so your library follows you across iPhone, iPad, and Mac Catalyst.

## Build

Two ways to build and run, depending on the tools you have.

### Xcode (full app — recommended)

The Xcode project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open Quotey.xcodeproj
```

This is the only path that builds the Share Extension and the unit tests.

```sh
xcodebuild test \
  -scheme Quotey \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Swift Playgrounds (iPad or Mac)

A self-contained App Playground lives at `QuoteyPlayground.swiftpm/`. Double-click it on macOS or copy it to the Files app on iPad and open it in Swift Playgrounds.

It mirrors the full app **except**:

- No Share Extension (App Playgrounds can't host app extensions).
- No unit tests (run them from Xcode).
- No App Group fallback — the SwiftData store lives in the app's Application Support directory.

CloudKit sync works, but Swift Playgrounds does not declare iCloud via `Package.swift`, so enable it from the Playground's **Capabilities** panel after opening:

1. Tap the ⓘ button next to the run button.
2. Open **Capabilities**.
3. Turn on **iCloud → CloudKit** and set the container to `iCloud.com.quotey.playground` (or any ID you own).

The `.swiftpm` duplicates the source under `QuoteyPlayground.swiftpm/`. When you change a file under `Quotey/`, copy it over (or keep your edits in one place and sync the other after).
