//
//  MainButton.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 21/06/22.
//

import UIKit
 
@IBDesignable
class StateBackgroundButton: UIButton
{
    override var isEnabled: Bool { didSet {
        super.isEnabled = isEnabled
        self.alpha = isEnabled ? 1.0 : 0.5
    }}
}
