# Quotey

An iOS app for capturing quotes with their context and learning them by heart. Built as a single Swift Playgrounds App Project so it opens without Xcode.

## Capture

- Type or paste a quote directly.
- Scan text from a printed page with VisionKit's `DataScannerViewController`.
- Bulk-import a library from CSV or JSON.

## Learn

Four practice modes, all driven off the same SwiftData store:

- **Spaced repetition** — SM-2 scheduler with an "easy / good / hard / again" grader.
- **Self-quiz** — the context is shown as a prompt; tap to reveal the quote.
- **Fill-in-the-blank** — random words are masked; tap a blank to reveal.
- **Recitation** — type the quote from memory; the app diffs your attempt against the original and scores it.

## Sync

SwiftData persistence with optional CloudKit sync over the user's private database, so your library follows you across iPhone, iPad, and Mac.

## Open it

### On Mac

```sh
git clone <this repo>
open Quotey/Quotey.swiftpm
```

Swift Playgrounds (free on the Mac App Store) launches and loads the project.

### On iPad

1. Clone the repo on your Mac.
2. Drop `Quotey.swiftpm` into iCloud Drive (or AirDrop it to the iPad).
3. In the Files app on iPad, tap `Quotey.swiftpm` — Swift Playgrounds opens it.

### Enable CloudKit sync (optional)

Camera and photo-library permissions are already declared in `Package.swift`. CloudKit has to be turned on in the Swift Playgrounds UI:

1. Tap the ⓘ button next to the run button.
2. Open **Capabilities**.
3. Turn on **iCloud → CloudKit**, container `iCloud.com.quotey.playground` (or replace with an ID you own).

Without CloudKit the app still works — data just stays on the current device.

## Layout

```
Quotey.swiftpm/
├── Package.swift             # iOS 17 app, camera + photo capabilities
├── QuoteyApp.swift           # @main, ModelContainer w/ CloudKit
├── Models/                   # Quote, Tag, ReviewLog (CloudKit-safe)
├── Services/                 # SRSScheduler, FillBlankGenerator, TextDiff, OCR, Import/Export
└── Features/
    ├── Library/              # list, detail, editor
    ├── Capture/              # DataScanner + CSV/JSON importer
    ├── Study/                # SRS + self-quiz + fill-blank + recitation
    └── Settings/             # library stats, JSON export
```
