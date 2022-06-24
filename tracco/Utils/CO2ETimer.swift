//
//  CarbonEmissionWeekly.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 22/06/22.
//

import Foundation

struct CO2ETimer: Codable
{
    var carbonEmissionInKg: Double
    var beginDate: Date
    var endDate: Date
    
    // return carbon emission in kg with time frequency
    func withFrequency(_ frequency: TimeFrequency) -> Double
    {
        let components  = Calendar.current.dateComponents([.day], from: beginDate, to: endDate)
        let resultDays  = Double(components.day ?? 0)
        let avgDays     = Double(frequency.rawValue)
        let divident    = resultDays < avgDays ? 1.0 : resultDays / avgDays
        return carbonEmissionInKg / divident
    }
}
