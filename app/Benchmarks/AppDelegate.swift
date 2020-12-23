import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow? = nil
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    window.rootViewController = BenchmarksViewController(nibName: nil, bundle: nil)
    window.makeKeyAndVisible()
    return true
  }
}
