//
//  AnimTabBarController.swift
//  tracco
//
//  Created by Michael Ricky on 27/06/22.
//

import UIKit

struct BottomViewAdjustment
{
    weak var owner: UIViewController?
    weak var mostBottomLayoutConstraint: NSLayoutConstraint?
    var isRaised: Bool
}

class AnimTabBarController: UITabBarController
{
    public static var shared: AnimTabBarController?
    
    private var adjustments: [BottomViewAdjustment] = []
    
    public let onGoingTripSheet: OnGoingTripSheet = {
        let view = OnGoingTripSheet()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        
        onGoingTripSheet.isHidden = true
        
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
    
    public func observeAdjustment(_ mostBottom: NSLayoutConstraint, owner: UIViewController)
    {
        let adjustment = BottomViewAdjustment(
            owner: owner,
            mostBottomLayoutConstraint: mostBottom,
            isRaised: false
        )
        adjustments.append(adjustment)
        doCheckAdjustment(adjustments.count - 1)
    }
    
    private func doCheckAdjustment(_ index: Int)
    {
        let isSheetShown = onGoingTripSheet.isHidden == false
        
        // make sure the sate is not equal to be adjusted
        guard isSheetShown != adjustments[index].isRaised,
              let bottomConstaint = adjustments[index].mostBottomLayoutConstraint
        else { return }
        
        let onGoingTripSheetHeight  = onGoingTripSheet.frame.height
        let bottomViewPadding       = 24.0
        var heightAdjustment        = onGoingTripSheetHeight + bottomViewPadding
        
        if adjustments[index].isRaised { heightAdjustment *= -1 }
        bottomConstaint.constant    += heightAdjustment
        
        adjustments[index].isRaised = !adjustments[index].isRaised
    }
}

extension AnimTabBarController: GlobalEvent
{
    func onTripTransitModelUpdated(_ model: TransitModel)
    {
        onGoingTripSheet.type = model.type
        onGoingTripSheet.distance = model.distanceInKm
        onGoingTripSheet.durationInSeconds = model.endDate.timeIntervalSince(model.beginDate)
    }
    
    func onTripStarted()
    {
        onGoingTripSheet.isHidden = false
        // adjust every view that is overlayed by trip sheet
        if let counts = AnimTabBarController.shared?.adjustments.count
        {
            for i in 0..<counts
                { AnimTabBarController.shared?.doCheckAdjustment(i) }
        }
    }
    
    func onTripEnded()
    {
        onGoingTripSheet.isHidden = true
        // adjust every view that is overlayed by trip sheet
        if let counts = AnimTabBarController.shared?.adjustments.count
        {
            for i in 0..<counts
                { AnimTabBarController.shared?.doCheckAdjustment(i) }
        }
    }
}

extension AnimTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let tabViewControllers = tabBarController.viewControllers!
        guard let toIndex = tabViewControllers.firstIndex(of: viewController) else {
            return false
        }
            
        animateToTab(toIndex: toIndex)
        
        return true
    }
    
    func animateToTab(toIndex: Int) {
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
