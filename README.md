# CSPC Announce

- ### A student event calendar app
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

1. Clone this repository to your project directory using [**`Github Desktop`**](https://desktop.github.com/), or open your terminal and run the following Git command:
```shell
git clone https://github.com/ronhedwigzape/student_event_calendar.git
```
2. Navigate to the project directory:
```shell
cd student_event_calendar
```

3. If you don't have a device, start Android/IOS emulators and wait for them to finish loading. If you don't have emulators, install [**`Android Studio`**](https://developer.android.com/studio) and create an emulator. Here are the steps to take to create and run the emulator:

### Creating an Android Emulator from the Command Line
- **Install necessary system images**: The Android emulator requires specific system images to run different versions of Android. You can install these images using the sdkmanager tool. Here's an example of how to install the system image for Android 31 with Google APIs:
```shell
sdkmanager --install "system-images;android-31;google_apis;x86_64"
```
- **Create a new Android Virtual Device (AVD)**: After installing the necessary system images, you can create a new AVD using the avdmanager tool. Here's an example of how to create a new AVD:
```shell
echo "no" | avdmanager create avd --name "my_android_31" --package "system-images;android-31;google_apis;x86_64" --tag "google_apis" --abi "x86_64"
```
- **Configure the AVD**: You can further configure the AVD by editing the **`config.ini`** file located in `~/.android/avd/<avd-name>.avd/config.ini`. Here you can set various properties such as the device's RAM size, screen resolution, and whether the Google Play Store is enabled.
- **Launch the AVD**: Once the AVD is created and configured, you can launch it using the emulator command:
```shell
emulator @my_android_31
```
### Creating an Android Emulator using Android Studio
- **Open Android Studio**: Launch **Android Studio** on your machine. In the welcome screen, select `"More Options" > "Virtual Device Manager"`.
- **Create a new Virtual Device**: In the Android Virtual Device Manager window, click on the `"Create Virtual Device"` button. Select a device from the list (for example, a `Pixel XL` or a `Pixel 4`), and click the `"Next"` button to continue.
- **Download a System Image**: Now, you need to download a system image for the virtual device. For this, select a version of Android to run on your virtual device. If the image is not installed on your computer, click `"Download" > "Accept" > "Next" > "Finish"`.
- **Configure the AVD**: After the system image is downloaded and installed, you can choose additional configuration details for your device. You can also set a custom name for your emulator in the `"AVD Name"` field.
- **Launch the AVD**: Once you have created and configured your AVD, you can run your app on the Android Emulator. Select the virtual device that you created from the dropdown menu at the top of the Android Studio window. The virtual device starts just like a physical device, and it may take a while for the emulator to start for the first time.

Remember to include the `sdkmanager`, `avdmanager`, and `emulator` commands in your system's `PATH` for easy access from the terminal. The exact locations of these commands will depend on where the Android SDK is installed on your system. Also, remember to accept all the Android license agreements if you haven't done so before.

### Running Android emulator
To open the Android emulator from the terminal in ***Windows***, you need to follow these steps:

- **Locate Android SDK**: First, you need to know the location of your Android SDK. This will vary depending on your installation. The default location is usually `C:\Users\<your-user-name>\AppData\Local\Android\Sdk`
- **Set the PATH environment variable**: You need to add the emulator directory to your PATH environment variable. This can be done by editing the system environment variables and adding the following path: `C:\Users\<your-user-name>\AppData\Local\Android\Sdk\emulator` Don't forget to replace **`<your-user-name>`** with your actual username.
- **List and run emulators**: Now you can list all your available Android Virtual Devices (AVDs) using the command `emulator -list-avds` in the terminal. To run a specific AVD, use the command `emulator -avd <name-of-your-emulator>`. Replace <name-of-your-emulator> with the name of the AVD that you want to run. 
- Here is an example of how you can run an emulator:
```shell
emulator -avd Pixel_XL_API_33
```
In this example, `Pixel_XL_API_33` is the name of the AVD to be launched.

4. If you have a device, ensure that your device is connected. You can enable `Developer Options` on your phone and turn on `USB debugging mode`.

5. Run the following command to install the dependencies and start the development on both **`Android`** and **`iOS`**:

```
flutter run
```

6. If your project has a error of `Current Dart SDK version not updated`, you can run this command.

```
flutter channel beta
```

- then run this to upgrade Flutter to the latest version,

```
flutter upgrade
```

7. To run on Chrome, use the following command:

```
flutter run -d chrome --web-renderer html
``` 

## Production Setup
Build and release a Flutter app for production on Android, iOS, and Web.

### Building and Releasing an Android App
1. **Review the App Manifest**: Check the Android manifest file located in `<app dir>/android/app/src/main` and verify the values are correct, especially the following:
- `application`: Edit the `android:label` in the application tag to reflect the final name of the app.
- `uses-permission`: Remove the `android.permission.INTERNET` permission if your application code does not need Internet access.
2. **Review the Build Configuration**: Review the default Gradle build file file located in `<app dir>/android/app/build.gradle`.
3. **Build an App Bundle**: During a typical development cycle, you test an app using `flutter run` at the command line, or by using the Run and Debug options in your IDE. When you’re ready to prepare a release version of your app, run `flutter build appbundle`. The release bundle for your app is created at `<app dir>/build/app/outputs/bundle/release/app.aab`.
```
flutter build appbundle
```
4. **Test the App Bundle**: Test the app bundle in a variety of devices.
5. **Publish the App Bundle to the Google Play Store**: Follow the [**`Google Play launch documentation`**](https://developer.android.com/studio/publish) to publish your app to Google Play.
### Building and Releasing an iOS App
1. **Review the App Configuration**: Open the default Xcode workspace in your project by running `open ios/Runner.xcworkspace` in a terminal window from your Flutter project directory.
2. Select the Deployment Target: In Xcode, open `Runner.xcworkspace` in your app’s `ios` folder. To specify the iOS version that your app supports, select `Runner` in the Xcode project navigator, then select the `Runner` target in the settings view sidebar. In the `Deployment Info` section, specify the iOS Deployment Target.
3. **Add an App Icon**: Add the app icon by reviewing the [App Icon](https://developer.apple.com/design/human-interface-guidelines/app-icons) section of the iOS Human Interface Guidelines.
4. **Create a Build Archive**: Select `Product > Archive` to produce a build archive.
5. **Publish the App to the App Store**: Follow the official [**`iOS App Store distribution guide`**](https://help.apple.com/xcode/mac/current/#/dev442d7f2ca).
### Building and Releasing a Web App
1. **Add Web Support**: If you created the project using `flutter create`, web support is already enabled. If not, you can enable web support using the following command:
```
flutter channel stable
flutter upgrade
flutter config --enable-web
```
2. **Build the App for Release**: Build the app for deployment using the `flutter build web` command. This generates the app, including the assets, and places the files into the `/build/web` directory of the project.
```
flutter build web
```
3. **Serve the App from a Web Server**: You can use any HTTP server to serve your app during development. For example, you can use the one included with Python by running the following command:
```python
python -m http.server 8000
```

Then, navigate to `localhost:8000` in your browser to view your app.

4. **Deploy the App**: You can deploy your web app to any web server or service. For example, you can use [**`Firebase Hosting`**](https://firebase.google.com/docs/hosting) to host your Flutter app.

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
