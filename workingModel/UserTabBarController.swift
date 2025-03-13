import UIKit
import FirebaseAuth

class UserTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white // Set the tab bar background color to white
        appearance.stackedLayoutAppearance.selected.iconColor = .orange // Set icon color when selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.orange // Set title color when selected
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = .gray // Default icon color
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray // Default title color
        ]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        setupTabs()
    }
    
    private func setupTabs() {
        let feedVC = UINavigationController(rootViewController:EventListViewController())
        feedVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "house"), tag: 0)
        
        let chatVC = UINavigationController(rootViewController: ChatViewController())
        chatVC.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "bubble.right"), tag: 1)
        
//        let collegeFeedVC = UINavigationController(rootViewController: CollegeFeedViewController())
//        collegeFeedVC.tabBarItem = UITabBarItem(title: "Community", image: UIImage(systemName: "newspaper"), tag: 2)
        
        let swipeVC = UINavigationController(rootViewController: SwipeViewController())
        swipeVC.view.backgroundColor = .white
        swipeVC.tabBarItem = UITabBarItem(title: "Swipe", image: UIImage(systemName: "rectangle.on.rectangle.angled"), tag: 3)
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController()) // Profile tab
        profileVC.view.backgroundColor = .white
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        
        viewControllers = [feedVC, chatVC, swipeVC, profileVC]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 3 {
            handleSwipeTabSelection()
        }
    }
    
    private func handleSwipeTabSelection() {
        guard let userId = Auth.auth().currentUser?.uid else {
            // Handle the case where the user is not authenticated
            promptUserToSignIn()
            return
        }
        
        let hasLoggedInBeforeKey = "hasLoggedInBefore_\(userId)"
        let isFirstTimeUser = !UserDefaults.standard.bool(forKey: hasLoggedInBeforeKey)
        
        if isFirstTimeUser {
            let interestsVC = InterestsViewController()
            interestsVC.isFirstTimeUser = true
            interestsVC.userID = userId
            navigationController?.pushViewController(interestsVC, animated: true)
        } else {
            if let swipeVC = viewControllers?[3] as? UINavigationController {
                swipeVC.popToRootViewController(animated: false)
            }
        }
    }
    
    private func promptUserToSignIn() {
        let alert = UIAlertController(title: "Sign In Required", message: "Please sign in to access this feature.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { _ in
            // Navigate to the sign-in view controller
            self.showSignInViewController()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showSignInViewController() {
        // Code to show the sign-in view controller
        let signInVC = LoginViewController()
        let navController = UINavigationController(rootViewController: signInVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
}

