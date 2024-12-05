//
//  BoldDeviceSDK.swift
//
//  Created by Ruud Diterwich on 27/03/2019.
//  Copyright © 2019 Sesam Technologies. All rights reserved.
//

import Foundation
import BoldDeviceSDK
import React

@objc(RNBoldDeviceSDK) open class RNBoldDeviceSDK: NSObject {

  private static let sdkInstance = BoldDeviceSDKImpl.instance

  @objc static func requiresMainQueueSetup() -> Bool {
    // see: https://stackoverflow.com/questions/50773748/difference-requiresmainqueuesetup-and-dispatch-get-main-queue
    return true
  }

  @objc func initialize(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      let instance = Self.sdkInstance
      _ = instance.onLoginChanged { isLoggedIn in
        RNBoldDeviceSDKEventEmitter.emit("LoginChanged", isLoggedIn)
      }
      _ = instance.onDevicesChanged { devices in
        RNBoldDeviceSDKEventEmitter.emit("DevicesChanged", devices.map { obj($0) } )
      }
      _ = instance.onInstallableDevicesChanged { installableDevices in
        RNBoldDeviceSDKEventEmitter.emit("InstallableDevicesChanged", installableDevices.map { obj($0) } )
      }
      _ = instance.onStateChanged { state in
        RNBoldDeviceSDKEventEmitter.emit("StateChanged", obj(state) )
      }
      resolve(nil)
    }
  }

  @objc func setDebugLogging(_ enabled: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.setDebugLogging(enabled: enabled)
    resolve(nil)
  }

  @objc func getBaseURL(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Resolve(Self.sdkInstance.getBaseURL(), nil, resolve, reject)
  }

  @objc func setBaseURL(_ baseURL: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.setBaseURL(baseURL)
    resolve(nil)
  }

  @objc func setDeviceConfig(_ configuration: NSArray, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    let converted = configuration.compactMap({ $0 as? NSDictionary}).map { convertDeviceConfig($0) }
    Self.sdkInstance.setDeviceConfig(converted as [DeviceConfig])
    resolve(nil)
  }

  private func convertDeviceConfig(_ obj: NSDictionary) -> DeviceConfig {
    let geoLocation = obj["geoLocation"] as! NSDictionary
    let autoActivation = obj["autoActivation"] as! NSDictionary
    let leaveAlert = obj["leaveAlert"] as! NSDictionary
    return DeviceConfig(
      deviceId: obj["deviceId"] as! DeviceID,
      geoLocation: GeoLocation(
        latitude: geoLocation["latitude"] as! Double,
        longitude: geoLocation["longitude"] as! Double
      ),
      autoActivation: AutoActivation(
        enabled: autoActivation["enabled"] as! Bool,
        sensitivity: autoActivation["sensitivity"] as! Int,
        notification: autoActivation["notification"] as! Bool
      ),
      leaveAlert: LeaveAlert(
        enabled: leaveAlert["enabled"] as! Bool
      )
    )
  }

  @objc func setTranslations(_ translations: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.setTranslations(translations)
    resolve(nil)
  }

  @objc func getState(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Resolve(obj(Self.sdkInstance.getState()), nil, resolve, reject)
  }

  @objc func login(_ authorizationCode: String, clientId: String, clientSecret: String, redirectUri: String?, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.login(authorizationCode: authorizationCode, clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri) {
      Resolve($0.map {NSString(string: $0)} ?? NSNull(), $1, resolve, reject)
    }
  }

  @objc func isLoggedIn(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.isLoggedIn { Resolve($0, $1, resolve, reject) }
  }

  @objc func getAccessToken(_ forceRefresh: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.getAccessToken(forceRefresh: forceRefresh) {
      Resolve($0.map {NSString(string: $0)} ?? NSNull(), $1, resolve, reject)
    }
  }

  @objc func logout(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.logout { Resolve(nil, $0, resolve, reject) }
  }

  @objc func refreshDevices(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.refreshDevices { Resolve($0.map { $0.map { obj($0) } }, $1, resolve, reject) }
  }

  @objc func processMessages(_ deviceId: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.processMessages(deviceId: deviceId.int64Value) { Resolve(nil, $0, resolve, reject) }
  }

  @objc func getDevices(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.getDevices { Resolve($0.map { obj($0) }, nil, resolve, reject) }
  }

  @objc func getInstallableDevices(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Resolve(Self.sdkInstance.getInstallableDevices().map { obj($0) }, nil, resolve, reject)
  }

  @objc func getWokenUpDevice(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.getWokenUpDevice { Resolve($0.map { NSNumber(value: $0) }, nil, resolve, reject) }
  }

  @objc func activate(_ deviceId: NSNumber, keepActiveUntil: NSDate?, allowButtonKeepActiveCancel: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.activate(deviceId: deviceId.int64Value, keepActiveUntil: keepActiveUntil as Date?, allowButtonKeepActiveCancel: allowButtonKeepActiveCancel) {
      Resolve($0.map { NSNumber(value: $0) }, $1, resolve, reject)
    }
  }

  @objc func deactivate(_ deviceId: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.deactivate(deviceId: deviceId.int64Value) {
      Resolve($0.map { NSNumber(value: $0) }, $1, resolve, reject)
    }
  }

  @objc func performKeyExchange(_ deviceId: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.performKeyExchange(deviceId: deviceId.int64Value) {
      Resolve(nil, $0, resolve, reject)
    }
  }

  @objc func startInstallation(_ deviceId: NSNumber, organizationId: NSNumber, skipKeyExchange: Bool, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.startInstallation(deviceId: deviceId.int64Value, organizationId: organizationId.int64Value < 0 ? nil : organizationId.int64Value, skipKeyExchange: skipKeyExchange) {
      Resolve(nil, $0, resolve, reject)
    }
  }

  @objc func startPairingForInstallation(_ deviceId: NSNumber, pairingCode: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.startPairingForInstallation(deviceId: deviceId.int64Value, pairingCode: pairingCode) {
      Resolve(nil, $0, resolve, reject)
    }
  }

  @objc func pairForInstallation(_ deviceId: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.pairForInstallation(deviceId: deviceId.int64Value) {
      Resolve(nil, $0, resolve, reject)
    }
  }

  @objc func finishInstallation(_ deviceId: NSNumber, name: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.finishInstallation(deviceId: deviceId.int64Value, name: name) { Resolve(nil, $0, resolve, reject) }
  }

  @objc func cancelInstallation(_ deviceId: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.cancelInstallation(deviceId: deviceId.int64Value);
    resolve(nil)
  }

  @objc func updateFirmware(_ deviceId: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.updateFirmware(deviceId: deviceId.int64Value, progress: fwprogress) { Resolve(nil, $0, resolve, reject) }
  }

  @objc func getAccessPoints(_ deviceId: NSNumber, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.getAccessPoints(deviceId: deviceId.int64Value) { Resolve($0.map { obj($0) }, $1, resolve, reject) }
  }

  @objc func setAccessPoint(_ deviceId: NSNumber, ssid: String, password: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    Self.sdkInstance.setAccessPoint(deviceId: deviceId.int64Value, ssid: ssid, password: password) {
      Resolve(nil, $0, resolve, reject)
    }
  }

  private func fwprogress(progress: FirmwareProgress) {
    RNBoldDeviceSDKEventEmitter.emit("FirmwareUpdateProgress", obj(progress))
  }
}

@objc(RNBoldDeviceSDKEventEmitter) open class RNBoldDeviceSDKEventEmitter: RCTEventEmitter {
  public static var instance: RNBoldDeviceSDKEventEmitter? = nil

  override init() {
    super.init()
    RNBoldDeviceSDKEventEmitter.instance = self
  }

  @objc open override func supportedEvents() -> [String] {
    return ["LoginChanged", "DevicesChanged", "StateChanged", "FirmwareUpdateProgress", "InstallableDevicesChanged"]
  }

  static func emit(_ name: String, _ body: Any?) {
    RNBoldDeviceSDKEventEmitter.instance?.sendEvent(withName: name, body: body)
  }

  @objc
  override public static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

fileprivate func Resolve(_ value: Any?, _ error: SDKError?, _ resolve: RCTPromiseResolveBlock, _ reject: RCTPromiseRejectBlock) {
  if let error = error {
    reject("\(error.type)", error.message,  nil) }
  else { resolve(value) }
}

fileprivate func obj(_ device: Device) -> NSDictionary {
  let result = NSMutableDictionary(dictionary: device.json.obj() ?? [:])
  if let deviceBLE = device.ble {
    result.setValue(obj(deviceBLE), forKey: "ble")
  }
  return result
}

fileprivate func obj(_ device: DeviceBLE) -> NSDictionary {
  return [
    "id": device.id,
    "type": device.type,
    "model": device.model,
    "address": device.address ?? NSNull(),
    "protocolVersion": device.protocolVersion,
    "isInRange": device.isInRange,
    "isActivatable": device.isActivatable,
    "isInstallable": device.isInstallable,
    "isInDFUMode": device.isInDFUMode,
    "shouldTimeSync": device.shouldTimeSync,
    "eventsAvailable": device.eventsAvailable,
    "isWokenUp": device.isWokenUp,
    "isBusy": device.isBusy,
    "rssi": device.rssi,
    "lastRssi": device.lastRssi,
    "distance": device.distance,
    "isActive": device.isActive,
    "lastSeen": device.lastSeen ?? NSNull()]
}

fileprivate func obj(_ accessPoint: AccessPoint) -> NSDictionary {
  return [
    "ssid": accessPoint.ssid,
    "rssi": accessPoint.rssi
  ]
}

fileprivate func obj(_ organization: Organization) -> NSDictionary {
  return [
    "id": organization.id,
    "name": organization.name
  ]
}

fileprivate func obj(_ state: BLEState) -> NSDictionary {
  return [
    "bluetoothOn": state.bluetoothOn
  ]
}

fileprivate func obj(_ progress: FirmwareProgress) -> NSDictionary {
  return [
    "percentage": progress.percentage,
    "status": progress.status.rawValue
  ]
}
