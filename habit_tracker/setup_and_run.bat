@echo off
REM Generates android/windows/web platform folders, keeps our code, installs packages, runs the app.
cd /d "%~dp0"
copy /Y lib\main.dart lib\main.dart.bak >nul
copy /Y pubspec.yaml pubspec.yaml.bak >nul
call flutter create . --project-name habit_tracker --platforms=android,windows,web
copy /Y lib\main.dart.bak lib\main.dart >nul
copy /Y pubspec.yaml.bak pubspec.yaml >nul
del lib\main.dart.bak pubspec.yaml.bak
if exist test rmdir /s /q test
call flutter pub get
echo.
echo Choose: 1 = Windows  2 = Chrome  3 = Android
set /p c=Enter number: 
if "%c%"=="1" call flutter run -d windows
if "%c%"=="2" call flutter run -d chrome
if "%c%"=="3" call flutter run
pause
