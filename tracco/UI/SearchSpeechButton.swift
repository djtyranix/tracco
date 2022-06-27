//
//  SearchSpeechButton.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 26/06/22.
//

import UIKit

@IBDesignable
class SearchSpeechButton: UIButton
{
    @IBOutlet weak var micImageView: UIImageView!
    
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
    
    public func isMicPressed(event: UIEvent) -> Bool
    {
        guard let touches = event.allTouches
        else { return false }
        for touch in touches
        {
            let point = touch.location(in: self)
            if self.micImageView.frame.contains(point) { return true }
        }
        return false
    }
}
