//
//  GeoFeatureTests.swift
//  CycleHack_ARTests
//
//  Created by Leo Thomas on 16.09.17.
//  Copyright © 2017 CycleHackBer. All rights reserved.
//

import XCTest
@testable import CycleHack_AR

class GeoFeatureTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEncodeStreetGeofeature() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testEncodePointGeofeature() {
        let jsonString = "{ \"type\": \"Feature\", \"properties\": { \"name\": \"ALT-REINICKENDORF / ROEDERNALLEE / VELTENER STR.\", \"year\": 2016, \"count\": 2, \"directorate\": \"11\" }, \"geometry\": { \"type\": \"Point\", \"coordinates\": [ 13.3477435, 52.5758387 ] } }"
        let data = jsonString.data(using: .utf8)!
        let feature = try! JSONDecoder().decode(GeoFeature<Point, [Float]>.self, from: data)
        XCTAssertEqual(feature.type, "Feature")

        let point = feature.properties
        XCTAssertEqual(point.name, "ALT-REINICKENDORF / ROEDERNALLEE / VELTENER STR.")
        XCTAssertEqual(point.year, 2016)
        XCTAssertEqual(point.count, 2)
        XCTAssertEqual(point.directorate, "11")
        
        let geometry = feature.geometry
        XCTAssertEqual(feature.type, "Feature")
        XCTAssertEqual(geometry.type, "Point")
        XCTAssertEqual(geometry.coordinates, [13.3477435, 52.5758387])
    }

}
