//
//  TransportAnnotation.swift
//  practice-map
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import MapKit

class TransportAnnotation: NSObject, MKAnnotation
{
    // MARK: MKAnnotation Protocol
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    // MARK: Custom Property
    var type: TransportType
    
    init(coordinate: CLLocationCoordinate2D, subtitle: String?, type: TransportType)
    {
        self.coordinate = coordinate
        self.title = "\(type)".capitalized
        self.subtitle = subtitle
        self.type = type
    }
}
