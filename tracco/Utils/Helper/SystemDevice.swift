//
//  SystemDevice.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 04/07/22.
//

import Foundation
import UIKit

class SystemDevice
{
    static func openAppSettings()
    {
        if let bundleIdentifier = Bundle.main.bundleIdentifier
        {
            let path = UIApplication.openSettingsURLString + bundleIdentifier
            let url = URL(string: path)!
            UIApplication.shared.open(url)
        }
        else
        {
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        }
    }
}
