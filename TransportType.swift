//
//  File.swift
//  practice-map
//
//  Created by Ramadhan Kalih Sewu on 09/06/22.
//

import Foundation
import UIKit

// transportation and their average carbon emission
enum TransportType: CO2EBase, CaseIterable
{
    case car          = 0.27
    case motorcycle   = 0.15
    case bus          = 0.08
    case train        = 0.04
    
    public var color: UIColor { get {
        if self == .car         { return .systemBlue }
        if self == .motorcycle  { return .systemRed }
        if self == .bus         { return .systemGreen }
        if self == .train       { return .black }
        return .white
    }}
    
    public func cost(_ kilometers: Double) -> Double
    {
        if (self == .car)           { return 99.0 * kilometers }
        if (self == .motorcycle)    { return 67.0 * kilometers }
        if (self == .bus)           { return 22.0 * kilometers }
        if (self == .train)         { return 12.0 * kilometers }
        return Double.nan
    }
}
