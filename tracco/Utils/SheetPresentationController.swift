//
//  SheetPresentationController.swift
//  carbonless
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import UIKit

/// present a view controller from the bottom of the container view (ignoring safe area)
class SheetPresentationController: FocusPresentationController
{
    public static func getFrameOfPresentedViewInContainerView(_ presentedView: UIView, containerView: UIView) -> CGRect
    {
        let targetWidth     = containerView.bounds.width
        let targetHeight    = presentedView.frame.height

        var frame           = containerView.bounds
        frame.origin.y      += frame.size.height - targetHeight
        frame.size.width    = targetWidth
        frame.size.height   = targetHeight
        return frame
    }
    
    override var frameOfPresentedViewInContainerView: CGRect
    {
        guard let containerView = containerView, let presentedView = presentedView
        else { return .zero }
        
        return SheetPresentationController.getFrameOfPresentedViewInContainerView(presentedView, containerView: containerView)
    }
}
