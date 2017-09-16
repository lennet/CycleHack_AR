//
//  GeoFeature.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import Foundation

enum GeoFeatureType: String {
    case feature = "Feature"
}

struct GeoFeature<T: Codable>: Codable {
    var type: String
    var properties: T
    var geometry: Geometry
}
