//
//  ViewHelper.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import UIKit

@discardableResult func loadNib<T: UIView>(_ nibView: T) -> UIView
{
    let bundle = Bundle(for: T.self)
    let view = bundle.loadNibNamed(String(describing: T.self),owner: nibView, options: nil)![0] as! UIView
    view.frame = nibView.bounds
    nibView.addSubview(view)
    return view
}
