//
//  ChooseTransportationViewController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import UIKit

@objc protocol ChooseTransportationViewControllerDelegate: AnyObject
{
    @objc optional func onConfirmChanges(_ selected: TransportRadioButton?)
    @objc optional func onSelectionChanges(_ selected: TransportRadioButton?)
}

class ChooseTransportationViewController: UIViewController
{
    public weak var delegate: ChooseTransportationViewControllerDelegate?
    public var dataSource: [TransportRadioButton]?
    private(set) var selectedIndex: Int = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    public init(_ dataSource: [TransportRadioButton]?)
    {
        super.init(nibName: "ChooseTransportationViewController", bundle: nil)
        self.dataSource = dataSource
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onConfirmChanges(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        delegate?.onConfirmChanges?(nil)
    }
}
