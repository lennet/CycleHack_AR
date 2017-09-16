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

extension GeoFeature where P == [Float] {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(geometry.coordinates[0]), longitude: CLLocationDegrees(geometry.coordinates[1]))
    }
    
    var location: CLLocation {
        return CLLocation(coordinate: coordinate, altitude: 1)
    }
}
