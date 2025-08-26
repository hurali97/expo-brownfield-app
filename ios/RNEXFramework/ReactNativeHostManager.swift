internal import React
internal import React_RCTAppDelegate
internal import Expo
internal import ReactAppDependencyProvider
import UIKit


/// The main entry point for loading React Native views
public class ReactNativeHostManager {
  public static let shared = ReactNativeHostManager()
  
  private var reactNativeDelegate: ExpoReactNativeFactoryDelegate?
  private var reactNativeFactory: RCTReactNativeFactory?
  private var expoDelegate: ExpoAppDelegate?
  
  public func initialize() {
    let delegate = ReactNativeDelegate()
    let factory = ExpoReactNativeFactory(delegate: delegate)
    delegate.dependencyProvider = RCTAppDependencyProvider()
    
    reactNativeDelegate = delegate
    reactNativeFactory = factory
    
    expoDelegate = ExpoAppDelegate()
    expoDelegate?.bindReactNativeFactory(factory)
    
    // If we do not do this, then the count of moduleClasses is zero. Maybe because swift compiler
    // removes the internals considering a deadcode? However, doing `nm -gU RNEXFramework | grep ExpoModulesProvider`
    // returns the symbols from the framework. So this is strange.
    
    // required to avoid this being file be stripped by the swift compiler
    let _ = ExpoModulesProvider()
  }
  
  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    ((expoDelegate?.application(application, didFinishLaunchingWithOptions: launchOptions)) != nil)
  }
  
  /// Loads a React Native view with the given module name.
  ///
  /// React components are registered as modules by using the [AppRegistry](https://reactnative.dev/docs/appregistry) API.
  /// - Parameter moduleName: Name used while registering the React Component with the `AppRegistry` API.
  /// - Parameter initialProps: Props that are going to be passed to the React Component.
  /// - Parameter launchOptions: The options app was launched with. This is usually obtained from the app delagate. This is mainly used for deep linking.
  public func loadView(
    moduleName: String, initialProps: [AnyHashable: Any]?,
    launchOptions: [AnyHashable: Any]?
  ) -> UIView {
    return (expoDelegate?.recreateRootView(withBundleURL: nil, moduleName: "main",initialProps: initialProps, launchOptions: launchOptions))!
  }
}

class ReactNativeDelegate: ExpoReactNativeFactoryDelegate {
  // Extension point for config-plugins
  
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    // needed to return the correct URL for expo-dev-client.
    bridge.bundleURL ?? bundleURL()
  }
  
  override func bundleURL() -> URL? {
#if DEBUG
    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: ".expo/.virtual-metro-entry")
#else
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
