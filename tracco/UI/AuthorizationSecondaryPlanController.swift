//
//  ActivateLocationViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 12/06/22.
//

import UIKit

protocol AuthorizationSecondaryPlanDelegate: AnyObject
{
    func onGoToSettings()
    func onCancel()
}

extension AuthorizationSecondaryPlanDelegate
{
    func onGoToSettings()
    {
        if let bundleIdentifier = Bundle.main.bundleIdentifier
        {
            let path = UIApplication.openSettingsURLString + bundleIdentifier
            let url = URL(string: path)!
            UIApplication.shared.open(url)
        }
        else
        {
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        }
    }
    
    func onCancel() {}
}

class AuthorizationSecondaryPlanController: UIViewController
{
    public weak var delegate: AuthorizationSecondaryPlanDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alertLabel: UILabel!
    
    public var message: String? { didSet {
        if (alertLabel != nil) { alertLabel.text = message }
    }}
    
    public var image: UIImage? { didSet {
        if (imageView != nil) { imageView.image = image }
    }}
    
    public init(message: String?, image: UIImage?)
    {
        self.image = image
        self.message = message
        super.init(nibName: "AuthorizationSecondaryPlanController", bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // invoke didSet property observer
        ({ self.image = self.image })()
        ({ self.message = self.message })()
    }
    
    @IBAction func onGoToSettingsButton(_ sender: UIButton)
    {
        delegate?.onGoToSettings()
    }
    
    @IBAction func onCancelButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onCancel()
    }
}
