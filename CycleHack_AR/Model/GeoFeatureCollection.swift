//
//  GeoFeatureCollection.swift
//  CycleHack_AR
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import Foundation

struct StreetFeatureCollection: Codable {
    var type: String
    var features: [GeoFeature<Street, [[[Double]]]>]
}

extension StreetFeatureCollection {
    
    init() {
        let path = Bundle.main.path(forResource: "streets", ofType: "geojson")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        self = try! JSONDecoder().decode(StreetFeatureCollection.self, from: data)
    }
    
}

struct PointFeatureCollection: Codable {
    var type: String
    var features: [GeoFeature<Point, [Double]>]
}

extension PointFeatureCollection {
    
    init() {
        let path = Bundle.main.path(forResource: "points", ofType: "geojson")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        self = try! JSONDecoder().decode(PointFeatureCollection.self, from: data)
    }
    
}

struct GeoFeatureCollection<T: Codable, P: Codable>: Codable {
    var type: String
    var features: [GeoFeature<T, P>]
}
