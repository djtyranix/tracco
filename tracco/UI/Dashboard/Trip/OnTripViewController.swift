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

func layoutBottomSheet(_ view: UIView)
{
    view.backgroundColor        = .systemBackground
    view.layer.cornerRadius     = 25
    view.layer.maskedCorners    = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
}

class OnTripViewController: UIViewController
{
    enum Segue: String { case summarizing = "summarizingSegue" }
    
    public static var instanceOnPause: OnTripViewController?
    
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
    
    public let connectionLost = AppAlertController(
        title: "Connection Lost",
        message: "Don’t worry, we will continue tracking as soon as you are back online.",
        image: UIImage(named: "Connection")
    )
    
    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
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
    
    private var pendingLocations: [CLLocationCoordinate2D] = []
    
    private var keyboardHeight: CGFloat = 210
    private var isRequestingEndTrip: Bool = false
    private var isTripInitiated = false
    private var isRequestingLocationLostAlert = false
    private var isInForeground = true
    
    private var model: TripModel?
    private var viewModel: OnTripVM?
    private var cancellables: [AnyCancellable]?
    private var timerUpdate: Timer?
    private var timerLocationAvailability: Timer?
    private var currAnnotation: TransportAnnotation?
    
    
    // this should not be empty while choosing / switching transport
    private var updateTransportLocation: CLLocation!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationButtonYConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // user can bypass the notification request in the onboarding by clicking not now.
        // make sure to ask permission request once so the user can tweak notification in
        // the settings later. if never asked, there will be no notif settings
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.sound, .alert, .badge],
            completionHandler: { _,_ in }
        )
        
        GlobalPublisher.addObserver(self)
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
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
        
        // start updating location after choose transport
        // this will trigger CLLocationManagerDelegate in bg and fg
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // start the timer
        timerLocationAvailability = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(taskLocationAvailability),
            userInfo: nil,
            repeats: true
        )
        timerUpdate = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(taskDrawAndModelUpdate),
            userInfo: nil, repeats: true
        )
        
        // trip will ended when user trigger cancel my trip action
        connectionLost.addAction(AppAlertAction(
            title: "Cancel My Trip Instead",
            style: .destructive
        ) { _ in
            GlobalPublisher.shared.onTripEnded()
            self.view.window?.rootViewController?.dismiss(animated: true)
        })
        
        // add observer to handle keyboard covering cost view
        let keyboardListeningStates = [
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillShowNotification
        ]
        keyboardListeningStates.forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardStateChanged(_:)),
                name: $0,
                object: nil
            )
        }
        
        // add observer to handle app background & foreground state
        let applicationListeningStates = [
            UIApplication.didBecomeActiveNotification,
            UIApplication.willResignActiveNotification
        ]
        applicationListeningStates.forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationStateChanged(_:)),
                name: $0,
                object: nil
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        OnTripViewController.instanceOnPause = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? SummarizingViewController
        {
            // stop updating location
            locationManager.stopUpdatingLocation()
            timerUpdate?.invalidate()
            timerLocationAvailability?.invalidate()
            
            GlobalPublisher.shared.onTripEnded()
            
            vc.modelToSummarize = self.model
            self.model = nil
            
            // TODO: wait for all pendingLocations to be processed
            // right now we force update by timerUpdate.invalidate()
            // maybe we could wait using summarizing trip view
        }
    }
    
    @IBAction func onBackButton(_ sender: UIButton)
    {
        OnTripViewController.instanceOnPause = self
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    @IBAction func onLocationButton(_ sender: UIButton)
    {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func updateTransportation(_ manager: RadioButtonManager<TransportRadioButton>)
    {
        let nowDate     = Date()
        let currentType = TransportType.allCases[manager.selectedIndex]
        let location    = updateTransportLocation!
        
        // update model
        
        let transitPath = TransitPath(
            startLatitude: location.coordinate.latitude,
            startLongitude: location.coordinate.longitude,
            endLatitude: location.coordinate.latitude,
            endLongitude: location.coordinate.longitude
        )
        
        let transitModel = TransitModel(
            transitPath: transitPath,
            carbonEmissionInKg: 0,
            costInIDR: 0,
            type: currentType,
            distanceInKm: 0,
            beginDate: nowDate,
            endDate: nowDate
        )
        
        let isFirstTransit = model == nil || model!.transits.isEmpty
        if isFirstTransit { model = TripModel(id: -1, transits: [transitModel]) }
        else { model!.transits.append(transitModel) }
        
        // update view model
        
        let viewModel = OnTripVM(currentType, currentLocation: location)
        viewModel.processor.delegate = self
        self.viewModel = viewModel
        
        // update annotation in the map
        
        if let model = model,
           let prevAnnotation = currAnnotation
        {
            let transitModel = model[prevAnnotation.indexInModel]
            updateAnnotation(prevAnnotation, model: transitModel)
        }
        
        // create map annotation
        
        let annotation = TransportAnnotation.initOngoing(
            coordinate: location.coordinate,
            indexInModel: model!.transits.count - 1,
            type: currentType,
            beginDate: nowDate
        )
        mapView.addAnnotation(annotation)
        currAnnotation = annotation
        
        // update current transport view in this subview
        
        let selectedRadioButton = manager.selected
        currentTransportationVC.imageView.image = selectedRadioButton?.image
        currentTransportationVC.nameLabel.text = selectedRadioButton?.title
        
        // inform a new transit model has been added
        
        GlobalPublisher.shared.onTripTransitModelUpdated(transitModel)
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

// MARK: Global Event
extension OnTripViewController: GlobalEvent
{
    // the reason that we update the view in this method event
    // instead from the internal implementation it gives the benefit of
    // clear instruction and remove code redundancy.
    // see all calls from GlobalPublisher.shared.onTripTransitModelUpdated()
    func onTripTransitModelUpdated(_ model: TransitModel)
    {
        guard let viewModel = viewModel
        else { return }
        // update the view
        let vc = currentTransportationVC
        vc.distanceLabel.text = viewModel.distanceInKmText
        vc.approxCostLabel.text = viewModel.totalCostInIDRText
        vc.carbonEmissionLabel.text = viewModel.carbonEmissionInKgText
    }
}

// MARK: Notification Center Observer
extension OnTripViewController
{
    @objc func applicationStateChanged(_ notification: Notification)
    {
        if notification.name == UIApplication.didBecomeActiveNotification
        {
            isInForeground = true
        }
        else if notification.name == UIApplication.willResignActiveNotification
        {
            isInForeground = false
        }
    }
    
    @objc func keyboardStateChanged(_ notification: Notification)
    {
        if notification.name == UIApplication.keyboardWillShowNotification
        {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
            isCostViewElevated = true
        }
        else if notification.name == UIApplication.keyboardWillHideNotification
        {
            isCostViewElevated = false
        }
    }
}

// MARK: Timer Task (Background & Foreground Process)
extension OnTripViewController
{
    // this method job was to present the alert indicating location lost
    // CLLocationManagerDelegate didUpdateLocations is responsible for
    // dismissing the alert in order to provide better response time
    @objc func taskLocationAvailability()
    {
        // this is easier than invalidate the timer and re-schedule it
        guard isInForeground else { return }
        
        // only present the alert while no user input is in progress because of:
        // [1] ViewController can only present once at a time and [2] provide better ux
        if self.presentedViewController == nil && isRequestingLocationLostAlert
        {
            self.present(connectionLost, animated: true)
        }
    }
    
    @objc func taskDrawAndModelUpdate()
    {
        // this is easier than invalidate the timer and re-schedule it
        guard isInForeground else { return }
        
        let image = mapView?.userTrackingMode == .follow ? trackingModeFollowImage : trackingModeNofollowImage
        locationButton.setImage(image, for: .normal)
        
        // model only gets updated when there's no modal presentation
        // it means that there's no pending user input for affirmation
        guard let viewModel = viewModel, self.presentedViewController == nil
        else { return }
        
        let coords = pendingLocations
        pendingLocations = []
        coords.forEach
        {
            let location = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            viewModel.processor.update(location)
        }
    }
}

// MARK: ULProcessorDelegate
extension OnTripViewController: ULProcessorDelegate
{
    func location(_ processor: ULProcessor, didRefactor index: Int)
    {
        viewModel?.location(processor, didRefactor: index)
    }
    
    func location(_ processor: ULProcessor, didAdd location: CLLocation)
    {
        viewModel?.location(processor, didAdd: location)
        
        guard let viewModel = viewModel
        else { return }
        
        // update the model
        let currIndex = model!.transits.endIndex - 1
        model![currIndex].carbonEmissionInKg = viewModel.carbonEmissionInKg
        model![currIndex].endDate = Date()
        model![currIndex].distanceInKm = viewModel.distanceInKm
        model![currIndex].transitPath.endLatitude = location.coordinate.latitude
        model![currIndex].transitPath.endLongitude = location.coordinate.longitude
        
        // connecting the last stroke with current stroke
        if let prevLocation = viewModel.prevValidLocation
        {
            let currLocation = viewModel.currValidLocation
            let coords = [prevLocation.coordinate, currLocation.coordinate]
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            mapView.addOverlay(polyline, level: .aboveRoads)
        }
        
        // inform transit model updated
        GlobalPublisher.shared.onTripTransitModelUpdated(model![currIndex])
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        // map view will use default annotation view if returns nil (ex: user location as blue indicator)
        guard let annotation = annotation as? TransportAnnotation
        else { return nil }
        
        let identifier = "\(annotation.type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil
        {
            annotationView = TransportAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else
        {
            annotationView?.annotation = annotation
        }
        
        (annotationView as? TransportAnnotationView)?.configureCalloutView()
        return annotationView
    }
    
    func updateAnnotation(_ annotation: TransportAnnotation, model: TransitModel)
    {
        let updatedAnnotation = TransportAnnotation.initDone(
            coordinate: annotation.coordinate,
            indexInModel: annotation.indexInModel,
            type: model.type,
            beginDate: model.beginDate,
            endDate: model.endDate,
            carbonEmissionInKg: model.carbonEmissionInKg,
            distanceInKm: model.distanceInKm,
            costInIDR: model.costInIDR
        )

        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(updatedAnnotation)
    }
}

// MARK: CLLocationManagerDelegate
extension OnTripViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        isRequestingLocationLostAlert = false
        
        // to provide better response time, this delegate is responsible to dismiss
        // the alert only if necessary
        if isInForeground && self.presentedViewController === connectionLost
        {
            connectionLost.dismiss(animated: true)
        }
        
        if let first = locations.first, isTripInitiated == false
        {
            isTripInitiated = true
            updateTransportLocation = first
            // choose transport and layout subviews for the first time
            self.present(chooseTransportationVC, animated: true)
        }
        
        let coords = locations.map({ $0.coordinate })
        pendingLocations.append(contentsOf: coords)
        GlobalPublisher.shared.onTripLocationUpdate(locations)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
        guard   manager.authorizationStatus == .denied ||
                manager.authorizationStatus == .notDetermined,
                let rootViewController = self.view.window?.rootViewController
        else { return }
        
        // alert
        let alert = AppAlertController(
            title: "Tracking Stopped",
            message: "We were unable to locate you due to changes in location access permission.",
            image: UIImage(named: "Lost")
        )
        alert.addAction(AppAlertAction(title: "I Understand", style: .default) { _ in
            alert.dismiss(animated: true)
        })
        
        // forcefully cancel ongoing trip
        GlobalPublisher.shared.onTripEnded()
        rootViewController.dismiss(animated: true)
        rootViewController.present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        // we should not try to present the alert immediately because of
        // [1] user input may stil be in progress. The job of presenting the alert
        // is handled by timerLocationAvailability.
        isRequestingLocationLostAlert = true
        GlobalPublisher.shared.onTripLocationLost(manager)
    }
}

// MARK: CurrentTransportationViewControllerDelegate
extension OnTripViewController: CurrentTransportationViewControllerDelegate
{
    func onChangeTransportationButton(_ sender: UIButton)
    {
        guard let location = viewModel?.currValidLocation
        else { return }
        
        updateTransportLocation = location
        presentCostVC()
    }
    
    func onEndTripButton(_ sender: UIButton)
    {
        guard let location = viewModel?.currValidLocation
        else { return }
        
        updateTransportLocation = location
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
    func onCancelChoose()
    {
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    func onConfirmChoose(_ selected: TransportRadioButton?)
    {
        // set bottom constraint to adjust the center of the map after adding CurrentTransportation view from the bottom
        UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseIn) { [unowned self] in
            mapViewBottomConstraint.constant = 340
        }
        // current transporation view always exists on the bottom of the container view
        currentTransportationVC.view.frame = SheetPresentationController.getFrameOfPresentedViewInContainerView(
            currentTransportationVC.view,
            containerView: self.view,
            elevated: true
        )
        self.view.addSubview(currentTransportationVC.view)
        // follow user location button must be on top of currentTransportationVC
        let yFromBottom = currentTransportationVC.view.frame.height + 16
        locationButtonYConstraint.constant = yFromBottom
        // notify trip started
        updateTransportation(chooseTransportationVC.radioButton!)
        GlobalPublisher.shared.onTripStarted()
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
        model![model!.transits.endIndex - 1].costInIDR = cost
        // perform next view
        isRequestingEndTrip ?
            performSegue(withIdentifier: Segue.summarizing.rawValue, sender: self) :
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
