# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SoundFlow** is a procedural real-time audio synthesis app for sleep, focus, and relaxation. All sounds are generated on-device using AVAudioEngine — no pre-recorded audio loops, no backend, no network (except optional WeatherKit). Users compose soundscapes by layering multiple generators (rain, wind, ocean, etc.) with individual volume/parameter control.

## Build & Test Commands

```bash
# Build for iOS Simulator (requires Xcode 26+)
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -project SoundFlow.xcodeproj -scheme SoundFlow -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run unit tests
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -project SoundFlow.xcodeproj -scheme SoundFlow -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Run a single test (Swift Testing framework)
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -project SoundFlow.xcodeproj -scheme SoundFlow -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test -only-testing:SoundFlowTests/TestClassName/testMethodName
```

Note: `xcode-select` points to CommandLineTools, so use the full Xcode path for `xcodebuild`.

## Architecture

### Pattern: MVVM + Audio Engine Singleton

- **Models** (`SoundFlow/Models/`): Pure data types — `SoundScene`, `SoundLayer`, `Preset`, `SleepSession`, `GeneratorType` enum. Persistence via SwiftData (on-device only). Note: `Scene` is renamed to `SoundScene` to avoid conflict with SwiftUI's `Scene` protocol. `SubscriptionStatus` is renamed to `AppSubscriptionStatus` to avoid conflict with StoreKit's type.
- **Views** (`SoundFlow/Views/`): SwiftUI views organized by feature area (Main, Scenes, Settings, Stats, Onboarding, Components).
- **State**: `AppState` uses `@Observable` macro. Injected via `.environment()` — use `@Environment(AppState.self)` in views, not `@EnvironmentObject`.
- **Audio Engine** (`SoundFlow/Audio/`): Singleton `AudioEngine` owns the `AVAudioEngine` instance. All audio flows through `AudioMixer` which manages multi-layer mixing with crossfade. Also uses `@Observable`.

### Observation Pattern

All state classes (`AppState`, `AudioEngine`, `StoreManager`, `TimerManager`, `AlarmManager`) use Swift's `@Observable` macro with `@MainActor`. Inject via `.environment()` in the view hierarchy, consume via `@Environment(TypeName.self)` in views. Do NOT use `ObservableObject`/`@Published`/`@StateObject`/`@EnvironmentObject`.

### Audio Pipeline

```
Generator (protocol) → Effects (Reverb/EQ/Pan/Fade) → AudioMixer → AVAudioEngine.mainMixerNode → Output
```

Each sound type implements `GeneratorProtocol` and fills audio buffers procedurally. Generators use DSP techniques:
- **Noise**: White/pink/brown via spectral shaping
- **Rain**: Filtered noise + stochastic raindrop events (uses seed sample as impulse)
- **Waves**: LFO-modulated filtered noise for ocean surge
- **Birds**: FM synthesis with randomized chirp patterns
- **Fire**: Granular synthesis from seed crackle samples
- **Binaural**: Two sine oscillators with configurable frequency offset

Seed samples in `Resources/Seeds/` are minimal impulses (< 500 KB total) used as synthesis building blocks, not loops.

### Services Layer

- `StoreManager`: StoreKit 2 subscription handling
- `HealthManager`: HealthKit integration (heart rate, sleep data)
- `TimerManager`: Sleep timer with background audio continuation
- `AlarmManager`: Wake alarm with fade-in
- `SessionTracker`: Usage statistics persisted via SwiftData
- `PresetManager`: Save/load user sound presets
- `HapticsManager`: Haptic feedback

### Targets

| Target | Purpose |
|--------|---------|
| SoundFlow | Main iOS app |
| SoundFlowTests | Unit tests (Swift Testing framework) |
| SoundFlowUITests | UI tests (XCTest) |

Watch, Widget, and Live Activity targets are planned but not yet added to the Xcode project.

### Key Design Decisions

- **No audio files as loops** — all sound is synthesized or granularly constructed from tiny seed samples. This keeps the app bundle small and allows infinite non-repeating audio.
- **`AdaptiveController`** adjusts generator parameters based on external inputs (time of day, HealthKit heart rate, etc.).
- **Premium gating**: Free tier gets a subset of scenes/generators. Premium unlocks all generators, custom mixing, and advanced features. Use `AppSubscriptionStatus` enum to check access.
- **Background audio**: The app must maintain audio playback in background. Timer fade-outs happen while backgrounded.

## Conventions

- **Language**: Swift 6, SwiftUI for all UI
- **Minimum deployments**: iOS 26.2 (Xcode 26 beta)
- **Persistence**: SwiftData only (no Core Data, no UserDefaults for model data)
- **Concurrency**: Use Swift concurrency (async/await, actors). `@MainActor` on all state/service classes. Audio engine runs on its own dispatch queue.
- **Observation**: Use `@Observable` macro, NOT `ObservableObject`
- **Localization**: Use String Catalogs (`.xcstrings`)
- **No third-party dependencies**: Everything is built with Apple frameworks only
