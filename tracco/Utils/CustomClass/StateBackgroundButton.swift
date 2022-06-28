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
    @IBInspectable var cornerRadius: CGFloat = 8 { didSet {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }}
    
    @IBInspectable var backgroundNormalColor: UIColor! { didSet {
        self.backgroundColor = backgroundNormalColor
    }}
    
    @IBInspectable var backgroundDisabledColor: UIColor!
    
    @IBInspectable var foregroundNormalColor: UIColor! { didSet {
        setTitleColor(foregroundNormalColor, for: .normal)
        self.tintColor = foregroundNormalColor
    }}
    
    @IBInspectable var foregroundDisabledColor: UIColor! { didSet {
        setTitleColor(foregroundDisabledColor, for: .disabled)
    }}
    
    override var isEnabled: Bool { didSet {
        super.isEnabled = isEnabled
        self.tintColor = isEnabled ? foregroundNormalColor : foregroundDisabledColor
        self.backgroundColor = isEnabled ? backgroundNormalColor : backgroundDisabledColor
    }}
    
    override var isHighlighted: Bool { didSet {
        self.alpha = isHighlighted ? 0.7 : 1.0
    }}
}
