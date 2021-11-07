import Flutter
import UIKit

public class SwiftMapboxPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mapbox", binaryMessenger: registrar.messenger())
    let instance = SwiftMapboxPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    let factory = FLNativeViewFactory(messenger: registrar.messenger())
    registrar.register(
                  factory,
                  withId: "test-view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
