//
//  ViewAccessory.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 14/06/22.
//

import Foundation
import UIKit

extension UIView
{
    enum AccessoryAlignment { case left, middle, right }
    
    func addDoneButton(textField: UITextField, alignment: AccessoryAlignment)
    {
        let keypadToolbar: UIToolbar = UIToolbar()
        let barDoneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: textField, action: #selector(UITextField.resignFirstResponder))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        if (alignment == .left)     { keypadToolbar.items = [barDoneButton, flexibleSpace] }
        if (alignment == .middle)   { keypadToolbar.items = [flexibleSpace, barDoneButton, flexibleSpace] }
        if (alignment == .right)    { keypadToolbar.items = [flexibleSpace, barDoneButton] }
        
        keypadToolbar.sizeToFit()
        textField.inputAccessoryView = keypadToolbar
    }
}
