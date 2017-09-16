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
import SceneKit.ModelIO
import ModelIO

enum CollisionCategory: Int {
    case ground
    case bicycle
}

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
    
    
    var distanceLimit: Double = 20
    let sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentNodes = Set<LocationNode>()
    var startingRegionSet = false

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapBlurOverlay: UIVisualEffectView!
    @IBOutlet weak var panIndicatorView: PanIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSceneView()
        configureMapView()
        configureLocationManager()
        displayPointFeaturesOnMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
        mapContainerHeightConstraint.constant = view.frame.height/2
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resignFirstResponder()
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
        sceneLocationView.locationViewDelegate = self
        view.insertSubview(sceneLocationView, at: 0)
    }
    
    func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 5
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        // add pin to current position on touch
//        if let _ = touches.first{
//            let image = UIImage(named: "pinBlue")!
//            let annotationNode = LocationAnnotationNode(location: nil, image: image)
//            annotationNode.scaleRelativeToDistance = true
//            sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
//        }
    }
    
    func displayPointFeatures() {
        let pointFeatures = PointFeatureCollection()
        
        pointFeatures
            .features
            .filter(inDesiredArea)
            .forEach(displayARNodes)
    }
    
    func displayStreetFeatures() {
        let streetFeatures = StreetFeatureCollection()
        
        streetFeatures
            .features
            .filter(inDesiredArea)
            .forEach(displayARNodes)
    }
    
    
    func displayPointFeaturesOnMap() {
        let pointFeatures = PointFeatureCollection()
        
        pointFeatures
            .features
            .filter(inDesiredArea)
            .forEach(displayMapNodes)
    }
    
    func inDesiredArea(pointFeature: GeoFeature<Point, [Double]>) -> Bool {
        return isInArea(distanceLimit: distanceLimit, coordinate: pointFeature.location)
    }
    
    func inDesiredArea(streetFeature: GeoFeature<Street,[[[Double]]]>)-> Bool {
        let coordinates = streetFeature.flattenedCoordinates
        return coordinates
            .filter{
                let location = CLLocation(coordinate: $0, altitude: 0)
                return isInArea(distanceLimit: distanceLimit, coordinate: location)
            }
            .count > 0
    }
    
    
    public func isInArea(distanceLimit: Double, coordinate: CLLocation) -> Bool {
        guard let distance = userDistance(from: coordinate) else {
            return false
        }
        return distance <= distanceLimit
    }
    
    func displayARNodes(pointFeature: GeoFeature<Point, [Double]>) {
        let locationNode = LocationNode(streetFeature: pointFeature, radius: 5.0)
        locationNode.continuallyUpdatePositionAndScale = true
        
        
        let graphNode = SCNNode.graphNode(with: [1,5,7,3,7,9], for: .red)
        locationNode.addChildNode(graphNode)
        
        currentNodes.insert(locationNode)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
    }
    
    func displayARNodes(streetFeature: GeoFeature<Street,[[[Double]]]>) {
        let coordinates = streetFeature.flattenedCoordinates
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        let polyNode = PolylineNode(polyline: polyline, altitude: 40)
        sceneLocationView.add(polyNode: polyNode)
    }
    
    func displayMapNodes(streetFeature: GeoFeature<Point, [Double]>) {
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
        currentNodes.forEach { (node) in
            sceneLocationView.removeLocationNode(locationNode: node)
        }
        currentNodes.removeAll()
        displayPointFeatures()

        currentLocation = locations.last!
        if !startingRegionSet {
            setStartingRegion()
        } else {
            currentLocation = locations.last
            currentNodes.removeAll()
            displayPointFeatures()
            displayStreetFeatures()
        }
    }
    
    private func setStartingRegion(){
        let latitude = currentLocation!.coordinate.latitude
        let longitude = currentLocation!.coordinate.longitude
        let latDegr: CLLocationDegrees = 0.005
        let lonDegr: CLLocationDegrees = 0.005
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDegr, lonDegr)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        startingRegionSet = true
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
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
//        guard motion == .motionShake else { return }
////        guard let position = sceneLocationView.currentScenePosition() else { return }
//        let insertionYOffset: Float = 0.5
//        let scene = SCNScene(named: "bicycle.scn")
//        if let node = scene?.rootNode.childNodes.first {
//            
//
//
//        for i in 0...100 {
//            node.position = SCNVector3Make(
//                position.x - 50 + Float(i),
//                position.y + insertionYOffset + Float(i),
//                position.z - 100 + Float(i)
//            )
////            let when = DispatchTime.now() + 0.1
////                DispatchQueue.main.asyncAfter(deadline: when) {
////                    self.sceneLocationView.add(node: node)
////                }
//            }
//
//        }
        
    }
    
}

