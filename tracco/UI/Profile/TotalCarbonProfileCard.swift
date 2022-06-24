//
//  TotalCarbonProfileCard.swift
//  tracco
//
//  Created by Fannisa Rahmah on 20/06/22.
//

import Foundation
import UIKit

@IBDesignable
class TotalCarbonProfileCard: UIView
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBInspectable var title: String! { didSet {
        titleLabel.text = title
    }}
    
    @IBInspectable var logo: UIImage! { didSet {
        logoImageView.image = logo
    }}
    
    @IBInspectable var value: String! { didSet {
        valueLabel.text = value
    }}
    
    @IBInspectable var text: String! { didSet {
        textLabel.text = text
    }}
    
    @IBInspectable var detail: String! { didSet {
        detailLabel.text = detail
    }}
    
    @IBInspectable var image: UIImage! { didSet {
        cardImageView.image = image
    }}
    
    @IBInspectable var labelColor: UIColor! { didSet {
        titleLabel.textColor = labelColor
        detailLabel.textColor = labelColor
        valueLabel.textColor = labelColor
        textLabel.textColor = labelColor
        logoImageView.tintColor = labelColor
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
