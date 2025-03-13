//
//  GeneralTabbar.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 16/11/24.
//

import UIKit


class GeneralTabbarController: UITabBarController {

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
        let eventsVC = UINavigationController(rootViewController: EventViewController())
        eventsVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "house"), tag: 0)
        
    
        let profileVC = UINavigationController(rootViewController: UnauthenticatedProfileViewController())
        
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        viewControllers = [eventsVC, profileVC]
    }
}

#Preview {
    GeneralTabbarController()
}
