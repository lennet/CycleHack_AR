//
//  ViewController.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import UIKit
import ARCL
import MapKit
import SceneKit

extension MKCoordinateRegion {
    
    static var berlin: MKCoordinateRegion {
        return MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 52.520008, longitude: 13.404954), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    }
    
}

extension LocationAnnotationNode {
    
    convenience init(streetFeature: GeoFeature<Point, [Double]>) {
        let pinImage = UIImage(named: "pin")!
        self.init(location: streetFeature.location, image: pinImage)
    }
    
}

extension LocationNode {
    
    convenience init(streetFeature: GeoFeature<Point, [Double]>, radius: CGFloat){
        let sphere = SCNSphere(radius: radius)
        self.init(location: streetFeature.location)
        geometry = sphere
    }
    
}


class ViewController: UIViewController,
MKMapViewDelegate, SceneLocationViewDelegate, CLLocationManagerDelegate{
    
    
    let sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentNodes = Set<LocationNode>()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapBlurOverlay: UIVisualEffectView!
    @IBOutlet weak var panIndicatorView: PanIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSceneView()
        configureMapView()
        configureLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapContainerHeightConstraint.constant = view.frame.height/2
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneLocationView.pause()
    }
    
    func configureMapView() {
        mapView.showsUserLocation = true
        mapView.setRegion(.berlin, animated: false)
        mapView.layer.cornerRadius = 8
        mapView.layer.maskedCorners = CACornerMask.layerMinXMinYCorner.union(.layerMaxXMinYCorner)
    }
    
    func configureSceneView() {
        sceneLocationView.frame = view.frame
        sceneLocationView.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        view.insertSubview(sceneLocationView, at: 0)
    }
    
    func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // add pin to current position on touch
        if let _ = touches.first{
            let image = UIImage(named: "pinBlue")!
            let annotationNode = LocationAnnotationNode(location: nil, image: image)
            annotationNode.scaleRelativeToDistance = true
            sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
        }
    }
    
    func displayPointFeatures() {
        let pointFeatures = PointFeatureCollection()
        
        pointFeatures
            .features
            .filter(inDesiredArea)
            .forEach(display)
    }
    
    func inDesiredArea(streetFeature: GeoFeature<Point, [Double]>) -> Bool {
        return isInArea(distanceLimit: 500.0, coordinate: streetFeature.location)
    }

    
    public func isInArea(distanceLimit: Double, coordinate: CLLocation) -> Bool {
        guard let distance = userDistance(from: coordinate) else {
            return false
        }
        return distance <= distanceLimit
    }
    
    func display(streetFeature: GeoFeature<Point, [Double]>) {
        let locationNode = LocationNode(streetFeature: streetFeature, radius: 5.0)
        locationNode.continuallyUpdatePositionAndScale = true
        currentNodes.insert(locationNode)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
        
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = streetFeature.coordinate
        mapAnnotation.subtitle = "\(streetFeature.properties.name): \(streetFeature.properties.count)"
        mapView.addAnnotation(mapAnnotation)
    }
    
    // get distance from point to current location
    private func userDistance(from point: CLLocation) -> Double? {
        guard let userLocation = currentLocation else {
            print("Error - User location unknown!")
            return nil
        }
        return userLocation.distance(from: point)
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        currentNodes.removeAll()
        displayPointFeatures()
        
    }
    
    // MARK: MapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return nil
    }
    
    @objc func updateLocation() {
//        print("updateLocation called")
//        print("Current number of locationNodes:  \(self.sceneLocationView)")
    }

    
    // MARK: SceneLocatioNViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {

    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {

    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {

    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {

    }

    @IBAction func handleMapContainerPan(_ sender: UIPanGestureRecognizer) {
        guard let containerView = sender.view else { return }
        let translation = sender.translation(in: containerView)
        sender.setTranslation(.zero, in: containerView)
        
        let panIndicatorHeight = mapContainerHeightConstraint.constant - mapView.frame.height
        
        var newHeight = mapContainerHeightConstraint.constant - translation.y
        newHeight = max(newHeight, panIndicatorHeight)
        newHeight = min(newHeight, view.frame.height*0.8)
        
        switch sender.state {
        case .ended,
             .cancelled,
             .failed:
            mapBlurOverlay.isHidden = true
            panIndicatorView.touchesEnded([], with: nil)
        default:
            mapBlurOverlay.isHidden = false
            panIndicatorView.touchesBegan([], with: nil)
        }
        
        mapContainerHeightConstraint.constant = newHeight
    }
    
    
}

