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
        let elevation: CGFloat = isCostViewElevated ? -210 : 210
        costTransportationVC.view.frame.origin.y += elevation
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
    
    private var transits: [TransitModel] = []
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
                containerView: self.view
            )
            self.view.addSubview(currentTransportationVC.view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummaryViewController
        {
            vc.viewModel = SummaryVM(transits)
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
        
        if transits.isEmpty == false
        {
            let currIndex = transits.endIndex - 1
            transits[currIndex].carbonEmissionInKg = viewModel.carbonEmissionInKg
            transits[currIndex].transitPath.endDate = Date()
            transits[currIndex].transitPath.distanceInKm = viewModel.distanceInKm
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
            type: currentType,
            coords: [currCoordinate],
            distanceInKm: 0,
            sampleRate: 1,
            beginDate: Date(),
            endDate: Date()
        )
        
        let transitModel = TransitModel(
            transitPath: transitPath,
            carbonEmissionInKg: 0,
            costInIDR: 0
        )
        
        let annotation = TransportAnnotation(coordinate: currCoordinate, subtitle: "...", type: currentType)
        transits.append(transitModel)
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
        transits[transits.endIndex - 1].costInIDR = cost
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
        return SheetPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}
