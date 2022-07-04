//
//  MainButton.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 21/06/22.
//

import UIKit

// MARK: BUG
// foreground (title color) for state .disabled cannot be changed
// this will only happen if "style: plain" was set in the interface builder
//
// foreground (title color) for all kind of state works fine if
// in interface builder, button "style: default"
// but with button style default, we cannot configure image alignment and point size

@IBDesignable
class StateBackgroundButton: UIButton
{
    var buttonFeedbackGenerator: UIImpactFeedbackGenerator?
    
    @IBInspectable var impactFeedbackStyle: Int = 0 { didSet {
        var style: UIImpactFeedbackGenerator.FeedbackStyle?
        if (impactFeedbackStyle <= 0) { style = nil }
        if (impactFeedbackStyle == 1) { style = .light }
        if (impactFeedbackStyle == 2) { style = .medium }
        if (impactFeedbackStyle >= 3) { style = .heavy }
        if (style == nil) { return }
        buttonFeedbackGenerator = UIImpactFeedbackGenerator(style: style!)
    }}
    
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
    
    static let appButtonFont = UIFont(name: "Nunito-SemiBold", size: 16)!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State)
    {
        guard let title = title
        else
        {
            super.setTitle(title, for: state)
            return
        }
        let attributed = NSAttributedString(
            string: title,
            attributes: [.font : StateBackgroundButton.appButtonFont]
        )
        super.setAttributedTitle(attributed, for: state)
    }
    
    @objc private func buttonPressed()
    {
        buttonFeedbackGenerator?.impactOccurred()
    }
}
