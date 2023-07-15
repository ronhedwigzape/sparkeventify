# CSPC Announce

Before starting the project setup, you should have Flutter SDK installed and Git installed. 

## Installation

### Flutter with Git

1. Go to [**`Flutter Documentation`**](https://docs.flutter.dev/get-started/install) to get started.
   
2. Choose the appropriate OS for installing Flutter.

3. You must meet the system requirements to be able to run Git commands, or if you have [**`Git`**](https://git-scm.com/download/win) installed, proceed to the next step.

4. Download [**`Flutter SDK`**](https://docs.flutter.dev/get-started/install/windows#get-the-flutter-sdk), if you're using Windows, and make sure to follow the steps.

5. Update your path. See the [documentation](https://docs.flutter.dev/get-started/install/windows#get-the-flutter-sdk) for instructions.

6. After updating the path, run **`flutter doctor`** in your terminal:

```shell
flutter doctor
```

After completing these steps, you can ensure that Flutter is installed.

## Project Setup

1. Clone this repository to your project directory using [Github Desktop](https://desktop.github.com/), or open your terminal and run the following Git command:

```shell
git clone https://github.com/ronhedwigzape/student_event_calendar.git
```

2. Navigate to the project directory:

```shell
cd student_event_calendar
```

3. If you don't have a device, start Android/IOS emulators and wait for them to finish loading. If you don't have emulators, install Android Studio and create an emulator.

4. If you have a device, ensure that your device is connected. You can enable `Developer Options` on your phone and turn on `USB debugging mode`.

5. Run the following command to install the dependencies and start the development on both **`Android`** and **`iOS`**:

```
flutter run
```

6. To run on Chrome, use the following command:

```
flutter run -d chrome --web-renderer html
``` 

## Production Setup

- Run this command for app release. This will create a release build.

```
flutter run --release
```

## Updating Dependencies

- Run this command for updating dependencies.

```
flutter pub upgrade
```

## Cleaning Build

- Run this command if built app is not working as expected:

```
flutter clean
```

- Run this to fetch all dependencies

```
flutter pub get
```
