# Gymly

🏋️ **Gymly** is an iOS fitness tracking app built with UIKit, providing a seamless and customizable workout logging experience.

## Features
- **Training Planner** – Set up workout routines with a flexible schedule.
- **Weight & Reps Tracking** – Log workouts with an intuitive input system.
- **Unit Switching** – Seamless transition between kg and lbs.
- **Calendar Overview** – Visual representation of workout history.
- **Workout Plan Export & Import** – Share workout routines using JSON.

## Tech Stack
- **Language:** Swift
- **Framework:** UIKit (selective use of SwiftUI for certain views)
- **Architecture:** MVVM + Coordinator
- **Storage:** UserDefaults for small preferences, CoreData for persistent workout history

## Installation
### Prerequisites:
- iOS 16+ / Xcode 15+
- Swift Package Manager (SPM)

### Setup:
```sh
git clone https://github.com/yourusername/gymly.git
cd gymly
open Gymly.xcodeproj
