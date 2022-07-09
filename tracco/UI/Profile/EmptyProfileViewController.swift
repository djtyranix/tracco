//
//  EmptyProfileViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 09/07/22.
//

import UIKit

class EmptyProfileViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AnimTabBarController.shared?.observeAdjustment(self)
    }
}
