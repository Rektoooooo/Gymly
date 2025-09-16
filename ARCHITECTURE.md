# 🏗️ Gymly Architecture Documentation

## Overview

Gymly is built using modern iOS development practices with SwiftUI and follows an MVVM (Model-View-ViewModel) architecture pattern. The app leverages SwiftData for persistent storage and integrates deeply with Apple's ecosystem through HealthKit and AuthenticationServices.

## 📋 Table of Contents

1. [Architecture Pattern](#architecture-pattern)
2. [Data Models](#data-models)
3. [View Models](#view-models)
4. [Views Architecture](#views-architecture)
5. [Data Persistence](#data-persistence)
6. [Business Logic](#business-logic)
7. [Integration Points](#integration-points)
8. [Error Handling](#error-handling)
9. [Performance Considerations](#performance-considerations)

## Architecture Pattern

### MVVM + ObservableObject

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Views       │────│   ViewModels    │────│     Models      │
│   (SwiftUI)     │    │ (ObservableObj) │    │  (SwiftData)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         └──────────────│     Config      │──────────────┘
                        │ (App Settings)  │
                        └─────────────────┘
```

### Key Principles
- **Separation of Concerns**: Views handle UI, ViewModels manage business logic, Models represent data
- **Reactive Programming**: Uses `@Published` and `ObservableObject` for data binding
- **Dependency Injection**: ViewModels receive dependencies through initializers
- **Single Source of Truth**: Config class manages app-wide state

## Data Models

### Core Entity Relationships

```
Split (1) ──────────── (many) Day
                                │
                                │ (1)
                                │
                               \│/
                             (many)
                           Exercise (1) ──────────── (many) Set
                               │
                               │ (1)
                               │
                              \│/
                            (many)
                          GraphEntry
```

### Model Details

#### `Exercise.swift`
```swift
@Model
class Exercise: Codable {
    @Attribute(.unique) var id: UUID
    var name: String
    var sets: [Set]
    var repGoal: String
    var muscleGroup: String
    var createdAt: Date
    var completedAt: Date?
    var exerciseOrder: Int
    var done: Bool

    @Relationship(deleteRule: .nullify, inverse: \Day.exercises) var day: Day?
}
```

**Key Features:**
- Implements `Codable` for import/export functionality
- Contains nested `Set` model for detailed tracking
- Supports deep copying for workout duplication
- Maintains relationship integrity with SwiftData

#### `Day.swift`
```swift
@Model
class Day: Codable {
    @Attribute(.unique) var id: UUID
    var name: String
    var dayOfSplit: Int
    var exercises: [Exercise]
    var date: String

    @Relationship(deleteRule: .cascade, inverse: \Split.days) var split: Split?
}
```

**Responsibilities:**
- Represents a single workout day
- Manages exercise collection
- Supports split-based and calendar-based access patterns

#### `Set.swift`
```swift
@Model
class Set {
    var weight: Int/Double
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

**Features:**
- Multiple set types (warm-up, failure, drop set, rest-pause)
- Flexible weight handling (both Int and Double variants exist)
- Time and note tracking for detailed logging

### Support Models

- **`Split`**: Workout routine container
- **`DayStorage`**: Calendar-specific storage wrapper
- **`WeightPoint`**: HealthKit weight data points
- **`GraphEntry`**: Muscle group analytics data
- **`MuscleGroup`**: UI grouping for exercises

## View Models

### `WorkoutViewModel.swift`

Central business logic coordinator managing:

#### Core Responsibilities

```swift
final class WorkoutViewModel: ObservableObject {
    @Published var days: [Day] = []
    @Published var exercises: [Exercise] = []
    @Published var muscleGroups: [MuscleGroup] = []

    // Split Management
    func createNewSplit(name: String, numberOfDays: Int, startDate: Date)
    func getActiveSplit() -> Split?
    func switchActiveSplit(split: Split)

    // Day Management
    func fetchDay(dayOfSplit: Int?) async -> Day
    func fetchCalendarDay(date: String) async -> Day
    func insertWorkout() async

    // Exercise Management
    func createExercise(to: Day) async
    func deleteExercise(_ exercise: Exercise)
    func sortData(dayOfSplit: Int) async -> [MuscleGroup]

    // Import/Export
    func importSplit(from url: URL) -> Split?
    func exportSplit(_ split: Split) -> URL?
}
```

#### Architecture Benefits
- **Async/Await Integration**: Modern concurrency for data operations
- **Error Handling**: Comprehensive error management for data operations
- **State Management**: Centralized state updates with `@Published` properties
- **Modular Functions**: Single responsibility principle applied

### `Config.swift`

App-wide configuration and settings manager:

```swift
class Config: ObservableObject {
    @Published var weightUnit: String
    @Published var splitStarted: Bool
    @Published var dayInSplit: Int
    @Published var isUserLoggedIn: Bool
    @Published var userWeight: Double
    @Published var userBMI: Double
    // ... 20+ configuration properties
}
```

**Persistence Strategy:**
- Automatic UserDefaults synchronization
- Property observers ensure data consistency
- Centralized configuration access

## Views Architecture

### Navigation Structure

```
TabView (ToolBar.swift)
├── TodayWorkoutView
│   ├── ShowSplitDayView
│   │   └── ExerciseDetailView
│   │       └── EditExerciseSetView
│   └── SplitsView
│       └── SplitDetailView
└── CalendarView
    └── CalendarExerciseView
```

### Key View Components

#### `ToolBar.swift`
- Main app navigation using `TabView`
- Manages authentication state
- Handles deep linking for split imports

#### Workout Views
- **`TodayWorkoutView`**: Current workout interface
- **`ShowSplitDayView`**: Day-specific workout display
- **`ExerciseDetailView`**: Individual exercise management
- **`WorkoutSummaryView`**: Post-workout analytics

#### Settings Views
- **`SettingsView`**: Main settings interface
- **`ConnectionsView`**: HealthKit integration
- **`EditUserView`**: Profile management

### UI Components (`Cells/`)

Reusable components following composition pattern:
- **`SetCell`**: Individual set display and editing
- **`WeightChart`**: Progress visualization
- **`BMIGaugeView`**: BMI visual representation
- **`ProfileImageCell`**: User avatar handling

## Data Persistence

### SwiftData Integration

```swift
// Model Container Setup (GymlyApp.swift)
.modelContainer(for: [Exercise.self, Day.self, DayStorage.self, WeightPoint.self])
```

### Storage Strategy

1. **SwiftData Models**: Primary data storage
   - Exercise and workout data
   - Split configurations
   - Calendar entries

2. **UserDefaults**: Configuration and preferences
   - User settings
   - App state
   - Small data pieces

3. **FileManager**: Binary data
   - Profile images
   - Split export files

### Data Access Patterns

```swift
// Fetch with Predicates
let fetchDescriptor = FetchDescriptor<Split>(predicate: #Predicate { $0.isActive })
let activeSplits = try context.fetch(fetchDescriptor)

// Relationship Management
exercise.day = currentDay  // Automatic relationship handling
```

## Business Logic

### Split Management Flow

```
User Creates Split
        │
        ▼
Generate Days (1...n)
        │
        ▼
Set Split as Active
        │
        ▼
Update Config.dayInSplit
        │
        ▼
Save to SwiftData
```

### Workout Progression Logic

```swift
// Day advancement algorithm
func updateDayInSplit() -> Int {
    if !calendar.isDateInToday(config.lastUpdateDate) {
        let daysPassed = numberOfDaysBetween(start: config.lastUpdateDate, end: Date())
        let totalDays = config.dayInSplit + daysPassed
        let activeSplit = getActiveSplit()
        let newDayInSplit = (totalDays - 1) % activeSplit!.days.count + 1

        config.dayInSplit = newDayInSplit
        return newDayInSplit
    }
    return config.dayInSplit
}
```

### Analytics Engine

```swift
// Muscle group analytics
func updateMuscleGroupDataValues(from exercises: [Exercise]) {
    var muscleCounts: [MuscleGroupEnum: Double] = [:]

    // Process completed exercises
    let newExercises = exercises.filter { $0.done && !config.graphUpdatedExerciseIDs.contains($0.id) }

    // Calculate muscle group contributions
    for exercise in newExercises {
        if let group = MuscleGroupEnum(rawValue: exercise.muscleGroup.lowercased()) {
            muscleCounts[group, default: 0] += Double(exercise.sets.count)
        }
    }

    // Update radar chart data
    config.graphDataValues = orderedGroups.map { muscleCounts[$0] ?? 0 }
}
```

## Integration Points

### HealthKit Integration

```swift
class HealthKitManager {
    func requestHealthKitPermissions()
    func fetchWeight() async -> [WeightPoint]
    func writeWorkout(startDate: Date, endDate: Date)
    func calculateBMI(weight: Double, height: Double) -> Double
}
```

**Data Flow:**
1. Request permissions on app launch
2. Fetch user data (weight, height, BMI)
3. Sync workout sessions
4. Update Config with latest values

### Apple Sign In

```swift
// AuthenticationServices integration
private func handleSuccessfulLogin(with authorization: ASAuthorization) {
    if let userCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        config.username = userCredential.fullName?.givenName ?? "User"
        config.userEmail = userCredential.email ?? "user@example.com"
        config.isUserLoggedIn = true
    }
}
```

### File System Integration

Import/Export workflow:
```swift
func exportSplit(_ split: Split) -> URL? {
    let encoder = JSONEncoder()
    let data = try encoder.encode(split)
    let fileURL = documentsURL.appendingPathComponent("\(split.name).gymlysplit")
    try data.write(to: fileURL)
    return fileURL
}
```

## Error Handling

### Error Types

```swift
enum InsertionError: Error {
    case invalidReps(String)
    case invalidIndex(String)
}
```

### Error Handling Strategy

1. **Graceful Degradation**: App continues functioning with fallback data
2. **User Feedback**: Clear error messages for user-facing issues
3. **Logging**: Comprehensive debug logging for development
4. **Recovery**: Automatic retry mechanisms for transient failures

```swift
do {
    try context.save()
    debugPrint("Successfully saved data")
} catch {
    debugPrint("Save error: \(error)")
    // Implement recovery strategy
}
```

## Performance Considerations

### Data Loading Strategy

1. **Lazy Loading**: Load data on-demand
2. **Async Operations**: Non-blocking UI updates
3. **Caching**: In-memory caching for frequently accessed data
4. **Batch Operations**: Efficient bulk data operations

### Memory Management

- **Weak References**: Prevent retain cycles in relationships
- **Automatic Reference Counting**: Leverage Swift's ARC
- **Resource Cleanup**: Proper disposal of resources

### UI Performance

- **SwiftUI Optimization**: Minimize view updates
- **Animation Performance**: Efficient animation handling
- **List Virtualization**: Automatic with SwiftUI Lists

## Future Architecture Considerations

### Planned Improvements

1. **Modular Architecture**: Extract features into separate modules
2. **Dependency Injection Container**: Formal DI system
3. **Repository Pattern**: Abstract data access
4. **Event-Driven Architecture**: Decouple components with events
5. **Cloud Sync**: CloudKit integration for multi-device sync

### Scalability Considerations

- **Microservices Readiness**: Prepare for potential backend integration
- **Plugin Architecture**: Support for extensible features
- **Internationalization**: Multi-language architecture support
- **Accessibility**: Enhanced accessibility features

---

This architecture provides a solid foundation for a fitness tracking application while maintaining flexibility for future enhancements and scalability requirements.