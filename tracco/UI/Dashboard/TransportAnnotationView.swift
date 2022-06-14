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
        guard let myAnnotation = self.annotation as? TransportAnnotation
        else { return }
    }
}
