//
//  MiniCardView.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import UIKit

@IBDesignable class MiniCardView: UIView {

    var cornerRadius: CGFloat = 12
    var offsetWidth: CGFloat = 0
    var offsetHeight: CGFloat = 1
    var blur: CGFloat = 10
    
    var offsetShadowOpacity: Float = 0.8
    var shadowColor = UIColor.init(hex: "#DDDDDDFF")
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: offsetWidth, height: offsetHeight)
        layer.shadowPath = nil
        layer.shadowRadius = blur / 2.0
        layer.shadowOpacity = offsetShadowOpacity
    }
}
