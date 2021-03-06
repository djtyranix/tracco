//
//  TotalCarbonProfileCard.swift
//  tracco
//
//  Created by Fannisa Rahmah on 20/06/22.
//

import Foundation
import UIKit

@IBDesignable
class ReduceCarbonConciseCardView: UIView
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBInspectable var value: String! { didSet {
        valueLabel.text = value
    }}
    
    @IBInspectable var detail: String! { didSet {
        detailLabel.text = detail
    }}
    
    @IBInspectable var image: UIImage! { didSet {
        cardImageView.image = image
    }}
    
    @IBInspectable var labelColor: UIColor! { didSet {
        detailLabel.textColor = labelColor
        valueLabel.textColor = labelColor
        titleLabel.textColor = labelColor
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
