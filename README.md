# GoNoGo Attendance Tracker


GoNoGo is a smart, cross-platform attendance tracking application built with Flutter. It helps students monitor their class attendance for multiple subjects, providing real-time percentage calculations and intelligent insights.

Its core "Go/No-Go" feature instantly determines if you can afford to miss your next class, helping you balance academic requirements with personal time. With a sleek, animated user interface and persistent local storage via Hive, managing your attendance has never been easier or more visually appealing.

## Features

-   **Intuitive Subject Management:** Easily add, edit, and delete subjects with custom attendance requirements.
-   **Real-time Tracking:** Mark classes as 'Present' or 'Absent' with a single tap. The app instantly recalculates your standing.
-   **"Go/No-Go" Safety Indicator:** Instantly know if you are "Safe to skip next class" or if you need to "Attend upcoming classes" based on your configurable attendance threshold.
-   **Comprehensive Statistics:** A dedicated stats screen visualizes your overall attendance, highlights your best and worst-performing subjects, and offers actionable insights on your progress.
-   **Daily Attendance Logging:** Use the "Mark Today's Attendance" feature to update the status for all your subjects for the day in a single, streamlined process.
-   **Detailed Subject View:** Tap on any subject to toggle between a summary view and a detailed breakdown of attended, missed, and total lectures.
-   **Persistent Local Storage:** All your data is stored locally and securely on your device using Hive, ensuring fast, offline access.
-   **Modern, Animated Interface:** A polished UI featuring smooth transitions, gradients, and glass morphism effects for a premium user experience.
-   **Cross-Platform:** Built with Flutter for a consistent experience on Android, iOS, and other supported platforms.

## Tech Stack

-   **Framework:** Flutter
-   **Language:** Dart
-   **Database:** Hive (Lightweight & fast key-value database)
-   **UI Components:** `percent_indicator`, `flutter_slidable`, custom animations.
-   **Code Generation:** `build_runner`, `hive_generator`

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Ensure you have the Flutter SDK installed on your system.

### Installation & Running

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/atharv1912/attendance_tracker.git
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd attendance_tracker/attendance_tracker
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

4.  **Run the code generator:**
    This project uses Hive, which requires generating adapter files. Run the following command in the terminal:
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the application:**
    Connect a device or start an emulator and run the app:
    ```sh
    flutter run
