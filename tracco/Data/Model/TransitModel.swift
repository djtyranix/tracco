//
//  TransitModel.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 16/06/22.
//

import Foundation

struct TransitModel: Codable
{
    // transit path
    var transitPath: TransitPath
    // carbon emission in kg
    var carbonEmissionInKg: Double
    // cost of transportation in IDR
    var costInIDR: Double
}

typealias TripModel = [TransitModel]
