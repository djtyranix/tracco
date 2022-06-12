//
//  TransportRadioButton.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import UIKit

@IBDesignable
class TransportRadioButton: UIControl
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBInspectable var image: UIImage! { didSet {
        imageView.image = image
    }}
    
    @IBInspectable var title: String! { didSet {
        titleLabel.text = title
    }}
    
    @IBInspectable var bgColor: UIColor! { didSet {
        backgroundView.backgroundColor = bgColor
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
