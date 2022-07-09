//
//  SceneDelegate.swift
//  tracco
//
//  Created by Michael Ricky on 11/06/22.
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    var window: UIWindow?
    var locationManager = CLLocationManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        let isOnboardingFinished = UserDefaults.standard.bool(forKey: "isOnboardingFinished")
        let initialStoryboard = isOnboardingFinished ? "Main" : "Onboarding"
        
        let launchAnimation = SplashViewController(
            nibName: "SplashViewController",
            bundle: nil
        )
        
        launchAnimation.completion = { [unowned self] in
            let mainStoryBoard = UIStoryboard(name: initialStoryboard, bundle: nil)
            let vc = mainStoryBoard.instantiateInitialViewController()
            self.window?.rootViewController = vc
            
            guard let window = window
            else { return }

            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve) {}
        }
        
        self.window?.rootViewController = launchAnimation
        
        GlobalPublisher.addObserver(self)
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
        let theme = SettingsBundle.ThemeValue.from(SettingsBundle.theme)
        window?.overrideUserInterfaceStyle = theme.style
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}

extension SceneDelegate: GlobalEvent
{
    func onTripStarted() { locationManager.delegate = self }
    func onTripEnded()   { locationManager.delegate = nil }
}

// scene will listen if only trip has started and checked for authorization change
// and warns the user anywhere in the app that tracking has been forcefully ended
// because the app can no longer track the user
extension SceneDelegate: CLLocationManagerDelegate
{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        guard   manager.authorizationStatus == .denied ||
                manager.authorizationStatus == .notDetermined,
                let rootViewController = window?.rootViewController
        else { return }
        
        // alert
        let alert = AppAlertController(
            title: "Tracking Stopped",
            message: "We were unable to locate you due to changes in location access permission.",
            image: UIImage(named: "Lost")
        )
        alert.addAction(AppAlertAction(title: "I Understand", style: .default) { _ in
            alert.dismiss(animated: true)
        })
        
        // forcefully cancel ongoing trip
        GlobalPublisher.shared.onTripEnded()
        rootViewController.dismiss(animated: true)
        rootViewController.present(alert, animated: true)
    }
}
