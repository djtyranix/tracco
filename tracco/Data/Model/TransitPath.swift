//
//  TransitData.swift
//  practice-map
//
//  Created by Ramadhan Kalih Sewu on 09/06/22.
//

import Foundation
import MapKit

struct TransitPath : Codable
{
    // Trip Start Location
    var startLatitude: Double
    var startLongitude: Double
    var startTitle: String?
    
    // Trip End Location
    var endLatitude: Double
    var endLongitude: Double
    var endTitle: String?
}
