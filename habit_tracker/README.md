# Habit Tracker (Flutter)

Double-click `setup_and_run.bat` (or run it in PowerShell) once. It creates the
platform folders, installs packages and launches the app.

Manual way:
    flutter create . --project-name habit_tracker --platforms=android,windows,web
    (keep this project's lib/main.dart and pubspec.yaml)
    flutter pub get
    flutter run -d chrome        # or -d windows / android device

Windows desktop needs Visual Studio 2022 with "Desktop development with C++".
Requires Flutter 3.22+.

Release builds:
    flutter build apk --split-per-abi --release
    flutter build windows --release
