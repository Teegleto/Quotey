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

The Xcode project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen generate
open Quotey.xcodeproj
```

### Tests

```sh
xcodebuild test \
  -scheme Quotey \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```
