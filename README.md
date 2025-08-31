# Mindfulness - AI-Powered Guided Meditation App

A sophisticated iOS meditation app that uses artificial intelligence to create personalized guided meditation experiences based on scientific psychological frameworks.

## 🧠 Overview

This SwiftUI app provides AI-generated guided meditations tailored to the user's current emotional state, life situation, and available time. The app implements evidence-based psychological models to match users with the most effective meditation techniques.

## 🔬 Scientific Framework

The app is built on three core psychological models:

### 1. Circumplex Model of Affect
- Categorizes emotions by **valence** (pleasant/unpleasant) and **arousal** (high/low energy)
- Ensures meditation techniques are matched appropriately:
  - High-arousal negative emotions (anxiety, anger) → calming practices
  - Low-arousal negative emotions (sadness, fatigue) → energizing or compassion-focused meditations

### 2. Cognitive Appraisal Theory
- Considers situational context to determine coping strategy:
  - **Problem-focused coping** for actionable situations → action-oriented meditations
  - **Emotion-focused coping** for unchangeable situations → acceptance-based meditations

### 3. Polyvagal Theory
- Matches meditation techniques to nervous system states:
  - Stressed users → parasympathetic activation (breathing, body scans)
  - Disconnected users → grounding techniques first

## 📱 App Architecture

### Core Data Models (`MeditationModels.swift`)
- **EmotionCategory**: 8 scientifically-based emotions with valence/arousal classification
- **SituationCategory**: 8 life contexts (work, relationships, health, etc.)
- **MeditationType**: 8 meditation techniques matched to psychological needs
- **MeditationSession**: Complete session tracking with AI-generated content
- **UserProfile**: Progress tracking and personalization learning
- **MoodEntry**: Before/after emotional state tracking

### Key Components

#### 1. Emotion Selection (`EmotionSelectionView.swift`)
- Visual emotion wheel with color-coded categories
- Intensity slider (1-10 scale)
- Based on Circumplex Model implementation

#### 2. Situation Input (`SituationInputView.swift`)
- 8 life situation categories with intuitive icons
- Optional custom description field
- Skip option for users in emotional distress

#### 3. Duration Selection (`DurationSelectionView.swift`)
- AI-powered duration recommendations based on emotional state
- Visual timer interface with preset (3-60 min) and custom options
- Smart suggestions considering emotion intensity and situation

#### 4. AI Meditation Engine (`MeditationAI.swift`)
- **Sophisticated script generation** using psychological principles
- **8 meditation types**:
  - Breathwork (4-7-8 breathing, box breathing)
  - Body scan (systematic relaxation)
  - Loving-kindness (compassion cultivation)
  - Mindfulness (present-moment awareness)
  - Sleep stories (rest preparation)
  - Progressive muscle relaxation (tension release)
  - Guided imagery (peaceful visualization)
  - Self-compassion (self-kindness practices)
- **Contextually aware content** adapted to user's specific situation

#### 5. Meditation Session Player (`MeditationSessionView.swift`)
- Real-time text-to-speech synthesis with meditation-optimized settings
- Beautiful circular progress timer with dynamic backgrounds
- Audio controls (play/pause/stop) with iOS-standard behavior
- Loading screen with animated meditation preparation

#### 6. Post-Meditation Reflection (`MeditationCompletionView.swift`)
- 5-star effectiveness rating system
- Before/after mood comparison with visual indicators
- Optional journaling with guided prompts
- Progress celebration and streak building

#### 7. Progress Dashboard (`ContentView.swift`)
- Meditation streak calculation with daily tracking
- Session history with visual emotion journey mapping
- Statistical overview (sessions, total minutes, streaks)
- Personalized recommendations based on user preferences
- Settings button integration for easy access to account management

#### 8. Settings & Account Management (`SettingsView.swift`)
- **User Profile**: Visual profile with subscription status display
- **Subscription Management**: Pro subscription handling and App Store integration
- **Dark/Light Mode**: Complete theme switching with automatic, light, and dark options
- **Notification Settings**: Meditation reminders with customizable times and streak alerts
- **Account Deletion**: Apple-required account deletion with data export options
- **Support & Legal**: Privacy policy, terms of service, help contact, and app reviews
- **App Information**: Version details and build information

## 🎨 User Experience Design

### Flow Optimization
- **Under 30-second setup**: From app open to meditation start
- **3-step process**: Emotion → Situation → Duration → Session
- **Back navigation**: Full ability to revise choices with smooth animations
- **Progress indicators**: Visual dots and step numbers (1/3, 2/3, 3/3)
- **Skip options**: Respects users in emotional distress

### Visual Design
- **Color psychology**: Emotions mapped to appropriate colors and gradients
- **Calming aesthetics**: Soft gradients, rounded corners, gentle animations
- **Accessibility ready**: VoiceOver compatible, scalable text, high contrast options
- **Platform consistency**: iOS Human Interface Guidelines compliance

## 🛠 Technical Implementation

### Technologies Used
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Core Data replacement for persistent storage
- **AVFoundation**: Text-to-speech synthesis with custom voice settings
- **Combine**: Reactive programming for state management

### Key Features
- **Offline functionality**: Works without internet after initial setup
- **Persistent storage**: User progress and preferences saved locally
- **Background audio**: Continues playing when app is backgrounded
- **Memory efficient**: Optimized for long meditation sessions

### File Structure
```
mindfulness/
├── MeditationModels.swift          # Core data models and enums
├── EmotionSelectionView.swift      # Emotion selection interface
├── SituationInputView.swift        # Context input screen
├── DurationSelectionView.swift     # Time selection with recommendations
├── MeditationAI.swift             # AI script generation engine
├── MeditationSessionView.swift     # Audio player and session UI
├── MeditationCompletionView.swift  # Post-session reflection
├── SettingsView.swift             # Settings and account management
├── ContentView.swift              # Main dashboard and flow coordination
├── mindfulnessApp.swift           # App entry point and data setup
└── Assets.xcassets               # App icons and visual assets
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 18.5+ deployment target
- iPhone/iPad simulator or physical device

### Building the Project
```bash
# Clone and navigate to project
cd mindfulness

# Build for simulator
xcodebuild -project mindfulness.xcodeproj -scheme mindfulness -destination 'platform=iOS Simulator,name=iPhone 16' build

# Or open in Xcode
open mindfulness.xcodeproj
```

### Running the App
1. Select iPhone/iPad simulator or connected device
2. Press ⌘R or click the Play button in Xcode
3. The app will launch with the main dashboard

## 📊 User Flow

### Main Flow
1. **Dashboard**: View progress, stats, and start new meditation
2. **Emotion Selection**: Choose current emotional state (8 options) with intensity
3. **Situation Context** (optional): Select life situation or skip
4. **Duration Choice**: AI recommends optimal time, user can customize
5. **AI Processing**: 2-second generation of personalized meditation script
6. **Meditation Session**: Text-to-speech guided meditation with timer
7. **Completion Reflection**: Rate session, check mood shift, optional notes
8. **Progress Update**: Stats updated, streaks calculated, preferences learned

### Settings Flow
1. **Access**: Tap gear icon on dashboard to open settings
2. **Profile Management**: View subscription status and account details
3. **Theme Selection**: Choose between light, dark, or automatic appearance
4. **Notifications**: Configure meditation reminders and streak alerts
5. **Subscription**: Manage Pro subscription or upgrade from free plan
6. **Account Actions**: Export data, delete account, or contact support
7. **Legal**: Access privacy policy, terms of service, and app review options

## 🔧 Customization & Extensions

### Adding New Emotions
1. Add case to `EmotionCategory` enum
2. Define valence/arousal properties
3. Add corresponding icon and color in UI components
4. Update AI logic in `MeditationAI.swift`

### Adding New Meditation Types
1. Add case to `MeditationType` enum
2. Implement content generation in `createCoreContent()`
3. Add type-specific UI styling
4. Update recommendation logic in `determineMeditationType()`

### Extending AI Capabilities
- The `MeditationAI` class can be enhanced with:
  - Integration with ChatGPT/Claude APIs for dynamic content
  - Machine learning models for personalization
  - Voice cloning for consistent narrator experience
  - Real-time biometric integration (Apple Watch)

## 🧪 Testing

### Manual Testing Checklist
- [ ] Emotion selection with all 8 categories
- [ ] Back navigation through all steps
- [ ] Text-to-speech functionality
- [ ] Timer accuracy and controls
- [ ] Data persistence across app launches
- [ ] Progress tracking and streak calculation

### Known Issues
- Minor Swift warnings for optional string interpolation in debug prints
- Text-to-speech requires iOS simulator or device (won't work in Xcode previews)

## 📈 Future Enhancements

### Planned Features
- **Apple Watch integration** for meditation reminders and heart rate monitoring
- **Siri Shortcuts** for voice-activated meditation starts
- **Widget support** for quick access to favorite meditations
- **Social features** for sharing progress with meditation buddies
- **Advanced analytics** with mood pattern recognition
- **Custom voice recording** for personal meditation guides

### Technical Improvements
- **Background processing** for meditation preparation
- **Offline AI models** for faster script generation
- **CloudKit sync** for multi-device progress sharing
- **Haptic feedback** integration for breathing guidance

## 📝 Notes for Future Development

### Code Organization
- All views follow SwiftUI best practices with proper state management
- Data models use SwiftData for automatic persistence
- AI logic is modular and easily extensible
- Navigation is centralized in the main flow coordinator

### Performance Considerations
- Text-to-speech is optimized for meditation with slower rates and lower pitch
- Large meditation scripts are handled efficiently by AVSpeechSynthesizer
- SwiftData queries are optimized for dashboard statistics
- Memory usage is controlled during long meditation sessions

### Accessibility
- All UI elements support VoiceOver
- Color choices consider color blindness
- Text sizes respect user system preferences
- Audio guidance works for visually impaired users

---

**Last Updated**: August 31, 2025  
**Version**: 1.0  
**Author**: Built with Claude Code AI assistance  

This meditation app represents a sophisticated blend of psychological science, AI technology, and thoughtful user experience design, creating a personalized wellness tool that adapts to each user's unique emotional needs.