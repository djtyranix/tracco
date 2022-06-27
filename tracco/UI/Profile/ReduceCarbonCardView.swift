//
//  ReduceCarbonCardView.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 25/06/22.
//

import UIKit

@IBDesignable
class ReduceCarbonCardView: UIView
{
    @IBOutlet weak var carbonValueLabel: UILabel!
    @IBOutlet weak var treesValueLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var labels: [UILabel]!
    
    @IBInspectable var carbonValue: String! { didSet {
        carbonValueLabel.text = carbonValue
    }}
    
    @IBInspectable var treesValue: String! { didSet {
        treesValueLabel.text = treesValue
    }}
    
    @IBInspectable var image: UIImage! { didSet {
        imageView.image = image
    }}
    
    @IBInspectable var labelColor: UIColor! { didSet {
        labels.forEach { $0.textColor = labelColor }
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
