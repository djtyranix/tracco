//
//  AlertPresentationController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 12/06/22.
//

import Foundation
import UIKit

/// present a view controller in the center of the container view
class AlertPresentationController: FocusPresentationController
{
    public var inset: CGFloat = 0
    
    public static func getFrameOfPresentedViewInContainerView(_ presentedView: UIView, containerView: UIView, inset: CGFloat) -> CGRect
    {
        let targetWidth     = containerView.frame.width - 2 * inset
        let targetHeight    = presentedView.frame.height
        let originX         = inset
        let originY         = containerView.center.y - targetWidth / 2
        
        return CGRect(x: originX, y: originY, width: targetWidth, height: targetHeight)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect
    {
        guard let containerView = containerView, let presentedView = presentedView
        else { return .zero }
        
        return AlertPresentationController.getFrameOfPresentedViewInContainerView(presentedView, containerView: containerView, inset: inset)
    }
}
