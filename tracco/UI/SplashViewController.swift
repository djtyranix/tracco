//
//  SplashViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 28/06/22.
//

import UIKit

class SplashViewController: UIViewController
{
    @IBOutlet weak var animationImageView: UIImageView!

    public var completion: (() -> Void)?
    
    private let targetFPS: Double = 60.0
    
    private let imageSequence: [UIImage] = {
        // load images
        let indexStart = 1
        let indexStop = 70
        let sequenceLength = indexStop - indexStart
        
        let assetFormat = "AAA_%05d"
        
        var images: [UIImage] = []
        images.reserveCapacity(sequenceLength)
        
        for i in indexStart...indexStop
        {
            let assetName = String(format: assetFormat, i)
            let image = UIImage(named: assetName)
            images.append(image!)
        }
        
        return images
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if completion == nil { completion = { self.dismiss(animated: true) } }
        
        animationImageView.animationImages = imageSequence
        animationImageView.animationDuration = Double(imageSequence.count) / targetFPS
        animationImageView.animationRepeatCount = 0
        animationImageView.startAnimatingWithCompletionBlock(block: completion!)
    }
}
