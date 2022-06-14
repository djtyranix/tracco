//
//  AllowNotificationViewController.swift
//  carbonless
//
//  Created by Michael Ricky on 13/06/22.
//

import UIKit

class AllowNotificationViewController: UIViewController {
    
    @IBAction func allowNotificationTapped(_ sender: UIButton) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if error != nil {
                // Handle the error here.
                print(error!)
            }
            
            // Enable or disable features based on the authorization.
            DispatchQueue.main.async {
                self.goToMainMenu()
            }
        }
    }
    
    @IBAction func notNowTapped(_ sender: UIButton) {
        goToMainMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func goToMainMenu() {
        guard let window = UIApplication
            .shared
            .connectedScenes
            .flatMap({ ($0 as? UIWindowScene)?.windows ?? [] })
            .first(where: { $0.isKeyWindow }) else {
            return
        }
        
        UserDefaults.standard.set(true, forKey: "isOnboardingFinished")
        
        let mainMenu = self.storyboard?.instantiateViewController(withIdentifier: "mainmenu")
        self.view.window?.rootViewController = mainMenu
        
        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .transitionCrossDissolve

        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.3

        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
        { completed in
            // maybe do something on completion here
        })
    }
}
