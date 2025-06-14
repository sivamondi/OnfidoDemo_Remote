# OnFido Authentication Demo

A SwiftUI-based iOS application demonstrating identity verification integration using the Onfido SDK. The app includes a beautiful UI for identity verification flow and a wealth management dashboard.

## Features

- ID Document Verification
- Selfie Verification
- Wealth Management Dashboard
- Real-time Portfolio Tracking
- Asset Allocation View
- Recent Activity Tracking

## Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- An Onfido account with API credentials

## Installation

You can integrate the Onfido SDK using either Swift Package Manager or CocoaPods.

### Option 1: Swift Package Manager (Recommended)

1. Open your project in Xcode
2. Go to File > Add Packages...
3. In the search field, enter: `https://github.com/onfido/onfido-ios-sdk.git`
4. Select the latest version (e.g., 29.3.0 or later)
5. Click "Add Package"
6. Select your target and click "Add Package" again

### Option 2: CocoaPods

1. Install CocoaPods if you haven't already:
```bash
sudo gem install cocoapods
```

2. Create a Podfile in your project directory:
```bash
pod init
```

3. Add the following to your Podfile:
```ruby
platform :ios, '15.0'

target 'OnFidoAuthDemo' do
  use_frameworks!
  pod 'Onfido'
end
```

4. Install the dependencies:
```bash
pod install
```

5. Open the `.xcworkspace` file (not the `.xcodeproj`):
```bash
open OnFidoAuthDemo.xcworkspace
```

## Configuration

1. Sign up for an Onfido account at [Onfido Dashboard](https://dashboard.onfido.com/signup)

2. Once you have access to the Onfido Dashboard:
   - Create a new API token
   - Generate an SDK token (this will be used in your app)

3. In `ContentView.swift`, locate the following line:
```swift
let sdkToken = "sdk_token_1234567890"
```
Replace it with your actual SDK token:
```swift
let sdkToken = "your_actual_sdk_token_here"
```

## Camera Permissions

The app requires camera permissions for document and selfie capture. Add the following keys to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your ID document and selfie for verification.</string>
```

## Running the App

1. Open the project in Xcode
   - If using CocoaPods: Open the `.xcworkspace` file
   - If using SPM: Open the `.xcodeproj` file
2. Select your target device or simulator
3. Press ⌘R or click the Play button to build and run the project

## Project Structure

- `ContentView.swift`: Main view containing the verification flow and Onfido SDK integration
- `WealthManagementView.swift`: Dashboard view shown after successful verification
- `VerificationSuccessView.swift`: Success screen shown after verification

## Troubleshooting

1. If you encounter build errors:
   - Clean the build folder (⌘⇧K)
   - Clean the build cache (⌥⌘⇧K)
   - Rebuild the project

2. If using Swift Package Manager and the package fails to resolve:
   - Go to File > Packages > Reset Package Caches
   - Go to File > Packages > Resolve Package Versions
   - Clean and rebuild the project

3. If using CocoaPods and the Onfido SDK isn't recognized:
   - Ensure you opened the `.xcworkspace` file and not the `.xcodeproj`
   - Try running `pod install` again
   - Check that your Podfile is correctly configured

4. If camera permissions are denied:
   - Users can enable camera access through iOS Settings
   - The app will show guidance for enabling camera permissions

## Security Considerations

- Never commit your SDK token to version control
- Consider using environment variables or a secure configuration management system
- Follow Onfido's security best practices for token management

## Support

For issues related to:
- Onfido SDK: Visit [Onfido Documentation](https://documentation.onfido.com/)
- App Implementation: Create an issue in this repository

## License

[Your License Information Here] 