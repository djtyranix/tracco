//
//  AnimTabBarController.swift
//  tracco
//
//  Created by Michael Ricky on 27/06/22.
//

import UIKit

// view controllers who gets overlaid by OnGoingTripSheet
struct BottomViewAdjustment
{
    var isRaised: Bool
    let isReversed: Bool
    weak var vc: UIViewController?
    weak var constraint: NSLayoutConstraint?
    
    init(vc: UIViewController)
    {
        self.vc = vc
        self.isRaised = false
        constraint = vc.view.constraints.first(where: { $0.firstAttribute == .bottom && $0.secondAttribute == .bottom })
        isReversed = constraint?.secondItem === vc.view
    }
    
    mutating func adjust(_ sheet: OnGoingTripSheet)
    {
        let isSheetShown = sheet.isHidden == false
        
        // make sure to adjust only when needed
        guard isSheetShown != self.isRaised
        else { return }
        
        let onGoingTripSheetHeight  = sheet.frame.height
        let bottomViewPadding       = 20.0
        var heightAdjustment        = onGoingTripSheetHeight + bottomViewPadding
        if self.isRaised            { heightAdjustment *= -1 }
        if isReversed == true       { heightAdjustment *= -1 }
        
        constraint?.constant        += heightAdjustment
        
        self.isRaised = !self.isRaised
    }
}

class AnimTabBarController: UITabBarController
{
    public static weak var shared: AnimTabBarController?
    
    private var onTripTimer: Timer?
    private var prevModel: TransitModel?
    private var adjustments: [BottomViewAdjustment] = []
    
    public let onGoingTripSheet: OnGoingTripSheet = {
        let view = OnGoingTripSheet()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden               = true
        view.layer.cornerRadius     = 8
        view.backgroundColor        = UIColor(named: "OnGoingButtonBackground")
        view.labelColor             = UIColor(named: "OnGoingButtonForeground")
        return view
    }()
    
    override func viewDidLoad()
    {
        AnimTabBarController.shared = self
        
        self.view.addSubview(onGoingTripSheet)
        
        GlobalPublisher.addObserver(self)
        onGoingTripSheet.isUserInteractionEnabled = true
        onGoingTripSheet.addTarget(self, action: #selector(onGoingTripButton(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            onGoingTripSheet.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor, constant: -20),
            onGoingTripSheet.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            onGoingTripSheet.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            onGoingTripSheet.heightAnchor.constraint(equalToConstant: 76)
        ])
        
        super.viewDidLoad()
        delegate = self
    }
    
    @objc private func onGoingTripButton(_ sender: OnGoingTripSheet)
    {
        if let instanceOnPause = OnTripViewController.instanceOnPause
        {
            self.present(instanceOnPause, animated: true)
        }
    }
    
    public func observeAdjustment(_ vc: UIViewController)
    {
        let mostBottom = vc.view.constraints.first(where: {
            $0.firstAttribute == .bottom && $0.secondAttribute == .bottom
        })
        if mostBottom == nil { return }
        var adjustment = BottomViewAdjustment(vc: vc)
        adjustment.adjust(onGoingTripSheet)
        adjustments.append(adjustment)
    }
}

extension AnimTabBarController: GlobalEvent
{
    // this will not get updated if user doesn't move
    func onTripTransitModelUpdated(_ model: TransitModel)
    {
        prevModel = model
        onGoingTripSheet.type = model.type
        onGoingTripSheet.distance = model.distanceInKm
    }
    
    // this will update the time even though user doesn't move
    @objc func onTripTimeUpdate()
    {
        guard let prevModel = prevModel
        else { return }
        
        let seconds = Date().timeIntervalSince(prevModel.beginDate)
        onGoingTripSheet.durationInSeconds = seconds
    }
    
    func onTripStarted()
    {
        onTripTimer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(onTripTimeUpdate),
            userInfo: nil,
            repeats: true
        )
        
        onGoingTripSheet.isHidden = false
        // adjust every view that is overlayed by trip sheet
        for i in 0..<(AnimTabBarController.shared?.adjustments.count ?? 0) {
            AnimTabBarController.shared?.adjustments[i].adjust(onGoingTripSheet)
        }
    }
    
    func onTripEnded()
    {
        onTripTimer?.invalidate()
        onTripTimer = nil
        
        onGoingTripSheet.isHidden = true
        // adjust every view that is overlayed by trip sheet
        for i in 0..<(AnimTabBarController.shared?.adjustments.count ?? 0) {
            AnimTabBarController.shared?.adjustments[i].adjust(onGoingTripSheet)
        }
    }
}

extension AnimTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        let tabViewControllers = tabBarController.viewControllers!
        guard let toIndex = tabViewControllers.firstIndex(of: viewController) else {
            return false
        }
            
        animateToTab(toIndex: toIndex)
        
        return true
    }
    
    func animateToTab(toIndex: Int)
    {
        let tabViewControllers = viewControllers!
        let fromView = selectedViewController!.view
        let toView = tabViewControllers[toIndex].view
        let fromIndex = tabViewControllers.firstIndex(of: selectedViewController!)
        
        guard fromIndex != toIndex else {return}
        
        // Add the toView to the tab bar view
        fromView!.superview!.addSubview(toView!)
        
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width;
        let scrollRight = toIndex > fromIndex!;
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView!.center = CGPoint(x: fromView!.center.x + offset, y: toView!.center.y)
        
        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            
            // Slide the views by -offset
            fromView!.center = CGPoint(x: fromView!.center.x - offset, y: fromView!.center.y);
            toView!.center   = CGPoint(x: toView!.center.x - offset, y: toView!.center.y);
            
        }, completion: { finished in
            
            // Remove the old view from the tabbar view.
            fromView!.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
}
