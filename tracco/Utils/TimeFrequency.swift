//
//  TimeFrequency.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 22/06/22.
//

import Foundation

// time frequency and the long of days
enum TimeFrequency: UInt, CaseIterable
{
    case daily          = 1
    case weekly         = 7
    case fortnightly    = 15
    case monthly        = 30
    case quarterly      = 90
    case halfly         = 180
    case yearly         = 365
}
