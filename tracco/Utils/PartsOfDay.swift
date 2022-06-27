//
//  PartsOfDay.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 26/06/22.
//

import Foundation

// ref: https://www.britannica.com/dictionary/eb/qa/parts-of-the-day-early-morning-late-morning-etc
enum PartsOfDay
{
    case morning
    case afternoon
    case evening
    case night
    
    static func from(_ date: Date) -> PartsOfDay
    {
        let hour = Calendar.current.component(.hour, from: date)
        if (hour >= 5 && hour <= 12)    { return .morning }
        if (hour >= 12 && hour <= 17)   { return .afternoon }
        if (hour >= 17 && hour <= 21)   { return .evening }
        return .night
    }
    
    static func now() -> PartsOfDay
    {
        return from(Date())
    }
    
    static func greetingText(_ when: PartsOfDay) -> String
    {
        return String(format: "Good %@ 👋", "\(when)".capitalized)
    }
}
