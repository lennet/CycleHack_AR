//
//  Geometry.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import Foundation

enum GeometryType: String {
    case point = "Point"
    case multiLineString = "MultiLineString"
}

struct Geometry: Codable {
    var type: GeometryType
    var coordinates: [Float]
}
