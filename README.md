# CR image cropper package

Flutter package for convenient usage of native Android View and iOS ViewController for cropping
image and compress it if it's size is too big.

Used plugins:

- [image_cropper](https://pub.dev/packages/image_cropper).
- [flutter_native_image](https://pub.dev/packages/flutter_native_image).
- [image_picker](https://pub.dev/packages/image_picker).

## Getting Started

1. Add plugin to the project. pubspec.yaml:

    ```
    cr_image_cropper:
        path: ../ path to package folder
    ```

   or

    ```
    cr_image_cropper:
        git:
            url: https://igmar:glpat-85BwV99UReQg6cFxBxQx@gitlab.cleveroad.com/internal/flutter/bootstrap/cr_image_cropper
            ref: VERSION_NUMBER
    ```
2. Add to AndroidManifest.xml next activity (needed by image_cropper plugin):

```xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
```

3. Add to iOS Info.plist file next lines with description of why need access ti gallery app (needed
   by image_picker plugin):

```xml
<key>NSCameraUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
<key>NSMicrophoneUsageDescription</key>
<string>Used to capture audio for image picker plugin</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to demonstrate image picker plugin</string>
```

## How to use see [Example app code](https://gitlab.cleveroad.com/internal/android/bootstrap_flutter/blob/master/packages/cr_image_cropper/example/lib/main_page.dart).


