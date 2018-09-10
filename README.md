# Beamer

**Beamer** is an upload manager framework for iOS applications.

## Requirements
* iOS 9+
* Swift 4

## Key Features

* Supports background uploads.
* Saves upload status of each file, internally
* Operation based requests
* Block based implementation
* Extensive notification support for operation status
* Cancellable operations
* Supports multiple asynchronous uploads

## Dependencies

Beamer is an AWS based upload manager, so you have to get AWS credentials and create a model for it.

Beamer has dependency for `AWSS3` library to use AWS's core functionalities.

## Installation

Beamer uses [CocoaPods](http://cocoapods.org), a library dependency management tool for iOS projects. Implementing Beamer into your project is as simple as adding the following line to your [Podfile](https://github.com/CocoaPods/CocoaPods/wiki/A-Podfile),

```ruby
pod 'Beamer'
```

Then, run `pod install` in your project directory.

Make sure to use the `.xcworkspace` file from now on.

## Usage

Beamer has dependency AWSS3 so, you should provide  `AWSCredentialPermissionS3` and `AWSCredential` otherwise library will give fatal error.

```swift

AWSCredentialPermissionS3(bucketName: String,
    uploadPath: String,
    regionName: String)
```

```swift

AWSCredential(regionType: AWSRegionType,
    permission: AWSCredentialPermissionS3,
    identityPoolID: String,
    token: String,
    identityID: String,
    providerName: String)

```

After providing `AWSCredential` you need to register it on `AppDelegate.swift`'s `application(_:didFinishLaunchingWithOptions:)` method

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    ...
    Beamer.shared.register(awsCredential: awsCredentialModel)
    ...
    return true
}

```

For creating uploadable items, you need to conform `Uploadable` protocol for `UploadTask`.

You will append uploadable item with `UploadTask` class.

```swift
UploadTask(file: Uploadable,
    directoryName: String,
    fileName: String,
    identifier: Int)
```

*Optional*

If your app supports background uploads, you need to call Beamer's method on `AppDelegate.swift`'s `application(_:handleEventsForBackgroundURLSession:completionHandler:)` method

```swift
func application(_ application: UIApplication,
                 handleEventsForBackgroundURLSession identifier: String,
                 completionHandler: @escaping () -> Void) {
    Beamer.shared.handleBackgroundEvents(application: application, identifier: identifier, completionHandler: completionHandler)
}
```

After setting up, you can upload item wherever you are. 

```swift
Beamer.shared.add(uploadTask: uploadTask)
```

### Delegates / Observers / Notifications

## Credits

Beamer is brought to you by [Hipo Team](http://hipolabs.com).

## License

Beamer is licensed under the terms of the Apache License, version 2.0. Please see the LICENSE file for full details.

