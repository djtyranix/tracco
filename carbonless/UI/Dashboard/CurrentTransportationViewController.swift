//
//  CurrentTransportationViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit

@objc protocol CurrentTransportationViewControllerDelegate: AnyObject
{
    @objc optional func onEndTripButton(_ sender: UIButton)
    @objc optional func onChangeTransportationButton(_ sender: UIButton)
}

class CurrentTransportationViewController: UIViewController
{
    public weak var delegate: CurrentTransportationViewControllerDelegate?
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var carbonEmissionLabel: UILabel!
    @IBOutlet weak var approxCostLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    public init()
    {
        super.init(nibName: "CurrentTransportationViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func onEndTripButton(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onEndTripButton?(sender)
    }
    
    @IBAction func onChangeTransportationButton(_ sender: UIButton)
    {
        delegate?.onChangeTransportationButton?(sender)
    }
    
}
