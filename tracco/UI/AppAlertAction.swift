//
//  AppAlertAction.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 04/07/22.
//

import Foundation
import UIKit

class AppAlertAction
{
    enum Style { case `default`, `cancel`, `destructive` }
    
    open var title: String?
    open var style: AppAlertAction.Style
    open var handler: ((AppAlertAction) -> Void)?
    
    public init(title: String?, style: AppAlertAction.Style, handler: ((AppAlertAction) -> Void)? = nil)
    {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    public var button: StateBackgroundButton { get {
        let button = StateBackgroundButton()
        button.setTitle(self.title, for: .normal)
        button.cornerRadius = 8.0
        // custom coloring based on style
        switch (self.style)
        {
        case .`default`:
            button.backgroundNormalColor    = UIColor(named: "MainButtonBackground")
            button.backgroundDisabledColor  = UIColor(named: "MainButtonBackgroundDisabled")
            button.foregroundNormalColor    = UIColor(named: "MainButtonForeground")
            button.foregroundDisabledColor  = UIColor(named: "MainButtonForegroundDisabled")
            break
        case .`cancel`:
            let cancelColor = UIColor(named: "CancelButton")
            button.backgroundNormalColor    = .clear
            button.backgroundDisabledColor  = UIColor(named: "MainButtonBackgroundDisabled")
            button.foregroundNormalColor    = cancelColor
            button.foregroundDisabledColor  = UIColor(named: "MainButtonForegroundDisabled")
            button.layer.borderColor        = cancelColor?.cgColor
            button.layer.borderWidth        = 2.0
            break
        case .`destructive`:
            button.backgroundNormalColor    = UIColor(named: "DestructiveButtonBackground")
            button.backgroundDisabledColor  = UIColor(named: "DestructiveButtonBackgroundDisabled")
            button.foregroundNormalColor    = UIColor(named: "MainButtonForeground")
            button.foregroundDisabledColor  = UIColor(named: "MainButtonForegroundDisabled")
            break
        }
        return button
    }}
}
