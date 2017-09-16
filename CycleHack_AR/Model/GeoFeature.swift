//
//  GeoFeature.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import Foundation
import CoreLocation

enum GeoFeatureType: String {
    case feature = "Feature"
}

struct GeoFeature<T: Codable, P: Codable>: Codable {
    var type: String
    var properties: T
    var geometry: Geometry<P>
}

extension Array where Element == Double {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(self[1]), longitude: CLLocationDegrees(self[0]))
    }
    
    var location: CLLocation {
        return CLLocation(coordinate: coordinate, altitude: 40)
    }
    
}

extension Array where Element == [Double] {
    
    var coordinates: [CLLocationCoordinate2D] {
        return self.map{ $0.coordinate }
        
    }
    
    var locations: [CLLocation] {
        return self.map{ $0.location }
    }
    
}

extension GeoFeature where P == [Double] {
    
    var coordinate: CLLocationCoordinate2D {
        return self.geometry.coordinates.coordinate
    }
    
    var location: CLLocation {
        return self.geometry.coordinates.location
    }
}

extension GeoFeature where P == [[[Double]]] {

    var coordinate: [[CLLocationCoordinate2D]] {
        return self.geometry.coordinates.map{ $0.coordinates }
    }
    
    var location: [[CLLocation]] {
        return self.geometry.coordinates.map{ $0.locations }
    }
    
    var flattenedCoordinates: [CLLocationCoordinate2D] {
        return coordinate.reduce([CLLocationCoordinate2D](),+)
    }
    
}
