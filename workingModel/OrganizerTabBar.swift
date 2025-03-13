//
//  OrganizerTabBar.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 19/11/24.
//

import UIKit
import MobileCoreServices

class OrganizerTabBar: UITabBarController {
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
            let eventsVC = UINavigationController(rootViewController: OrganizerEventListViewController())
            eventsVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "house"), tag: 0)
            
            let chatVC = UINavigationController(rootViewController: OrganiserChatViewController())
            chatVC.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "bubble.right"), tag: 1)
            
            let PostVC = UINavigationController(rootViewController: EventPostViewController())
            PostVC.tabBarItem = UITabBarItem(title: "Post", image: UIImage(systemName: "plus.app"), tag: 2)
            
           
            
            let profileVC = UINavigationController(rootViewController: OrganizerProfileViewController()) // Pass categories here if required
            profileVC.view.backgroundColor = .white // Fixed this line
            profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)
            
            
            
            viewControllers = [eventsVC,chatVC, PostVC,profileVC]
        }
    }

