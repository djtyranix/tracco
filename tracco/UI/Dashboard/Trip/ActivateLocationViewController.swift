//
//  ActivateLocationViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 12/06/22.
//

import UIKit

@objc protocol ActivateLocationViewControllerDelegate: AnyObject
{
    @objc optional func onGoToSettings()
}

class ActivateLocationViewController: UIViewController
{
    public weak var delegate: ActivateLocationViewControllerDelegate?
    
    @IBOutlet weak var alertLabel: UILabel!
    
    public init()
    {
        super.init(nibName: "ActivateLocationViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func onGoToSettingsButton(_ sender: UIButton)
    {
        delegate?.onGoToSettings?()
    }
}
