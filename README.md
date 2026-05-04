# Achilles HQ

A native **iOS** app for training and nutrition: daily dashboard, macro logging, workouts, and progress intel. Built with **SwiftUI** and **SwiftData** (local persistence).

## Features

- **HQ** — Today’s calories, macro rings, water, streaks, weight, and trends.
- **Fuel** — Day-by-day nutrition: meals, supplements, water, custom foods, macro targets.
- **Ops** — Log workouts from a catalog, track sets and volume, charts for the selected day.
- **Intel** — Profile and goals, weight history, macro adherence and workout frequency charts, export.

On first launch, onboarding collects profile basics before the main tab experience.

## Requirements

- **macOS** with **Xcode 15** or newer (project targets **iOS 17**)
- **Swift 5.9**
- Optional: **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** to regenerate the Xcode project from `project.yml`

## Getting started

```bash
git clone <your-repo-url>
cd achilles
```

### Generate the Xcode project

If you use XcodeGen:

```bash
xcodegen generate
```

Or use the Makefile (see below), which runs `xcodegen generate` before building.

### Firebase Crashlytics (optional)

The app loads Firebase only if `GoogleService-Info.plist` is present in the bundle. That file is **gitignored**; add your own from the [Firebase Console](https://console.firebase.google.com/) if you want Crashlytics. The app runs without it.

### Open in Xcode

```bash
open Achilles.xcodeproj
```

Select your development team for signing (**Signing & Capabilities**), then build and run on a simulator or device.

## Build from the command line

The included `Makefile` assumes a simulator named **iPhone 17 Pro** (adjust `SIM_NAME` in the Makefile if yours differs).

| Target    | Description                                      |
| --------- | ------------------------------------------------ |
| `make`    | Regenerate project with XcodeGen and build       |
| `make generate` | Run `xcodegen generate` only               |
| `make build`    | Generate + build for the simulator         |
| `make run`      | Build, install, and launch on the simulator |
| `make open`     | Generate and open the project in Xcode     |
| `make clean`    | Clean build artifacts                      |

Example:

```bash
make run
```

## Tests

Unit tests live under `AchillesTests`. Run them in Xcode (**Product → Test**) or:

```bash
xcodebuild test -project Achilles.xcodeproj -scheme Achilles \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Project layout

| Path            | Role                                      |
| --------------- | ----------------------------------------- |
| `Achilles/`     | App sources, resources, SwiftData models  |
| `AchillesTests/`| Unit tests                                |
| `project.yml`   | XcodeGen spec (targets, SwiftPM packages) |
| `Makefile`      | XcodeGen + `xcodebuild` shortcuts         |

**Dependencies** (Swift Package Manager, declared in `project.yml`): [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) (Crashlytics).

## License

Specify your license here (for example MIT, Apache-2.0, or “All rights reserved”).
