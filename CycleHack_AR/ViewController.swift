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
        self.init(location: streetFeature.location)
    }
    
}


class ViewController: UIViewController,
MKMapViewDelegate, SceneLocationViewDelegate, CLLocationManagerDelegate{
    
    
    var distanceLimit: Double = 200
    let sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentNodes = Set<LocationNode>()
    let yearData = DataOverYearModel.getAll()
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
        sceneLocationView.showAxesNode = false
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
        
        let text = SCNText(string: """
\(pointFeature.properties.name
            .components(separatedBy: " / ")
            .joined(separator: "\n"))
\(pointFeature.properties.count) \(pointFeature.properties.count > 1 ? "Unfälle" : "Unfall")
""", extrusionDepth: 5)
        let textNode = SCNNode(geometry: text)
        textNode.position.y += 1
        locationNode.addChildNode(textNode)
        
        defer {
            locationNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
            currentNodes.insert(locationNode)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationNode)
        }
        
        //locationNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        let constraint = SCNLookAtConstraint(target: sceneLocationView.pointOfView)
        constraint.isGimbalLockEnabled = true
        locationNode.constraints = [constraint]
        
        // 🙈🚨 TODO: create new data instead of filtering every time
        guard let yearData = yearData.filter({
            return $0.street == pointFeature.properties.name && "\($0.directorate)" == pointFeature.properties.directorate &&  $0.y2016 == pointFeature.properties.count
        }).first else {
           return
        }
        
        
        let yearCounts: [Float] = [yearData.y2008,yearData.y2009,yearData.y2010,yearData.y2011,yearData.y2012,yearData.y2013, yearData.y2014, yearData.y2015, yearData.y2016].map{Float($0)}
        let graphNode = SCNNode.graphNode(with: yearCounts, for: [#colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1),#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1),#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1),#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1),#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1),#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1),#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)])
        graphNode.position.y -= 1
        graphNode.position.x -= graphNode.boundingBox.max.x * 1.5
        
        let minText = SCNText(string: "2008", extrusionDepth: 3)
        let minTextNode = SCNNode(geometry: minText)
        minTextNode.position.y -= minTextNode.boundingBox.max.y
        minTextNode.position.x -= minTextNode.boundingBox.max.x/2
        graphNode.addChildNode(minTextNode)
        
        let maxText = SCNText(string: "2016", extrusionDepth: 3)
        let maxTextNode = SCNNode(geometry: maxText)
        maxTextNode.position.y -= maxTextNode.boundingBox.max.y
        maxTextNode.position.x += graphNode.boundingBox.max.x - (maxTextNode.boundingBox.max.x/2)
        graphNode.addChildNode(maxTextNode)
        
        let maxValueText = SCNText(string: "\(yearCounts.max() ?? 0)", extrusionDepth: 3)
        let maxValueNode = SCNNode(geometry: maxValueText)
        maxValueNode.position.y = graphNode.boundingBox.max.y - (maxValueNode.boundingBox.max.y / 2)
        maxValueNode.position.x -= maxValueNode.boundingBox.max.x
        graphNode.addChildNode(maxValueNode)
        
        locationNode.addChildNode(graphNode)
    }
    
    func displayARNodes(streetFeature: GeoFeature<Street,[[[Double]]]>) {
        streetFeature.coordinate.forEach { (coordinates) in
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            let polyNode = PolylineNode(polyline: polyline, altitude: 40)
            self.sceneLocationView.add(polyNode: polyNode)
        }
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
//        guard let position = sceneLocationView.currentScenePosition() else { return }
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
//            let when = DispatchTime.now() + 0.1
//                DispatchQueue.main.asyncAfter(deadline: when) {
//                    self.sceneLocationView.add(node: node)
//                }
//            }
//
//        }
        
    }
    
}

