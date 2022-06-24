//
//  LocationCoordinate2D.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 22/06/22.
//

import Foundation
import CoreLocation

struct LocationCoordinate2D: Codable
{
    var latitude: Double
    var longitude: Double
    
    init(_ location: CLLocationCoordinate2D)
    {
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
    
    init(latitude: Double, longitude: Double)
    {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension CLLocationCoordinate2D
{
    init(_ location: LocationCoordinate2D)
    {
        self.init(latitude: location.latitude, longitude: location.longitude)
    }
}
