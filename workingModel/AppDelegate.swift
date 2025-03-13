import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        clearBookmarkedEvents()
        
        let userDefaults = UserDefaults.standard
        let hasLoggedInBefore = userDefaults.bool(forKey: "hasLoggedInBefore")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if !hasLoggedInBefore {
            // Set the flag to indicate the user has logged in before
            userDefaults.set(true, forKey: "hasLoggedInBefore")
            
            // Show the InterestsViewController
            let interestsViewController = InterestsViewController()
            let navigationController = UINavigationController(rootViewController: interestsViewController)
            window?.rootViewController = navigationController
        } else {
            // Show the main view controller
            let mainViewController = SwipeViewController()
            let navigationController = UINavigationController(rootViewController: mainViewController)
            window?.rootViewController = navigationController
        }
        
        window?.makeKeyAndVisible()
        
        // Set the global appearance for back button text color to orange
        let backButtonAppearance = UIBarButtonItem.appearance()
        backButtonAppearance.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)


        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    func clearBookmarkedEvents() {
        UserDefaults.standard.removeObject(forKey: "bookmarkedEvents1")
    }
}
