//
//  SplashViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 28/06/22.
//

import UIKit

class SplashViewController: UIViewController
{
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet weak var animationImageView: UIImageView!

    public var completion: (() -> Void)?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if completion == nil { completion = { self.dismiss(animated: true) } }
        
        let targetFPS: Double = 60.0
        let imageSequence: [UIImage] = {
            let assetFormat = "AAA_%05d"
            var images: [UIImage] = []
            images.reserveCapacity(100)
            for i in 1...70
            {
                let assetName = String(format: assetFormat, i)
                let image = UIImage(named: assetName)!
                images.append(image)
            }
            return images
        }()
        
        animationImageView.animationImages = imageSequence
        animationImageView.animationDuration = Double(imageSequence.count) / targetFPS
        animationImageView.animationRepeatCount = 0
        animationImageView.startAnimatingWithCompletionBlock(block: completion!)
    }
}
