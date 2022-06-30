//
//  TransportAnnotationView.swift
//  practice-map
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import MapKit

class TransportAnnotationView: MKAnnotationView
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
      
    override init(annotation: MKAnnotation?, reuseIdentifier: String?)
    {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        guard let annotation = annotation as? TransportAnnotation
        else { return }
        
        self.canShowCallout = true
        if let image = annotation.type.annotationImage
        {
            self.image = image
            // we want to offset y so bottom of the image (i.e "tip of pin") points
            // exactly in the middle of coordinate in the map
            self.centerOffset = CGPoint(x: 0, y: -image.size.height / 2)
        }
    }
    
    public func configureCalloutView()
    {
        guard let annotation = annotation as? TransportAnnotation
        else { return }
        
        if annotation.isOngoing
        {
            let calloutView = self.detailCalloutAccessoryView as? TransportCalloutOngoingView ?? TransportCalloutOngoingView()
            calloutView.type = annotation.type
            calloutView.date = annotation.beginDate
            self.detailCalloutAccessoryView = calloutView
        }
        else
        {
            let calloutView = self.detailCalloutAccessoryView as? TransportCalloutView ?? TransportCalloutView()
            calloutView.type            = annotation.type
            calloutView.distanceInKm    = annotation.distanceInKm
            calloutView.costInIDR       = annotation.costInIDR
            calloutView.carbonInKg      = annotation.carbonEmissionInKg
            calloutView.setDurationLabel(beginDate: annotation.beginDate, endDate: annotation.endDate)
            self.detailCalloutAccessoryView = calloutView
        }
    }
}
