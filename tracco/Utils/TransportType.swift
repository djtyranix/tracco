//
//  File.swift
//  practice-map
//
//  Created by Ramadhan Kalih Sewu on 09/06/22.
//

import Foundation
import UIKit

// transportation and their average carbon emission
enum TransportType: CO2EBase, Codable, CaseIterable
{
    case train  = 0.04
    case bus    = 0.08
    case car    = 0.27
    case motor  = 0.15
    
    public var color: UIColor { get {
        if (self == .car)       { return .green }
        if (self == .motor)     { return .yellow }
        if (self == .bus)       { return .blue }
        if (self == .train)     { return .red }
        return .white
    }}
    
    public var backgroundColor: UIColor? { get {
        if (self == .car)       { return UIColor(named: "CarBackground") }
        if (self == .motor)     { return UIColor(named: "MotorBackground") }
        if (self == .bus)       { return UIColor(named: "BusBackground") }
        if (self == .train)     { return UIColor(named: "TrainBackground") }
        return .white
    }}
    
    public var image: UIImage? { get {
        if (self == .car)       { return UIImage(named: "Car") }
        if (self == .motor)     { return UIImage(named: "Motor") }
        if (self == .bus)       { return UIImage(named: "Bus") }
        if (self == .train)     { return UIImage(named: "Train") }
        return UIImage(systemName: "questionmark.square")
    }}
    
    public var annotationImage: UIImage? { get {
        if (self == .car)       { return UIImage(named: "MapCarPin") }
        if (self == .motor)     { return UIImage(named: "MapMotorPin") }
        if (self == .bus)       { return UIImage(named: "MapBusPin") }
        if (self == .train)     { return UIImage(named: "MapTrainPin") }
        return nil
    }}
    
    public func cost(_ kilometers: Double) -> Double
    {
        if (self == .car)       { return 1550 * kilometers }
        if (self == .motor)     { return 140  * kilometers }
        if (self == .bus)       { return 3000 * kilometers }
        if (self == .train)
        {
            // first 25 km fare is 3000
            let first25 = 3000.0
            // next 10 km fare is 1000
            let every10 = kilometers <= 25 ? 0 : ceil((kilometers - 25) / 10) * 1000
            // first 25 + every 10 multiply of 10
            return first25 + every10
        }
        return Double.nan
    }
}
