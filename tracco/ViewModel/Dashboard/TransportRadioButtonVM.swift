//
//  TransportRadioButtonVM.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 12/06/22.
//

import Foundation
import UIKit

class TransportRadioButtonVM
{
    public var type: TransportType { didSet {
        name = "\(type)".capitalized
        image = UIImage(systemName: "lanyardcard.fill")
    }}
    
    @Published
    private(set) var name: String!
    
    @Published
    private(set) var image: UIImage!
    
    public init(_ type: TransportType)
    {
        self.type = type
        ({ self.type = self.type })()
    }
}
