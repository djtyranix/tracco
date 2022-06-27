//
//  LongCardInfoView.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 24/06/22.
//

import UIKit

@IBDesignable
class LongCardInfoView: UIView
{
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet var logoOverlayImageView: [UIImageView]!
    
    @IBInspectable var logoImage: UIImage! { didSet {
        logoImageView.image = logoImage
    }}
    
    @IBInspectable var logoOverlayImage: UIImage! { didSet {
        logoOverlayImageView.forEach { $0.image = logoOverlayImage }
    }}
    
    @IBInspectable var title: String! { didSet {
        titleLabel.text = title
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
        logoOverlayImageView.forEach { $0.tintColor = labelColor }
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
