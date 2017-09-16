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


class ViewController: UIViewController,
MKMapViewDelegate, SceneLocationViewDelegate, CLLocationManagerDelegate{
    
    
    let sceneLocationView = SceneLocationView()
    var numberOfPointsOfInterest = 0
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapBlurOverlay: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        // example node with coordinates for a street near Alexanderplatz
        let pinCoordinate = CLLocationCoordinate2D(latitude: 52.528700, longitude: 13.416931)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 45)
        let pinImage = UIImage(named: "pin")!
        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
        pinLocationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        
        mapView.delegate = self
        mapView.alpha = 0.75
        mapView.showsUserLocation = true
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        mapView.showsUserLocation = true
        mapView.setRegion(.berlin, animated: false)

        view.addSubview(mapView)
        view.insertSubview(sceneLocationView, at: 0)
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapView.frame = CGRect(x: 0,
                               y: self.view.frame.size.height/2,
                               width: self.view.frame.size.width,
                               height: self.view.frame.size.height/2)
        sceneLocationView.frame = CGRect(x: 0,
                                         y: 0,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // add pin to current position on touch
        if let _ = touches.first{
            let image = UIImage(named: "pin")!
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
        numberOfPointsOfInterest += 1
        let locationAnnotationNode = LocationAnnotationNode(streetFeature: streetFeature)
        locationAnnotationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotationNode)
        
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
        
        let panIndicatorHeight = containerView.frame.height - mapContainerHeightConstraint.constant
        
        var newHeight = mapContainerHeightConstraint.constant - translation.y
        newHeight = max(newHeight, panIndicatorHeight)
        newHeight = min(newHeight, view.frame.height/0.8)
        
        switch sender.state {
        case .ended,
             .cancelled,
             .failed:
            mapBlurOverlay.isHidden = true
        default:
            mapBlurOverlay.isHidden = false
        }
        
        mapContainerHeightConstraint.constant = newHeight
    }
    
    
}

