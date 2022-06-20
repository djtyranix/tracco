//
//  RoundingDigit.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 15/06/22.
//

import Foundation

class RoundingDigit
{
    enum Kind { case currency, number }
    
    public var value: Double
    public var units: SystemUnits
    public var kind: Kind
    
    public var symbol: String? { get {
        if (units == .base) { return nil }
        if (units == .kilo) { return "k" }
        if (units == .mega) { return "m" }
        if (units == .giga) { return kind == .currency ? "bn" : "g" }
        return kind == .currency ? "tn" : "t"
    }}
    
    public init(_ value: Double, kind: Kind)
    {
        self.kind = kind
        if (value >= 1e12)
        {
            self.value = value / 1e12
            self.units = .tera
        }
        else if (value >= 1e9)
        {
            self.value = value / 1e9
            self.units = .giga
        }
        else if (value >= 1e6)
        {
            self.value = value / 1e6
            self.units = .mega
        }
        else if (value >= 1e4)
        {
            self.value = value / 1e3
            self.units = .kilo
        }
        else
        {
            self.value = value
            self.units = .base
        }
    }
    
    public func getString(precision: Int) -> String
    {
        let format = String(format: "%%.%df", precision)
        let string = String(format: format, self.value)
        if let symbol = symbol { return string + symbol }
        return string
    }
}
