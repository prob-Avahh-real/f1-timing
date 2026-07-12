# F1 Timing

An F1 race timing app built with SwiftUI, featuring live timing data, Widgets, and Live Activities.

## Features
- Real-time F1 timing data via WebSocket
- Driver position tracking with sector colors
- Session schedule management
- Live Activity support for lock screen
- Widget for home screen quick glance

## Architecture
- MVVM pattern with `@Observable` view models
- `TimingDataSource` protocol for testable data sources
- SwiftUI with dark mode optimized UI

## Requirements
- iOS 17.0+
- Xcode 15.0+

## Setup
```bash
brew install xcodegen
xcodegen generate
open *.xcodeproj
```
