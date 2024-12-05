# Bold Device SDK for iOS

## Getting started

To obtain the SDK, clone the `bold-device-sdk-dist` git repository into your project folder. A specific version can be obtained by using the following URL:

```json
"git+https://CREDENTIALS@gitlab.com/sesamsolutions/bold-device-sdk-dist.git#v1.0.7"
```

The credentials are provided by Bold on request.

### Setting up XCode

The files needed for XCode are located in the `ios` folder.
1. Add the folder `bold-device-sdk-dist/ios/BoldDeviceSDK.framework` to your project and make sure it has target membership (this is the default). 
2. Embed the SDK's framework in your project's target selecting 'General' &rarr; 'Frameworks, Libraries and Embedded Content' &rarr; `BoldDeviceSDK.framework` &rarr;  select 'Embed & Sign'.
3. Make sure your project supports background location updates (Target  &rarr; Signing & Capabilities  &rarr; Background Modes &rarr; Location Updates)
4. Add a Bluetooth Usage description to Info.plist:
```
	<key>NSBluetoothAlwaysUsageDescription</key>
	<string>The app requires permission to use bluetooth to install, manage and activate your devices.</string>

```

## Usage

This sample shows how to use the SDK in your project:

```swift
import BoldDeviceSDK

let sdk = BoldDeviceSDK()

func activate(deviceId: Int64) {
    sdk.activate(deviceId: deviceId) { seconds, error in
        if let seconds = seconds {
            print("Lock will be active for \(seconds) seconds")
        }
    }
}

let callback = sdk.onDevicesChanged { devices in
    if devices.count > 0 {
        let device = devices[0]
        print("Closest device is now \(device.name)")
    }
}
```

## Reference

The `BoldDeviceSDK` class is the entry point to the SDK:

```swift
public class BoldDeviceSDK {
    let sdk = BoldDeviceSDKImpl(debugLogging: false)
    func loginWithAuthorizationCode(authorizationCode: String, clientId: String, clientSecret: String, redirectUri: String?, _ complete: @escaping (AuthToken?, SDKError?) -> Void)
    func login(username: String, password: String, validationId: String, _ complete: @escaping (AuthToken?, SDKError?) -> Void)
    func isLoggedIn(_ complete: @escaping (Bool, SDKError?) -> Void)
    func logout(_ complete: @escaping (SDKError?) -> Void)
    func getAccessToken(forceRefresh: Bool, _ complete: @escaping (AuthToken?, SDKError?) -> Void)
    func getDevices(_ complete: @escaping ([Device]?, SDKError?) -> Void)
    func refreshDevices(_ complete: @escaping ([Device]?, SDKError?) -> Void)
    func activate(deviceId: Int64, keepActiveUntil: Date?, allowButtonKeepActiveCancel: Bool, _ complete: @escaping (TimeInterval?, SDKError?) -> Void)
    func deactivate(deviceId: Int64, _ complete: @escaping (TimeInterval?, SDKError?) -> Void)
    func processMessages(deviceId: Int64, _ complete: @escaping (SDKError?) -> Void)
    func updateFirmware(deviceId: Int64, progress: @escaping (Int) -> Void, _ complete: @escaping (SDKError?) -> Void)
    func onLoginChanged(loginChanged: @escaping (Bool) -> Void) -> Callback
    func onDevicesChanged(devicesChanged: @escaping ([Device]) -> Void) -> Callback
}
```

Devices have the following fields:

```swift
public struct Device: Codable, Equatable, Identifiable, Hashable {
    public var id: Int64
    public var name: String
    public var personalName: String?
    public var model: String
    public var type: String // "Lock", "Gateway"
    public var actualFirmwareVersion: Int
    public var requiredFirmwareVersion: Int
    public var synced: Bool
    public var isInRange: Bool
    public var isInDFUMode: Bool
    public var isBusy: Bool
    public var isActive: Bool
    public var batteryLevel: String? // "Empty", "Critical", "Low", "Good", "Excellent"
    public var permissionAdministrate: Bool
    public var permissionRemoteActivate: Bool
    public var permissionAssignKeyfob: Bool
    public var features: DeviceFeatures
    public var gateway: DeviceGateway?
}
```

Utility classes:

```swift
public protocol Callback {
    func remove()
}
public struct DeviceFeatures: Codable, Equatable {
    public var activatable: Bool?
}
public struct DeviceGateway: Codable, Equatable {
    public var id: Int64?
    public var name: String?
    public var rssi: Int?
    public var lastSeen: Date?
}
```
