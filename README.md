# 🏋️ Gymly

**Gymly** is a comprehensive iOS fitness tracking app built with SwiftUI that provides a complete workout logging and planning experience with HealthKit integration and advanced workout analytics.

## 🌟 Features

### Core Functionality
- **Training Planner** – Create and manage custom workout splits with flexible scheduling
- **Exercise Tracking** – Log workouts with detailed weight, reps, and set tracking
- **Workout History** – Complete calendar view of workout history with visual indicators
- **Progress Analytics** – Advanced muscle group tracking with radar charts and progress visualization
- **Unit Conversion** – Seamless switching between kg and lbs weight units

### Advanced Features
- **HealthKit Integration** – Sync weight, BMI, height, and workout data with Apple Health
- **Split Management** – Import/export workout splits with `.gymlysplit` format
- **Set Types** – Support for warm-up sets, failure sets, drop sets, and rest-pause sets
- **Exercise Notes** – Add detailed notes to individual sets
- **Workout Timer** – Track total workout time with automatic timing
- **BMI Calculator** – Built-in BMI tracking with visual gauge display

### User Experience
- **Dark Mode Support** – Optimized for both light and dark themes
- **Apple Sign In** – Secure authentication with Apple ID
- **Intuitive UI** – Clean, modern interface built with SwiftUI
- **Offline First** – Full functionality without internet connection

## 🏗️ Architecture

### Tech Stack
- **Language:** Swift 5.9+
- **Framework:** SwiftUI
- **Storage:** SwiftData for persistent data, UserDefaults for preferences
- **APIs:** HealthKit, AuthenticationServices
- **Architecture Pattern:** MVVM + ObservableObject
- **Target:** iOS 17.0+

### Core Data Models

#### Exercise Model
```swift
@Model class Exercise {
    var id: UUID
    var name: String
    var sets: [Set]
    var repGoal: String
    var muscleGroup: String
    var createdAt: Date
    var completedAt: Date?
    var exerciseOrder: Int
    var done: Bool
}
```

#### Set Model
```swift
@Model class Set {
    var weight: Double/Int
    var reps: Int
    var failure: Bool
    var warmUp: Bool
    var restPause: Bool
    var dropSet: Bool
    var time: String
    var note: String
    var bodyWeight: Bool
}
```

#### Day & Split Models
- **Day**: Represents a workout day with exercises
- **Split**: Collection of days forming a complete workout routine
- **DayStorage**: Calendar storage for completed workouts

## 📱 App Structure

### Main Components

1. **ToolBar** (`ToolBar.swift`) - Main tab navigation
2. **TodayWorkoutView** - Current day workout interface
3. **CalendarView** - Workout history and calendar
4. **WorkoutViewModel** - Core business logic and data management
5. **Config** - App configuration and user preferences

### Key Views
- **SplitsView** - Manage workout splits
- **ExerciseDetailView** - Individual exercise tracking
- **SettingsView** - User preferences and HealthKit settings
- **SignInView** - Authentication interface
- **WorkoutSummaryView** - Post-workout summary with time tracking

## 🚀 Installation & Setup

### Prerequisites
- **iOS 17.0+**
- **Xcode 15.0+**
- **Swift 5.9+**

### Setup Steps
```bash
git clone https://github.com/rektoooooo/gymly.git
cd gymly
open Gymly.xcodeproj
```

### Required Permissions
Add these to your `Info.plist`:
```xml
<key>NSHealthShareUsageDescription</key>
<string>Gymly needs access to read your health data to sync workout and body metrics</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Gymly needs access to write workout data to your health records</string>
```

## 🔧 Configuration

### HealthKit Setup
The app integrates with HealthKit for:
- Weight tracking
- BMI calculations
- Height measurements
- Workout session data

### Data Persistence
- **SwiftData**: Exercise data, workout history, splits
- **UserDefaults**: User preferences, settings, small data
- **FileManager**: Profile images, split exports

## 📊 Key Features Deep Dive

### Split Management
- Create custom workout routines (Push/Pull/Legs, Upper/Lower, etc.)
- Export splits as `.gymlysplit` files
- Import shared workout routines
- Automatic day progression

### Exercise Tracking
- 10 predefined muscle groups: Chest, Back, Biceps, Triceps, Shoulders, Quads, Hamstrings, Calves, Glutes, Abs
- Multiple set types with specific tracking
- Real-time progress visualization
- Exercise copying between days

### Analytics & Progress
- Muscle group radar charts
- Workout frequency tracking
- Weight progression graphs
- BMI monitoring with visual indicators

### Calendar Integration
- Visual workout history
- Date-based workout retrieval
- Progress tracking over time
- Workout completion indicators

## 🧪 Testing

### TestFlight Access
For TestFlight access, reach out with your email to [sebastian.kucera@icloud.com](mailto:sebastian.kucera@icloud.com)

### Test Coverage
- Unit tests: `GymlyTests/`
- UI tests: `GymlyUITests/`

## 🛠️ Development

### Key Files Structure
```
Gymly/
├── GymlyApp.swift              # App entry point
├── ToolBar.swift               # Main navigation
├── Config.swift                # App configuration
├── Logic/
│   └── WorkoutViewModel.swift  # Core business logic
├── Workout/                    # Workout-related views
├── Settings/                   # Settings and preferences
├── Calendar/                   # Calendar functionality
├── Cells/                      # Reusable UI components
└── Extensions/                 # Swift extensions
```

### Core Functionality
- **Split Management**: Create, edit, import/export workout routines
- **Exercise Creation**: Add exercises with sets, reps, and weight tracking
- **Progress Tracking**: Calendar-based workout history
- **Data Persistence**: SwiftData integration for reliable storage
- **HealthKit Sync**: Bidirectional health data synchronization

## 📬 Contact & Support

### Get in Touch
- 💬 **Discord**: rektoooooo
- 📧 **Email**: [sebastian.kucera@icloud.com](mailto:sebastian.kucera@icloud.com)
- 📸 **Instagram**: [@seb.kuc](https://www.instagram.com/seb.kuc/)

### Contributing
This is currently a personal project. For feature requests or bug reports, please reach out via email.

## 🔮 Future Roadmap

### Planned Features
- **Cloud Sync** - iCloud synchronization across devices
- **Social Features** - Share workouts and compete with friends
- **AI Recommendations** - Intelligent workout suggestions
- **Apple Watch App** - Companion watch application
- **Exercise Database** - Expanded exercise library with instructions
- **Rest Timer** - Built-in rest timer between sets

### Technical Improvements
- **Performance Optimization** - Enhanced data loading and UI responsiveness
- **Accessibility** - Full VoiceOver and accessibility support
- **Localization** - Multi-language support
- **Widget Support** - Home screen widgets for quick workout access

## 📄 License

This project is currently private. All rights reserved by Sebastián Kučera.

---

**Built with ❤️ by Sebastián Kučera**

*Making fitness tracking simple, powerful, and beautiful.*