# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a native iOS mindfulness app built with SwiftUI and SwiftData. The app generates personalized meditation sessions using AI based on scientific psychological models (Circumplex Model of Affect, Cognitive Appraisal Theory, Polyvagal Theory).

## Common Development Commands

**Building and Running:**
```bash
# Open project in Xcode
open mindfulness.xcodeproj

# Build for simulator from command line
xcodebuild -project mindfulness.xcodeproj -scheme mindfulness -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -project mindfulness.xcodeproj -scheme mindfulness -destination 'platform=iOS Simulator,name=iPhone 16'
```

**Requirements:**
- Xcode 15.0+
- iOS 18.5+ deployment target
- No external dependencies (pure Swift/iOS frameworks)

## Architecture Overview

**Tech Stack:**
- SwiftUI for declarative UI
- SwiftData for local persistence 
- AVFoundation for text-to-speech
- Combine for reactive state management
- StoreKit for subscriptions
- UserNotifications for reminders

**Key Architecture Patterns:**
- MVVM with SwiftUI
- Centralized navigation coordinator in `ContentView.swift`
- Scientific psychology integration (8 emotions × 8 situations × 8 meditation types)
- AI-powered content generation in `MeditationAI.swift`

## Core Data Models

The app uses three main SwiftData models in `Item.swift`:

1. **MeditationSession**: Complete session tracking with AI-generated content
2. **UserProfile**: Progress tracking and personalization learning
3. **MoodEntry**: Before/after emotional state tracking

Key enums define the scientific categorization system:
- `EmotionCategory`: 8 emotions with valence/arousal classification
- `SituationCategory`: 8 life contexts
- `MeditationType`: 8 evidence-based meditation techniques

## User Flow Structure

**3-Step Meditation Creation:**
1. `EmotionSelectionView.swift` → emotion selection with circumplex model
2. `SituationInputView.swift` → life context input
3. `DurationSelectionView.swift` → time selection with AI recommendations

**Session Execution:**
- `MeditationSessionView.swift`: Audio player and meditation UI
- `MeditationCompletionView.swift`: Post-session reflection and mood tracking

## Key Implementation Details

**AI Content Generation:**
- Located in `MeditationAI.swift`
- Generates personalized scripts based on psychological frameworks
- 2-second average generation time for complete meditation content

**Navigation Pattern:**
- Single `NavigationView` in `ContentView` acts as coordinator
- State-driven UI transitions using `@State` and `@Environment`
- Full back navigation support throughout the flow

**Data Persistence:**
- SwiftData configured in `mindfulnessApp.swift`
- Reactive UI updates through `@Query` properties
- Offline-first architecture with no external API dependencies

## File Organization

- `mindfulnessApp.swift`: App entry point and SwiftData configuration
- `ContentView.swift`: Main dashboard and navigation coordinator  
- `MeditationAI.swift`: Core AI script generation engine
- `Item.swift`: All data models and scientific categorization enums
- View files follow descriptive naming: `*SelectionView.swift`, `*SessionView.swift`

## Testing Strategy

- Unit tests in `mindfulnessTests/`
- UI tests in `mindfulnessUITests/` 
- Physical device recommended for testing text-to-speech functionality
- Test meditation flow with all emotion/situation combinations