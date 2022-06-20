//
//  TransportationCostVM.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 13/06/22.
//

import Foundation
import UIKit

class TransportationCostVM
{
    public var totalCostInIDR: Double { didSet {
        // if using approximation, text displayed in text field should not be overriden
        if isUsingCostApproximation { totalCostInIDRText = String(Int(totalCostInIDR)) }
    }}
    
    public var isUsingCostApproximation: Bool { didSet {
        totalCostInIDRText = isUsingCostApproximation ? String(format: "%.2f", totalCostInIDR) : nil
    }}
    
    @Published
    private(set) var totalCostInIDRText: String?
    
    public init(_ totalCostInIDR: Double, useApproximation: Bool)
    {
        self.totalCostInIDR = totalCostInIDR
        self.isUsingCostApproximation = useApproximation
        ({ self.totalCostInIDR = self.totalCostInIDR })()
        ({ self.isUsingCostApproximation = self.isUsingCostApproximation })()
    }
}
