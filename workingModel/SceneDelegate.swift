//
//  SceneDelegate.swift
//  workingModel
//
//  Created by Yash's Mackbook on 12/11/24.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
   

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = KeyWindow(windowScene: windowScene)
                self.window = window

                window.rootViewController = UINavigationController(rootViewController: SplashViewController()) // Set your first VC here
                window.makeKeyAndVisible()
        // Add global tap gesture recognizer to dismiss keyboard
               addGlobalTapGesture()
        // Initialize the main window
//        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
//        window?.windowScene = windowScene
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//                tapGesture.cancelsTouchesInView = false
//        window?.addGestureRecognizer(tapGesture)
//
//        let window = UIWindow(windowScene: windowScene)
//            window.rootViewController = SplashViewController() // Set SplashViewController as the initial screen
//            window.makeKeyAndVisible()
//            self.window = window
    }
    private func addGlobalTapGesture() {
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
          tapGesture.cancelsTouchesInView = false
          window?.addGestureRecognizer(tapGesture)
      }

      @objc private func dismissKeyboard() {
          window?.endEditing(true)
      }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

