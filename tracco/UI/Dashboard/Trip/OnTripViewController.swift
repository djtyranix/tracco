//
//  OnTripViewController.swift
//  tracco
//
//  Created by Ramadhan Kalih Sewu on 11/06/22.
//

import Foundation
import UIKit
import MapKit
import Combine

fileprivate func layoutBottomSheet(_ view: UIView)
{
    view.backgroundColor        = .systemBackground
    view.layer.cornerRadius     = 25
    view.layer.maskedCorners    = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
}

class OnTripViewController: UIViewController
{
    enum Segue: String { case summary = "summarySegue" }
    
    // first time vc elevation adjustment by SheetPresentationController
    private var elevationAdjustments: Set<UIViewController> = []
    
    private let chooseTransportationVC: ChooseTransportationViewController = {
        let vc = ChooseTransportationViewController(TransportType.allCases)
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let changeTransportationVC: ChangeTransportViewController = {
        let vc = ChangeTransportViewController(TransportType.allCases)
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let costTransportationVC: TransportationCostViewController = {
        let vc = TransportationCostViewController()
        vc.modalPresentationStyle = .custom
        layoutBottomSheet(vc.view)
        vc.view.addDoneButton(textField: vc.textField, alignment: .right)
        return vc
    }()
    
    private let currentTransportationVC: CurrentTransportationViewController = {
        let vc = CurrentTransportationViewController()
        layoutBottomSheet(vc.view)
        return vc
    }()
    
    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    private var isCostViewElevated = false { didSet {
        if (isCostViewElevated == oldValue) { return }
        let safeAreaBottomInset = self.view.safeAreaInsets.bottom
        // height should be cover the button and should revert back to original state
        // this will handle cases for simulator keyboard toggle (keyboard size not fixed)
        let costViewFloatingHeight = view.frame.height - costTransportationVC.view.frame.maxY
        let isCostViewFloating = costViewFloatingHeight != 0
        let heightToMove: CGFloat = isCostViewFloating ? costViewFloatingHeight : -(keyboardHeight - safeAreaBottomInset - 85)
        costTransportationVC.view.frame.origin.y += heightToMove
        // In order to adjust the extra height given by the SheetPresentationController (isElevated)
        // When about to elevated, bottom safe area inset are no longer relevant.
        // This will fix the issue where view height are kind of moving to the top
        let bottomConstraint = costTransportationVC.view.constraints.first(where: { $0.firstAttribute == .bottom })
        bottomConstraint?.constant += isCostViewFloating ? -safeAreaBottomInset : safeAreaBottomInset
    }}
    
    private let trackingModeFollowImage: UIImage? = {
        let image = "location.fill"
        let config = UIImage.SymbolConfiguration(scale: .medium)
        return UIImage(systemName: image, withConfiguration: config)
    }()
    
    private let trackingModeNofollowImage: UIImage? = {
        let image = "location"
        let config = UIImage.SymbolConfiguration(scale: .medium)
        return UIImage(systemName: image, withConfiguration: config)
    }()
    
    private var model: TripModel = []
    private var keyboardHeight: CGFloat = 210
    private var viewModel: OnTripVM?
    private var cancellables: [AnyCancellable]?
    private var timerUpdate: Timer?
    private var isRequestingEndTrip: Bool = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        // delegation (event handler)
        mapView.delegate                    = self
        locationManager.delegate            = self
        currentTransportationVC.delegate    = self
        costTransportationVC.delegate       = self
        chooseTransportationVC.delegate     = self
        changeTransportationVC.delegate     = self
        
        // presentation controller will disabled input from container vc
        chooseTransportationVC.transitioningDelegate    = self
        costTransportationVC.transitioningDelegate      = self
        changeTransportationVC.transitioningDelegate    = self
        
        // add observer to handle keyboard covering cost view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // this vc do a presentation fullscreen on summary vc
        // when summary vc dismiss all of the stack from view hierarchy
        // viewWillAppear(_ animated: Bool) will be called
        if (isRequestingEndTrip) { return }
        
        // present choose transportation for the first time (this won't work in viewDidLoad())
        present(chooseTransportationVC, animated: true) { [unowned self] in
            // set bottom constraint to adjust the center of the map after adding CurrentTransportation view from the bottom
            UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseIn) { [unowned self] in
                mapViewBottomConstraint.constant = 330
            }
            // current transporation view always exists on the bottom of the container view
            currentTransportationVC.view.frame = SheetPresentationController.getFrameOfPresentedViewInContainerView(
                currentTransportationVC.view,
                containerView: self.view,
                elevated: true
            )
            self.view.addSubview(currentTransportationVC.view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummaryViewController
        {
//            if StoredModel.history == nil
//            {
//                StoredModel.history = []
//                StoredModel.profile = ProfileModel(
//                    distanceInCar: 0,
//                    distanceInMotor: 0,
//                    distanceInBus: 0,
//                    distanceInTrain: 0,
//                    costInCar: 0,
//                    costInMotor: 0,
//                    costInBus: 0,
//                    costInTrain: 0,
//                    tripTrackCount: 0,
//                    carbonEmissionInKgTotal: 0,
//                    carbonEmissionInKgReducedTotal: 0
//                )
//            }
//
//            GlobalPublisher.shared.addTripModel(model)
//            // Save to User Default
//            StoredModel.history?.append(model)
//            model.forEach { StoredModel.profile?.add($0) }
            self.viewModel?.saveTripData(tripData: model)
            
            vc.viewModel = SummaryVM(model)
        }
    }
    
    @IBAction func onBackButton(_ sender: UIButton)
    {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @IBAction func onLocationButton(_ sender: UIButton)
    {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    @objc func onUpdate()
    {
        let image = mapView?.userTrackingMode == .follow ? trackingModeFollowImage : trackingModeNofollowImage
        locationButton.setImage(image, for: .normal)
        
        guard let viewModel = viewModel
        else { return }
        
        guard let userCurrentLocation = mapView.userLocation.location
        else { return }

        viewModel.currentLocation = userCurrentLocation
        
        guard let prevLocation = viewModel.previousLocation
        else { return }
        
        if !model.isEmpty
        {
            // Edit last model
            let currIndex = model.endIndex - 1
            model[currIndex].carbonEmissionInKg = viewModel.carbonEmissionInKg
            model[currIndex].endDate = Date()
            model[currIndex].distanceInKm = viewModel.distanceInKm
            
            // Adding endpoint
            let coordinate = userCurrentLocation.coordinate
            model[currIndex].transitPath.endLatitude = coordinate.latitude
            model[currIndex].transitPath.endLongitude = coordinate.longitude
        }
        
        // update cost vc, user location may still move while adding a cost confirmation
        costTransportationVC.viewModel?.totalCostInIDR = viewModel.totalCostInIDR
        
        let polyline = MKPolyline(coordinates: [prevLocation.coordinate, viewModel.currentLocation.coordinate], count: 2)
        mapView.addOverlay(polyline, level: .aboveRoads)
    }
    
    private func updateTransportation(_ manager: RadioButtonManager<TransportRadioButton>)
    {
        let currCoordinate = mapView.userLocation.coordinate
        let currentType = TransportType.allCases[manager.selectedIndex]
        
        let viewModel = OnTripVM(currentType, currentLocation: mapView.userLocation.location!)
        self.viewModel = viewModel
        
        cancellables = [
            viewModel.$distanceInKmText.sink(receiveValue: { [unowned self] in currentTransportationVC.distanceLabel.text = $0 }),
            viewModel.$totalCostInIDRText.sink(receiveValue: { [unowned self] in currentTransportationVC.approxCostLabel.text = $0 }),
            viewModel.$carbonEmissionInKgText.sink(receiveValue: { [unowned self] in currentTransportationVC.carbonEmissionLabel.text = $0 })
        ]
        
        let transitPath = TransitPath(
            startLatitude: currCoordinate.latitude,
            startLongitude: currCoordinate.longitude,
            endLatitude: 0,
            endLongitude: 0
        )
        
        let transitModel = TransitModel(
            transitPath: transitPath,
            carbonEmissionInKg: 0,
            costInIDR: 0,
            type: currentType,
            distanceInKm: 0,
            beginDate: Date(),
            endDate: Date()
        )
        
        let annotation = TransportAnnotation(coordinate: currCoordinate, subtitle: "...", type: currentType)
        model.append(transitModel)
        mapView.addAnnotation(annotation)
        
        let selectedRadioButton = manager.selected
        currentTransportationVC.imageView.image = selectedRadioButton?.image
        currentTransportationVC.nameLabel.text = selectedRadioButton?.title
        
        if (timerUpdate == nil)
        {
            timerUpdate = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)
        }
    }
    
    private func presentCostVC()
    {
        // update view model (to show recommendation cost)
        costTransportationVC.viewModel = TransportationCostVM(
            viewModel?.totalCostInIDR ?? 0,
            useApproximation: true
        )
        present(costTransportationVC, animated: true)
    }
}

extension OnTripViewController
{
    // this method can be called twice even though keyboard already showed up
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        isCostViewElevated = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        isCostViewElevated = false
    }
}

// MARK: MKMapViewDelegate
extension OnTripViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 4.0
            renderer.strokeColor = viewModel?.transportType.color
            return renderer
        }
        if overlay is MKTileOverlay
        {
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            return renderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: CLLocationManagerDelegate
extension OnTripViewController: CLLocationManagerDelegate
{
    
}

// MARK: CurrentTransportationViewControllerDelegate
extension OnTripViewController: CurrentTransportationViewControllerDelegate
{
    func onChangeTransportationButton(_ sender: UIButton)
    {
        presentCostVC()
    }
    
    func onEndTripButton(_ sender: UIButton)
    {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "Confirm arrival at final destination? This action cannot be undone",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "I'm Arrived", style: .default) { [unowned self] _ in
            isRequestingEndTrip = true
            presentCostVC()
        })
        present(alert, animated: true)
    }
}

// MARK: ChooseTransportationViewControllerDelegate
extension OnTripViewController: ChooseTransportationViewControllerDelegate
{
    func onConfirmChoose(_ selected: TransportRadioButton?)
    {
        updateTransportation(chooseTransportationVC.radioButton!)
    }
}

// MARK: ChangeTransportViewControllerDelegate
extension OnTripViewController: ChangeTransportViewControllerDelegate
{
    func onConfirmChange(_ selected: TransportRadioButton?)
    {
        // update current view model
        updateTransportation(changeTransportationVC.radioButton!)
    }
}

// MARK: TransportationCostViewControllerDelegate
extension OnTripViewController: TransportationCostViewControllerDelegate
{
    func onConfirmCost(_ cost: Double)
    {
        // update cost in the model
        model[model.endIndex - 1].costInIDR = cost
        // perform next view
        isRequestingEndTrip ?
            performSegue(withIdentifier: Segue.summary.rawValue, sender: self) :
            present(changeTransportationVC, animated: true)
    }
    
    func onCancelCost()
    {
        isRequestingEndTrip = false
    }
}

// MARK: TransitioningDelegate
extension OnTripViewController: UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        let pc = SheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        let insertion = elevationAdjustments.insert(presented)
        // only elevate when vc was previously not in the set
        pc.isNeedElevation = insertion.inserted
        return pc
    }
}
