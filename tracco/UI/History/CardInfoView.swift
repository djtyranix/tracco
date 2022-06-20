//
//  CardInfoView.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 14/06/22.
//

import Foundation
import UIKit

@IBDesignable
class CardInfoView: UIView
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var logoOverlayImageView: UIImageView!
    
    @IBInspectable var title: String! { didSet {
        titleLabel.text = title
    }}
    
    @IBInspectable var logo: UIImage! { didSet {
        logoImageView.image = logo
        logoOverlayImageView.image = logo
    }}
    
    @IBInspectable var value: String! { didSet {
        valueLabel.text = value
    }}
    
    @IBInspectable var detail: String! { didSet {
        detailLabel.text = detail
    }}
    
    @IBInspectable var labelColor: UIColor! { didSet {
        titleLabel.textColor = labelColor
        detailLabel.textColor = labelColor
        valueLabel.textColor = labelColor
        logoImageView.tintColor = labelColor
        logoOverlayImageView.tintColor = labelColor
    }}
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadNib(self)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        loadNib(self)
    }
}
