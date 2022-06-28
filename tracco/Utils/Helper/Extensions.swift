//
//  Extensions.swift
//  tracco
//
//  Created by Michael Ricky on 15/06/22.
//

import Foundation
import UIKit
import CoreData
import MapKit

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension UIView
{
    func snapshot() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension CLPlacemark
{
    public var regionText: String { get {
        
        let details: [String?] = [
            self.thoroughfare,
            self.subLocality,
            self.locality,
            self.administrativeArea
        ]
        
        var buffer = ""
        
        for (i, detail) in details.enumerated()
        {
            if let string = detail
                { buffer += string }
            if buffer.isEmpty == false && i != details.count - 1 && details[i + 1] != nil
                { buffer += ", " }
        }
        
        return buffer.isEmpty ? "Unknown Administrative Region" : buffer
    }}
}
