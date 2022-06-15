//
//  HomeTripViewController.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import UIKit

class HomeTripViewController: UIViewController {

    @IBOutlet weak var trackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setTrackingButtonFont()
    }
    
    private func setTrackingButtonFont() {
        if #available(iOS 15.0, *) {
            guard var config = trackButton.configuration else {
                return
            }
            
            config.attributedTitle = try! AttributedString( NSAttributedString(string: "Start Tracking", attributes: [
                .font: UIFont(name: "Nunito-Bold", size: 17)!,
            ]), including: AttributeScopes.UIKitAttributes.self
            )
            
            trackButton.configuration = config
        }
    }
}
