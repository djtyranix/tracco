//
//  DestinationPlanVM.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import MapKit

class DestinationPlanVM
{
    public var targetLocation: CLLocation { didSet {
        CLGeocoder().reverseGeocodeLocation(targetLocation) { [unowned self] placemarks, error in
            if (error != nil)
            {
                self.error = error
                return
            }
            
            let latitude    = targetLocation.coordinate.latitude
            let longitude   = targetLocation.coordinate.longitude
            coordinateText  = String(format: "Latitude: %.4f, Longitude: %.4f", latitude, longitude)
            
            if let placemarks = placemarks
            {
                let mainPlacemark   = placemarks[0]
                titleText           = mainPlacemark.name
                regionText          = getRegionName(mainPlacemark)
            }
        }
    }}
    
    @Published
    private(set) var error: Error?
    
    @Published
    private(set) var titleText: String?
    
    @Published
    private(set) var regionText: String?
    
    @Published
    private(set) var coordinateText: String?
    
    public init(_ targetLocation: CLLocation)
    {
        // setter via closure to invoke didSet
        self.targetLocation = targetLocation
        ({ self.targetLocation = self.targetLocation })()
    }
    
    func getRegionName(_ placemark: CLPlacemark) -> String
    {
        let details: [String?] = [
            placemark.administrativeArea,
            placemark.locality,
            placemark.subLocality
        ]
        
        var buffer = ""
        
        for (i, detail) in details.enumerated()
        {
            if let string = detail
                { buffer += string }
            if buffer.isEmpty == false && i != details.count - 1 && details[i + 1] != nil
                { buffer += ", " }
        }
        
        return buffer.isEmpty ? "[Undefined Administrative Region]" : buffer
    }
}
